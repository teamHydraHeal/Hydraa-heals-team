import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../widgets/local_heatmap_widget.dart';
import '../widgets/recent_activity_widget.dart';

class FieldDashboardScreen extends StatefulWidget {
  const FieldDashboardScreen({super.key});

  @override
  State<FieldDashboardScreen> createState() => _FieldDashboardScreenState();
}

class _FieldDashboardScreenState extends State<FieldDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.name ?? 'ASHA Worker'}!'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, child) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: connectivity.isOnline ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      connectivity.isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildReportTab(),
          _buildEducationTab(),
          _buildSyncTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Education',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Sync',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Local Health Status
          const Text(
            'Local Health Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          const LocalHeatmapWidget(),
          
          const SizedBox(height: 24),
          
          // Quick Report Button
          SizedBox(
            width: double.infinity,
            height: 80,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/field-worker/report-form'),
              icon: const Icon(Icons.add, size: 32),
              label: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Quick Health Check',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Recent Activity
          const RecentActivityWidget(),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'MCP Cards',
                  'Digital patient records',
                  Icons.credit_card,
                  Colors.blue,
                  () => context.push('/field-worker/mcp-card'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Education',
                  'Health guides',
                  Icons.school,
                  Colors.green,
                  () => setState(() => _selectedIndex = 2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Reports',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildReportCard(
                  'Water Contamination Report',
                  'Mawryngkneng Village',
                  'High',
                  '2 hours ago',
                  Colors.red,
                ),
                _buildReportCard(
                  'Diarrhea Cases',
                  'Shillong Block',
                  'Medium',
                  '1 day ago',
                  Colors.orange,
                ),
                _buildReportCard(
                  'Health Check-up',
                  'Cherrapunji',
                  'Low',
                  '3 days ago',
                  Colors.green,
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/field-worker/report-form'),
              icon: const Icon(Icons.add),
              label: const Text('New Report'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Education',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildEducationCard(
                  'Water Safety',
                  'Learn about water purification methods',
                  Icons.water_drop,
                  Colors.blue,
                ),
                _buildEducationCard(
                  'Disease Prevention',
                  'Prevent water-borne diseases',
                  Icons.health_and_safety,
                  Colors.green,
                ),
                _buildEducationCard(
                  'Emergency Response',
                  'Handle health emergencies',
                  Icons.emergency,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Sync',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Column(
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.cloud_sync,
                          size: 64,
                          color: Colors.blue,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Sync Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('All data synced successfully'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Sync',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('2 reports pending sync'),
                        Text('Last sync: 2 hours ago'),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Handle sync
                    },
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                const Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text('Meera Devi'),
                    subtitle: Text('ASHA Worker'),
                    trailing: Icon(Icons.edit),
                  ),
                ),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.location_on),
                    title: Text('Location'),
                    subtitle: Text('Mawryngkneng, East Khasi Hills'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Settings'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: null,
                  ),
                ),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    trailing: Icon(Icons.arrow_forward_ios),
                    onTap: null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String location,
    String severity,
    String time,
    Color severityColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 8,
          height: 40,
          decoration: BoxDecoration(
            color: severityColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(location),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildEducationCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
