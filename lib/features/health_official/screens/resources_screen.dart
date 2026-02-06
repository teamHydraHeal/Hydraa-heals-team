import 'package:flutter/material.dart';

class ResourcesScreen extends StatefulWidget {
  const ResourcesScreen({super.key});

  @override
  State<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends State<ResourcesScreen> {
  String _selectedCategory = 'All';
  String _selectedDistrict = 'All Districts';

  final List<String> _categories = [
    'All',
    'Personnel',
    'Equipment',
    'Supplies',
    'Vehicles',
    'Budget',
  ];

  final List<String> _districts = [
    'All Districts',
    'East Khasi Hills',
    'West Khasi Hills',
    'Ri Bhoi',
    'Jaintia Hills',
    'Garo Hills',
  ];

  final List<Map<String, dynamic>> _resources = [
    {
      'id': '1',
      'name': 'Water Testing Kits',
      'category': 'Equipment',
      'district': 'East Khasi Hills',
      'quantity': 15,
      'status': 'Available',
      'lastUpdated': '2024-01-20',
      'location': 'Shillong Health Center',
      'priority': 'High',
    },
    {
      'id': '2',
      'name': 'ASHA Workers',
      'category': 'Personnel',
      'district': 'East Khasi Hills',
      'quantity': 8,
      'status': 'Available',
      'lastUpdated': '2024-01-19',
      'location': 'Various Villages',
      'priority': 'Critical',
    },
    {
      'id': '3',
      'name': 'Emergency Vehicles',
      'category': 'Vehicles',
      'district': 'East Khasi Hills',
      'quantity': 3,
      'status': 'Available',
      'lastUpdated': '2024-01-18',
      'location': 'District Health Office',
      'priority': 'High',
    },
    {
      'id': '4',
      'name': 'Chlorine Tablets',
      'category': 'Supplies',
      'district': 'East Khasi Hills',
      'quantity': 500,
      'status': 'Low Stock',
      'lastUpdated': '2024-01-17',
      'location': 'Medical Store',
      'priority': 'Medium',
    },
    {
      'id': '5',
      'name': 'Health Officials',
      'category': 'Personnel',
      'district': 'East Khasi Hills',
      'quantity': 5,
      'status': 'Available',
      'lastUpdated': '2024-01-16',
      'location': 'District Health Office',
      'priority': 'Critical',
    },
    {
      'id': '6',
      'name': 'Ambulances',
      'category': 'Vehicles',
      'district': 'East Khasi Hills',
      'quantity': 2,
      'status': 'Available',
      'lastUpdated': '2024-01-15',
      'location': 'Emergency Services',
      'priority': 'Critical',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredResources = _getFilteredResources();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resource Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showAddResourceDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Category Filter
                Row(
                  children: [
                    const Text('Category:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // District Filter
                Row(
                  children: [
                    const Text('District:'),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedDistrict,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Resource Statistics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Resources',
                    '${filteredResources.length}',
                    Icons.inventory,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    '${filteredResources.where((r) => r['status'] == 'Available').length}',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Low Stock',
                    '${filteredResources.where((r) => r['status'] == 'Low Stock').length}',
                    Icons.warning,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Resources List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredResources.length,
              itemBuilder: (context, index) {
                final resource = filteredResources[index];
                return _buildResourceCard(resource);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredResources() {
    return _resources.where((resource) {
      final matchesCategory = _selectedCategory == 'All' || 
          resource['category'] == _selectedCategory;
      final matchesDistrict = _selectedDistrict == 'All Districts' || 
          resource['district'] == _selectedDistrict;
      
      return matchesCategory && matchesDistrict;
    }).toList();
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
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

  Widget _buildResourceCard(Map<String, dynamic> resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showResourceDetails(resource),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(resource['category']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(resource['category']),
                      color: _getCategoryColor(resource['category']),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resource['category'],
                          style: TextStyle(
                            fontSize: 12,
                            color: _getCategoryColor(resource['category']),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(resource['status']),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      resource['status'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Quantity',
                      '${resource['quantity']}',
                      Icons.numbers,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'District',
                      resource['district'],
                      Icons.location_on,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      'Priority',
                      resource['priority'],
                      Icons.priority_high,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      'Updated',
                      resource['lastUpdated'],
                      Icons.schedule,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Personnel':
        return Colors.blue;
      case 'Equipment':
        return Colors.green;
      case 'Supplies':
        return Colors.orange;
      case 'Vehicles':
        return Colors.purple;
      case 'Budget':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Personnel':
        return Icons.people;
      case 'Equipment':
        return Icons.build;
      case 'Supplies':
        return Icons.inventory;
      case 'Vehicles':
        return Icons.directions_car;
      case 'Budget':
        return Icons.attach_money;
      default:
        return Icons.category;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Unavailable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showResourceDetails(Map<String, dynamic> resource) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(resource['category']).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getCategoryIcon(resource['category']),
                        color: _getCategoryColor(resource['category']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            resource['name'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            resource['category'],
                            style: TextStyle(
                              fontSize: 14,
                              color: _getCategoryColor(resource['category']),
                              fontWeight: FontWeight.w600,
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
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resource Details
                      _buildDetailRow('Quantity', '${resource['quantity']}'),
                      _buildDetailRow('Status', resource['status']),
                      _buildDetailRow('District', resource['district']),
                      _buildDetailRow('Location', resource['location']),
                      _buildDetailRow('Priority', resource['priority']),
                      _buildDetailRow('Last Updated', resource['lastUpdated']),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Edit resource
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Edit resource functionality coming soon'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Request resource
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Resource request submitted'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.request_quote),
                              label: const Text('Request'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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

  void _showAddResourceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Resource'),
        content: const Text('This feature will allow you to add new resources to the system.'),
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
                  content: Text('Add resource functionality coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Add Resource'),
          ),
        ],
      ),
    );
  }
}
