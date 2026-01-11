import 'package:flutter/material.dart';


class EducationalModuleScreen extends StatefulWidget {
  const EducationalModuleScreen({super.key});

  @override
  State<EducationalModuleScreen> createState() => _EducationalModuleScreenState();
}

class _EducationalModuleScreenState extends State<EducationalModuleScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Water Safety',
    'Hygiene',
    'Disease Prevention',
    'Emergency Response',
    'Nutrition',
    'Vaccination',
  ];

  final List<Map<String, dynamic>> _educationalContent = [
    {
      'id': '1',
      'title': 'Water Purification Methods',
      'category': 'Water Safety',
      'content': 'Learn about different methods to purify water including boiling, filtration, and chemical treatment.',
      'image': '💧',
      'steps': [
        'Boil water for at least 1 minute',
        'Use water filters or purifiers',
        'Add chlorine tablets if available',
        'Store purified water in clean containers',
      ],
      'tips': [
        'Always wash hands before handling water',
        'Keep water containers covered',
        'Replace stored water every 24 hours',
      ],
    },
    {
      'id': '2',
      'title': 'Hand Hygiene Best Practices',
      'category': 'Hygiene',
      'content': 'Proper hand washing techniques to prevent the spread of diseases.',
      'image': '🧼',
      'steps': [
        'Wet hands with clean running water',
        'Apply soap and lather for 20 seconds',
        'Scrub all surfaces including between fingers',
        'Rinse thoroughly and dry with clean towel',
      ],
      'tips': [
        'Wash hands before eating and after using toilet',
        'Use hand sanitizer when soap is not available',
        'Teach children proper hand washing techniques',
      ],
    },
    {
      'id': '3',
      'title': 'Diarrhea Prevention',
      'category': 'Disease Prevention',
      'content': 'How to prevent and manage diarrhea in children and adults.',
      'image': '🏥',
      'steps': [
        'Ensure access to clean drinking water',
        'Practice proper food hygiene',
        'Maintain clean living environment',
        'Seek medical help if symptoms persist',
      ],
      'tips': [
        'Oral Rehydration Solution (ORS) is crucial',
        'Continue breastfeeding for infants',
        'Avoid giving anti-diarrheal to children under 2',
      ],
    },
    {
      'id': '4',
      'title': 'Emergency First Aid',
      'category': 'Emergency Response',
      'content': 'Basic first aid procedures for common health emergencies.',
      'image': '🚑',
      'steps': [
        'Assess the situation and ensure safety',
        'Call emergency services (108)',
        'Provide basic life support if trained',
        'Keep the person comfortable until help arrives',
      ],
      'tips': [
        'Keep emergency contact numbers handy',
        'Learn basic CPR techniques',
        'Maintain a first aid kit at home',
      ],
    },
    {
      'id': '5',
      'title': 'Nutrition for Children',
      'category': 'Nutrition',
      'content': 'Essential nutrition guidelines for child development and health.',
      'image': '🍎',
      'steps': [
        'Ensure balanced diet with all food groups',
        'Include fruits and vegetables daily',
        'Provide adequate protein and calcium',
        'Limit processed and sugary foods',
      ],
      'tips': [
        'Breastfeeding is best for infants under 6 months',
        'Introduce solid foods gradually after 6 months',
        'Encourage regular meal times',
      ],
    },
    {
      'id': '6',
      'title': 'Vaccination Schedule',
      'category': 'Vaccination',
      'content': 'Important vaccinations for children and adults to prevent diseases.',
      'image': '💉',
      'steps': [
        'Follow the recommended vaccination schedule',
        'Keep vaccination records updated',
        'Get booster shots as required',
        'Consult healthcare providers for any concerns',
      ],
      'tips': [
        'Vaccinations are safe and effective',
        'Some vaccines require multiple doses',
        'Adults may need certain booster vaccinations',
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredContent {
    var filtered = _educationalContent.where((content) {
      final matchesCategory = _selectedCategory == 'All' || 
          content['category'] == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          content['title'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          content['content'].toLowerCase().contains(_searchQuery.toLowerCase());
      
      return matchesCategory && matchesSearch;
    }).toList();

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Education'),
        actions: [
          IconButton(
            icon: const Icon(Icons.offline_bolt),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All content is available offline'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search health topics...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Category Filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category == _selectedCategory;
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha:0.2),
                          checkmarkColor: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Content List
          Expanded(
            child: _filteredContent.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No content found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Try adjusting your search or filter',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredContent.length,
                    itemBuilder: (context, index) {
                      final content = _filteredContent[index];
                      return _buildContentCard(content);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showContentDetail(content),
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
                      color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        content['image'],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          content['title'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          content['category'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content['content'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContentDetail(Map<String, dynamic> content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
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
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          content['image'],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            content['category'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.primary,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      Text(
                        content['content'],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Steps
                      const Text(
                        'Steps:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(content['steps'] as List<String>).asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
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
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      const SizedBox(height: 24),
                      
                      // Tips
                      const Text(
                        'Important Tips:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(content['tips'] as List<String>).map((tip) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb_outline,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Share functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Content shared successfully'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Bookmark functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Content bookmarked'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bookmark_border),
                              label: const Text('Bookmark'),
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
}
