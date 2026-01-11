import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/district_model.dart';
import '../../../core/models/health_report_model.dart';
import '../widgets/iot_data_widget.dart';
import '../widgets/reports_list_widget.dart';

class DistrictDetailsScreen extends StatefulWidget {
  final String districtId;

  const DistrictDetailsScreen({
    super.key,
    required this.districtId,
  });

  @override
  State<DistrictDetailsScreen> createState() => _DistrictDetailsScreenState();
}

class _DistrictDetailsScreenState extends State<DistrictDetailsScreen> {
  District? _district;
  List<HealthReport> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDistrictData();
  }

  Future<void> _loadDistrictData() async {
    // Mock data loading - in real app, this would fetch from API
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _district = _getMockDistrict(widget.districtId);
      _reports = _getMockReports(widget.districtId);
      _isLoading = false;
    });
  }

  District _getMockDistrict(String districtId) {
    // Mock district data
    switch (districtId) {
      case 'east_khasi_hills':
        return District(
          id: 'east_khasi_hills',
          name: 'East Khasi Hills',
          state: 'Meghalaya',
          latitude: 25.5788,
          longitude: 91.8933,
          riskLevel: RiskLevel.high,
          riskScore: 7.8,
          population: 825922,
          activeReports: 23,
          criticalReports: 3,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        );
      case 'ri_bhoi':
        return District(
          id: 'ri_bhoi',
          name: 'Ri Bhoi',
          state: 'Meghalaya',
          latitude: 25.9000,
          longitude: 91.8833,
          riskLevel: RiskLevel.critical,
          riskScore: 9.1,
          population: 258380,
          activeReports: 45,
          criticalReports: 12,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 5)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );
      default:
        return District(
          id: districtId,
          name: 'Unknown District',
          state: 'Meghalaya',
          latitude: 25.0,
          longitude: 91.0,
          riskLevel: RiskLevel.medium,
          riskScore: 5.0,
          population: 100000,
          activeReports: 5,
          criticalReports: 1,
          lastUpdated: DateTime.now(),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        );
    }
  }

  List<HealthReport> _getMockReports(String districtId) {
    // Mock reports data
    return [
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
        aiAnalysis: 'High risk of water-borne disease outbreak. Immediate water testing required.',
        triageResponse: 'HIGH PRIORITY: Urgent medical evaluation needed within 24 hours.',
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
        aiAnalysis: 'Critical situation requiring immediate intervention.',
        triageResponse: 'CRITICAL: Immediate medical attention required.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      HealthReport(
        id: '3',
        userId: 'user3',
        reporterName: 'Citizen Report',
        location: 'Pynursla, East Khasi Hills',
        latitude: 25.4000,
        longitude: 91.7000,
        description: 'Water in our area looks dirty and smells bad.',
        symptoms: ['Nausea'],
        severity: ReportSeverity.medium,
        status: ReportStatus.processed,
        reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
        aiAnalysis: 'Water quality concern requiring investigation.',
        triageResponse: 'MEDIUM PRIORITY: Water testing recommended.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: null,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_district == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('District Details'),
        ),
        body: const Center(
          child: Text('District not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_district!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDistrictData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Risk Overview
            _buildRiskOverview(),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            _buildQuickActions(),
            
            const SizedBox(height: 16),
            
            // IoT Data
            IotDataWidget(iotData: {}), // Mock IoT data
            
            const SizedBox(height: 16),
            
            // Reports
            ReportsListWidget(reports: _reports),
            
            const SizedBox(height: 16),
            
            // Affected Blocks
            _buildAffectedBlocks(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getRiskColor(_district!.riskLevel).withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getRiskIcon(_district!.riskLevel),
                    color: _getRiskColor(_district!.riskLevel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Risk Level: ${_district!.riskLevel.name.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _getRiskColor(_district!.riskLevel),
                        ),
                      ),
                      Text(
                        'Score: ${_district!.riskScore.toStringAsFixed(1)}/10',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
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
                  child: _buildStatItem(
                    'Population',
                    '${_district!.population}',
                    Icons.people,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Active Reports',
                    '${_district!.activeReports}',
                    Icons.assignment,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Critical Reports',
                    '${_district!.criticalReports}',
                    Icons.warning,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'Last Updated',
                    _formatTime(_district!.lastUpdated),
                    Icons.schedule,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/health-official/ai-copilot'),
                    icon: const Icon(Icons.psychology),
                    label: const Text('AI Analysis'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push('/health-official/broadcast'),
                    icon: const Icon(Icons.broadcast_on_personal),
                    label: const Text('Broadcast'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // View all reports
                    },
                    icon: const Icon(Icons.assignment),
                    label: const Text('View Reports'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Emergency response
                    },
                    icon: const Icon(Icons.emergency),
                    label: const Text('Emergency'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAffectedBlocks() {
    // Mock check - no affectedBlocks property
    return const SizedBox.shrink();
  }

  // Removed unused method - functionality moved to mock implementation

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
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
              fontSize: 16,
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

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
      case RiskLevel.critical:
        return Colors.purple;
    }
  }

  IconData _getRiskIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.info;
      case RiskLevel.high:
        return Icons.warning;
      case RiskLevel.critical:
        return Icons.dangerous;
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}