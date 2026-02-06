import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/ai_analytics_service.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/models/notification_model.dart';

class BroadcastScreen extends StatefulWidget {
  const BroadcastScreen({super.key});

  @override
  State<BroadcastScreen> createState() => _BroadcastScreenState();
}

class _BroadcastScreenState extends State<BroadcastScreen> {
  final TextEditingController _topicController = TextEditingController();
  String _selectedLanguage = 'en';
  String _selectedSeverity = 'medium';
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedBroadcast;

  final List<String> _languages = [
    'en',
    'kha',
  ];

  final List<String> _severities = [
    'low',
    'medium',
    'high',
    'critical',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generateBroadcast() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a topic for the broadcast'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final broadcast = await AIAnalyticsService.generateBroadcastMessage(
        topic,
        _selectedLanguage,
        _selectedSeverity,
      );

      setState(() {
        _generatedBroadcast = broadcast;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate broadcast: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _sendBroadcast() async {
    if (_generatedBroadcast == null) return;

    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    // Create notification for the broadcast
    await notificationProvider.createHealthAlert(
      title: 'Community Broadcast',
      body: _generatedBroadcast!['message'] as String? ?? 'Health alert broadcast',
      districtId: 'all',
      priority: _selectedSeverity == 'critical' 
          ? NotificationPriority.urgent 
          : NotificationPriority.high,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Broadcast sent successfully to all users'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Broadcast'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Section
            _buildInputSection(),
            
            const SizedBox(height: 24),
            
            // Generated Broadcast Section
            if (_generatedBroadcast != null) _buildGeneratedBroadcastSection(),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Broadcast Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Topic Input
            TextFormField(
              controller: _topicController,
              decoration: const InputDecoration(
                labelText: 'Broadcast Topic',
                hintText: 'e.g., Water contamination, Disease outbreak, Health tips',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            
            const SizedBox(height: 16),
            
            // Language Selection
            Row(
              children: [
                const Expanded(
                  child: Text('Language:'),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _languages.map((lang) {
                      return DropdownMenuItem<String>(
                        value: lang,
                        child: Text(_getLanguageName(lang)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Severity Selection
            Row(
              children: [
                const Expanded(
                  child: Text('Severity:'),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSeverity,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: _severities.map((severity) {
                      return DropdownMenuItem<String>(
                        value: severity,
                        child: Text(severity.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSeverity = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Generate Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateBroadcast,
                icon: _isGenerating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(_isGenerating ? 'Generating...' : 'Generate Broadcast'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratedBroadcastSection() {
    final message = _generatedBroadcast!['message'] as String? ?? '';
    final translations = _generatedBroadcast!['translations'] as Map<String, dynamic>? ?? {};
    final reachEstimate = _generatedBroadcast!['reach_estimate'] as int? ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.broadcast_on_personal, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Generated Broadcast',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Main Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getSeverityColor(_selectedSeverity).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getSeverityColor(_selectedSeverity).withValues(alpha:0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getSeverityIcon(_selectedSeverity),
                        color: _getSeverityColor(_selectedSeverity),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_getLanguageName(_selectedLanguage)} Message',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _getSeverityColor(_selectedSeverity),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Translations
            if (translations.isNotEmpty) ...[
              const Text(
                'Translations:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...translations.entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getLanguageName(entry.key),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              )).toList(),
            ],
            
            const SizedBox(height: 16),
            
            // Broadcast Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Estimated Reach',
                    '$reachEstimate users',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Priority',
                    _selectedSeverity.toUpperCase(),
                    _getSeverityIcon(_selectedSeverity),
                    _getSeverityColor(_selectedSeverity),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _generatedBroadcast == null ? null : () {
              // Preview broadcast
              _showPreviewDialog();
            },
            icon: const Icon(Icons.preview),
            label: const Text('Preview'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generatedBroadcast == null ? null : _sendBroadcast,
            icon: const Icon(Icons.send),
            label: const Text('Send Broadcast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha:0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog() {
    if (_generatedBroadcast == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Broadcast Preview'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _generatedBroadcast!['message'] as String? ?? '',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'This message will be sent to all users in the affected areas.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendBroadcast();
            },
            child: const Text('Send Now'),
          ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'kha':
        return 'Khasi';
      default:
        return code.toUpperCase();
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.dangerous;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.check_circle;
      default:
        return Icons.info;
    }
  }
}
