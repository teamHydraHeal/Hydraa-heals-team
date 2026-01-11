import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/notification_provider.dart';
import '../../../core/models/notification_model.dart';

class RiskSummaryWidget extends StatelessWidget {
  const RiskSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        // Mock data - in real app, this would come from a provider
        final riskStats = {
          'critical': 1,
          'high': 1,
          'medium': 2,
          'low': 1,
        };

        final urgentNotifications = notificationProvider.getUrgentNotifications();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Risk Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  if (urgentNotifications.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${urgentNotifications.length} Alert${urgentNotifications.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildRiskItem(
                      'Critical',
                      riskStats['critical']!,
                      Colors.purple,
                      Icons.dangerous,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRiskItem(
                      'High',
                      riskStats['high']!,
                      Colors.red,
                      Icons.warning,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildRiskItem(
                      'Medium',
                      riskStats['medium']!,
                      Colors.orange,
                      Icons.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRiskItem(
                      'Low',
                      riskStats['low']!,
                      Colors.green,
                      Icons.check_circle,
                    ),
                  ),
                ],
              ),
              if (urgentNotifications.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Recent Alerts',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                ...urgentNotifications.take(2).map((notification) => 
                  _buildAlertItem(notification)
                ).toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiskItem(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  '$count District${count != 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(AppNotification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isEmergency 
            ? Colors.red.withValues(alpha:0.1)
            : Colors.orange.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: notification.isEmergency 
              ? Colors.red.withValues(alpha:0.3)
              : Colors.orange.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            notification.isEmergency ? Icons.emergency : Icons.warning,
            color: notification.isEmergency ? Colors.red : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: notification.isEmergency ? Colors.red : Colors.orange,
                  ),
                ),
                Text(
                  notification.body,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
