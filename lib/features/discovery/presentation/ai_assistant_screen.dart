import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/ai_gateway_service.dart';
import '../../../core/services/local_settings_service.dart';
import '../../../shared/data/mock_cultural_data.dart';
import '../../../shared/models/cultural_model.dart';
import '../../profile/presentation/widgets/profile_settings_sheet.dart';

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

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  // The conversation history
  final List<ChatMessage> _messages = [
    const ChatMessage(
      text:
          'Sugeng Rawuh & Sampurasun! 🙏\n\nI am your Nusantara Cultural Guide. I can help you uncover ancient temple histories, royal culinary traditions, batik philosophies, or plan cultural itineraries across Indonesia.\n\nWhat would you like to explore today?',
      isUser: false,
      timestamp: null, // Initial greeting
    ),
  ];

  // Quick prompt suggestions
  final List<String> _suggestions = [
    'Must-see places in Yogyakarta & Central Java',
    'Tell me about authentic East Java culinary',
    'The best anti-mainstream destination outside Java and Bali',
    'How much do i need to save up before visiting indonesia?',
    'What is the philosophy of Batik Tulis?',
    'Temple etiquette',
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

    String aiAnswer;
    try {
      final raw = await AiGatewayService.generateText(
        userPrompt: userText,
        conversationHistory: history,
        systemPrompt:
            'You are the Nusantara Cultural Guide for Bookaind. Answer questions about Indonesian heritage, '
            'ancient temples, royal palaces, traditional culinary dishes, textiles, and cultural etiquette '
            'concisely and respectfully in plain prose (no markdown asterisks).',
      );
      aiAnswer = raw.replaceAll('*', '').trim();
    } on AiGatewayException catch (e) {
      if (e.isMissingKey) {
        aiAnswer =
            'Bookaind is currently in Offline Mode with no AI API key configured.\n\n'
            'Tap "Add AI Key" at the top of this screen to paste a free Groq or Gemini API key and unlock live cultural answers.';
      } else {
        aiAnswer = e.message;
      }
    } catch (e) {
      aiAnswer = 'Unable to connect to AI provider: $e';
    }

    if (!mounted) return;

    // Detect if Groq mentioned any of our destinations to attach an interactive card!
    Destination? attachedDestination;
    CulturalEntry? attachedCultural;

    Destination? findDestination(String id) {
      for (final d in MockCulturalData.featuredDestinations) {
        if (d.id == id) return d;
      }
      return null;
    }

    CulturalEntry? findCultural(String id) {
      for (final e in MockCulturalData.culturalEntries) {
        if (e.id == id) return e;
      }
      return null;
    }

    final lower = aiAnswer.toLowerCase();
    if (lower.contains('borobudur')) {
      attachedDestination = findDestination('borobudur');
    } else if (lower.contains('bromo')) {
      attachedDestination = findDestination('bromo');
    } else if (lower.contains('prambanan')) {
      attachedDestination = findDestination('prambanan');
    }

    if (lower.contains('rawon')) {
      attachedCultural = findCultural('rawon');
    } else if (lower.contains('gudeg')) {
      attachedCultural = findCultural('gudeg');
    } else if (lower.contains('batik')) {
      attachedCultural = findCultural('batik_tulis');
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

  void _openByokSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProfileSettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final aiSettings = ref.watch(aiSettingsProvider);
    final hasKey = aiSettings.hasApiKey;

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
                  decoration: BoxDecoration(
                    color: hasKey ? Colors.green : colors.saffron,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  hasKey
                      ? 'BYOK Active • ${aiSettings.provider.shortLabel}'
                      : 'Offline Guide • Tap Add AI Key',
                  style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: _openByokSheet,
              icon: Icon(Icons.key_rounded, size: 17, color: colors.coral),
              label: Text(
                hasKey ? 'AI Key' : 'Add AI Key',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.coral,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!hasKey)
            InkWell(
              onTap: _openByokSheet,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.saffronSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.saffron.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.key_rounded, size: 18, color: colors.charcoal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Bring Your Own Key: Add a free Groq or Gemini key to enable live AI chat.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.charcoal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Setup',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.coral,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // Top Shortcut Banner to Smart Itinerary Planner
          GestureDetector(
            onTap: () => context.push('/itinerary-planner'),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: colors.warmWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.coral.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colors.coral.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.route_rounded, size: 16, color: colors.coral),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need a multi-day trip route?',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.charcoal,
                          ),
                        ),
                        Text(
                          'Open the Smart Cultural Itinerary Planner →',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.coral,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

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
