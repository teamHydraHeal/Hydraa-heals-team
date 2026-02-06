import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/models/district_model.dart';
import '../../../core/models/notification_model.dart';
import '../widgets/district_map_widget.dart';
import '../widgets/risk_summary_widget.dart';

class CommandCenterScreen extends StatefulWidget {
  const CommandCenterScreen({super.key});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  
  bool _showRiskPrediction = true;
  
  // Mock data for demonstration
  final List<District> _districts = [
    District(
      id: 'east_khasi_hills',
      name: 'East Khasi Hills',
      state: 'Meghalaya',
      latitude: 25.5788,
      longitude: 91.8933,
      riskLevel: RiskLevel.high,
      riskScore: 7.8,
      population: 825922,
      activeReports: 23,
      criticalReports: 3,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
    District(
      id: 'west_khasi_hills',
      name: 'West Khasi Hills',
      state: 'Meghalaya',
      latitude: 25.5000,
      longitude: 91.3000,
      riskLevel: RiskLevel.medium,
      riskScore: 5.2,
      population: 385601,
      activeReports: 8,
      criticalReports: 1,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    District(
      id: 'ri_bhoi',
      name: 'Ri Bhoi',
      state: 'Meghalaya',
      latitude: 25.9000,
      longitude: 91.8833,
      riskLevel: RiskLevel.critical,
      riskScore: 9.1,
      population: 258380,
      activeReports: 45,
      criticalReports: 12,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    District(
      id: 'jaintia_hills',
      name: 'Jaintia Hills',
      state: 'Meghalaya',
      latitude: 25.3000,
      longitude: 92.2000,
      riskLevel: RiskLevel.low,
      riskScore: 2.1,
      population: 395124,
      activeReports: 2,
      criticalReports: 0,
      lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    District(
      id: 'garo_hills',
      name: 'Garo Hills',
      state: 'Meghalaya',
      latitude: 25.5000,
      longitude: 90.6000,
      riskLevel: RiskLevel.medium,
      riskScore: 4.8,
      population: 317917,
      activeReports: 12,
      criticalReports: 2,
      lastUpdated: DateTime.now().subtract(const Duration(minutes: 45)),
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Initialize animations - removed unused animation fields
    
    // Start animations
    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
    
    _createMockNotifications();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _createMockNotifications() {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    // Create critical alert for Ri Bhoi
    notificationProvider.createHealthAlert(
      title: 'Critical Alert: Ri Bhoi District',
      body: 'High risk of water-borne disease outbreak detected. Immediate action required.',
      districtId: 'ri_bhoi',
      priority: NotificationPriority.urgent,
    );
  }

  void _onDistrictSelected(District district) {
    context.push('/health-official/district/${district.id}');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Command Center'),
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
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => context.push('/notifications'),
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
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
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Collapsible Risk Summary
          ExpansionTile(
            title: const Text(
              'Risk Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            initiallyExpanded: false,
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            childrenPadding: EdgeInsets.zero,
            children: const [
              RiskSummaryWidget(),
            ],
          ),
          
          // Map Layer Toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Layer:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Risk', style: TextStyle(fontSize: 13)),
                        icon: Icon(Icons.analytics, size: 18),
                      ),
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Reports', style: TextStyle(fontSize: 13)),
                        icon: Icon(Icons.report, size: 18),
                      ),
                    ],
                    selected: {_showRiskPrediction},
                    onSelectionChanged: (Set<bool> selection) {
                      setState(() {
                        _showRiskPrediction = selection.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Map Tab
                DistrictMapWidget(
                  districts: _districts,
                  showRiskPrediction: _showRiskPrediction,
                  onDistrictSelected: _onDistrictSelected,
                ),
                
                // Broadcast Tab
                _buildBroadcastTab(),
                
                // Settings Tab
                _buildSettingsTab(),
              ],
            ),
          ),
          
          // Bottom Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(
                  icon: Icon(Icons.map),
                  text: 'Map',
                ),
                Tab(
                  icon: Icon(Icons.broadcast_on_personal),
                  text: 'Broadcast',
                ),
                Tab(
                  icon: Icon(Icons.settings),
                  text: 'Settings',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/health-official/ai-copilot'),
        icon: const Icon(Icons.psychology),
        label: const Text('AI Co-pilot'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBroadcastTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Community Broadcast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red),
                    title: const Text('Emergency Alert'),
                    subtitle: const Text('Send urgent health alerts to affected areas'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/health-official/broadcast'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info, color: Colors.blue),
                    title: const Text('Health Advisory'),
                    subtitle: const Text('Share preventive health information'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/health-official/broadcast'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.campaign, color: Colors.orange),
                    title: const Text('Awareness Campaign'),
                    subtitle: const Text('Launch community health campaigns'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/health-official/broadcast'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Profile'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/profile'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/notifications'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Language'),
                    subtitle: const Text('English'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.push('/settings'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      // Handle logout
                    },
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
