import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/connectivity_provider.dart';

class FieldAssistantWidget extends StatefulWidget {
  const FieldAssistantWidget({super.key});

  @override
  State<FieldAssistantWidget> createState() => _FieldAssistantWidgetState();
}

class _FieldAssistantWidgetState extends State<FieldAssistantWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<AssistantMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(
      AssistantMessage(
        text: "Hello! I'm your Field Assistant. I can help you with:\n\n"
            "📝 Report submission guidance\n"
            "👶 MCP card procedures\n"
            "🏥 Patient assessment protocols\n"
            "🚨 Emergency response procedures\n"
            "📊 Data collection best practices\n\n"
            "What field work assistance do you need today?",
        isUser: false,
        timestamp: DateTime.now(),
        messageType: MessageType.welcome,
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        AssistantMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
          messageType: MessageType.user,
        ),
      );
      _isTyping = true;
    });

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));

    final aiResponse = _generateFieldResponse(userMessage);

    setState(() {
      _messages.add(
        AssistantMessage(
          text: aiResponse.text,
          isUser: false,
          timestamp: DateTime.now(),
          messageType: aiResponse.type,
        ),
      );
      _isTyping = false;
    });
  }

  FieldResponse _generateFieldResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('report') || message.contains('submit')) {
      return FieldResponse(
        text: "📝 **Report Submission Guide:**\n\n"
            "**Step-by-step process:**\n"
            "1. **Location**: Use GPS or manual entry\n"
            "2. **Description**: Be specific about symptoms/conditions\n"
            "3. **Severity**: Assess using standard scale (Low/Medium/High/Critical)\n"
            "4. **Photos**: Add if relevant and safe to do so\n"
            "5. **Submit**: Ensure connectivity or save for later sync\n\n"
            "**Best practices:**\n"
            "• Use clear, objective language\n"
            "• Include patient demographics (age, gender)\n"
            "• Note any environmental factors\n"
            "• Follow up on critical cases within 24 hours",
        type: MessageType.guidance,
      );
    } else if (message.contains('mcp') || message.contains('mother') || message.contains('child')) {
      return FieldResponse(
        text: "👶 **MCP Card Procedures:**\n\n"
            "**Essential Information to Record:**\n"
            "• Mother's age, weight, and health status\n"
            "• Child's birth date, weight, and milestones\n"
            "• Vaccination status and schedule\n"
            "• Nutritional status and feeding practices\n"
            "• Any health concerns or complications\n\n"
            "**Key Protocols:**\n"
            "• Update cards during each visit\n"
            "• Flag high-risk cases for priority follow-up\n"
            "• Coordinate with health center for referrals\n"
            "• Maintain confidentiality of patient information\n"
            "• Sync data when connectivity is available",
        type: MessageType.guidance,
      );
    } else if (message.contains('patient') || message.contains('assessment') || message.contains('examine')) {
      return FieldResponse(
        text: "🏥 **Patient Assessment Protocol:**\n\n"
            "**Initial Assessment:**\n"
            "• Vital signs (temperature, pulse, blood pressure if available)\n"
            "• General appearance and consciousness level\n"
            "• Chief complaint and symptom duration\n"
            "• Medical history and current medications\n\n"
            "**Physical Examination:**\n"
            "• Check for dehydration signs\n"
            "• Assess skin condition and color\n"
            "• Listen to breathing and heart sounds\n"
            "• Check for abdominal tenderness\n\n"
            "**Documentation:**\n"
            "• Record all findings objectively\n"
            "• Note any red flag symptoms\n"
            "• Determine urgency level\n"
            "• Plan follow-up care",
        type: MessageType.guidance,
      );
    } else if (message.contains('emergency') || message.contains('urgent') || message.contains('critical')) {
      return FieldResponse(
        text: "🚨 **Emergency Response Protocol:**\n\n"
            "**Immediate Actions:**\n"
            "• Assess patient's condition quickly\n"
            "• Call 108 for ambulance if needed\n"
            "• Provide basic first aid if trained\n"
            "• Notify health center immediately\n"
            "• Document incident details\n\n"
            "**Red Flag Symptoms:**\n"
            "• Severe dehydration or shock\n"
            "• High fever with altered consciousness\n"
            "• Severe abdominal pain\n"
            "• Difficulty breathing\n"
            "• Signs of severe infection\n\n"
            "**Communication:**\n"
            "• Use clear, concise language\n"
            "• Provide exact location details\n"
            "• Describe symptoms accurately\n"
            "• Follow up with written report",
        type: MessageType.emergency,
      );
    } else if (message.contains('data') || message.contains('collect') || message.contains('survey')) {
      return FieldResponse(
        text: "📊 **Data Collection Best Practices:**\n\n"
            "**Quality Standards:**\n"
            "• Ensure data accuracy and completeness\n"
            "• Use standardized forms and protocols\n"
            "• Verify information with multiple sources\n"
            "• Maintain patient confidentiality\n"
            "• Follow ethical guidelines\n\n"
            "**Collection Methods:**\n"
            "• Use mobile app for real-time entry\n"
            "• Take photos when appropriate\n"
            "• Record GPS coordinates\n"
            "• Note environmental conditions\n"
            "• Include timestamps for all entries\n\n"
            "**Data Management:**\n"
            "• Sync regularly when online\n"
            "• Backup critical data offline\n"
            "• Review and validate entries\n"
            "• Report data quality issues",
        type: MessageType.guidance,
      );
    } else if (message.contains('water') || message.contains('quality') || message.contains('contamination')) {
      return FieldResponse(
        text: "💧 **Water Quality Assessment:**\n\n"
            "**Visual Inspection:**\n"
            "• Check for color, odor, and turbidity\n"
            "• Look for visible contaminants\n"
            "• Assess source protection\n"
            "• Note storage conditions\n\n"
            "**Community Impact:**\n"
            "• Document affected population\n"
            "• Record symptoms reported\n"
            "• Assess alternative water sources\n"
            "• Coordinate with local authorities\n\n"
            "**Immediate Actions:**\n"
            "• Advise against consumption if unsafe\n"
            "• Provide water treatment guidance\n"
            "• Report to health authorities\n"
            "• Monitor for health effects",
        type: MessageType.guidance,
      );
    } else {
      return FieldResponse(
        text: "I'm here to assist with your field work. Here are some common areas I can help with:\n\n"
            "💡 **Available Assistance:**\n"
            "• Report submission and documentation\n"
            "• Patient assessment and care protocols\n"
            "• MCP card management procedures\n"
            "• Emergency response guidelines\n"
            "• Data collection best practices\n"
            "• Water quality assessment\n"
            "• Community health education\n\n"
            "Please describe your specific need or question, and I'll provide detailed guidance. "
            "Remember to follow all safety protocols and consult with supervisors for complex cases.",
        type: MessageType.general,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final connectivity = Provider.of<ConnectivityProvider>(context);

    return Column(
      children: [
        // Connection status
        if (!connectivity.isOnline)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.orange[100],
            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Offline mode - Limited AI assistance available',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ],
            ),
          ),

        // Quick action buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildQuickButton(
                  '📝 Quick Report',
                  Colors.blue,
                  () => _showQuickReportDialog(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickButton(
                  '👶 MCP Update',
                  Colors.green,
                  () => _showMcpDialog(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickButton(
                  '🚨 Emergency',
                  Colors.red,
                  () => _showEmergencyDialog(),
                ),
              ),
            ],
          ),
        ),

        // Chat messages
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping) {
                return _buildTypingIndicator();
              }
              return _buildMessageBubble(_messages[index]);
            },
          ),
        ),

        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: Colors.grey[300]!,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask about field procedures...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton(
                mini: true,
                onPressed: connectivity.isOnline ? _sendMessage : null,
                backgroundColor: connectivity.isOnline
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                child: const Icon(Icons.send, color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMessageBubble(AssistantMessage message) {
    Color bubbleColor;
    Color textColor;

    switch (message.messageType) {
      case MessageType.emergency:
        bubbleColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        break;
      case MessageType.guidance:
        bubbleColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        break;
      case MessageType.welcome:
        bubbleColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        break;
      default:
        bubbleColor = message.isUser
            ? Theme.of(context).colorScheme.primary
            : Colors.grey[100]!;
        textColor = message.isUser ? Colors.white : Colors.black87;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(
                Icons.assignment_ind,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16),
                border: message.messageType == MessageType.emergency
                    ? Border.all(color: Colors.red[300]!, width: 2)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(
              Icons.assignment_ind,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final delay = index * 0.2;
        final animationValue = (value - delay).clamp(0.0, 1.0);
        return Opacity(
          opacity: (animationValue * 2 - 1).abs(),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  void _showQuickReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Report'),
        content: const Text('This will open the report submission form with AI assistance.'),
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
            child: const Text('Open Form'),
          ),
        ],
      ),
    );
  }

  void _showMcpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MCP Card Update'),
        content: const Text('This will open the MCP card management system.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to MCP card
            },
            child: const Text('Open MCP'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emergency, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency Protocol'),
          ],
        ),
        content: const Text('Access emergency response procedures and contacts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Show emergency contacts
            },
            child: const Text('Emergency Contacts'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class AssistantMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType messageType;

  AssistantMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    required this.messageType,
  });
}

class FieldResponse {
  final String text;
  final MessageType type;

  FieldResponse({
    required this.text,
    required this.type,
  });
}

enum MessageType {
  user,
  welcome,
  guidance,
  emergency,
  general,
}

