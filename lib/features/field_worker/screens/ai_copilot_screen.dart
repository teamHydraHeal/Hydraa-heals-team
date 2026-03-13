import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/connectivity_provider.dart';
import '../widgets/field_assistant_widget.dart';
import '../widgets/patient_care_widget.dart';

class FieldWorkerAiCopilotScreen extends StatefulWidget {
  const FieldWorkerAiCopilotScreen({super.key});

  @override
  State<FieldWorkerAiCopilotScreen> createState() => _FieldWorkerAiCopilotScreenState();
}

class _FieldWorkerAiCopilotScreenState extends State<FieldWorkerAiCopilotScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        toolbarHeight: 74,
        titleSpacing: 20,
        title: const Text('Field Assistant'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0E6E63), Color(0xFF2A9D8F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, child) {
              return Container(
                margin: const EdgeInsets.only(right: 12, top: 18, bottom: 18),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      connectivity.isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.assignment),
              text: 'Field Guide',
            ),
            Tab(
              icon: Icon(Icons.assessment),
              text: 'Reporting',
            ),
            Tab(
              icon: Icon(Icons.health_and_safety),
              text: 'Patient Care',
            ),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Field Guide Tab
              const FieldAssistantWidget(),
              // Reporting Guide Tab
              const Center(
                child: Text('Reporting Guide - Coming Soon'),
              ),
              // Patient Care Tab
              const PatientCareWidget(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.quick_contacts_dialer, color: Colors.white),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionItem(
                    context,
                    Icons.description_outlined,
                    'Submit Report',
                    'Quickly submit a health report with AI assistance',
                    () => context.push('/field-worker/report-form'),
                  ),
                  _buildActionItem(
                    context,
                    Icons.badge_outlined,
                    'MCP Card Update',
                    'Update Mother & Child Protection card information',
                    () => context.push('/field-worker/mcp-card'),
                  ),
                  _buildActionItem(
                    context,
                    Icons.health_and_safety_outlined,
                    'Patient Assessment',
                    'Get AI guidance for patient assessment and care',
                    () => _tabController.animateTo(2),
                  ),
                  _buildActionItem(
                    context,
                    Icons.insights_outlined,
                    'Report Analysis',
                    'Analyze health trends and patterns in your area',
                    () => _tabController.animateTo(1),
                  ),
                  _buildActionItem(
                    context,
                    Icons.emergency_outlined,
                    'Emergency Protocol',
                    'Access emergency response procedures and contacts',
                    () => _showEmergencyProtocol(context),
                  ),
                  _buildActionItem(
                    context,
                    Icons.menu_book_outlined,
                    'Training Resources',
                    'Access offline training materials and guidelines',
                    () => context.push('/education'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF0E6E63).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF0E6E63)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  void _showEmergencyProtocol(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Protocol'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For medical emergencies:'),
            SizedBox(height: 8),
            Text('🚨 Call 108 (Ambulance)'),
            Text('🏥 Contact District Health Officer'),
            Text('📞 Notify Health Center'),
            SizedBox(height: 16),
            Text('For water contamination:'),
            SizedBox(height: 8),
            Text('💧 Stop water supply immediately'),
            Text('📢 Alert community members'),
            Text('🧪 Collect water samples'),
            Text('📝 Document incident details'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open emergency contacts
            },
            child: const Text('Emergency Contacts'),
          ),
        ],
      ),
    );
  }
}

