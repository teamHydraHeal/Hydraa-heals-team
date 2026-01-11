import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/connectivity_provider.dart';

class CommunitySupportWidget extends StatefulWidget {
  const CommunitySupportWidget({super.key});

  @override
  State<CommunitySupportWidget> createState() => _CommunitySupportWidgetState();
}

class _CommunitySupportWidgetState extends State<CommunitySupportWidget> {
  final List<CommunityMember> _communityMembers = [];
  final List<HealthTip> _communityTips = [];

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  void _loadCommunityData() {
    // Mock community data
    _communityMembers.addAll([
      CommunityMember(
        name: 'Dr. Priya Sharma',
        role: 'Local Health Officer',
        location: 'Shillong Health Center',
        isOnline: true,
        lastActive: DateTime.now().subtract(const Duration(minutes: 5)),
        specialties: ['Water Quality', 'Child Health'],
      ),
      CommunityMember(
        name: 'Meera Devi',
        role: 'ASHA Worker',
        location: 'Mawryngkneng',
        isOnline: true,
        lastActive: DateTime.now().subtract(const Duration(minutes: 15)),
        specialties: ['Community Health', 'Maternal Care'],
      ),
      CommunityMember(
        name: 'Rajesh Kumar',
        role: 'Community Health Worker',
        location: 'Cherrapunji',
        isOnline: false,
        lastActive: DateTime.now().subtract(const Duration(hours: 2)),
        specialties: ['Health Education', 'Disease Prevention'],
      ),
    ]);

    _communityTips.addAll([
      HealthTip(
        title: 'Water Purification Method',
        description: 'Boil water for 1 minute, then let it cool before drinking',
        author: 'Dr. Priya Sharma',
        likes: 24,
        isLiked: false,
      ),
      HealthTip(
        title: 'Hand Hygiene Best Practices',
        description: 'Wash hands with soap for at least 20 seconds, especially before eating',
        author: 'Meera Devi',
        likes: 18,
        isLiked: true,
      ),
      HealthTip(
        title: 'Preventing Water-borne Diseases',
        description: 'Store water in clean, covered containers and avoid drinking from unknown sources',
        author: 'Rajesh Kumar',
        likes: 31,
        isLiked: false,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = Provider.of<ConnectivityProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Community Support',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Connect with local health workers and community members',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 24),

          // Connection status
          if (!connectivity.isOnline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange[200]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline mode - Community features limited',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Health Workers Section
          Text(
            'Available Health Workers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          ..._communityMembers.map((member) => _buildHealthWorkerCard(member)),

          const SizedBox(height: 24),

          // Community Tips Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community Health Tips',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () => _showAddTipDialog(),
                child: const Text('Share Tip'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._communityTips.map((tip) => _buildHealthTipCard(tip)),

          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Report Health Issue',
                  Icons.report_problem,
                  Colors.red,
                  () => _showReportDialog(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Request Health Visit',
                  Icons.local_hospital,
                  Colors.blue,
                  () => _showRequestDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthWorkerCard(CommunityMember member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: member.isOnline ? Colors.green : Colors.grey,
          child: Text(
            member.name.split(' ').map((n) => n[0]).join(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          member.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(member.role),
            Text(
              member.location,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            if (member.isOnline)
              Text(
                'Online now',
                style: TextStyle(
                  color: Colors.green[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Text(
                'Last active: ${_formatLastActive(member.lastActive)}',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: member.isOnline
            ? ElevatedButton(
                onPressed: () => _contactHealthWorker(member),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text('Contact'),
              )
            : null,
        isThreeLine: true,
      ),
    );
  }

  Widget _buildHealthTipCard(HealthTip tip) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tip.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleLike(tip),
                  icon: Icon(
                    tip.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: tip.isLiked ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tip.description,
              style: TextStyle(
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  tip.author,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Icon(Icons.thumb_up, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${tip.likes}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _contactHealthWorker(CommunityMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact ${member.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${member.role}'),
            Text('Location: ${member.location}'),
            const SizedBox(height: 8),
            Text('Specialties: ${member.specialties.join(', ')}'),
            const SizedBox(height: 16),
            const Text('How would you like to contact?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would initiate a call or message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contacting ${member.name}...'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Call'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would open a messaging interface
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening chat with ${member.name}...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Message'),
          ),
        ],
      ),
    );
  }

  void _toggleLike(HealthTip tip) {
    setState(() {
      tip.isLiked = !tip.isLiked;
      tip.likes += tip.isLiked ? 1 : -1;
    });
  }

  void _showAddTipDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Health Tip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Tip Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Health tip shared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Health Issue'),
        content: const Text(
          'This will help connect you with the appropriate health workers in your area.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to report form
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Health Visit'),
        content: const Text(
          'Request a home visit from a health worker for health checkup or consultation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Health visit request submitted!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class CommunityMember {
  final String name;
  final String role;
  final String location;
  final bool isOnline;
  final DateTime lastActive;
  final List<String> specialties;

  CommunityMember({
    required this.name,
    required this.role,
    required this.location,
    required this.isOnline,
    required this.lastActive,
    required this.specialties,
  });
}

class HealthTip {
  final String title;
  final String description;
  final String author;
  int likes;
  bool isLiked;

  HealthTip({
    required this.title,
    required this.description,
    required this.author,
    required this.likes,
    required this.isLiked,
  });
}

