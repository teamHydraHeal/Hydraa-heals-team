import 'package:flutter/material.dart';

import '../../../core/models/health_report_model.dart';

class ReportAnalysisModal extends StatelessWidget {
  final HealthReport report;

  const ReportAnalysisModal({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.analytics,
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
                          'AI Report Analysis',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Report ID: ${report.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report Overview
                    _buildSection(context,
                      'Report Overview',
                      Icons.description,
                      [
                        _buildInfoRow('Reporter', report.reporterName),
                        _buildInfoRow('Location', report.location),
                        _buildInfoRow('Severity', _getSeverityText(report.severity)),
                        _buildInfoRow('Status', _getStatusText(report.status)),
                        _buildInfoRow('Reported At', _formatDateTime(report.reportedAt)),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Original Report Text
                    _buildSection(context,
                      'Original Report',
                      Icons.article,
                      [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            report.description,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // AI Analysis
                    if (report.aiAnalysis != null) ...[
                      _buildSection(context,
                        'AI Analysis',
                        Icons.psychology,
                        [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
                            ),
                            child: Text(
                              report.aiAnalysis!,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Triage Response
                    if (report.triageResponse != null) ...[
                      _buildSection(context,
                        'Triage Response',
                        Icons.medical_services,
                        [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(report.severity).withValues(alpha:0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getSeverityColor(report.severity).withValues(alpha:0.3),
                              ),
                            ),
                            child: Text(
                              report.triageResponse!,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: _getSeverityColor(report.severity),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                    
                    // Extracted Entities
                    _buildSection(context,
                      'Extracted Information',
                      Icons.highlight,
                      [
                        _buildEntityCard('Symptoms', report.symptoms, Icons.health_and_safety, Colors.red),
                        if (report.photoUrls.isNotEmpty)
                          _buildEntityCard('Photos', report.photoUrls, Icons.photo, Colors.blue),
                        _buildEntityCard('Location Data', [
                          'Latitude: ${report.latitude}',
                          'Longitude: ${report.longitude}',
                        ], Icons.location_on, Colors.green),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Structured JSON Summary
                    _buildSection(context,
                      'Structured Data',
                      Icons.code,
                      [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _generateJsonSummary(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // Export report
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Report exported successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Export'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Generate action plan
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Generating action plan...'),
                                  backgroundColor: Colors.blue,
                                ),
                              );
                            },
                            icon: const Icon(Icons.assignment),
                            label: const Text('Action Plan'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntityCard(String title, List<String> items, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text(
              'No data available',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: items.map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
        ],
      ),
    );
  }

  String _getSeverityText(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return 'Low';
      case ReportSeverity.medium:
        return 'Medium';
      case ReportSeverity.high:
        return 'High';
      case ReportSeverity.critical:
        return 'Critical';
    }
  }

  String _getStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.processed:
        return 'Processed';
      case ReportStatus.escalated:
        return 'Escalated';
      case ReportStatus.processing:
        return 'Processing';
    }
  }

  Color _getSeverityColor(ReportSeverity severity) {
    switch (severity) {
      case ReportSeverity.low:
        return Colors.green;
      case ReportSeverity.medium:
        return Colors.orange;
      case ReportSeverity.high:
        return Colors.red;
      case ReportSeverity.critical:
        return Colors.purple;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _generateJsonSummary() {
    return '''
{
  "reportId": "${report.id}",
  "reporter": "${report.reporterName}",
  "location": {
    "name": "${report.location}",
    "coordinates": {
      "latitude": ${report.latitude},
      "longitude": ${report.longitude}
    }
  },
  "severity": "${report.severity.name}",
  "status": "${report.status.name}",
  "symptoms": ${report.symptoms.map((s) => '"$s"').toList()},
  "description": "${report.description}",
  "timestamp": "${report.reportedAt.toIso8601String()}",
  "aiAnalysis": "${report.aiAnalysis ?? 'Not available'}",
  "triageResponse": "${report.triageResponse ?? 'Not available'}",
  "photos": ${report.photoUrls.length},
  "isOffline": ${report.isOffline},
  "isSynced": ${report.isSynced}
}''';
  }

  static void show({
    required BuildContext context,
    required HealthReport report,
  }) {
    showDialog(
      context: context,
      builder: (context) => ReportAnalysisModal(report: report),
    );
  }
}
