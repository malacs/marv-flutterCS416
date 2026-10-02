import 'package:flutter/material.dart';

// Activity Item Model
class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final String route;
  final String category;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.route,
    required this.category,
  });

  // Default Activities List
  static List<ActivityItem> get defaultActivities => const [
        ActivityItem(
          id: 'act1',
          title: 'Activity 1',
          subtitle: 'Flutter Portfolio & State Management',
          description: 'Explore basic Flutter widgets, local state, and interactive controls.',
          icon: Icons.widgets_outlined,
          route: '/activity1',
          category: 'UI & State',
        ),
        ActivityItem(
          id: 'act2',
          title: 'Activity 2',
          subtitle: 'Network Monitor',
          description: 'Real-time network stream listener, request queuing system, and graceful offline recovery.',
          icon: Icons.wifi_tethering_rounded,
          route: '/activity2',
          category: 'Networking',
        ),
        ActivityItem(
          id: 'act3',
          title: 'Activity 3',
          subtitle: 'Dynamic Performance Throttle App',
          description: 'Network diagnostic dashboard testing ping & bandwidth to dynamically throttle multimedia UI.',
          icon: Icons.speed_rounded,
          route: '/activity3',
          category: 'Performance & Network',
        ),
        ActivityItem(
          id: 'act4',
          title: 'Activity 4',
          subtitle: 'Serverless Local Chat App',
          description: 'Peer-to-peer localized mesh chat app utilizing Google Nearby Connections without internet or central servers.',
          icon: Icons.hub_rounded,
          route: '/activity4',
          category: 'Mesh & P2P',
        ),
      ];
}
