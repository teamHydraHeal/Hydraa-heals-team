import 'package:flutter/material.dart';

class EmergencyEscalationScreen extends StatefulWidget {
  const EmergencyEscalationScreen({super.key});

  @override
  State<EmergencyEscalationScreen> createState() => _EmergencyEscalationScreenState();
}

class _EmergencyEscalationScreenState extends State<EmergencyEscalationScreen> {
  String _selectedEmergencyType = 'Disease Outbreak';
  String _selectedDistrict = 'East Khasi Hills';
  String _selectedSeverity = 'Critical';
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isEscalating = false;

  final List<String> _emergencyTypes = [
    'Disease Outbreak',
    'Water Contamination',
    'Environmental Hazard',
    'Mass Casualty',
    'Natural Disaster',
    'Other',
  ];

  final List<String> _districts = [
    'East Khasi Hills',
    'West Khasi Hills',
    'Ri Bhoi',
    'Jaintia Hills',
    'Garo Hills',
  ];

  final List<String> _severityLevels = [
    'High',
    'Critical',
    'Emergency',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Escalation'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Alert Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha:0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMERGENCY ESCALATION',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          'This will notify state emergency services and trigger immediate response protocols.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Emergency Type Selection
            const Text(
              'Emergency Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedEmergencyType,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.emergency),
              ),
              items: _emergencyTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEmergencyType = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // District Selection
            const Text(
              'Affected District',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDistrict,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              items: _districts.map((district) {
                return DropdownMenuItem<String>(
                  value: district,
                  child: Text(district),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDistrict = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Severity Level
            const Text(
              'Severity Level',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSeverity,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.priority_high),
              ),
              items: _severityLevels.map((severity) {
                return DropdownMenuItem<String>(
                  value: severity,
                  child: Text(severity),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeverity = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Location Details
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Specific Location',
                hintText: 'Enter the specific location or area affected',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Emergency Description',
                hintText: 'Provide detailed description of the emergency situation',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
            
            const SizedBox(height: 24),
            
            // Emergency Contacts
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.phone, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem('State Emergency Services', '108'),
                  _buildContactItem('Health Helpline', '104'),
                  _buildContactItem('District Health Officer', '+91-XXXX-XXXXXX'),
                  _buildContactItem('State Health Department', '+91-XXXX-XXXXXX'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Escalation Protocol
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha:0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Escalation Protocol',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProtocolStep('1', 'Immediate notification to state emergency services'),
                  _buildProtocolStep('2', 'Activation of district emergency response team'),
                  _buildProtocolStep('3', 'Deployment of medical and support personnel'),
                  _buildProtocolStep('4', 'Coordination with local authorities and NGOs'),
                  _buildProtocolStep('5', 'Public announcement and safety measures'),
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
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isEscalating ? null : _escalateEmergency,
                    icon: _isEscalating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.emergency),
                    label: Text(_isEscalating ? 'Escalating...' : 'Escalate Emergency'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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

  Widget _buildContactItem(String name, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            number,
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              // Make call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling $number...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.phone, color: Colors.blue),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _escalateEmergency() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a description of the emergency'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isEscalating = true;
    });

    try {
      // Simulate escalation process
      await Future.delayed(const Duration(seconds: 3));

      // Show confirmation dialog
      _showEscalationConfirmation();
    } catch (e) {
      setState(() {
        _isEscalating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Escalation failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEscalationConfirmation() {
    setState(() {
      _isEscalating = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Emergency Escalated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Emergency has been successfully escalated to state authorities.'),
            const SizedBox(height: 16),
            const Text(
              'Response Actions Initiated:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• State emergency services notified'),
            const Text('• District response team activated'),
            const Text('• Medical personnel deployed'),
            const Text('• Public safety measures implemented'),
            const SizedBox(height: 16),
            Text(
              'Emergency ID: EMG-${DateTime.now().millisecondsSinceEpoch}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
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
}
