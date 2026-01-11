import 'package:flutter/material.dart';

import '../../../core/services/ai_analytics_service.dart';
import '../../../core/models/health_report_model.dart';
import '../widgets/action_plan_widget.dart';
import '../widgets/ai_chat_widget.dart';

class AiCopilotScreen extends StatefulWidget {
  const AiCopilotScreen({super.key});

  @override
  State<AiCopilotScreen> createState() => _AiCopilotScreenState();
}

class _AiCopilotScreenState extends State<AiCopilotScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isGeneratingPlan = false;
  Map<String, dynamic>? _actionPlan;
  List<Map<String, dynamic>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeChat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeChat() {
    _chatHistory = [
      {
        'type': 'ai',
        'message': 'Hello! I\'m your AI Co-pilot. I can help you analyze health data, generate action plans, and provide insights. What would you like to know?',
        'timestamp': DateTime.now(),
      },
    ];
  }

  Future<void> _generateActionPlan() async {
    setState(() {
      _isGeneratingPlan = true;
    });

    try {
      // Mock data for demonstration
      final mockReports = [
        HealthReport(
          id: '1',
          userId: 'user1',
          reporterName: 'ASHA Worker 1',
          location: 'Shillong, East Khasi Hills',
          latitude: 25.5788,
          longitude: 91.8933,
          description: 'Water contamination detected in village well. Multiple cases of diarrhea reported.',
          symptoms: ['Diarrhea', 'Vomiting'],
          severity: ReportSeverity.high,
          status: ReportStatus.pending,
          reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        HealthReport(
          id: '2',
          userId: 'user2',
          reporterName: 'ASHA Worker 2',
          location: 'Mawryngkneng, East Khasi Hills',
          latitude: 25.5000,
          longitude: 91.8000,
          description: 'Critical water quality issue. Several families affected.',
          symptoms: ['Diarrhea', 'Fever'],
          severity: ReportSeverity.critical,
          status: ReportStatus.pending,
          reportedAt: DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];

      final mockIotData = {
        'water_quality': 'Critical',
        'temperature': 30.5,
        'humidity': 88.2,
        'ph_level': 5.8,
      };

      final actionPlan = await AIAnalyticsService.generateActionPlan(
        'east_khasi_hills',
        mockReports,
        mockIotData,
      );

      setState(() {
        _actionPlan = actionPlan;
        _isGeneratingPlan = false;
      });

      // Add to chat history
      _addChatMessage('ai', 'I\'ve generated an action plan based on the current situation. You can view it in the Action Plan tab.');
    } catch (e) {
      setState(() {
        _isGeneratingPlan = false;
      });
      
      _addChatMessage('ai', 'Sorry, I encountered an error while generating the action plan. Please try again.');
    }
  }

  void _addChatMessage(String type, String message) {
    setState(() {
      _chatHistory.add({
        'type': type,
        'message': message,
        'timestamp': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Co-pilot'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.chat),
              text: 'Chat',
            ),
            Tab(
              icon: Icon(Icons.assignment),
              text: 'Action Plan',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildActionPlanTab(),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        // Situation Summary
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Current Situation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'High risk detected in East Khasi Hills\n23 active reports\nWater contamination issues\n3 critical cases requiring immediate attention',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingPlan ? null : _generateActionPlan,
                  icon: _isGeneratingPlan
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isGeneratingPlan ? 'Generating...' : 'Generate Action Plan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Chat Interface
        Expanded(
          child: AiChatWidget(
            chatHistory: _chatHistory,
            onSendMessage: (message) {
              _addChatMessage('user', message);
              _handleUserMessage(message);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionPlanTab() {
    if (_actionPlan == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Action Plan Generated',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Generate an action plan to see detailed recommendations and resource requirements.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateActionPlan,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Action Plan'),
            ),
          ],
        ),
      );
    }

    return ActionPlanWidget(actionPlan: _actionPlan!);
  }

  void _handleUserMessage(String message) {
    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      String response = _generateAIResponse(message);
      _addChatMessage('ai', response);
    });
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('risk') || message.contains('situation')) {
      return 'Based on current data, East Khasi Hills shows high risk with 23 active reports. Water contamination is the primary concern affecting multiple villages. I recommend immediate water testing and emergency response deployment.';
    } else if (message.contains('action') || message.contains('plan')) {
      return 'I can generate a comprehensive action plan that includes water testing, emergency response, containment measures, and public awareness campaigns. Would you like me to create one?';
    } else if (message.contains('resources') || message.contains('supplies')) {
      return 'Current resource status: 15 water testing kits available, 8 health workers on standby, 3 vehicles ready. Estimated additional needs: 20 more testing kits, 5 additional health workers, 2 more vehicles for emergency response.';
    } else if (message.contains('timeline') || message.contains('time')) {
      return 'Recommended timeline: Water testing within 2 hours, emergency response deployment within 4 hours, containment measures within 6 hours, public awareness campaign within 8 hours. Total estimated duration: 24-48 hours for full response.';
    } else if (message.contains('outbreak') || message.contains('disease')) {
      return 'Outbreak probability is currently at 65% based on symptom patterns and environmental conditions. Primary concerns: Gastroenteritis and potential Typhoid cases. Prevention measures should focus on water purification and hygiene education.';
    } else {
      return 'I understand you\'re asking about "$userMessage". I can help you with risk analysis, action planning, resource management, and outbreak prediction. What specific aspect would you like me to focus on?';
    }
  }
}
