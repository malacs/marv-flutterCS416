import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/network_diagnostic_provider.dart';
import '../widgets/section_header.dart';

class Activity3Screen extends StatelessWidget {
  const Activity3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final diagnosticProvider = Provider.of<NetworkDiagnosticProvider>(context);
    final activeTier = diagnosticProvider.activeTier;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 3: Network Diagnostics'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Run Diagnostics',
            onPressed: diagnosticProvider.status == DiagnosticStatus.idle ||
                    diagnosticProvider.status == DiagnosticStatus.completed ||
                    diagnosticProvider.status == DiagnosticStatus.error
                ? () => diagnosticProvider.runFullDiagnostics()
                : null,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Description Card
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withAlpha(90),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Network Diagnostic Dashboard',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Measure the connection in three ordered phases and adapt content to the result.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Current Network Health Banner
              _buildActiveTierBanner(context, diagnosticProvider),
              const SizedBox(height: 20),

              // Network Metrics Section
              const SectionHeader(
                title: 'Network Metrics',
                icon: Icons.analytics_outlined,
              ),
              _buildMetricsListCard(context, diagnosticProvider),
              const SizedBox(height: 20),

              // Diagnostic Controls Section
              const SectionHeader(
                title: 'Diagnostic Controls',
                icon: Icons.alt_route_rounded,
              ),
              _buildDiagnosticControlsCard(context, diagnosticProvider),
              const SizedBox(height: 20),

