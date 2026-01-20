import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/widgets/app_header.dart';
import '../../../account/presentation/controllers/profile_controller.dart';
import '../../domain/ai_models.dart';
import '../controllers/ai_chat_controller.dart';

/// Cultural Context AI Chat Screen
/// 
/// Provides an AI assistant that understands Nigerian fashion culture
/// and can help buyers with fashion advice, cultural context, and
/// product recommendations.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isInitialized = false;

  // App consistent colors
  static const _backgroundColor = Color(0xFFFFFBF5);
  static const _cardColor = Color(0xFFF5E0CE);
  static const _primaryColor = Color(0xFFFDAF40);
  static const _textDark = Color(0xFF241508);
  static const _textSecondary = Color(0xFF777F84);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    final user = ref.read(userProfileProvider).value;
    if (user != null && !_isInitialized) {
      _isInitialized = true;
      await ref.read(aiChatControllerProvider.notifier).initialize(user.id.toString());
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    await ref.read(aiChatControllerProvider.notifier).sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatStateAsync = ref.watch(aiChatControllerProvider);
    final chatState = chatStateAsync.value ?? const AiChatState();

    // Scroll to bottom when new messages arrive
    ref.listen(aiChatControllerProvider, (previous, next) {
      final prevMessages = previous?.value?.messages ?? [];
      final nextMessages = next.value?.messages ?? [];
      if (prevMessages.length != nextMessages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: _backgroundColor,
              iconColor: _textDark,
              title: const Text(
                'Cultural AI Assistant',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              showActions: false,
            ),

            // Chat Messages
            Expanded(
              child: chatState.messages.isEmpty && !chatState.isLoading
                  ? _buildWelcomeView()
                  : _buildChatList(chatState),
            ),

            // Error message
            if (chatState.error != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: _primaryColor, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Unable to get response. Please try again.',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          color: _textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Message Input
            _buildMessageInput(chatState.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
          
          // AI Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 36,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Welcome to Your Cultural\nFashion Assistant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'I\'m here to help you discover Nigerian fashion, understand cultural significance, and find the perfect outfit for any occasion.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              color: _textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // Suggested Questions
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Try asking me:',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          ...defaultChatSuggestions.map((suggestion) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildSuggestionChip(suggestion),
          )),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return InkWell(
      onTap: () {
        ref.read(aiChatControllerProvider.notifier).sendSuggestion(suggestion);
        _scrollToBottom();
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 16,
              color: _primaryColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: _textDark,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: _textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(AiChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: state.messages.length + (state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == state.messages.length && state.isLoading) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(state.messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(AiChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _cardColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 18,
                color: _primaryColor,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser ? _primaryColor : _cardColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isUser ? 12 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 12),
                    ),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      color: isUser ? Colors.white : _textDark,
                      height: 1.4,
                    ),
                  ),
                ),

                // Suggestions
                if (!isUser && message.suggestions != null && message.suggestions!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: message.suggestions!.take(3).map((suggestion) {
                      return InkWell(
                        onTap: () {
                          ref.read(aiChatControllerProvider.notifier)
                              .sendSuggestion(suggestion);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            suggestion,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Campton',
                              color: _primaryColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Products
                if (!isUser && message.products != null && message.products!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: message.products!.length,
                      itemBuilder: (context, index) {
                        final product = message.products![index];
                        return _buildProductCard(product);
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: _textDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProductCard(AiSuggestedProduct product) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Container(
                width: double.infinity,
                color: _cardColor,
                child: product.imageUrl != null
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: _textSecondary,
                            size: 24,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: _textSecondary,
                          size: 24,
                        ),
                      ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w500,
                    color: _textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '₦${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 18,
              color: _primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
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
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: Color.lerp(
              _textSecondary,
              _primaryColor,
              value,
            ),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildMessageInput(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                enabled: !isLoading,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                decoration: const InputDecoration(
                  hintText: 'Ask about Nigerian fashion...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    fontFamily: 'Campton',
                    color: _textSecondary,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: _textDark,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: isLoading ? null : _sendMessage,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: _primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
