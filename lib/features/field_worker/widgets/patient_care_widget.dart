import 'package:flutter/material.dart';

class PatientCareWidget extends StatefulWidget {
  const PatientCareWidget({super.key});

  @override
  State<PatientCareWidget> createState() => _PatientCareWidgetState();
}

class _PatientCareWidgetState extends State<PatientCareWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<PatientCareGuide> _careGuides = [];
  final List<AssessmentProtocol> _protocols = [];

  @override
  void initState() {
    super.initState();
    _loadPatientCareData();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadPatientCareData() {
    // Patient care guides
    _careGuides.addAll([
      PatientCareGuide(
        title: 'Dehydration Assessment',
        category: 'Emergency Care',
        icon: Icons.water_drop,
        color: Colors.blue,
        severity: 'High',
        steps: [
          'Check skin turgor by pinching skin on back of hand',
          'Assess mucous membranes (mouth, eyes)',
          'Check for sunken eyes or fontanelle (in infants)',
          'Monitor urine output and color',
          'Assess level of consciousness',
          'Check pulse rate and strength',
        ],
        interventions: [
          'Provide oral rehydration solution (ORS)',
          'Encourage small, frequent sips of water',
          'Monitor vital signs every 15 minutes',
          'Seek immediate medical help if severe',
        ],
        isBookmarked: true,
      ),
      PatientCareGuide(
        title: 'Fever Management',
        category: 'Symptom Care',
        icon: Icons.thermostat,
        color: Colors.red,
        severity: 'Medium',
        steps: [
          'Measure temperature accurately',
          'Assess for associated symptoms',
          'Check for signs of dehydration',
          'Evaluate level of consciousness',
          'Look for rash or other skin changes',
          'Assess breathing pattern',
        ],
        interventions: [
          'Provide cool compresses',
          'Encourage fluid intake',
          'Use antipyretics if available',
          'Monitor temperature every 2 hours',
          'Seek medical help if fever >102°F',
        ],
        isBookmarked: false,
      ),
      PatientCareGuide(
        title: 'Diarrhea Management',
        category: 'Gastrointestinal',
        icon: Icons.healing,
        color: Colors.orange,
        severity: 'Medium',
        steps: [
          'Assess frequency and consistency of stools',
          'Check for blood or mucus in stool',
          'Evaluate hydration status',
          'Assess for abdominal pain or cramping',
          'Check for fever or other symptoms',
          'Evaluate recent food/water intake',
        ],
        interventions: [
          'Provide ORS immediately',
          'Continue breastfeeding (for infants)',
          'Avoid dairy and fatty foods',
          'Monitor for signs of dehydration',
          'Seek medical help if severe or persistent',
        ],
        isBookmarked: true,
      ),
      PatientCareGuide(
        title: 'Respiratory Assessment',
        category: 'Respiratory',
        icon: Icons.air,
        color: Colors.green,
        severity: 'High',
        steps: [
          'Observe breathing rate and pattern',
          'Check for chest retractions',
          'Assess skin color (cyanosis)',
          'Listen for abnormal breath sounds',
          'Check for nasal flaring',
          'Evaluate level of consciousness',
        ],
        interventions: [
          'Position patient for comfort',
          'Ensure clear airway',
          'Provide oxygen if available',
          'Monitor breathing continuously',
          'Seek immediate medical help',
        ],
        isBookmarked: false,
      ),
    ]);

    // Assessment protocols
    _protocols.addAll([
      AssessmentProtocol(
        title: 'Vital Signs Assessment',
        category: 'Basic Assessment',
        icon: Icons.favorite,
        color: Colors.red,
        parameters: [
          'Temperature (normal: 98.6°F/37°C)',
          'Pulse rate (normal: 60-100 bpm)',
          'Blood pressure (if equipment available)',
          'Respiratory rate (normal: 12-20/min)',
          'Oxygen saturation (if pulse oximeter available)',
        ],
        normalRanges: {
          'Temperature': '97.8°F - 99.1°F (36.5°C - 37.3°C)',
          'Pulse': '60-100 beats per minute',
          'Blood Pressure': '90/60 - 140/90 mmHg',
          'Respiratory Rate': '12-20 breaths per minute',
          'Oxygen Saturation': '95-100%',
        },
        isBookmarked: true,
      ),
      AssessmentProtocol(
        title: 'Pediatric Assessment',
        category: 'Child Health',
        icon: Icons.child_care,
        color: Colors.pink,
        parameters: [
          'Weight and height measurements',
          'Head circumference (for infants)',
          'Developmental milestones',
          'Vaccination status',
          'Growth chart plotting',
          'Parental concerns',
        ],
        normalRanges: {
          'Weight': 'Varies by age - use growth charts',
          'Height': 'Varies by age - use growth charts',
          'Head Circumference': 'Varies by age - use growth charts',
          'Temperature': '97.8°F - 99.1°F (36.5°C - 37.3°C)',
        },
        isBookmarked: false,
      ),
      AssessmentProtocol(
        title: 'Maternal Health Assessment',
        category: 'Maternal Care',
        icon: Icons.pregnant_woman,
        color: Colors.purple,
        parameters: [
          'Blood pressure monitoring',
          'Weight gain tracking',
          'Fetal movement assessment',
          'Edema evaluation',
          'Nutritional status',
          'Mental health screening',
        ],
        normalRanges: {
          'Blood Pressure': '<140/90 mmHg',
          'Weight Gain': '25-35 lbs during pregnancy',
          'Fetal Movement': '10 movements in 2 hours',
          'Edema': 'Minimal in hands/feet only',
        },
        isBookmarked: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(
                icon: Icon(Icons.healing),
                text: 'Care Guides',
              ),
              Tab(
                icon: Icon(Icons.assessment),
                text: 'Assessment',
              ),
              Tab(
                icon: Icon(Icons.emergency),
                text: 'Emergency',
              ),
            ],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCareGuidesTab(),
              _buildAssessmentTab(),
              _buildEmergencyTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareGuidesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Care Guides',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Step-by-step care protocols for common conditions',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 20),
          ..._careGuides.map((guide) => _buildCareGuideCard(guide)),
        ],
      ),
    );
  }

  Widget _buildAssessmentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assessment Protocols',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Standardized assessment procedures and normal ranges',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 20),
          ..._protocols.map((protocol) => _buildProtocolCard(protocol)),
        ],
      ),
    );
  }

  Widget _buildEmergencyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Emergency Protocols',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Critical care procedures and emergency contacts',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 20),

          // Emergency contacts
          _buildEmergencyContactsCard(),

          const SizedBox(height: 16),

          // Emergency procedures
          _buildEmergencyProceduresCard(),

          const SizedBox(height: 16),

          // Red flag symptoms
          _buildRedFlagSymptomsCard(),
        ],
      ),
    );
  }

  Widget _buildCareGuideCard(PatientCareGuide guide) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: guide.color.withOpacity(0.1),
          child: Icon(guide.icon, color: guide.color),
        ),
        title: Text(
          guide.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(guide.category),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.warning,
                  size: 16,
                  color: _getSeverityColor(guide.severity),
                ),
                const SizedBox(width: 4),
                Text(
                  'Severity: ${guide.severity}',
                  style: TextStyle(
                    color: _getSeverityColor(guide.severity),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _toggleBookmark(guide),
              icon: Icon(
                guide.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: guide.isBookmarked ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assessment Steps:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...guide.steps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
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
                            step,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'Interventions:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...guide.interventions.map((intervention) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 8),
                          Expanded(child: Text(intervention)),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsCompleted(guide),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark as Done'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareGuide(guide),
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(AssessmentProtocol protocol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: protocol.color.withOpacity(0.1),
          child: Icon(protocol.icon, color: protocol.color),
        ),
        title: Text(
          protocol.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(protocol.category),
        trailing: IconButton(
          onPressed: () => _toggleProtocolBookmark(protocol),
          icon: Icon(
            protocol.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: protocol.isBookmarked ? Colors.blue : Colors.grey,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Assessment Parameters:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...protocol.parameters.map((parameter) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.assessment, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(child: Text(parameter)),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
                const Text(
                  'Normal Ranges:',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...protocol.normalRanges.entries.map((entry) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            entry.value,
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.phone, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Emergency Contacts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildContactItem('108', 'Ambulance', Colors.red),
            _buildContactItem('102', 'Health Helpline', Colors.blue),
            _buildContactItem('District Health Officer', 'Emergency Line', Colors.orange),
            _buildContactItem('Local Health Center', '24/7 Emergency', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String number, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.phone, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _makeCall(number),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Call'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyProceduresCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.emergency, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Emergency Procedures',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProcedureItem('CPR', 'Cardiopulmonary Resuscitation', Colors.red),
            _buildProcedureItem('Choking', 'Heimlich Maneuver', Colors.orange),
            _buildProcedureItem('Bleeding', 'Direct Pressure & Elevation', Colors.red),
            _buildProcedureItem('Shock', 'Position & Monitor', Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildProcedureItem(String title, String description, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.medical_services, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showProcedureDetails(title),
            child: const Text('Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildRedFlagSymptomsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Red Flag Symptoms',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Seek immediate medical help for:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _buildSymptomItem('Severe dehydration', 'Sunken eyes, no tears, dry mouth'),
            _buildSymptomItem('High fever with confusion', 'Temperature >102°F with altered consciousness'),
            _buildSymptomItem('Severe abdominal pain', 'Intense, persistent pain with vomiting'),
            _buildSymptomItem('Difficulty breathing', 'Rapid breathing, chest retractions'),
            _buildSymptomItem('Severe bleeding', 'Uncontrolled bleeding from any source'),
            _buildSymptomItem('Signs of shock', 'Pale, cold, sweaty skin with weak pulse'),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomItem(String symptom, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.red,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _toggleBookmark(PatientCareGuide guide) {
    setState(() {
      guide.isBookmarked = !guide.isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          guide.isBookmarked
              ? 'Care guide bookmarked!'
              : 'Care guide removed from bookmarks',
        ),
        backgroundColor: guide.isBookmarked ? Colors.green : Colors.orange,
      ),
    );
  }

  void _toggleProtocolBookmark(AssessmentProtocol protocol) {
    setState(() {
      protocol.isBookmarked = !protocol.isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          protocol.isBookmarked
              ? 'Protocol bookmarked!'
              : 'Protocol removed from bookmarks',
        ),
        backgroundColor: protocol.isBookmarked ? Colors.green : Colors.orange,
      ),
    );
  }

  void _markAsCompleted(PatientCareGuide guide) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great job! "${guide.title}" marked as completed'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _shareGuide(PatientCareGuide guide) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${guide.title}" shared successfully!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _makeCall(String number) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Calling $number...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showProcedureDetails(String procedure) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(procedure),
        content: const Text('Detailed procedure steps will be available here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class PatientCareGuide {
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final String severity;
  final List<String> steps;
  final List<String> interventions;
  bool isBookmarked;

  PatientCareGuide({
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.severity,
    required this.steps,
    required this.interventions,
    required this.isBookmarked,
  });
}

class AssessmentProtocol {
  final String title;
  final String category;
  final IconData icon;
  final Color color;
  final List<String> parameters;
  final Map<String, String> normalRanges;
  bool isBookmarked;

  AssessmentProtocol({
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.parameters,
    required this.normalRanges,
    required this.isBookmarked,
  });
}

