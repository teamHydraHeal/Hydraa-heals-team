import 'package:flutter/material.dart';

class HealthTipsWidget extends StatefulWidget {
  const HealthTipsWidget({super.key});

  @override
  State<HealthTipsWidget> createState() => _HealthTipsWidgetState();
}

class _HealthTipsWidgetState extends State<HealthTipsWidget>
    with TickerProviderStateMixin {
  late TabController _categoryController;
  final List<HealthTipCategory> _categories = [];
  final List<HealthTip> _allTips = [];

  @override
  void initState() {
    super.initState();
    _loadHealthTips();
    _categoryController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _loadHealthTips() {
    // Water Safety Tips
    _categories.add(HealthTipCategory(
      name: 'Water Safety',
      icon: Icons.water_drop,
      color: Colors.blue,
    ));

    _allTips.addAll([
      HealthTip(
        title: 'Boiling Water for Safety',
        description: 'Boil water for at least 1 minute to kill harmful bacteria and viruses. Let it cool before drinking.',
        category: 'Water Safety',
        difficulty: 'Easy',
        duration: '5 minutes',
        steps: [
          'Fill a clean pot with water',
          'Bring water to a rolling boil',
          'Keep boiling for 1 minute',
          'Let water cool naturally',
          'Store in clean, covered container',
        ],
        isBookmarked: false,
      ),
      HealthTip(
        title: 'Water Storage Best Practices',
        description: 'Proper water storage prevents contamination and maintains water quality.',
        category: 'Water Safety',
        difficulty: 'Easy',
        duration: '2 minutes',
        steps: [
          'Use clean, food-grade containers',
          'Keep containers covered at all times',
          'Store in cool, dark place',
          'Clean containers regularly',
          'Use within 24-48 hours',
        ],
        isBookmarked: true,
      ),
    ]);

    // Disease Prevention Tips
    _categories.add(HealthTipCategory(
      name: 'Disease Prevention',
      icon: Icons.health_and_safety,
      color: Colors.green,
    ));

    _allTips.addAll([
      HealthTip(
        title: 'Hand Hygiene Protocol',
        description: 'Proper hand washing is the most effective way to prevent disease transmission.',
        category: 'Disease Prevention',
        difficulty: 'Easy',
        duration: '30 seconds',
        steps: [
          'Wet hands with clean water',
          'Apply soap and lather well',
          'Scrub for at least 20 seconds',
          'Rinse thoroughly with water',
          'Dry with clean towel or air dry',
        ],
        isBookmarked: false,
      ),
      HealthTip(
        title: 'Food Safety Guidelines',
        description: 'Safe food handling prevents food-borne illnesses and contamination.',
        category: 'Disease Prevention',
        difficulty: 'Medium',
        duration: '10 minutes',
        steps: [
          'Wash hands before handling food',
          'Use separate cutting boards for raw meat',
          'Cook food to proper temperatures',
          'Refrigerate leftovers promptly',
          'Avoid cross-contamination',
        ],
        isBookmarked: false,
      ),
    ]);

    // Child Health Tips
    _categories.add(HealthTipCategory(
      name: 'Child Health',
      icon: Icons.child_care,
      color: Colors.orange,
    ));

    _allTips.addAll([
      HealthTip(
        title: 'Child Hydration Safety',
        description: 'Ensure children drink safe water and stay properly hydrated.',
        category: 'Child Health',
        difficulty: 'Easy',
        duration: '3 minutes',
        steps: [
          'Provide only boiled or filtered water',
          'Encourage regular water intake',
          'Monitor for signs of dehydration',
          'Avoid sugary drinks',
          'Keep water easily accessible',
        ],
        isBookmarked: true,
      ),
      HealthTip(
        title: 'Vaccination Schedule',
        description: 'Keep children up-to-date with essential vaccinations for disease prevention.',
        category: 'Child Health',
        difficulty: 'Medium',
        duration: '15 minutes',
        steps: [
          'Consult with healthcare provider',
          'Maintain vaccination records',
          'Schedule regular check-ups',
          'Follow recommended timeline',
          'Monitor for side effects',
        ],
        isBookmarked: false,
      ),
    ]);

    // Emergency Preparedness Tips
    _categories.add(HealthTipCategory(
      name: 'Emergency',
      icon: Icons.emergency,
      color: Colors.red,
    ));

    _allTips.addAll([
      HealthTip(
        title: 'Emergency Water Supply',
        description: 'Prepare emergency water supply for natural disasters or water shortages.',
        category: 'Emergency',
        difficulty: 'Medium',
        duration: '30 minutes',
        steps: [
          'Store 1 gallon per person per day',
          'Use food-grade containers',
          'Rotate water every 6 months',
          'Keep in cool, dark location',
          'Have purification tablets ready',
        ],
        isBookmarked: false,
      ),
      HealthTip(
        title: 'First Aid for Dehydration',
        description: 'Recognize and treat dehydration symptoms, especially in children and elderly.',
        category: 'Emergency',
        difficulty: 'Easy',
        duration: '5 minutes',
        steps: [
          'Recognize symptoms (dry mouth, fatigue)',
          'Provide oral rehydration solution',
          'Encourage small, frequent sips',
          'Monitor vital signs',
          'Seek medical help if severe',
        ],
        isBookmarked: true,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Category tabs
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 16),
          child: TabBar(
            controller: _categoryController,
            isScrollable: true,
            tabs: _categories.map((category) => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(category.icon, color: category.color, size: 18),
                  const SizedBox(width: 8),
                  Text(category.name),
                ],
              ),
            )).toList(),
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
          ),
        ),

        // Tips content
        Expanded(
          child: TabBarView(
            controller: _categoryController,
            children: _categories.map((category) {
              final categoryTips = _allTips
                  .where((tip) => tip.category == category.name)
                  .toList();
              return _buildCategoryContent(category, categoryTips);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryContent(HealthTipCategory category, List<HealthTip> tips) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: category.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: category.color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(category.icon, color: category.color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: category.color,
                        ),
                      ),
                      Text(
                        '${tips.length} tips available',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tips list
          ...tips.map((tip) => _buildTipCard(tip)),
        ],
      ),
    );
  }

  Widget _buildTipCard(HealthTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        title: Text(
          tip.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              tip.description,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildInfoChip(Icons.timer, tip.duration, Colors.blue),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.speed, tip.difficulty, Colors.orange),
                const Spacer(),
                IconButton(
                  onPressed: () => _toggleBookmark(tip),
                  icon: Icon(
                    tip.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: tip.isBookmarked ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
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
                  'Steps:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...tip.steps.asMap().entries.map((entry) {
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markAsCompleted(tip),
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
                        onPressed: () => _shareTip(tip),
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

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleBookmark(HealthTip tip) {
    setState(() {
      tip.isBookmarked = !tip.isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tip.isBookmarked
              ? 'Tip bookmarked successfully!'
              : 'Tip removed from bookmarks',
        ),
        backgroundColor: tip.isBookmarked ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAsCompleted(HealthTip tip) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great job! "${tip.title}" marked as completed'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            // Undo logic here
          },
        ),
      ),
    );
  }

  void _shareTip(HealthTip tip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Health Tip'),
        content: Text('Share "${tip.title}" with your community?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${tip.title}" shared successfully!'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

class HealthTipCategory {
  final String name;
  final IconData icon;
  final Color color;

  HealthTipCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class HealthTip {
  final String title;
  final String description;
  final String category;
  final String difficulty;
  final String duration;
  final List<String> steps;
  bool isBookmarked;

  HealthTip({
    required this.title,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.duration,
    required this.steps,
    required this.isBookmarked,
  });
}

