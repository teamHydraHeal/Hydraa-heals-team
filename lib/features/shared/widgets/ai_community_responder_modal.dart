import 'package:flutter/material.dart';

class AiCommunityResponderModal extends StatelessWidget {
  final String reportId;
  final String reportType;
  final String location;
  final VoidCallback? onClose;

  const AiCommunityResponderModal({
    super.key,
    required this.reportId,
    required this.reportType,
    required this.location,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Report Submitted Successfully!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Report ID: $reportId',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // AI Response
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'AI Community Response',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getAiResponse(reportType, location),
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Next Steps
            const Text(
              'What happens next?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildNextStep(
              Icons.visibility,
              'Review',
              'Health officials will review your report within 24 hours',
            ),
            
            _buildNextStep(
              Icons.analytics,
              'Analysis',
              'AI will analyze the data and provide insights to health teams',
            ),
            
            _buildNextStep(
              Icons.notifications,
              'Updates',
              'You\'ll receive notifications about any actions taken',
            ),
            
            const SizedBox(height: 24),
            
            // Educational Links
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.school, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Learn More',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildEducationalLink(
                    'Water Safety Guidelines',
                    'Learn how to keep your water safe',
                    Icons.water_drop,
                  ),
                  _buildEducationalLink(
                    'Disease Prevention Tips',
                    'Simple steps to prevent water-borne diseases',
                    Icons.health_and_safety,
                  ),
                  _buildEducationalLink(
                    'Emergency Contacts',
                    'Important numbers for health emergencies',
                    Icons.emergency,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Navigate to educational content
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening educational content...'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.school),
                    label: const Text('Learn More'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      onClose?.call();
                    },
                    icon: const Icon(Icons.done),
                    label: const Text('Got it'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextStep(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Colors.blue,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalLink(String title, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          // Navigate to specific educational content
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: Colors.orange, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _getAiResponse(String reportType, String location) {
    switch (reportType.toLowerCase()) {
      case 'water quality issue':
        return 'Thank you for reporting this water quality concern in $location. Our AI system has analyzed your report and identified this as a priority issue. Health officials will investigate within 24 hours. In the meantime, please avoid using the affected water source and use alternative safe water sources.';
      
      case 'disease outbreak':
        return 'Your report about potential disease outbreak in $location has been received and flagged as high priority. Our AI analysis suggests immediate investigation is needed. Health teams will be deployed to assess the situation and implement containment measures. Please follow any health advisories issued.';
      
      case 'environmental hazard':
        return 'Thank you for reporting this environmental hazard in $location. The AI system has categorized this as a medium priority issue. Environmental health teams will investigate and take appropriate action. Please avoid the affected area until further notice.';
      
      case 'general health concern':
        return 'Your health concern for $location has been noted and will be reviewed by health officials. While this may not require immediate action, it contributes valuable information to our community health monitoring system. You will be updated on any follow-up actions.';
      
      default:
        return 'Thank you for your report about $location. Our AI system has received and processed your submission. Health officials will review the information and take appropriate action based on the severity and type of concern reported.';
    }
  }

  static void show({
    required BuildContext context,
    required String reportId,
    required String reportType,
    required String location,
    VoidCallback? onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AiCommunityResponderModal(
        reportId: reportId,
        reportType: reportType,
        location: location,
        onClose: onClose,
      ),
    );
  }
}
