import 'package:flutter/material.dart';
import '../../../core/services/chat_service.dart';
import '../../../core/services/tts_service.dart';

/// Beautiful AI chat widget powered by Ollama LLM with inline TTS.
///
/// Features:
/// - Ollama-powered intelligent responses about water quality & health
/// - Inline TTS: tap 🔊 on any AI message to hear it in a regional language
/// - Animated typing indicator
/// - Gradient message bubbles & modern design
/// - Regional language picker for TTS playback
class AiChatWidget extends StatefulWidget {
  final Map<String, dynamic>? actionPlanContext;

  const AiChatWidget({
    super.key,
    this.actionPlanContext,
  });

  @override
  State<AiChatWidget> createState() => _AiChatWidgetState();
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool llmUsed;
  bool isSpeaking;

  _ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.llmUsed = true,
  })  : isSpeaking = false,
        timestamp = timestamp ?? DateTime.now();
}

class _AiChatWidgetState extends State<AiChatWidget>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<_ChatMessage> _messages = [];
  final List<Map<String, String>> _history = [];

  bool _isTyping = false;
  bool _ollamaOnline = false;
  String _ttsLanguage = 'hindi';
  int? _speakingIndex;

  // Beautiful gradient colors
  static const _primaryGradient = [Color(0xFF667eea), Color(0xFF764ba2)];
  static const _userBubbleGradient = [Color(0xFF4facfe), Color(0xFF00f2fe)];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    _checkOllamaStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    TtsService.stop();
    super.dispose();
  }

  void _addWelcomeMessage() {
    _messages.add(_ChatMessage(
      text:
          'Namaste! \u{1F64F} I\'m Jal Guard AI \u{2014} your water quality and health assistant.\n\n'
          'Ask me anything about water safety, health risks, or precautions. '
          'I can also read my answers aloud in your language \u{2014} just tap the \u{1F50A} icon!',
      isUser: false,
    ));
  }

  Future<void> _checkOllamaStatus() async {
    final status = await ChatService.checkOllamaStatus();
    if (mounted) {
      setState(() {
        _ollamaOnline = status['ollama_running'] == true &&
            status['model_ready'] == true;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isTyping) return;

    _controller.clear();

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Add to history for context
    _history.add({'role': 'user', 'content': text});

    // Call Ollama chat backend
    final result = await ChatService.sendMessage(
      text,
      history: _history,
      context: widget.actionPlanContext,
    );

    final response = result['response'] as String? ?? 'No response.';
    final llmUsed = result['llm_used'] as bool? ?? false;

    _history.add({'role': 'assistant', 'content': response});

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(
          text: response,
          isUser: false,
          llmUsed: llmUsed,
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _speakMessage(int index) async {
    final msg = _messages[index];
    if (msg.isUser) return;

    // If already speaking this message, stop
    if (_speakingIndex == index) {
      await TtsService.stop();
      setState(() {
        _messages[index].isSpeaking = false;
        _speakingIndex = null;
      });
      return;
    }

    // Stop any current speech
    if (_speakingIndex != null) {
      await TtsService.stop();
      _messages[_speakingIndex!].isSpeaking = false;
    }

    setState(() {
      _messages[index].isSpeaking = true;
      _speakingIndex = index;
    });

    await TtsService.translateAndSpeak(
      msg.text,
      language: _ttsLanguage,
      onComplete: () {
        if (mounted) {
          setState(() {
            _messages[index].isSpeaking = false;
            _speakingIndex = null;
          });
        }
      },
      onError: (err) {
        if (mounted) {
          setState(() {
            _messages[index].isSpeaking = false;
            _speakingIndex = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('TTS: $err'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8F9FE), Color(0xFFEEF1F8)],
        ),
      ),
      child: Column(
        children: [
          _buildTopBar(),
          Expanded(child: _buildMessageList()),
          _buildInputArea(),
        ],
      ),
    );
  }

  // ===== TOP STATUS BAR =====
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ollama status pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _ollamaOnline
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _ollamaOnline ? Colors.green : Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _ollamaOnline ? 'AI Online' : 'Fallback Mode',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _ollamaOnline
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // TTS Language selector
          Icon(Icons.volume_up_rounded, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F0FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFD1C4E9)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _ttsLanguage,
                isDense: true,
                icon: Icon(Icons.expand_more,
                    size: 16, color: Colors.deepPurple.shade400),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.deepPurple.shade700,
                ),
                items: TtsService.supportedLanguages.entries.map((e) {
                  return DropdownMenuItem(
                    value: e.key,
                    child: Text(e.value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _ttsLanguage = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== MESSAGE LIST =====
  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index], index);
      },
    );
  }

  // ===== MESSAGE BUBBLE =====
  Widget _buildMessageBubble(_ChatMessage msg, int index) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) _buildAvatar(false),
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isUser
                        ? const LinearGradient(colors: _userBubbleGradient)
                        : null,
                    color: isUser ? null : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? const Color(0xFF4facfe).withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF2D3142),
                      fontSize: 14.5,
                      height: 1.45,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Bottom row: timestamp + TTS button for AI messages
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(msg.timestamp),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    if (!isUser) ...[
                      const SizedBox(width: 8),
                      _buildTtsButton(index, msg),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
          if (isUser) _buildAvatar(true),
        ],
      ),
    );
  }

  // ===== TTS SPEAK BUTTON =====
  Widget _buildTtsButton(int index, _ChatMessage msg) {
    final isSpeaking = msg.isSpeaking;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _speakMessage(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            gradient: isSpeaking
                ? const LinearGradient(colors: _primaryGradient)
                : null,
            color: isSpeaking ? null : const Color(0xFFF3F0FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSpeaking ? Icons.stop_rounded : Icons.volume_up_rounded,
                size: 14,
                color: isSpeaking ? Colors.white : const Color(0xFF667eea),
              ),
              const SizedBox(width: 4),
              Text(
                isSpeaking ? 'Stop' : '\u{1F50A} Listen',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSpeaking ? Colors.white : const Color(0xFF667eea),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== AVATAR =====
  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: isUser
            ? const LinearGradient(
                colors: [Color(0xFF4facfe), Color(0xFF00f2fe)])
            : const LinearGradient(colors: _primaryGradient),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: (isUser ? const Color(0xFF4facfe) : const Color(0xFF667eea))
                .withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.water_drop_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  // ===== TYPING INDICATOR =====
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildAvatar(false),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                const SizedBox(width: 4),
                _buildDot(1),
                const SizedBox(width: 4),
                _buildDot(2),
                const SizedBox(width: 10),
                Text(
                  'Thinking...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade400,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delay * 200),
      curve: Curves.easeInOut,
      builder: (_, value, __) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF667eea).withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  // ===== INPUT AREA =====
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(fontSize: 14.5),
                  decoration: InputDecoration(
                    hintText: 'Ask about water safety, health risks...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: _primaryGradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667eea).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: _isTyping ? null : _sendMessage,
                icon: const Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
