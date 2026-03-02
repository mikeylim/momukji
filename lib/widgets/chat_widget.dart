import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/app_provider.dart';
import '../models/chat_message.dart';
import 'restaurant_card.dart';

/// Chat interface widget for conversing with the AI food concierge.
///
/// Displays a scrollable list of chat messages with a text input
/// at the bottom. Messages are styled differently based on sender:
/// - User messages: right-aligned, primary color
/// - Assistant messages: left-aligned, grey background
/// - System messages: left-aligned, orange background
///
/// Assistant messages may include restaurant recommendation cards.
class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  /// Controller for the message input text field.
  final TextEditingController _controller = TextEditingController();

  /// Controller for scrolling the message list.
  final ScrollController _scrollController = ScrollController();

  /// Focus node for managing keyboard focus on input.
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            // Scrollable message list
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: provider.chatMessages.length,
                itemBuilder: (context, index) {
                  final message = provider.chatMessages[index];
                  return _buildMessageBubble(context, message, provider);
                },
              ),
            ),
            // Message input area
            _buildInputArea(context, provider),
          ],
        );
      },
    );
  }

  /// Builds a chat bubble for a single message.
  ///
  /// Handles three message types:
  /// - Loading: shows animated dots
  /// - Regular: shows text with appropriate styling
  /// - With recommendations: includes restaurant cards below text
  Widget _buildMessageBubble(
    BuildContext context,
    ChatMessage message,
    AppProvider provider,
  ) {
    // Show loading animation for pending AI response
    if (message.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: SpinKitThreeBounce(
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
          ],
        ),
      );
    }

    final isUser = message.type == MessageType.user;
    final isSystem = message.type == MessageType.system;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser
                  ? Theme.of(context).primaryColor
                  : isSystem
                      ? Colors.orange[100]
                      : Colors.grey[200],
              borderRadius: BorderRadius.circular(16).copyWith(
                // Pointed corner indicates message direction
                bottomRight: isUser ? const Radius.circular(4) : null,
                bottomLeft: !isUser ? const Radius.circular(4) : null,
              ),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),

          // Restaurant recommendation cards (if any)
          if (message.recommendations != null &&
              message.recommendations!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...message.recommendations!.map(
              (restaurant) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RestaurantCard(restaurant: restaurant),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the message input area at the bottom of the screen.
  Widget _buildInputArea(BuildContext context, AppProvider provider) {
    final isKorean = provider.locale.languageCode == 'ko';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text input field
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: isKorean
                      ? '뭐 먹고 싶으세요?'
                      : 'What do you want to eat?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (value) => _sendMessage(provider),
              ),
            ),
            const SizedBox(width: 8),
            // Send button
            IconButton.filled(
              onPressed: () => _sendMessage(provider),
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }

  /// Sends the current message to the AI.
  ///
  /// Clears the input, maintains focus for quick follow-up,
  /// and scrolls to show the new message.
  void _sendMessage(AppProvider provider) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    provider.sendMessage(text);
    _controller.clear();
    _focusNode.requestFocus();

    // Scroll to bottom after message is added
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
