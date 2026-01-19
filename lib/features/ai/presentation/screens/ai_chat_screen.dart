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
      backgroundColor: const Color(0xFFFFFBF5),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              backgroundColor: const Color(0xFFFFFBF5),
              iconColor: const Color(0xFF241508),
              title: const Text(
                'Cultural AI Assistant',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'Campton',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF241508),
                ),
              ),
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
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Color(0xFFE57373), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatState.error ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Campton',
                          color: Color(0xFFE57373),
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
          const SizedBox(height: 32),
          
          // AI Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFDAF40).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 40,
              color: Color(0xFFFDAF40),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Welcome to Your Cultural\nFashion Assistant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontFamily: 'Campton',
              fontWeight: FontWeight.w600,
              color: Color(0xFF241508),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'I\'m here to help you discover Nigerian fashion, understand cultural significance, and find the perfect outfit for any occasion.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'Campton',
              color: const Color(0xFF241508).withOpacity(0.7),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          // Suggested Questions
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Try asking me:',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                fontWeight: FontWeight.w600,
                color: Color(0xFF777F84),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.chat_bubble_outline,
              size: 18,
              color: Color(0xFFFDAF40),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: Color(0xFF241508),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFCCCCCC),
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
                color: const Color(0xFFFDAF40).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.psychology,
                size: 18,
                color: Color(0xFFFDAF40),
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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFFFDAF40) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Campton',
                      color: isUser ? Colors.white : const Color(0xFF241508),
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
                            color: const Color(0xFFFDAF40).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFDAF40).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            suggestion,
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: 'Campton',
                              color: Color(0xFFFDAF40),
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
                    height: 120,
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
                color: Color(0xFF241508),
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
      width: 140,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              image: product.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(product.imageUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: product.imageUrl == null
                ? const Center(
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: Color(0xFFCCCCCC),
                    ),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF241508),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '₦${product.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Campton',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFDAF40),
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
              color: const Color(0xFFFDAF40).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.psychology,
              size: 18,
              color: Color(0xFFFDAF40),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
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
              const Color(0xFFCCCCCC),
              const Color(0xFFFDAF40),
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
        color: Colors.white,
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
            child: TextField(
              controller: _messageController,
              enabled: !isLoading,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Ask about Nigerian fashion...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Campton',
                  color: Color(0xFFAAAAAA),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Campton',
                color: Color(0xFF241508),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFDAF40),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: isLoading ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded),
              color: Colors.white,
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
