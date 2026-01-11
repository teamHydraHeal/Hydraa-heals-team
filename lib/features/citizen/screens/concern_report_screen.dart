import 'package:flutter/material.dart';

import '../../../core/services/offline_service.dart';
import '../../../core/services/security_service.dart';
import '../../../core/models/health_report_model.dart';

class ConcernReportScreen extends StatefulWidget {
  const ConcernReportScreen({super.key});

  @override
  State<ConcernReportScreen> createState() => _ConcernReportScreenState();
}

class _ConcernReportScreenState extends State<ConcernReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactController = TextEditingController();
  
  String _selectedIssueType = 'Water Quality Issue';
  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'Water Quality Issue',
    'Disease Outbreak',
    'Environmental Hazard',
    'General Health Concern',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submitConcern() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Create the health report
      final report = HealthReport(
        id: SecurityService.generateSecureRandomString(16),
        userId: 'current_user', // In real app, get from auth provider
        reporterName: 'Citizen Report', // In real app, get from user profile
        location: _locationController.text.trim(),
        latitude: 25.5788, // In real app, get from GPS
        longitude: 91.8933,
        description: '${_selectedIssueType}: ${_descriptionController.text.trim()}',
        symptoms: [], // Citizens may not know specific symptoms
        severity: _getSeverityFromIssueType(_selectedIssueType),
        status: ReportStatus.pending,
        reportedAt: DateTime.now(),
        isOffline: true, // Assume offline for demo
        isSynced: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to offline storage
      await OfflineService.saveHealthReport(report);
      
      // Log security event
      await SecurityService.logSecurityEvent(
        'citizen_concern_submitted',
        'current_user',
        metadata: {
          'reportId': report.id,
          'issueType': _selectedIssueType,
          'severity': report.severity.toString(),
        },
      );

      setState(() {
        _isSubmitting = false;
      });

      // Show success message
      _showSuccessDialog();
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit concern: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  ReportSeverity _getSeverityFromIssueType(String issueType) {
    switch (issueType) {
      case 'Water Quality Issue':
        return ReportSeverity.medium;
      case 'Disease Outbreak':
        return ReportSeverity.high;
      case 'Environmental Hazard':
        return ReportSeverity.high;
      case 'General Health Concern':
        return ReportSeverity.low;
      default:
        return ReportSeverity.medium;
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Report Submitted'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thank you for reporting your health concern.'),
            SizedBox(height: 16),
            Text(
              'What happens next:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Your report will be reviewed by health officials'),
            Text('• You may receive updates via notifications'),
            Text('• Health teams will investigate if needed'),
            Text('• Community alerts will be sent if necessary'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Health Concern'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Issue Type Selection
              const Text(
                'What type of health concern are you reporting?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              ..._issueTypes.map((issueType) {
                return RadioListTile<String>(
                  title: Text(issueType),
                  value: issueType,
                  groupValue: _selectedIssueType,
                  onChanged: (value) {
                    setState(() {
                      _selectedIssueType = value!;
                    });
                  },
                );
              }).toList(),
              
              const SizedBox(height: 24),
              
              // Description Field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Describe the issue',
                  hintText: 'Please provide as much detail as possible about the health concern',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the health concern';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Where did you observe this issue?',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Contact Information
              TextFormField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact Information (Optional)',
                  hintText: 'Phone number or email for follow-up',
                  prefixIcon: Icon(Icons.contact_phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!SecurityService.validatePhoneNumber(value.trim())) {
                      return 'Please enter a valid phone number';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Information Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Important Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Your report will be reviewed by health officials\n'
                      '• You may be contacted for additional information\n'
                      '• All reports are confidential and secure\n'
                      '• False reports may result in legal action',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitConcern,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isSubmitting ? 'Submitting...' : 'Submit Concern'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Emergency Contact
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.withValues(alpha:0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.emergency, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Emergency Contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'For immediate medical emergencies, please contact:\n'
                      '• Emergency Services: 108\n'
                      '• Health Helpline: 104\n'
                      '• Local Hospital: [Hospital Number]',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
