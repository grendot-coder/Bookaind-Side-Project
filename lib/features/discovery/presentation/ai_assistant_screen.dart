import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../shared/data/mock_cultural_data.dart';
import '../../../shared/models/cultural_model.dart';
import '../../../core/services/groq_cultural_service.dart';

/// Data class representing a message in the cultural conversation
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime? timestamp;
  final Destination? attachedDestination;
  final CulturalEntry? attachedCulturalEntry;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.attachedDestination,
    this.attachedCulturalEntry,
  });
}

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // The conversation history
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text:
          'Sugeng Rawuh & Sampurasun! 🙏\n\nI am your Nusantara Cultural Guide. I can help you uncover ancient temple histories, royal culinary traditions, batik philosophies, or plan cultural itineraries across Java.\n\nWhat would you like to explore today?',
      isUser: false,
      timestamp: null, // Initial greeting
    ),
  ];

  // Quick prompt suggestions
  final List<String> _suggestions = [
    'Must-see temples in Yogyakarta & Central Java',
    'Tell me about authentic East Java culinary',
    'What is the philosophy of Batik Tulis?',
    'Temple etiquette & sarong rules',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String query) async {
    if (query.trim().isEmpty) return;

    final userText = query.trim();
    _textController.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: userText, isUser: true, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _scrollToBottom();

    // Prepare previous conversation history for context
    final history = _messages
        .where((m) => m.timestamp != null)
        .map(
          (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text},
        )
        .toList();

    // 🚀 CALL YOUR LIVE GROQ API!
    final aiAnswer = await GroqCulturalService.generateCulturalAnswer(
      userPrompt: userText,
      conversationHistory: history,
    );

    if (!mounted) return;

    // Detect if Groq mentioned any of our destinations to attach an interactive card!
    Destination? attachedDestination;
    CulturalEntry? attachedCultural;

    final lower = aiAnswer.toLowerCase();
    if (lower.contains('borobudur')) {
      attachedDestination = MockCulturalData.featuredDestinations.firstWhere(
        (d) => d.id == 'borobudur',
      );
    } else if (lower.contains('bromo')) {
      attachedDestination = MockCulturalData.featuredDestinations.firstWhere(
        (d) => d.id == 'bromo',
      );
    } else if (lower.contains('prambanan')) {
      attachedDestination = MockCulturalData.featuredDestinations.firstWhere(
        (d) => d.id == 'prambanan',
      );
    }

    if (lower.contains('rawon')) {
      attachedCultural = MockCulturalData.culturalEntries.firstWhere(
        (e) => e.id == 'rawon',
      );
    } else if (lower.contains('gudeg')) {
      attachedCultural = MockCulturalData.culturalEntries.firstWhere(
        (e) => e.id == 'gudeg',
      );
    } else if (lower.contains('batik')) {
      attachedCultural = MockCulturalData.culturalEntries.firstWhere(
        (e) => e.id == 'batik_tulis',
      );
    }

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage(
          text: aiAnswer,
          isUser: false,
          timestamp: DateTime.now(),
          attachedDestination: attachedDestination,
          attachedCulturalEntry: attachedCultural,
        ),
      );
    });

    _scrollToBottom();
  }

  // 👉 Right after the closing brace of _sendMessage, it goes straight to build:
  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colors.cream,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cultural Discovery AI',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'Online • Nusantara Guide',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. MESSAGES LIST
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _ChatBubble(message: message);
              },
            ),
          ),

          // 2. TYPING INDICATOR (Shown while AI is generating)
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: colors.coralSubtle,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: colors.coral,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cultural Guide is thinking...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.mutedBrown,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // 3. QUICK SUGGESTION CHIPS (Horizontal scroll)
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(_suggestions[index]),
                    labelStyle: TextStyle(
                      color: colors.charcoal,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    backgroundColor: colors.warmWhite,
                    side: BorderSide(
                      color: colors.mutedBrown.withValues(alpha: 0.2),
                    ),
                    onPressed: () => _sendMessage(_suggestions[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 4. INPUT BAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            decoration: BoxDecoration(
              color: colors.warmWhite,
              border: Border(
                top: BorderSide(
                  color: colors.mutedBrown.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: _sendMessage,
                    decoration: InputDecoration(
                      hintText: 'Ask about temples, batik, culinary...',
                      hintStyle: TextStyle(
                        color: colors.mutedBrown,
                        fontSize: 14,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      filled: true,
                      fillColor: colors.cream.withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: colors.mutedBrown.withValues(alpha: 0.2),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: colors.mutedBrown.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 22,
                  backgroundColor: colors.coral,
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () => _sendMessage(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Message bubble widget with support for embedded interactive cards
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: colors.coralSubtle,
              child: Icon(Icons.auto_awesome, size: 16, color: colors.coral),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? colors.coral : colors.warmWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Colors.transparent
                          : colors.mutedBrown.withValues(alpha: 0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isUser ? Colors.white : colors.charcoal,
                      height: 1.45,
                    ),
                  ),
                ),

                // Embedded Destination Recommendation Card
                if (message.attachedDestination != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.push(
                      '/destination/${message.attachedDestination!.id}',
                    ),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.warmWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.coral.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              message.attachedDestination!.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.attachedDestination!.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Tap to view guide →',
                                  style: TextStyle(
                                    color: colors.coral,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Embedded Cultural Entry Recommendation Card
                if (message.attachedCulturalEntry != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => context.push(
                      '/cultural/${message.attachedCulturalEntry!.id}',
                    ),
                    child: Container(
                      width: 260,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.warmWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.teal.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              message.attachedCulturalEntry!.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.attachedCulturalEntry!.title,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Read cultural story →',
                                  style: TextStyle(
                                    color: colors.teal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