              // Dynamic Content Section
              SectionHeader(
                title: 'Dynamic Content (${diagnosticProvider.tierName} Mode)',
                icon: Icons.perm_media_outlined,
              ),
              _buildDynamicContentSection(context, activeTier),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner displaying current network health tier
  Widget _buildActiveTierBanner(
      BuildContext context, NetworkDiagnosticProvider provider) {
    final theme = Theme.of(context);
    final tier = provider.activeTier;

    final Color color;
    final IconData icon;

    switch (tier) {
      case NetworkHealthTier.excellent:
        color = const Color(0xFF10B981);
        icon = Icons.bolt_rounded;
        break;
      case NetworkHealthTier.fair:
        color = Colors.amber.shade800;
        icon = Icons.wifi_rounded;
        break;
      case NetworkHealthTier.poor:
        color = Colors.orange.shade800;
        icon = Icons.network_check_rounded;
        break;
      case NetworkHealthTier.degraded:
        color = Colors.red.shade700;
        icon = Icons.signal_cellular_connected_no_internet_4_bar_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(120), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Network Health: ${provider.tierName}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.tierDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Clean Card displaying the 5 required network metrics
  Widget _buildMetricsListCard(
      BuildContext context, NetworkDiagnosticProvider provider) {
    final theme = Theme.of(context);

    final idlePingStr = provider.idlePingMs < 0
        ? 'Offline'
        : '${provider.idlePingMs.toStringAsFixed(1)} ms';
    final downloadSpeedStr = '${provider.downloadMbps.toStringAsFixed(2)} Mbps';
    final downloadPingStr = provider.downloadPingMs < 0
        ? 'Offline'
        : '${provider.downloadPingMs.toStringAsFixed(1)} ms';
    final uploadSpeedStr = '${provider.uploadMbps.toStringAsFixed(2)} Mbps';
    final uploadPingStr = provider.uploadPingMs < 0
        ? 'Offline'
        : '${provider.uploadPingMs.toStringAsFixed(1)} ms';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMetricRow(
              context,
              label: 'Idle Ping',
              value: idlePingStr,
              icon: Icons.timer_outlined,
              color: Colors.blue,
            ),
            const Divider(height: 16),
            _buildMetricRow(
              context,
              label: 'Download Speed',
              value: downloadSpeedStr,
              icon: Icons.download_rounded,
              color: Colors.green,
            ),
            const Divider(height: 16),
            _buildMetricRow(
              context,
              label: 'Download Ping',
              value: downloadPingStr,
              icon: Icons.speed_rounded,
              color: Colors.teal,
            ),
            const Divider(height: 16),
            _buildMetricRow(
              context,
              label: 'Upload Speed',
              value: uploadSpeedStr,
              icon: Icons.upload_rounded,
              color: Colors.purple,
            ),
            const Divider(height: 16),
            _buildMetricRow(
              context,
              label: 'Upload Ping',
              value: uploadPingStr,
              icon: Icons.network_ping_rounded,
              color: Colors.deepOrange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  /// Controls Card with 3-phase diagnostic progress, Run Diagnostic button, and Auto-Refresh switch
  Widget _buildDiagnosticControlsCard(
      BuildContext context, NetworkDiagnosticProvider provider) {
    final theme = Theme.of(context);
    final isTesting = provider.status == DiagnosticStatus.measuringIdlePing ||
        provider.status == DiagnosticStatus.measuringDownload ||
        provider.status == DiagnosticStatus.measuringUpload;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    provider.statusMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isTesting)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // 3-Phase Step Indicators
            Row(
              children: [
                _buildStepIndicator(
                  context,
                  stepNumber: 1,
                  title: 'Idle Ping',
                  isActive: provider.status == DiagnosticStatus.measuringIdlePing,
                  isDone: provider.status == DiagnosticStatus.measuringDownload ||
                      provider.status == DiagnosticStatus.measuringUpload ||
                      provider.status == DiagnosticStatus.completed,
                ),
                _buildStepConnector(context),
                _buildStepIndicator(
                  context,
                  stepNumber: 2,
                  title: 'Download & Ping',
                  isActive: provider.status == DiagnosticStatus.measuringDownload,
                  isDone: provider.status == DiagnosticStatus.measuringUpload ||
                      provider.status == DiagnosticStatus.completed,
                ),
                _buildStepConnector(context),
                _buildStepIndicator(
                  context,
                  stepNumber: 3,
                  title: 'Upload & Ping',
                  isActive: provider.status == DiagnosticStatus.measuringUpload,
                  isDone: provider.status == DiagnosticStatus.completed,
                ),
              ],
            ),
            const Divider(height: 24),

            // Action Buttons and Auto-Refresh Switch
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: isTesting ? null : () => provider.runFullDiagnostics(),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Run Diagnostic'),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Auto-Refresh (30s):',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Switch(
                      value: provider.isAutoRefreshEnabled,
                      onChanged: (val) => provider.toggleAutoRefresh(val),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required bool isActive,
    required bool isDone,
  }) {
    final theme = Theme.of(context);
    final color = isDone
        ? Colors.green
        : isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant.withAlpha(80);

    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: isActive || isDone
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Divider(
        color: Theme.of(context).colorScheme.outlineVariant,
        thickness: 1.5,
      ),
    );
  }

  /// Dynamic Content representation that adapts strictly to detected tier without layout overflow
  Widget _buildDynamicContentSection(
      BuildContext context, NetworkHealthTier tier) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(100),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  tier == NetworkHealthTier.excellent
                      ? Icons.star_rounded
                      : tier == NetworkHealthTier.fair
                          ? Icons.tune_rounded
                          : tier == NetworkHealthTier.poor
                              ? Icons.description_outlined
                              : Icons.warning_amber_rounded,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getContentTitle(tier),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            _buildDynamicContentBody(context, tier),
          ],
        ),
      ),
    );
  }

  String _getContentTitle(NetworkHealthTier tier) {
    switch (tier) {
      case NetworkHealthTier.excellent:
        return 'Richer High-Quality Content Mode';
      case NetworkHealthTier.fair:
        return 'Standard Reduced Content Mode';
      case NetworkHealthTier.poor:
        return 'Lightweight Placeholders Mode';
      case NetworkHealthTier.degraded:
        return 'Minimal Text-Focused Fallback';
    }
  }

  Widget _buildDynamicContentBody(
      BuildContext context, NetworkHealthTier tier) {
    final theme = Theme.of(context);

    switch (tier) {
      case NetworkHealthTier.excellent:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.primaryContainer.withAlpha(120),
              ),
              child: Row(
                children: [
                  Icon(Icons.high_quality_rounded,
                      size: 32, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'High Quality Content Enabled',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Full fidelity graphics, high-res assets, and uncompressed media loading enabled (>10 Mbps detected).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case NetworkHealthTier.fair:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.secondaryContainer.withAlpha(120),
              ),
              child: Row(
                children: [
                  Icon(Icons.sd_rounded,
                      size: 32, color: theme.colorScheme.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Standard Content Enabled',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Balanced media load: standard resolution images and compressed assets (2–10 Mbps detected).',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case NetworkHealthTier.poor:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: Row(
                children: [
                  Icon(Icons.insert_drive_file_outlined,
                      size: 32, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lightweight Placeholders Active',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Low bandwidth detected (<2 Mbps). Heavy media replaced with text placeholders.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case NetworkHealthTier.degraded:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.red.withAlpha(15),
            border: Border.all(color: Colors.red.withAlpha(80)),
          ),
          child: Row(
            children: [
              const Icon(Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                  size: 32, color: Colors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimal Text-Focused Fallback',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Heavy packet loss or extreme latency detected. Media loading suspended to conserve bandwidth.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
