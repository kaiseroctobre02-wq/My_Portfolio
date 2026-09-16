import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// Thrown when the simulated network request cannot complete.
class NetworkRequestException implements Exception {
  final String message;

  const NetworkRequestException(this.message);

  @override
  String toString() => message;
}

/// Monitors the real-time network state and manages a request queue.
///
/// - Listens to the `connectivity_plus` stream for live updates.
/// - Simulates long-running network requests.
/// - If the connection drops mid-request, the request is QUEUED instead
///   of crashing (the error is caught).
/// - When a stable connection returns, queued requests are retried
///   automatically (graceful recovery).
class NetworkMonitorProvider extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  List<ConnectivityResult> _results = [];
  final List<String> _queuedRequests = [];
  final List<String> _completedRequests = [];

  bool _inFlight = false;
  String? _inFlightLabel;
  bool _inFlightQueued = false;
  bool _recovering = false;
  int _requestNumber = 0;

  List<String> get queuedRequests => List.unmodifiable(_queuedRequests);
  List<String> get completedRequests => List.unmodifiable(_completedRequests);
  bool get inFlight => _inFlight;
  String? get inFlightLabel => _inFlightLabel;
  bool get recovering => _recovering;
  int get queuedCount => _queuedRequests.length;
  int get completedCount => _completedRequests.length;

  /// Online when we have at least one result that is not "none".
  bool get isOnline =>
      _results.isNotEmpty && !_results.contains(ConnectivityResult.none);

  String get networkLabel {
    if (_results.isEmpty || _results.contains(ConnectivityResult.none)) {
      return 'Offline';
    }
    if (_results.contains(ConnectivityResult.wifi)) return 'Wi-Fi';
    if (_results.contains(ConnectivityResult.mobile)) return 'Cellular';
    if (_results.contains(ConnectivityResult.ethernet)) return 'Ethernet';
    if (_results.contains(ConnectivityResult.vpn)) return 'VPN';
    return 'Other';
  }

  IconData get networkIcon {
    if (_results.isEmpty || _results.contains(ConnectivityResult.none)) {
      return Icons.wifi_off;
    }
    if (_results.contains(ConnectivityResult.wifi)) return Icons.wifi;
    if (_results.contains(ConnectivityResult.mobile)) {
      return Icons.signal_cellular_alt;
    }
    if (_results.contains(ConnectivityResult.ethernet)) return Icons.lan;
    if (_results.contains(ConnectivityResult.vpn)) return Icons.vpn_lock;
    return Icons.settings_ethernet;
  }

  /// Subscribes to the live connectivity stream and fetches the
  /// current state. Safe to call even where the platform plugin is
  /// unavailable (the app keeps running in an offline state).
  void startMonitoring() {
    try {
      _subscription = _connectivity.onConnectivityChanged.listen(
        _handleStreamResult,
        onError: (Object error) {
          // Stream errors are ignored; the app stays usable.
        },
      );
    } catch (_) {
      // Plugin unavailable - ignore.
    }
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final initial = await _connectivity.checkConnectivity();
      _handleStreamResult(initial);
    } catch (_) {
      // Plugin unavailable - ignore.
    }
  }

  /// Core of the stream listener. Handles both handover cases:
  /// 1. Dropping to offline -> queue the in-flight request.
  /// 2. Reconnecting -> drain (retry) the queue automatically.
  void _handleStreamResult(List<ConnectivityResult> results) {
    final wasOnline = isOnline;
    _results = results;
    final nowOnline = isOnline;

    if (wasOnline && !nowOnline && _inFlight) {
      // Connection dropped mid-request: catch and queue it.
      final label = _inFlightLabel ?? 'Data transfer';
      _inFlight = false;
      _inFlightLabel = null;
      _inFlightQueued = true;
      _queuedRequests.add(label);
    }

    if (!wasOnline && nowOnline) {
      // Stable connection restored: retry queued requests.
      _drainQueue();
    }

    notifyListeners();
  }

  /// Simulates starting a long-running network request. Sends the data
  /// right away when online, otherwise queues it for later.
  Future<void> sendPendingData([String? label]) async {
    final requestLabel = label ?? 'Data request ${++_requestNumber}';

    if (!isOnline) {
      _queuedRequests.add(requestLabel);
      notifyListeners();
      return;
    }

    _inFlight = true;
    _inFlightLabel = requestLabel;
    _inFlightQueued = false;
    notifyListeners();

    try {
      await _simulateTransfer();
      _inFlight = false;
      _inFlightLabel = null;
      if (!_inFlightQueued) {
        _completedRequests.insert(0, requestLabel);
      }
    } on NetworkRequestException {
      // The error is caught and the request is queued instead of crashing.
      _inFlight = false;
      _inFlightLabel = null;
      if (!_inFlightQueued) {
        _queuedRequests.add(requestLabel);
      }
    }
    notifyListeners();
  }

  /// Simulates a 3-second network transfer. Throws if the connection
  /// disappears while the "data" is being sent.
  Future<void> _simulateTransfer() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!isOnline) {
      throw const NetworkRequestException('Connection lost during transfer.');
    }
  }

  /// Graceful recovery: retries every queued request as soon as a
  /// stable connection (Wi-Fi or Cellular) is available again.
  Future<void> _drainQueue() async {
    if (_recovering || !isOnline) return;
    _recovering = true;
    notifyListeners();

    while (_queuedRequests.isNotEmpty && isOnline) {
      final label = _queuedRequests.removeAt(0);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!isOnline) {
        // Dropped again mid-retry: put it back for the next recovery.
        _queuedRequests.insert(0, label);
        break;
      }
      _completedRequests.insert(0, label);
      notifyListeners();
    }

    _recovering = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}