import 'restaurant.dart';

/// Types of messages in the chat conversation.
enum MessageType {
  /// Message sent by the user.
  user,

  /// Response from the AI assistant.
  assistant,

  /// System message (e.g., welcome message).
  system
}

/// Represents a single message in the chat conversation.
///
/// Can contain text content and optionally a list of restaurant
/// recommendations when the AI suggests places to eat.
class ChatMessage {
  /// Unique identifier for the message (timestamp-based).
  final String id;

  /// The text content of the message.
  final String content;

  /// Who sent this message (user, assistant, or system).
  final MessageType type;

  /// When the message was created.
  final DateTime timestamp;

  /// List of recommended restaurants (only for assistant messages).
  final List<Restaurant>? recommendations;

  /// Whether this is a loading placeholder message.
  final bool isLoading;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.recommendations,
    this.isLoading = false,
  });

  /// Creates a user message with the given content.
  factory ChatMessage.user(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
  }

  /// Creates an assistant response message, optionally with restaurant recommendations.
  factory ChatMessage.assistant(String content, {List<Restaurant>? recommendations}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      recommendations: recommendations,
    );
  }

  /// Creates a loading placeholder message shown while AI is processing.
  factory ChatMessage.loading() {
    return ChatMessage(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      content: '',
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      isLoading: true,
    );
  }

  /// Creates a system message (e.g., welcome or error messages).
  factory ChatMessage.system(String content) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now(),
    );
  }

  /// Creates a copy of this message with optionally modified fields.
  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    List<Restaurant>? recommendations,
    bool? isLoading,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
