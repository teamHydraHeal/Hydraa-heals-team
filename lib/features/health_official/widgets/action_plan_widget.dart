import 'package:flutter/material.dart';

class ActionPlanWidget extends StatefulWidget {
  final Map<String, dynamic> actionPlan;

  const ActionPlanWidget({
    super.key,
    required this.actionPlan,
  });

  @override
  State<ActionPlanWidget> createState() => _ActionPlanWidgetState();
}

class _ActionPlanWidgetState extends State<ActionPlanWidget> {

  @override
  Widget build(BuildContext context) {
    final situationAnalysis =
        widget.actionPlan['situation_analysis'] as Map<String, dynamic>? ?? {};
    final actionItems =
        widget.actionPlan['action_items'] as List<dynamic>? ?? [];
    final resourceRequirements =
        widget.actionPlan['resource_requirements'] as Map<String, dynamic>? ??
            {};
    final timeline = widget.actionPlan['timeline'] as List<dynamic>? ?? [];
    final successProbability =
        widget.actionPlan['success_probability'] as double? ?? 0.0;
    final mlPrediction =
        widget.actionPlan['ml_prediction'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ML Prediction Alert (if available)
          if (mlPrediction != null) _buildMlAlert(mlPrediction),
          if (mlPrediction != null) const SizedBox(height: 24),

          // Quick Summary Row
          _buildQuickSummary(situationAnalysis, successProbability),
          const SizedBox(height: 24),

          // Action Steps (simplified)
          _buildActionSteps(actionItems),
          const SizedBox(height: 24),

          // Resources Needed
          _buildResourcesNeeded(resourceRequirements),
          const SizedBox(height: 24),

          // Timeline
          _buildTimeline(timeline),
          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ===== ML PREDICTION ALERT =====
  Widget _buildMlAlert(Map<String, dynamic> prediction) {
    final status = (prediction['status'] as String? ?? 'UNKNOWN').toUpperCase();
    final totalRisk = (prediction['total_risk'] as num?)?.toDouble() ?? 0.0;
    final advisory = prediction['advisory'] as String? ?? '';

    Color alertColor;
    IconData alertIcon;
    String alertTitle;

    switch (status) {
      case 'RED':
        alertColor = const Color(0xFFD32F2F);
        alertIcon = Icons.error;
        alertTitle = 'HIGH RISK';
        break;
      case 'YELLOW':
        alertColor = const Color(0xFFF57C00);
        alertIcon = Icons.warning_amber_rounded;
        alertTitle = 'MODERATE RISK';
        break;
      case 'GREEN':
        alertColor = const Color(0xFF388E3C);
        alertIcon = Icons.check_circle;
        alertTitle = 'LOW RISK';
        break;
      default:
        alertColor = Colors.grey;
        alertIcon = Icons.help_outline;
        alertTitle = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: alertColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(alertIcon, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ML PREDICTION',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      alertTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(totalRisk * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (advisory.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              advisory,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ===== QUICK SUMMARY =====
  Widget _buildQuickSummary(Map<String, dynamic> situation, double probability) {
    final totalReports = situation['total_reports'] ?? 0;
    final criticalReports = situation['critical_reports'] ?? 0;
    final waterIssue = situation['water_quality_issue'] == true;
    final outbreakRisk = situation['outbreak_risk'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SITUATION OVERVIEW',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildSummaryCard(
              icon: Icons.article,
              label: 'Total\nReports',
              value: '$totalReports',
              color: Colors.blue,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              icon: Icons.priority_high,
              label: 'Critical\nCases',
              value: '$criticalReports',
              color: criticalReports > 0 ? Colors.red : Colors.grey,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              icon: Icons.water_drop,
              label: 'Water\nQuality',
              value: waterIssue ? 'BAD' : 'OK',
              color: waterIssue ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 12),
            _buildSummaryCard(
              icon: Icons.trending_up,
              label: 'Success\nChance',
              value: '${(probability * 100).round()}%',
              color: probability > 0.6 ? Colors.green : Colors.orange,
            ),
          ],
        ),
        if (outbreakRisk) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'OUTBREAK RISK DETECTED',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[400],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== ACTION STEPS =====
  Widget _buildActionSteps(List<dynamic> actionItems) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ACTION STEPS',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Colors.grey,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${actionItems.length} tasks',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...actionItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildActionStep(index + 1, item);
        }),
      ],
    );
  }

  Widget _buildActionStep(int stepNumber, dynamic item) {
    final priority = (item['priority'] as String? ?? 'medium').toLowerCase();
    final title = item['title'] as String? ?? 'Unknown Action';
    final description = item['description'] as String? ?? '';
    final duration = item['estimated_duration'] as String? ?? '';

    Color priorityColor;
    switch (priority) {
      case 'critical':
        priorityColor = Colors.red;
        break;
      case 'high':
        priorityColor = Colors.orange;
        break;
      default:
        priorityColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priorityColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with step number and priority
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: priorityColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    priority.toUpperCase(),
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Description
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[300],
                    height: 1.5,
                  ),
                ),
                if (duration.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 18, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        'Duration: $duration',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== RESOURCES NEEDED =====
  Widget _buildResourcesNeeded(Map<String, dynamic> requirements) {
    final cost = requirements['total_estimated_cost'] as int? ?? 0;
    final personnel = requirements['personnel_required'] ?? 0;
    final duration = requirements['estimated_duration'] as String? ?? 'Unknown';
    final equipment = requirements['equipment_needed'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RESOURCES NEEDED',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        
        // Key metrics row
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildResourceMetric(
                  Icons.currency_rupee,
                  'Budget',
                  '₹${_formatNumber(cost)}',
                  Colors.amber,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[700],
              ),
              Expanded(
                child: _buildResourceMetric(
                  Icons.people,
                  'Team Size',
                  '$personnel',
                  Colors.blue,
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.grey[700],
              ),
              Expanded(
                child: _buildResourceMetric(
                  Icons.schedule,
                  'Duration',
                  duration,
                  Colors.green,
                ),
              ),
            ],
          ),
        ),
        
        // Equipment list
        if (equipment.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.inventory_2, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Equipment Checklist',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[300],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...equipment.entries.map((e) => _buildEquipmentItem(e.key, e.value)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResourceMetric(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentItem(String name, dynamic quantity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[300],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'x$quantity',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== TIMELINE =====
  Widget _buildTimeline(List<dynamic> timeline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIMELINE',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: timeline.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == timeline.length - 1;
              return _buildTimelineItem(item, isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem(dynamic item, bool isLast) {
    final time = item['time'] as String? ?? '';
    final action = item['action'] as String? ?? 'Unknown';
    final duration = item['duration'] as String? ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2A2A2A), width: 3),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: Colors.green.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (time.isNotEmpty)
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[300],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  action,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                if (duration.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== ACTION BUTTONS =====
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Action plan approved and sent to teams'),
                  backgroundColor: Color(0xFF388E3C),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF388E3C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: 20),
                SizedBox(width: 8),
                Text(
                  'APPROVE PLAN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening plan editor...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[300],
              side: BorderSide(color: Colors.grey[600]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text(
                  'MODIFY PLAN',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 100000) {
      return '${(number / 100000).toStringAsFixed(1)}L';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
