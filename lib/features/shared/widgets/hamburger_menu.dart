import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';

class HamburgerMenu extends StatelessWidget {
  const HamburgerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) return const SizedBox.shrink();

        return Drawer(
          child: Column(
            children: [
              // Header
              _buildHeader(context, user),
              
              // Menu Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildMenuSection(
                      'Main Features',
                      _getMainMenuItems(context, user.role),
                    ),
                    _buildMenuSection(
                      'Tools & Utilities',
                      _getToolsMenuItems(context, user.role),
                    ),
                    _buildMenuSection(
                      'Support & Help',
                      _getSupportMenuItems(context),
                    ),
                  ],
                ),
              ),
              
              // Footer
              _buildFooter(context, authProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar and Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isNotEmpty ? user.name : 'User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRoleDisplayName(user.role),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user.isVerified ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.isVerified ? 'Verified' : 'Pending',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Quick Stats
              Row(
                children: [
                  _buildQuickStat('Reports', '12', Icons.assignment),
                  const SizedBox(width: 20),
                  _buildQuickStat('Alerts', '3', Icons.notifications),
                  const SizedBox(width: 20),
                  _buildQuickStat('Sync', 'Online', Icons.sync),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<MenuItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        ...items.map((item) => _buildMenuItem(item)).toList(),
      ],
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    return ListTile(
      leading: Icon(item.icon, color: item.color),
      title: Text(
        item.title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: item.subtitle != null
          ? Text(
              item.subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      trailing: item.badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${item.badge}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: item.onTap,
    );
  }

  Widget _buildFooter(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context, authProvider);
            },
          ),
        ],
      ),
    );
  }

  List<MenuItem> _getMainMenuItems(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.healthOfficial:
        return [
          MenuItem(
            title: 'Emergency Escalation',
            icon: Icons.emergency,
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              // Navigate to emergency escalation
            },
          ),
          MenuItem(
            title: 'Resource Management',
            icon: Icons.inventory,
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              // Navigate to resource management
            },
          ),
          MenuItem(
            title: 'Analytics Dashboard',
            icon: Icons.analytics,
            color: Colors.green,
            onTap: () {
              Navigator.pop(context);
              // Navigate to analytics
            },
          ),
        ];
      case UserRole.ashaWorker:
        return [
          MenuItem(
            title: 'MCP Cards',
            icon: Icons.credit_card,
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              // Navigate to MCP cards
            },
          ),
          MenuItem(
            title: 'Sync Status',
            icon: Icons.sync,
            color: Colors.orange,
            onTap: () {
              Navigator.pop(context);
              // Navigate to sync status
            },
          ),
          MenuItem(
            title: 'Field Reports',
            icon: Icons.assignment,
            color: Colors.green,
            onTap: () {
              Navigator.pop(context);
              // Navigate to field reports
            },
          ),
        ];
      case UserRole.citizen:
        return [
          MenuItem(
            title: 'Health Alerts',
            icon: Icons.notifications,
            color: Colors.red,
            badge: 3,
            onTap: () {
              Navigator.pop(context);
              // Navigate to health alerts
            },
          ),
          MenuItem(
            title: 'Emergency Contacts',
            icon: Icons.phone,
            color: Colors.green,
            onTap: () {
              Navigator.pop(context);
              // Navigate to emergency contacts
            },
          ),
          MenuItem(
            title: 'Health Tips',
            icon: Icons.health_and_safety,
            color: Colors.blue,
            onTap: () {
              Navigator.pop(context);
              // Navigate to health tips
            },
          ),
        ];
    }
  }

  List<MenuItem> _getToolsMenuItems(BuildContext context, UserRole role) {
    return [
      MenuItem(
        title: 'Data Export',
        icon: Icons.download,
        color: Colors.blue,
        onTap: () {
          Navigator.pop(context);
          _showDataExportDialog(context);
        },
      ),
      MenuItem(
        title: 'Offline Mode',
        icon: Icons.wifi_off,
        color: Colors.orange,
        subtitle: 'Manage offline data',
        onTap: () {
          Navigator.pop(context);
          _showOfflineModeDialog(context);
        },
      ),
      MenuItem(
        title: 'Language Settings',
        icon: Icons.language,
        color: Colors.purple,
        onTap: () {
          Navigator.pop(context);
          _showLanguageSettingsDialog(context);
        },
      ),
    ];
  }

  List<MenuItem> _getSupportMenuItems(BuildContext context) {
    return [
      MenuItem(
        title: 'Help & FAQ',
        icon: Icons.help,
        color: Colors.blue,
        onTap: () {
          Navigator.pop(context);
          _showHelpDialog(context);
        },
      ),
      MenuItem(
        title: 'Contact Support',
        icon: Icons.support_agent,
        color: Colors.green,
        onTap: () {
          Navigator.pop(context);
          _showContactSupportDialog(context);
        },
      ),
      MenuItem(
        title: 'Report Bug',
        icon: Icons.bug_report,
        color: Colors.red,
        onTap: () {
          Navigator.pop(context);
          _showReportBugDialog(context);
        },
      ),
      MenuItem(
        title: 'About App',
        icon: Icons.info,
        color: Colors.grey,
        onTap: () {
          Navigator.pop(context);
          _showAboutDialog(context);
        },
      ),
    ];
  }

  String _getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.healthOfficial:
        return 'Health Official';
      case UserRole.ashaWorker:
        return 'ASHA Worker';
      case UserRole.citizen:
        return 'Citizen';
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              authProvider.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDataExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Export'),
        content: const Text('Export your health data and reports for backup or sharing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export started'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showOfflineModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Offline Mode'),
        content: const Text('Manage your offline data and sync settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLanguageSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Settings'),
        content: const Text('Change your preferred language for the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & FAQ'),
        content: const Text('Find answers to common questions and learn how to use the app.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('Get help from our support team.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showReportBugDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Bug'),
        content: const Text('Report any issues or bugs you encounter.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Jal Guard'),
        content: const Text('Version 1.0.0\nAI-powered public health command center for Northeast India.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class MenuItem {
  final String title;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final int? badge;
  final VoidCallback? onTap;

  MenuItem({
    required this.title,
    required this.icon,
    required this.color,
    this.subtitle,
    this.badge,
    this.onTap,
  });
}
