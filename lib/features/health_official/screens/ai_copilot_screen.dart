import 'package:flutter/material.dart';

import '../../../core/services/ai_analytics_service.dart';
import '../../../core/services/ml_prediction_service.dart';
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
  bool _mlBackendAvailable = false;
  Map<String, dynamic>? _actionPlan;
  List<Map<String, dynamic>> _chatHistory = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeChat();
    _checkMlBackend();
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

  Future<void> _checkMlBackend() async {
    final available = await MlPredictionService.isBackendAvailable();
    if (mounted) {
      setState(() => _mlBackendAvailable = available);
      if (available) {
        _addChatMessage('ai', '🟢 ML backend is online. The trained RandomForest model is ready for predictions.');
      }
    }
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

      // Try to get ML prediction from the Flask backend
      Map<String, dynamic>? mlPrediction;
      try {
        mlPrediction = await MlPredictionService.predict(
          ph: 5.8,
          turbidity: 12.0,
          orp: 220.0,
          rainfall: 25.0,
          diarrhea: 3,
          vomiting: 2,
          fever: 1,
        );
      } catch (e) {
        debugPrint('ML prediction failed: $e');
      }

      // Attach ML prediction to the action plan if available
      if (mlPrediction != null) {
        actionPlan['ml_prediction'] = mlPrediction;
      }

      setState(() {
        _actionPlan = actionPlan;
        _isGeneratingPlan = false;
      });

      // Add to chat history
      if (mlPrediction != null) {
        final status = mlPrediction['status'] ?? 'UNKNOWN';
        final risk = ((mlPrediction['total_risk'] as num?)?.toDouble() ?? 0.0) * 100;
        _addChatMessage('ai', 'Action plan generated with ML prediction.\n\n'
            '🤖 ML Status: $status\n'
            '📊 Risk Score: ${risk.toStringAsFixed(0)}%\n'
            '💡 Advisory: ${mlPrediction['advisory'] ?? 'N/A'}\n\n'
            'View the full plan in the Action Plan tab.');
      } else {
        _addChatMessage('ai', 'I\'ve generated an action plan based on the current situation. View it in the Action Plan tab.\n\nNote: ML backend is offline — using rule-based analysis only. Start the Flask backend for ML predictions.');
      }
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
    // Check if user is sending data for ML prediction
    final lowerMsg = message.toLowerCase();
    if (lowerMsg.contains('predict') || lowerMsg.contains('analyze water') || lowerMsg.contains('test water')) {
      _handleMlQuery(message);
      return;
    }
    
    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      String response = _generateAIResponse(message);
      _addChatMessage('ai', response);
    });
  }

  Future<void> _handleMlQuery(String message) async {
    _addChatMessage('ai', 'Running ML prediction on the backend...');
    
    final prediction = await MlPredictionService.predictFromText(message);
    
    if (prediction != null) {
      final status = prediction['status'] ?? 'UNKNOWN';
      final risk = ((prediction['total_risk'] as num?)?.toDouble() ?? 0.0) * 100;
      _addChatMessage('ai',
          '\ud83e\udd16 ML Prediction Results:\n\n'
          'Status: $status\n'
          'Risk Score: ${risk.toStringAsFixed(0)}%\n'
          'Rule Engine: ${prediction['rule_status']}\n'
          'ML Model: ${prediction['ml_status']}\n\n'
          '\ud83d\udca1 Advisory: ${prediction['advisory']}\n\n'
          'Processed data: ${prediction['processed_data']}');
    } else {
      _addChatMessage('ai',
          'Could not reach the ML backend. Make sure the Flask server is running:\n\n'
          'cd jal-ML && python backend.py');
    }
  }

  String _generateAIResponse(String userMessage) {
    final message = userMessage.toLowerCase().trim();
    
    // Greetings
    if (RegExp(r'^(hi|hello|hey|greetings|good morning|good afternoon|good evening)[\s!.?]*$').hasMatch(message)) {
      return 'Hello! I\'m your JalGuard AI assistant. I can help you with:\n\n'
          '• Risk analysis for water contamination\n'
          '• Generate action plans\n'
          '• Resource management\n'
          '• Outbreak prediction\n'
          '• ML-powered water quality analysis (type "predict")\n\n'
          'How can I assist you today?';
    }
    
    // Help/What can you do
    if (message.contains('help') || message.contains('what can you do') || message.contains('capabilities')) {
      return 'I can assist you with:\n\n'
          '1. **Risk Analysis** - Type "risk" or "situation"\n'
          '2. **Action Plans** - Type "action plan" or click Generate\n'
          '3. **Resource Status** - Type "resources" or "supplies"\n'
          '4. **Timeline** - Type "timeline"\n'
          '5. **ML Prediction** - Type "predict" for real-time water quality analysis\n'
          '6. **Outbreak Info** - Type "outbreak" or "disease"\n\n'
          'What would you like to know?';
    }
    
    // Thanks
    if (message.contains('thank') || message.contains('thanks')) {
      return 'You\'re welcome! Let me know if you need anything else regarding water quality monitoring or health response.';
    }
    
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
      return 'I can help you with that! Here are some things you can ask me:\n\n'
          '• "What\'s the current risk situation?"\n'
          '• "Generate an action plan"\n'
          '• "What resources do we have?"\n'
          '• "predict" - to run ML water quality analysis\n'
          '• "help" - to see all my capabilities\n\n'
          'What would you like to know?';
    }
  }
}
