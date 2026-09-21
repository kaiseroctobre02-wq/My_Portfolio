import 'dart:async';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Categorized health of the connection after a diagnostic batch.
enum ConnectionTier {
  excellent,
  fair,
  poor,
  degraded;

  /// Human-friendly tier name shown across the UI.
  String get label {
    switch (this) {
      case ConnectionTier.excellent:
        return 'Excellent';
      case ConnectionTier.fair:
        return 'Fair';
      case ConnectionTier.poor:
        return 'Poor';
      case ConnectionTier.degraded:
        return 'Degraded';
    }
  }

  /// One-line description of what the tier means.
  String get description {
    switch (this) {
      case ConnectionTier.excellent:
        return '> 10 Mbps - excellent connection health.';
      case ConnectionTier.fair:
        return '2 - 10 Mbps - fair connection health.';
      case ConnectionTier.poor:
        return '< 2 Mbps - slow connection.';
      case ConnectionTier.degraded:
        return 'Heavy packet loss or extreme latency.';
    }
  }
}

/// Result of one bandwidth measurement plus the ping that was sampled
/// concurrently while the transfer was running.
class _TransferResult {
  final double? mbps;
  final double? pingMs;

  const _TransferResult({this.mbps, this.pingMs});
}

/// Background diagnostic tool that regularly tests the network.
///
/// Every run performs a multi-step sequence:
///  1. Baseline "idle ping" is measured first.
///  2. "Download bandwidth" is measured while pings are sampled
///     concurrently during the transfer.
///  3. "Upload bandwidth" is measured while the upload ping is tracked
///     simultaneously.
///
/// The results are then categorized into operational tiers:
///  - Excellent: > 10 Mbps
///  - Fair:      2 - 10 Mbps
///  - Poor:      < 2 Mbps
///  - Degraded:  heavy packet loss or extreme latency
///
/// Everything is wrapped in try/catch so an offline device (or a test
/// environment without the platform plugins) simply reports Degraded
/// instead of crashing.
class NetworkDiagnosticsProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  Timer? _timer;

  static const List<String> _downloadUrls = [
    'https://speed.cloudflare.com/__down?bytes=2000000',
    'https://proof.ovh.net/files/1Mb.dat',
  ];
  static const List<String> _uploadUrls = [
    'https://speed.cloudflare.com/__up',
  ];
  static const List<String> _pingUrls = [
    'https://connectivitycheck.gstatic.com/generate_204',
    'https://cp.cloudflare.com/generate_204',
    'https://www.gstatic.com/generate_204',
  ];

  ConnectionTier _tier = ConnectionTier.degraded;
  bool _isRunning = false;
  DateTime? _lastUpdated;
  String? _note;

  double? _idlePingMs;
  double? _downloadMbps;
  double? _downloadPingMs;
  double? _uploadMbps;
  double? _uploadPingMs;

  ConnectionTier get tier => _tier;
  String get tierLabel => _tier.label;
  String get tierDescription => _tier.description;
  bool get isRunning => _isRunning;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasRun => _lastUpdated != null;

  /// Short note explaining the last result (e.g. offline message).
  String? get note => _note;

  double? get idlePingMs => _idlePingMs;
  double? get downloadMbps => _downloadMbps;
  double? get downloadPingMs => _downloadPingMs;
  double? get uploadMbps => _uploadMbps;
  double? get uploadPingMs => _uploadPingMs;

  IconData get tierIcon {
    switch (_tier) {
      case ConnectionTier.excellent:
        return Icons.speed;
      case ConnectionTier.fair:
        return Icons.signal_wifi_4_bar;
      case ConnectionTier.poor:
        return Icons.network_wifi_1_bar;
      case ConnectionTier.degraded:
        return Icons.wifi_off;
    }
  }

  Color get tierColor {
    switch (_tier) {
      case ConnectionTier.excellent:
        return Colors.green;
      case ConnectionTier.fair:
        return Colors.amber.shade700;
      case ConnectionTier.poor:
        return Colors.orange;
      case ConnectionTier.degraded:
        return Colors.red;
    }
  }

  /// Starts the recurring background diagnostics. Also runs one full
  /// batch immediately so the state is fresh right away.
  void startDiagnostics({Duration interval = const Duration(seconds: 30)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => runDiagnostics());
    runDiagnostics();
  }

  /// Runs the full 3-step diagnostic sequence.
  Future<void> runDiagnostics() async {
    _isRunning = true;
    _note = null;
    notifyListeners();

    try {
      if (!await _hasNetwork()) {
        // No active connection (or plugin unavailable): report Degraded
        // without performing any real network I/O.
        _applyBatch(
          tier: ConnectionTier.degraded,
          note: 'No active network connection.',
        );
        return;
      }

      // Step 1: baseline idle ping.
      final idlePingMs = await _measureIdlePing();

      // Step 2: download bandwidth with concurrent ping sampling.
      final download = await _measureDownload();

      // Step 3: upload bandwidth with concurrent upload ping tracking.
      final upload = await _measureUpload();

      _idlePingMs = idlePingMs;
      _downloadMbps = download.mbps;
      _downloadPingMs = download.pingMs;
      _uploadMbps = upload.mbps;
      _uploadPingMs = upload.pingMs;
      _tier = _categorize();
      _note = null;
    } catch (error) {
      _applyBatch(
        tier: ConnectionTier.degraded,
        note: 'Diagnostic failed: $error',
      );
    } finally {
      _isRunning = false;
      _lastUpdated = DateTime.now();
      notifyListeners();
    }
  }

  /// Applies a fully degraded result (used when offline or on failure).
  void _applyBatch({required ConnectionTier tier, String? note}) {
    _idlePingMs = null;
    _downloadMbps = null;
    _downloadPingMs = null;
    _uploadMbps = null;
    _uploadPingMs = null;
    _tier = tier;
    _note = note;
  }

  /// Groups the measurements into the operational tiers listed above.
  ConnectionTier _categorize() {
    final extremeLatency = (_idlePingMs ?? 0) > 500 ||
        (_downloadPingMs ?? 0) > 500 ||
        (_uploadPingMs ?? 0) > 500;
    if (extremeLatency) return ConnectionTier.degraded;

    // Bandwidth tier is based on download, falling back to upload.
    final speed = _downloadMbps ?? _uploadMbps;
    if (speed == null) return ConnectionTier.degraded;
    if (speed > 10) return ConnectionTier.excellent;
    if (speed >= 2) return ConnectionTier.fair;
    return ConnectionTier.poor;
  }

  /// Guides the transfer and ping measurement helpers; returns true
  /// only when a usable connection (Wi-Fi / Cellular / Ethernet / VPN)
  /// is reported by the platform.
  Future<bool> _hasNetwork() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty && !results.contains(ConnectivityResult.none);
    } catch (_) {
      // Plugin unavailable (e.g. widget tests): treat as no network.
      return false;
    }
  }

  /// Step 1: averages several baseline pings before any transfer.
  Future<double?> _measureIdlePing({int samples = 3}) async {
    final pings = <double>[];
    for (var i = 0; i < samples; i++) {
      final ping = await _pingOnce();
      if (ping != null) pings.add(ping);
    }
    if (pings.isEmpty) return null;
    return pings.reduce((a, b) => a + b) / pings.length;
  }

  /// Step 2: measures download bandwidth while sampling ping at the
  /// same time. The concurrent pings finish when the transfer does.
  Future<_TransferResult> _measureDownload() async {
    final stopwatch = Stopwatch()..start();
    final downloadDone = _fetchDownloadBytes();
    final pingFuture = _samplePingsUntil(downloadDone.then((_) {}));
    final bytes = await downloadDone;
    final pingMs = await pingFuture;
    stopwatch.stop();
    final mbps = _bytesToMbps(bytes, stopwatch.elapsedMilliseconds);
    return _TransferResult(mbps: mbps, pingMs: pingMs);
  }

  /// Step 3: measures upload bandwidth while tracking the upload ping
  /// simultaneously.
  Future<_TransferResult> _measureUpload() async {
    final payload = Uint8List(512 * 1024); // 512 KB test payload.
    final stopwatch = Stopwatch()..start();
    final uploadDone = _fetchUploadBytes(payload);
    final pingFuture = _samplePingsUntil(uploadDone.then((_) {}));
    final sentBytes = await uploadDone;
    final pingMs = await pingFuture;
    stopwatch.stop();
    final mbps = _bytesToMbps(sentBytes, stopwatch.elapsedMilliseconds);
    return _TransferResult(mbps: mbps, pingMs: pingMs);
  }

  /// Downloads a known file from the first responsive endpoint and
  /// returns how many bytes were transferred (null if all failed).
  Future<int?> _fetchDownloadBytes() async {
    for (final url in _downloadUrls) {
      try {
        final response =
            await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));
        if (response.statusCode == 200) return response.bodyBytes.length;
      } catch (_) {
        // Try the next endpoint.
      }
    }
    return null;
  }

  /// Uploads a fixed payload to a test endpoint and returns the number
  /// of bytes transferred (null if the upload failed).
  Future<int?> _fetchUploadBytes(Uint8List payload) async {
    for (final url in _uploadUrls) {
      try {
        final response = await http
            .post(Uri.parse(url), body: payload)
            .timeout(const Duration(seconds: 12));
        if (response.statusCode == 200) return payload.length;
      } catch (_) {
        // Try the next endpoint.
      }
    }
    return null;
  }

  /// Samples pings while the given operation runs; finishes as soon as
  /// the operation completes or the sample cap is reached.
  Future<double?> _samplePingsUntil(
    Future<void> stopSignal, {
    int maxSamples = 6,
  }) async {
    final samples = <double>[];
    for (var i = 0; i < maxSamples; i++) {
      final stopped = await Future.any([
        stopSignal.then((_) => true),
        _pingOnce().then((ping) {
          if (ping != null) samples.add(ping);
          return false;
        }),
      ]);
      if (stopped) break;
    }
    if (samples.isEmpty) return null;
    return samples.reduce((a, b) => a + b) / samples.length;
  }

  /// Single round-trip latency to a well-known endpoint. Returns null
  /// when the request fails or times out (treated as a lost packet).
  Future<double?> _pingOnce({Duration timeout = const Duration(seconds: 4)}) async {
    for (final url in _pingUrls) {
      try {
        final stopwatch = Stopwatch()..start();
        await http.get(Uri.parse(url)).timeout(timeout);
        stopwatch.stop();
        return stopwatch.elapsedMilliseconds.toDouble();
      } catch (_) {
        // Endpoint unreachable or blocked, try the next one.
      }
    }
    return null;
  }

  /// Converts transferred bytes over the elapsed time into Mbps.
  double? _bytesToMbps(int? bytes, int elapsedMilliseconds) {
    if (bytes == null || elapsedMilliseconds <= 0) return null;
    final seconds = elapsedMilliseconds / 1000;
    return (bytes * 8) / seconds / 1000000;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}