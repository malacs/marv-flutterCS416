import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/activity_item.dart';
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

  Widget _buildActivityCompilationView(BuildContext context, List<ActivityItem> activities) {
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
