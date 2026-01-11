import 'package:flutter/material.dart';

import '../../features/health_official/screens/command_center_screen.dart';
import '../../features/health_official/screens/ai_copilot_screen.dart';
import '../../features/health_official/screens/broadcast_screen.dart';
import '../../features/health_official/screens/resources_screen.dart';
import '../../features/field_worker/screens/field_dashboard_screen.dart';
import '../../features/field_worker/screens/report_form_screen.dart';
import '../../features/field_worker/screens/mcp_card_screen.dart';
import '../../features/field_worker/screens/ai_copilot_screen.dart' as field_worker_ai;
import '../../features/citizen/screens/citizen_dashboard_screen.dart';
import '../../features/citizen/screens/concern_report_screen.dart';
import '../../features/citizen/screens/ai_copilot_screen.dart' as citizen_ai;
import '../../features/shared/screens/notifications_screen.dart';
import '../../features/shared/screens/profile_screen.dart';
import '../../features/shared/screens/educational_module_screen.dart';
import '../models/user_model.dart';

class RoleBasedNavigation extends StatelessWidget {
  final UserRole userRole;
  final int initialIndex;

  const RoleBasedNavigation({
    super.key,
    required this.userRole,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (userRole) {
      case UserRole.healthOfficial:
        return _HealthOfficialNavigation(initialIndex: initialIndex);
      case UserRole.ashaWorker:
        return _AshaWorkerNavigation(initialIndex: initialIndex);
      case UserRole.citizen:
        return _CitizenNavigation(initialIndex: initialIndex);
    }
  }
}

class _HealthOfficialNavigation extends StatefulWidget {
  final int initialIndex;

  const _HealthOfficialNavigation({required this.initialIndex});

  @override
  State<_HealthOfficialNavigation> createState() => _HealthOfficialNavigationState();
}

class _HealthOfficialNavigationState extends State<_HealthOfficialNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const CommandCenterScreen(),
    const AiCopilotScreen(),
    const BroadcastScreen(),
    const ResourcesScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.psychology,
      activeIcon: Icons.psychology,
      label: 'AI Co-pilot',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.broadcast_on_personal,
      activeIcon: Icons.broadcast_on_personal,
      label: 'Broadcast',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.inventory,
      activeIcon: Icons.inventory,
      label: 'Resources',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: 'Profile',
      badge: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: _navigationItems.map((item) {
            return BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(item.icon),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  Icon(item.activeIcon),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _AshaWorkerNavigation extends StatefulWidget {
  final int initialIndex;

  const _AshaWorkerNavigation({required this.initialIndex});

  @override
  State<_AshaWorkerNavigation> createState() => _AshaWorkerNavigationState();
}

class _AshaWorkerNavigationState extends State<_AshaWorkerNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const FieldDashboardScreen(),
    const field_worker_ai.FieldWorkerAiCopilotScreen(),
    const ReportFormScreen(),
    const EducationalModuleScreen(),
    const McpCardScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home,
      activeIcon: Icons.home,
      label: 'Home',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.psychology_alt,
      activeIcon: Icons.psychology_alt,
      label: 'AI Assistant',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.assignment,
      activeIcon: Icons.assignment,
      label: 'Report',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.school,
      activeIcon: Icons.school,
      label: 'Education',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.credit_card,
      activeIcon: Icons.credit_card,
      label: 'MCP Cards',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: 'Profile',
      badge: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: _navigationItems.map((item) {
            return BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(item.icon),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  Icon(item.activeIcon),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _CitizenNavigation extends StatefulWidget {
  final int initialIndex;

  const _CitizenNavigation({required this.initialIndex});

  @override
  State<_CitizenNavigation> createState() => _CitizenNavigationState();
}

class _CitizenNavigationState extends State<_CitizenNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const CitizenDashboardScreen(),
    const citizen_ai.CitizenAiCopilotScreen(),
    const ConcernReportScreen(),
    const EducationalModuleScreen(),
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home,
      activeIcon: Icons.home,
      label: 'Home',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.psychology_alt,
      activeIcon: Icons.psychology_alt,
      label: 'AI Health',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.report_problem,
      activeIcon: Icons.report_problem,
      label: 'Report',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.school,
      activeIcon: Icons.school,
      label: 'Learn',
      badge: null,
    ),
    NavigationItem(
      icon: Icons.notifications,
      activeIcon: Icons.notifications,
      label: 'Alerts',
      badge: 3, // Mock badge count
    ),
    NavigationItem(
      icon: Icons.person,
      activeIcon: Icons.person,
      label: 'Profile',
      badge: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: _navigationItems.map((item) {
            return BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(item.icon),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  Icon(item.activeIcon),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: item.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;

  NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}
