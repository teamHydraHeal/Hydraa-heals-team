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
  Map<String, dynamic>? _actionPlan;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _generateActionPlan() async {
    setState(() => _isGeneratingPlan = true);

    try {
      final mockReports = [
        HealthReport(
          id: '1',
          userId: 'user1',
          reporterName: 'ASHA Worker 1',
          location: 'Shillong, East Khasi Hills',
          latitude: 25.5788,
          longitude: 91.8933,
          description:
              'Water contamination detected in village well. Multiple cases of diarrhea reported.',
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
          description:
              'Critical water quality issue. Several families affected.',
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

      // Try ML prediction from Flask backend
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

      if (mlPrediction != null) {
        actionPlan['ml_prediction'] = mlPrediction;
      }

      setState(() {
        _actionPlan = actionPlan;
        _isGeneratingPlan = false;
      });
    } catch (e) {
      setState(() => _isGeneratingPlan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3142),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'AI Co-pilot',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF667eea),
          indicatorWeight: 3,
          labelColor: const Color(0xFF667eea),
          unselectedLabelColor: Colors.grey.shade400,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_rounded), text: 'Chat'),
            Tab(icon: Icon(Icons.assignment_rounded), text: 'Action Plan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Chat tab — fully powered by Ollama + TTS
          AiChatWidget(actionPlanContext: _actionPlan),
          // Action Plan tab
          _buildActionPlanTab(),
        ],
      ),
    );
  }

  Widget _buildActionPlanTab() {
    if (_actionPlan == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667eea).withValues(alpha: 0.1),
                      const Color(0xFF764ba2).withValues(alpha: 0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: Color(0xFF667eea),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No Action Plan Yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3142),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Generate an AI-powered action plan with ML water quality predictions and health recommendations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isGeneratingPlan ? null : _generateActionPlan,
                  icon: _isGeneratingPlan
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _isGeneratingPlan ? 'Generating...' : 'Generate Action Plan',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ActionPlanWidget(actionPlan: _actionPlan!);
  }
}
