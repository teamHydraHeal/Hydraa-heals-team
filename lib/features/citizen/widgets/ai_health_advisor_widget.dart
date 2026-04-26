import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/connectivity_provider.dart';

class AiHealthAdvisorWidget extends StatefulWidget {
  const AiHealthAdvisorWidget({super.key});

  @override
  State<AiHealthAdvisorWidget> createState() => _AiHealthAdvisorWidgetState();
}

class _AiHealthAdvisorWidgetState extends State<AiHealthAdvisorWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
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
      ChatMessage(
        text: "Hello! I'm your AI Health Assistant. I can help you with:\n\n"
            "💧 Water safety and quality questions\n"
            "🏥 Understanding common symptoms\n"
            "📚 Health tips and preventive measures\n"
            "🚨 Emergency guidance\n\n"
            "What health concern can I help you with today?",
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();
    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          text: userMessage,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });

    // Simulate AI response
    await Future.delayed(const Duration(seconds: 2));

    final aiResponse = _generateAiResponse(userMessage);

    setState(() {
      _messages.add(
        ChatMessage(
          text: aiResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = false;
    });
  }

  String _generateAiResponse(String userMessage) {
    final message = userMessage.toLowerCase();

    if (message.contains('water') || message.contains('drinking')) {
      return "💧 **Water Safety Guidance:**\n\n"
          "For safe drinking water:\n"
          "• Boil water for 1 minute before drinking\n"
          "• Use clean, covered containers for storage\n"
          "• Avoid drinking from unknown sources\n"
          "• If water looks/smells unusual, don't drink it\n\n"
          "If you suspect water contamination, report it immediately through the app or contact your local health center.";
    } else if (message.contains('diarrhea') || message.contains('stomach')) {
      return "🏥 **Diarrhea Management:**\n\n"
          "Immediate steps:\n"
          "• Drink plenty of clean, boiled water\n"
          "• Use oral rehydration solution (ORS)\n"
          "• Avoid dairy and fatty foods\n"
          "• Rest and monitor symptoms\n\n"
          "⚠️ Seek medical help if:\n"
          "• Symptoms persist for more than 2 days\n"
          "• High fever or severe dehydration\n"
          "• Blood in stool";
    } else if (message.contains('fever') || message.contains('temperature')) {
      return "🌡️ **Fever Management:**\n\n"
          "Home care:\n"
          "• Rest in a cool, well-ventilated room\n"
          "• Drink plenty of fluids\n"
          "• Use cool compresses on forehead\n"
          "• Monitor temperature regularly\n\n"
          "⚠️ Seek medical help if:\n"
          "• Fever above 102°F (39°C)\n"
          "• Fever lasts more than 3 days\n"
          "• Severe headache or neck stiffness";
    } else if (message.contains('prevent') || message.contains('avoid')) {
      return "🛡️ **Disease Prevention Tips:**\n\n"
          "• Wash hands frequently with soap\n"
          "• Drink only safe, boiled water\n"
          "• Eat freshly cooked food\n"
          "• Keep surroundings clean\n"
          "• Use mosquito nets and repellents\n"
          "• Get vaccinated as recommended\n\n"
          "These simple steps can prevent most water-borne diseases.";
    } else if (message.contains('emergency') || message.contains('urgent')) {
      return "🚨 **Emergency Response:**\n\n"
          "For immediate medical emergencies:\n"
          "• Call 108 (Ambulance)\n"
          "• Call 102 (Health Helpline)\n"
          "• Contact nearest health center\n\n"
          "Signs requiring immediate attention:\n"
          "• Severe dehydration\n"
          "• High fever with confusion\n"
          "• Severe abdominal pain\n"
          "• Difficulty breathing\n\n"
          "**This AI provides guidance only. Always consult healthcare professionals for serious conditions.**";
    } else {
      return "I understand you're concerned about your health. Here's some general guidance:\n\n"
          "💡 **General Health Tips:**\n"
          "• Maintain good hygiene practices\n"
          "• Stay hydrated with clean water\n"
          "• Eat a balanced diet\n"
          "• Get adequate rest\n"
          "• Exercise regularly\n\n"
          "If you have specific symptoms or concerns, please describe them in detail, and I'll provide more targeted advice. "
          "Remember, I'm here to help, but always consult healthcare professionals for proper medical diagnosis and treatment.";
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
                    hintText: 'Ask about health concerns...',
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

  Widget _buildMessageBubble(ChatMessage message) {
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
                Icons.psychology_alt,
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
                color: message.isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white70
                          : Colors.grey[600],
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
              Icons.psychology_alt,
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

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

