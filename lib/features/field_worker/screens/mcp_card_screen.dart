import 'package:flutter/material.dart';

class McpCardScreen extends StatefulWidget {
  const McpCardScreen({super.key});

  @override
  State<McpCardScreen> createState() => _McpCardScreenState();
}

class _McpCardScreenState extends State<McpCardScreen> {
  String _selectedPatient = '';

  final List<Map<String, dynamic>> _patients = [
    {
      'id': '1',
      'name': 'Rita Khonglah',
      'age': '2 years 3 months',
      'gender': 'Female',
      'motherName': 'Mary Khonglah',
      'village': 'Mawryngkneng',
      'lastVisit': '2024-01-15',
      'nextVisit': '2024-02-15',
      'vaccinationStatus': 'Up to date',
      'growthStatus': 'Normal',
    },
    {
      'id': '2',
      'name': 'John Lyngdoh',
      'age': '1 year 8 months',
      'gender': 'Male',
      'motherName': 'Sarah Lyngdoh',
      'village': 'Shillong',
      'lastVisit': '2024-01-10',
      'nextVisit': '2024-02-10',
      'vaccinationStatus': 'Due for MMR',
      'growthStatus': 'Underweight',
    },
    {
      'id': '3',
      'name': 'Meera Nongrum',
      'age': '3 years 1 month',
      'gender': 'Female',
      'motherName': 'Grace Nongrum',
      'village': 'Pynursla',
      'lastVisit': '2024-01-20',
      'nextVisit': '2024-02-20',
      'vaccinationStatus': 'Up to date',
      'growthStatus': 'Normal',
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _vaccinationRecords = {
    '1': [
      {'vaccine': 'BCG', 'date': '2022-01-15', 'status': 'Completed'},
      {'vaccine': 'OPV-1', 'date': '2022-02-15', 'status': 'Completed'},
      {'vaccine': 'DPT-1', 'date': '2022-02-15', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-1', 'date': '2022-02-15', 'status': 'Completed'},
      {'vaccine': 'OPV-2', 'date': '2022-03-15', 'status': 'Completed'},
      {'vaccine': 'DPT-2', 'date': '2022-03-15', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-2', 'date': '2022-03-15', 'status': 'Completed'},
      {'vaccine': 'OPV-3', 'date': '2022-04-15', 'status': 'Completed'},
      {'vaccine': 'DPT-3', 'date': '2022-04-15', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-3', 'date': '2022-04-15', 'status': 'Completed'},
      {'vaccine': 'Measles', 'date': '2022-10-15', 'status': 'Completed'},
    ],
    '2': [
      {'vaccine': 'BCG', 'date': '2022-05-10', 'status': 'Completed'},
      {'vaccine': 'OPV-1', 'date': '2022-06-10', 'status': 'Completed'},
      {'vaccine': 'DPT-1', 'date': '2022-06-10', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-1', 'date': '2022-06-10', 'status': 'Completed'},
      {'vaccine': 'OPV-2', 'date': '2022-07-10', 'status': 'Completed'},
      {'vaccine': 'DPT-2', 'date': '2022-07-10', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-2', 'date': '2022-07-10', 'status': 'Completed'},
      {'vaccine': 'OPV-3', 'date': '2022-08-10', 'status': 'Completed'},
      {'vaccine': 'DPT-3', 'date': '2022-08-10', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-3', 'date': '2022-08-10', 'status': 'Completed'},
      {'vaccine': 'Measles', 'date': '2024-02-10', 'status': 'Due'},
    ],
    '3': [
      {'vaccine': 'BCG', 'date': '2021-12-20', 'status': 'Completed'},
      {'vaccine': 'OPV-1', 'date': '2022-01-20', 'status': 'Completed'},
      {'vaccine': 'DPT-1', 'date': '2022-01-20', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-1', 'date': '2022-01-20', 'status': 'Completed'},
      {'vaccine': 'OPV-2', 'date': '2022-02-20', 'status': 'Completed'},
      {'vaccine': 'DPT-2', 'date': '2022-02-20', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-2', 'date': '2022-02-20', 'status': 'Completed'},
      {'vaccine': 'OPV-3', 'date': '2022-03-20', 'status': 'Completed'},
      {'vaccine': 'DPT-3', 'date': '2022-03-20', 'status': 'Completed'},
      {'vaccine': 'Hepatitis B-3', 'date': '2022-03-20', 'status': 'Completed'},
      {'vaccine': 'Measles', 'date': '2022-09-20', 'status': 'Completed'},
      {'vaccine': 'DPT Booster', 'date': '2023-03-20', 'status': 'Completed'},
    ],
  };

  final Map<String, List<Map<String, dynamic>>> _growthRecords = {
    '1': [
      {'age': 'Birth', 'weight': '3.2 kg', 'height': '50 cm', 'date': '2022-01-15'},
      {'age': '1 month', 'weight': '4.1 kg', 'height': '54 cm', 'date': '2022-02-15'},
      {'age': '3 months', 'weight': '5.8 kg', 'height': '61 cm', 'date': '2022-04-15'},
      {'age': '6 months', 'weight': '7.2 kg', 'height': '67 cm', 'date': '2022-07-15'},
      {'age': '9 months', 'weight': '8.1 kg', 'height': '72 cm', 'date': '2022-10-15'},
      {'age': '12 months', 'weight': '9.0 kg', 'height': '76 cm', 'date': '2023-01-15'},
      {'age': '18 months', 'weight': '10.2 kg', 'height': '82 cm', 'date': '2023-07-15'},
      {'age': '24 months', 'weight': '11.5 kg', 'height': '87 cm', 'date': '2024-01-15'},
    ],
    '2': [
      {'age': 'Birth', 'weight': '2.8 kg', 'height': '48 cm', 'date': '2022-05-10'},
      {'age': '1 month', 'weight': '3.5 kg', 'height': '52 cm', 'date': '2022-06-10'},
      {'age': '3 months', 'weight': '4.9 kg', 'height': '58 cm', 'date': '2022-08-10'},
      {'age': '6 months', 'weight': '6.1 kg', 'height': '64 cm', 'date': '2022-11-10'},
      {'age': '9 months', 'weight': '6.8 kg', 'height': '69 cm', 'date': '2023-02-10'},
      {'age': '12 months', 'weight': '7.5 kg', 'height': '73 cm', 'date': '2023-05-10'},
      {'age': '18 months', 'weight': '8.2 kg', 'height': '78 cm', 'date': '2023-11-10'},
    ],
    '3': [
      {'age': 'Birth', 'weight': '3.5 kg', 'height': '51 cm', 'date': '2021-12-20'},
      {'age': '1 month', 'weight': '4.3 kg', 'height': '55 cm', 'date': '2022-01-20'},
      {'age': '3 months', 'weight': '6.0 kg', 'height': '62 cm', 'date': '2022-03-20'},
      {'age': '6 months', 'weight': '7.5 kg', 'height': '68 cm', 'date': '2022-06-20'},
      {'age': '9 months', 'weight': '8.4 kg', 'height': '73 cm', 'date': '2022-09-20'},
      {'age': '12 months', 'weight': '9.3 kg', 'height': '77 cm', 'date': '2022-12-20'},
      {'age': '18 months', 'weight': '10.8 kg', 'height': '84 cm', 'date': '2023-06-20'},
      {'age': '24 months', 'weight': '12.2 kg', 'height': '89 cm', 'date': '2023-12-20'},
      {'age': '36 months', 'weight': '13.8 kg', 'height': '95 cm', 'date': '2024-01-20'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital MCP Cards'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddPatientDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Patient List
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient List',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _patients.length,
                      itemBuilder: (context, index) {
                        final patient = _patients[index];
                        final isSelected = _selectedPatient == patient['id'];
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          color: isSelected 
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                              : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                patient['name'][0],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              patient['name'],
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${patient['age']} • ${patient['gender']}'),
                                Text('Village: ${patient['village']}'),
                              ],
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(patient['vaccinationStatus']),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    patient['vaccinationStatus'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getGrowthStatusColor(patient['growthStatus']),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    patient['growthStatus'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _selectedPatient = patient['id'];
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Patient Details
          if (_selectedPatient.isNotEmpty)
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(16),
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      const TabBar(
                        tabs: [
                          Tab(text: 'Overview'),
                          Tab(text: 'Vaccination'),
                          Tab(text: 'Growth Chart'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildOverviewTab(),
                            _buildVaccinationTab(),
                            _buildGrowthChartTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final patient = _patients.firstWhere((p) => p['id'] == _selectedPatient);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Patient Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Patient Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Name', patient['name']),
                  _buildInfoRow('Age', patient['age']),
                  _buildInfoRow('Gender', patient['gender']),
                  _buildInfoRow('Mother\'s Name', patient['motherName']),
                  _buildInfoRow('Village', patient['village']),
                  _buildInfoRow('Last Visit', patient['lastVisit']),
                  _buildInfoRow('Next Visit', patient['nextVisit']),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Cards
          Row(
            children: [
              Expanded(
                child: Card(
                  color: _getStatusColor(patient['vaccinationStatus']).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.vaccines,
                          color: _getStatusColor(patient['vaccinationStatus']),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vaccination',
                          style: TextStyle(
                            color: _getStatusColor(patient['vaccinationStatus']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          patient['vaccinationStatus'],
                          style: TextStyle(
                            color: _getStatusColor(patient['vaccinationStatus']),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: _getGrowthStatusColor(patient['growthStatus']).withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.trending_up,
                          color: _getGrowthStatusColor(patient['growthStatus']),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Growth',
                          style: TextStyle(
                            color: _getGrowthStatusColor(patient['growthStatus']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          patient['growthStatus'],
                          style: TextStyle(
                            color: _getGrowthStatusColor(patient['growthStatus']),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Quick Actions
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
                  onPressed: () {
                    // Schedule visit
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Schedule Visit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Add record
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Record'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationTab() {
    final records = _vaccinationRecords[_selectedPatient] ?? [];
    
    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getVaccineStatusColor(record['status']),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getVaccineStatusIcon(record['status']),
                color: Colors.white,
                size: 20,
              ),
            ),
            title: Text(
              record['vaccine'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('Date: ${record['date']}'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getVaccineStatusColor(record['status']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                record['status'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrowthChartTab() {
    final records = _growthRecords[_selectedPatient] ?? [];
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Growth Records',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Growth Chart (Mock)
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Growth Chart Visualization\n(Weight & Height over time)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Growth Records Table
          ...records.map((record) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.analytics, color: Colors.blue),
              title: Text(
                'Age: ${record['age']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Date: ${record['date']}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Weight: ${record['weight']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Height: ${record['height']}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'up to date':
        return Colors.green;
      case 'due for mmr':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getGrowthStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'underweight':
        return Colors.orange;
      case 'overweight':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getVaccineStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'due':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getVaccineStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check;
      case 'due':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  void _showAddPatientDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Patient'),
        content: const Text('This feature will allow you to add new patients to the MCP system.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Patient addition feature coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Add Patient'),
          ),
        ],
      ),
    );
  }
}
