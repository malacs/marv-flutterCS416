import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_item.dart';
import '../providers/network_diagnostic_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/activity_card.dart';
import '../widgets/portfolio_header.dart';
import 'settings_screen.dart';

// Home Screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activities = ActivityItem.defaultActivities;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 0
              ? 'Marvin Flutter Profile'
              : _currentIndex == 1
                  ? 'Compilation of Activity'
                  : 'Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 1,
        actions: [
          // Global Network Health Badge
          Consumer<NetworkDiagnosticProvider>(
            builder: (context, netProvider, child) {
              final isOffline = netProvider.isOffline;
              final tier = netProvider.activeTier;
              final Color color;
              final IconData icon;

              if (isOffline) {
                color = Colors.red.shade700;
                icon = Icons.wifi_off_rounded;
              } else {
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
              }

              final speedText = (isOffline || !netProvider.hasMeasured || netProvider.downloadMbps <= 0)
                  ? '-'
                  : '${netProvider.downloadMbps.toStringAsFixed(1)} Mbps';

              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: Tooltip(
                  message: isOffline
                      ? 'Network Health: Offline. Tap to open Diagnostics.'
                      : 'Network Health: ${netProvider.tierName} ($speedText). Tap to open Diagnostics.',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(context, '/activity3'),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withAlpha(120)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 14, color: color),
                          const SizedBox(width: 4),
                          Text(
                            netProvider.tierName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Theme Toggle
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              final isDark = themeProvider.isDarkMode;
              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  themeProvider.toggleTheme(!isDark);
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Home View
          _buildHomeView(context, activities),

          // Activity View
          _buildActivityCompilationView(context, activities),

          // Settings View
          const SettingsScreen(isEmbedded: true),
        ],
      ),
      // Navigation Bar
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeView(BuildContext context, List<ActivityItem> activities) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Portfolio Header
          const PortfolioHeader(),
          const SizedBox(height: 16),

          // Activity Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              if (width < 650) {
                return Column(
                  children: activities.map((activity) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ActivityCard(
                        item: activity,
                        onTap: () {
                          Navigator.pushNamed(context, activity.route);
                        },
                      ),
                    );
                  }).toList(),
                );
              } else {
                final crossAxisCount = width > 1000 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.35,
                  ),
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return ActivityCard(
                      item: activity,
                      onTap: () {
                        Navigator.pushNamed(context, activity.route);
                      },
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCompilationView(
      BuildContext context, List<ActivityItem> activities) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity Directory Header
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
                  // Icon
                  Icon(
                    Icons.library_books_outlined,
                    color: theme.colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  // Text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Activity Directory',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Overview and quick launch for all laboratory submissions.',
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
          const SizedBox(height: 16),
          // Activity List
          ...activities.map((activity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14.0),
              child: ActivityCard(
                item: activity,
                onTap: () {
                  Navigator.pushNamed(context, activity.route);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
