import 'package:flutter/material.dart';
import '../widgets/section_header.dart';

// Activity 3 Screen
class Activity3Screen extends StatelessWidget {
  const Activity3Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity 3: Responsive UI'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final String layoutMode;
          final int columns;

          if (width < 600) {
            layoutMode = 'Mobile (< 600px)';
            columns = 1;
          } else if (width < 900) {
            layoutMode = 'Tablet (600px - 900px)';
            columns = 2;
          } else {
            layoutMode = 'Desktop (>= 900px)';
            columns = 3;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer.withAlpha(100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.devices_rounded,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Demonstrate adaptive layouts that automatically rearrange depending on available window width.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Live Screen Metrics Card
                const SectionHeader(
                  title: 'Real-Time Screen Metrics',
                  icon: Icons.aspect_ratio_rounded,
                ),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(100),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetricItem(
                              context,
                              label: 'Screen Width',
                              value: '${width.toInt()} px',
                              icon: Icons.straighten,
                            ),
                            _buildMetricItem(
                              context,
                              label: 'Layout Mode',
                              value: layoutMode,
                              icon: Icons.view_quilt_outlined,
                            ),
                            _buildMetricItem(
                              context,
                              label: 'Active Columns',
                              value: '$columns',
                              icon: Icons.grid_view_rounded,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Try resizing your browser window or switching screen orientation to observe instant layout changes!',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Responsive Cards Grid Demo
                SectionHeader(
                  title: 'Adaptive Cards Layout ($columns Column${columns > 1 ? 's' : ''})',
                  icon: Icons.dashboard_customize_outlined,
                ),
                _buildAdaptiveGrid(context, columns: columns),
                const SizedBox(height: 20),

                // Flex & Row Demonstration
                const SectionHeader(
                  title: 'Flex, Expanded & Flexible Demonstration',
                  icon: Icons.table_chart_outlined,
                ),
                Card(
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
                        const Text(
                          'Row with Expanded (Flex 2 : Flex 1)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Expanded (Flex 2)',
                                  style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Flex 1',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSecondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildAdaptiveGrid(BuildContext context, {required int columns}) {
    final theme = Theme.of(context);
    final demoItems = [
      {'title': 'Module A', 'desc': 'Adaptive card container 1'},
      {'title': 'Module B', 'desc': 'Adaptive card container 2'},
      {'title': 'Module C', 'desc': 'Adaptive card container 3'},
    ];

    if (columns == 1) {
      return Column(
        children: demoItems
            .map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildDemoCard(theme, item['title']!, item['desc']!),
                ))
            .toList(),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: demoItems
          .map(
            (item) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: _buildDemoCard(theme, item['title']!, item['desc']!),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDemoCard(ThemeData theme, String title, String desc) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard_outlined, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              desc,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
