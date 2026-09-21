import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/network_diagnostics_provider.dart';

/// Network Diagnostic Dashboard.
///
/// Displays the live results of the background diagnostic tool: idle
/// ping, download bandwidth (with concurrent ping), upload bandwidth
/// (with concurrent upload ping), and the categorized health tier.
class NetworkDiagnosticsScreen extends StatelessWidget {
  const NetworkDiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkDiagnosticsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Diagnostic Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Run diagnostic now',
            onPressed: provider.isRunning ? null : provider.runDiagnostics,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _TierCard(provider: provider),
          const SizedBox(height: 16),
          _IdlePingCard(provider: provider),
          const SizedBox(height: 16),
          _DownloadCard(provider: provider),
          const SizedBox(height: 16),
          _UploadCard(provider: provider),
          const SizedBox(height: 16),
          const _ThresholdCard(),
          const SizedBox(height: 16),
          const _HowItWorksCard(),
        ],
      ),
    );
  }
}

/// Big card with the categorized health of the connection.
class _TierCard extends StatelessWidget {
  final NetworkDiagnosticsProvider provider;

  const _TierCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String timeLabel = provider.lastUpdated == null
        ? 'Awaiting first test…'
        : 'Last test: ${_formatTime(provider.lastUpdated!)} · '
            'auto-retests every 30s';

    final Color color =
        provider.hasRun ? provider.tierColor : theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                provider.hasRun ? provider.tierIcon : Icons.hourglass_top,
                size: 40,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.hasRun ? provider.tierLabel : 'Checking…',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.note ?? provider.tierDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (provider.isRunning) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ],
            const SizedBox(height: 10),
            Text(
              timeLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Baseline idle ping measured before any transfer.
class _IdlePingCard extends StatelessWidget {
  final NetworkDiagnosticsProvider provider;

  const _IdlePingCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _MetricCard(
      title: 'Idle Ping',
      icon: Icons.timer_outlined,
      value: _formatPing(provider.idlePingMs),
      hint: 'Baseline latency before any transfer.',
    );
  }
}

/// Download bandwidth + the ping sampled during the download.
class _DownloadCard extends StatelessWidget {
  final NetworkDiagnosticsProvider provider;

  const _DownloadCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _MetricCard(
      title: 'Download Bandwidth',
      icon: Icons.download_outlined,
      value: _formatSpeed(provider.downloadMbps),
      subLabel: 'Concurrent download ping: ${_formatPing(provider.downloadPingMs)}',
      hint: 'Downloaded a known file while pings ran simultaneously.',
    );
  }
}

/// Upload bandwidth + the ping tracked during the upload.
class _UploadCard extends StatelessWidget {
  final NetworkDiagnosticsProvider provider;

  const _UploadCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return _MetricCard(
      title: 'Upload Bandwidth',
      icon: Icons.upload_outlined,
      value: _formatSpeed(provider.uploadMbps),
      subLabel: 'Concurrent upload ping: ${_formatPing(provider.uploadPingMs)}',
      hint: 'Sent a test payload while the upload ping was tracked.',
    );
  }
}

/// The operational tiers used to categorize connection health.
class _ThresholdCard extends StatelessWidget {
  const _ThresholdCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Thresholds',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const _ThresholdRow(label: 'Excellent', rule: '> 10 Mbps', tier: ConnectionTier.excellent),
            const SizedBox(height: 6),
            const _ThresholdRow(label: 'Fair', rule: '2 – 10 Mbps', tier: ConnectionTier.fair),
            const SizedBox(height: 6),
            const _ThresholdRow(label: 'Poor', rule: '< 2 Mbps', tier: ConnectionTier.poor),
            const SizedBox(height: 6),
            const _ThresholdRow(label: 'Degraded', rule: 'Heavy packet loss / extreme latency', tier: ConnectionTier.degraded),
          ],
        ),
      ),
    );
  }
}

/// One row inside the thresholds card.
class _ThresholdRow extends StatelessWidget {
  final String label;
  final String rule;
  final ConnectionTier tier;

  const _ThresholdRow({
    required this.label,
    required this.rule,
    required this.tier,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color color = _tierColorFor(tier, theme);

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          rule,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Short explanation of the diagnostic sequence.
class _HowItWorksCard extends StatelessWidget {
  const _HowItWorksCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How the diagnostic works',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Measure the baseline idle ping.\n'
              '2. Compute the download bandwidth while measuring ping\n'
              '   concurrently.\n'
              '3. Compute the upload bandwidth while tracking the\n'
              '   upload ping simultaneously.\n'
              '\n'
              'Results are injected into the app-wide Provider state so '
              'every screen (including the Home Dashboard) sees the same '
              'connection tier in real time.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable metric card used for the ping/bandwidth results.
class _MetricCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String? subLabel;
  final String hint;

  const _MetricCard({
    required this.title,
    required this.icon,
    required this.value,
    this.subLabel,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 22, color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                subLabel!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              hint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatSpeed(double? mbps) =>
    mbps == null ? '—' : '${mbps.toStringAsFixed(2)} Mbps';

String _formatPing(double? ms) => ms == null ? '—' : '${ms.toStringAsFixed(0)} ms';

String _formatTime(DateTime time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  final second = time.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second';
}

Color _tierColorFor(ConnectionTier tier, ThemeData theme) {
  switch (tier) {
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