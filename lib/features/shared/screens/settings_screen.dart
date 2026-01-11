import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/language_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Settings
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Language & Region',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return Column(
                      children: [
                        RadioListTile<String>(
                          title: const Text('English'),
                          subtitle: const Text('English (US)'),
                          value: 'en',
                          groupValue: languageProvider.getLanguageCode(),
                          onChanged: (value) {
                            if (value != null) {
                              languageProvider.setLanguage(value);
                            }
                          },
                        ),
                        RadioListTile<String>(
                          title: const Text('Khasi'),
                          subtitle: const Text('Khasi (Meghalaya)'),
                          value: 'kha',
                          groupValue: languageProvider.getLanguageCode(),
                          onChanged: (value) {
                            if (value != null) {
                              languageProvider.setLanguage(value);
                            }
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Notification Settings
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive health alerts and updates'),
                  value: true,
                  onChanged: (value) {
                    // Handle notification toggle
                  },
                ),
                SwitchListTile(
                  title: const Text('Health Alerts'),
                  subtitle: const Text('Critical health situation alerts'),
                  value: true,
                  onChanged: (value) {
                    // Handle health alerts toggle
                  },
                ),
                SwitchListTile(
                  title: const Text('Report Updates'),
                  subtitle: const Text('Updates on your submitted reports'),
                  value: true,
                  onChanged: (value) {
                    // Handle report updates toggle
                  },
                ),
                SwitchListTile(
                  title: const Text('System Messages'),
                  subtitle: const Text('App updates and maintenance notices'),
                  value: false,
                  onChanged: (value) {
                    // Handle system messages toggle
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Privacy Settings
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Privacy & Security',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Location Sharing'),
                  subtitle: const Text('Share location for accurate reporting'),
                  value: true,
                  onChanged: (value) {
                    // Handle location sharing toggle
                  },
                ),
                SwitchListTile(
                  title: const Text('Data Analytics'),
                  subtitle: const Text('Help improve the app with anonymous data'),
                  value: true,
                  onChanged: (value) {
                    // Handle data analytics toggle
                  },
                ),
                const ListTile(
                  title: Text('Data Export'),
                  subtitle: Text('Download your data'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: null,
                ),
                const ListTile(
                  title: Text('Delete Account'),
                  subtitle: Text('Permanently delete your account'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // App Settings
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'App Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Use dark theme'),
                  value: false,
                  onChanged: (value) {
                    // Handle dark mode toggle
                  },
                ),
                SwitchListTile(
                  title: const Text('Offline Mode'),
                  subtitle: const Text('Work without internet connection'),
                  value: true,
                  onChanged: (value) {
                    // Handle offline mode toggle
                  },
                ),
                const ListTile(
                  title: Text('Clear Cache'),
                  subtitle: Text('Free up storage space'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: null,
                ),
                const ListTile(
                  title: Text('App Version'),
                  subtitle: Text('v1.0.0'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Support
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const ListTile(
                  title: Text('Help Center'),
                  subtitle: Text('Get help and tutorials'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: null,
                ),
                const ListTile(
                  title: Text('Contact Support'),
                  subtitle: Text('Get in touch with our team'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: null,
                ),
                const ListTile(
                  title: Text('Report Bug'),
                  subtitle: Text('Report issues with the app'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: null,
                ),
                const ListTile(
                  title: Text('Rate App'),
                  subtitle: Text('Rate us on the app store'),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: null,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
