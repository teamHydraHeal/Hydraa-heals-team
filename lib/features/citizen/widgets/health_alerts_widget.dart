import 'package:flutter/material.dart';

class HealthAlertsWidget extends StatelessWidget {
  const HealthAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for health alerts
    final alerts = [
      {
        'title': 'Water Quality Good',
        'message': 'Your area water supply is safe for consumption',
        'type': 'info',
        'color': Colors.green,
        'icon': Icons.check_circle,
      },
      {
        'title': 'No Active Outbreaks',
        'message': 'No water-borne disease outbreaks reported in your area',
        'type': 'info',
        'color': Colors.blue,
        'icon': Icons.info,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Health Alerts',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'All Clear',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map((alert) => _buildAlertItem(alert)).toList(),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Navigate to full alerts list
            },
            child: const Text('View All Alerts'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (alert['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (alert['color'] as Color).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            alert['icon'] as IconData,
            color: alert['color'] as Color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: alert['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert['message'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
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
