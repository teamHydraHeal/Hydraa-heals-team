import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/language_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        user?.name.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user?.name ?? 'Unknown User',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user?.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getRoleColor(user?.role).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        _getRoleDisplayName(user?.role),
                        style: TextStyle(
                          color: _getRoleColor(user?.role),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          user?.isVerified == true ? Icons.verified : Icons.pending,
                          color: user?.isVerified == true ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user?.isVerified == true ? 'Verified' : 'Pending Verification',
                          style: TextStyle(
                            color: user?.isVerified == true ? Colors.green : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Personal Information
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.phone),
                    title: Text('Phone Number'),
                    subtitle: Text('+91-9876543210'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Location'),
                    subtitle: Text('Shillong, East Khasi Hills, Meghalaya'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.credit_card),
                    title: Text('Aadhaar Number'),
                    subtitle: Text('**** **** 9012'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Settings
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: Text(languageProvider.getLanguageName()),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/settings'),
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Notifications'),
                    subtitle: Text('Manage notification preferences'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: null,
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.security),
                    title: Text('Privacy & Security'),
                    subtitle: Text('Manage your privacy settings'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: null,
                  ),
                  const Divider(height: 1),
                  const ListTile(
                    leading: Icon(Icons.help),
                    title: Text('Help & Support'),
                    subtitle: Text('Get help and contact support'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: null,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Account Actions
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Version
            Text(
              'Jal Guard v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(role) {
    switch (role?.toString()) {
      case 'UserRole.healthOfficial':
        return Colors.blue;
      case 'UserRole.ashaWorker':
        return Colors.green;
      case 'UserRole.citizen':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRoleDisplayName(role) {
    switch (role?.toString()) {
      case 'UserRole.healthOfficial':
        return 'Health Official';
      case 'UserRole.ashaWorker':
        return 'ASHA Worker';
      case 'UserRole.citizen':
        return 'Citizen';
      default:
        return 'Unknown';
    }
  }

  void _showLogoutDialog(BuildContext context) {
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
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/welcome');
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
}
