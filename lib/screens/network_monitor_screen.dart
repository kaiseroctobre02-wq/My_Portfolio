import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/network_monitor_provider.dart';

/// Network Monitor: shows the live network state and demonstrates a
/// request queue that survives Wi-Fi -> Cellular handovers.
///
/// StatelessWidget: all changing data lives in NetworkMonitorProvider,
/// and `context.watch` rebuilds this UI whenever it changes.
class NetworkMonitorScreen extends StatelessWidget {
  const NetworkMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NetworkMonitorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Network Monitor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _NetworkStatusCard(provider: provider),
          const SizedBox(height: 16),
          _TransferCard(provider: provider),
          const SizedBox(height: 16),
          _QueueCard(provider: provider),
          const SizedBox(height: 16),
          _CompletedCard(provider: provider),
          const SizedBox(height: 16),
          const _InfoCard(),
        ],
      ),
    );
  }
}

/// Live network status panel (Wi-Fi / Cellular / Offline).
class _NetworkStatusCard extends StatelessWidget {
  final NetworkMonitorProvider provider;

  const _NetworkStatusCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color statusColor = provider.isOnline ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                provider.networkIcon,
                size: 38,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.networkLabel,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              provider.isOnline
                  ? 'Connected · live stream updates'
                  : 'No active connection · requests will be queued',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simulated long-running request with a queuing fallback.
class _TransferCard extends StatelessWidget {
  final NetworkMonitorProvider provider;

  const _TransferCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Simulated Data Transfer',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => provider.sendPendingData(),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Send New Request'),
            ),
            const SizedBox(height: 12),
            if (provider.inFlight) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Transferring ${provider.inFlightLabel}...',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows pending requests waiting for a stable connection.
class _QueueCard extends StatelessWidget {
  final NetworkMonitorProvider provider;

  const _QueueCard({required this.provider});

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
                Expanded(
                  child: Text(
                    'Queued Requests',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (provider.queuedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${provider.queuedCount}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (provider.queuedRequests.isEmpty)
              Text(
                'Nothing queued right now.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else ...[
              for (final label in provider.queuedRequests)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.hourglass_bottom,
                        size: 20,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(label)),
                    ],
                  ),
                ),
              Text(
                provider.recovering
                    ? 'Connection restored — retrying queued requests...'
                    : 'Waiting for a connection... the queue auto-retries '
                        'when Wi-Fi or Cellular returns.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows transfers that finished successfully.
class _CompletedCard extends StatelessWidget {
  final NetworkMonitorProvider provider;

  const _CompletedCard({required this.provider});

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
              'Completed Transfers',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            if (provider.completedRequests.isEmpty)
              Text(
                'No completed transfers yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              for (final label in provider.completedRequests)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(label)),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

/// Short explanation of the handover behavior.
class _InfoCard extends StatelessWidget {
  const _InfoCard();

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
              'How it works',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. connectivity_plus streams every network change.\n'
              '2. A dropped Wi-Fi -> Cellular handover queues the '
              'in-flight request.\n'
              '3. When a stable connection returns, queued requests '
              'are retried automatically.',
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