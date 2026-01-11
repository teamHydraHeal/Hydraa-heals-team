import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/connectivity_provider.dart';
import '../widgets/ai_health_advisor_widget.dart';
import '../widgets/community_support_widget.dart';
import '../widgets/health_tips_widget.dart';

class CitizenAiCopilotScreen extends StatefulWidget {
  const CitizenAiCopilotScreen({super.key});

  @override
  State<CitizenAiCopilotScreen> createState() => _CitizenAiCopilotScreenState();
}

class _CitizenAiCopilotScreenState extends State<CitizenAiCopilotScreen>
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
      appBar: AppBar(
        title: const Text('AI Health Assistant'),
        actions: [
          Consumer<ConnectivityProvider>(
            builder: (context, connectivity, child) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(
                  connectivity.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.psychology_alt),
              text: 'Health Guide',
            ),
            Tab(
              icon: Icon(Icons.people),
              text: 'Community',
            ),
            Tab(
              icon: Icon(Icons.lightbulb),
              text: 'Tips',
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
              // Health Guide Tab
              const AiHealthAdvisorWidget(),
              // Community Support Tab
              const CommunitySupportWidget(),
              // Health Tips Tab
              const HealthTipsWidget(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickHelp(context),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.help_outline, color: Colors.white),
      ),
    );
  }

  void _showQuickHelp(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                    'Quick Help',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildHelpItem(
                    context,
                    '💧 Water Safety',
                    'Get instant advice on water quality and safety measures',
                    () => _tabController.animateTo(0),
                  ),
                  _buildHelpItem(
                    context,
                    '🏥 Health Symptoms',
                    'Describe symptoms and get preliminary health guidance',
                    () => _tabController.animateTo(0),
                  ),
                  _buildHelpItem(
                    context,
                    '👥 Community Support',
                    'Connect with local health workers and community members',
                    () => _tabController.animateTo(1),
                  ),
                  _buildHelpItem(
                    context,
                    '📚 Health Education',
                    'Access offline health tips and preventive measures',
                    () => _tabController.animateTo(2),
                  ),
                  _buildHelpItem(
                    context,
                    '🚨 Emergency Help',
                    'Get immediate guidance for health emergencies',
                    () => _showEmergencyHelp(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.arrow_forward_ios, size: 16),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(description),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
      ),
    );
  }

  void _showEmergencyHelp(BuildContext context) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Help'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For immediate medical emergencies:'),
            SizedBox(height: 8),
            Text('🚨 Call 108 (Ambulance)'),
            Text('🏥 Call 102 (Health Helpline)'),
            Text('👨‍⚕️ Contact Local Health Center'),
            SizedBox(height: 16),
            Text('AI can provide preliminary guidance, but always consult healthcare professionals for serious conditions.'),
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
              // In a real app, this would open the phone dialer
            },
            child: const Text('Call 108'),
          ),
        ],
      ),
    );
  }
}

