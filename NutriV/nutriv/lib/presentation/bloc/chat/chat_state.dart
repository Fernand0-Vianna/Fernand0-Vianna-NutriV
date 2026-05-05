import 'package:equatable/equatable.dart';
import '../../../data/datasources/groq_chat_service.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;
  final List<String> suggestions;

  const ChatLoaded({
    required this.messages,
    this.isTyping = false,
    this.error,
    this.suggestions = const [],
  });

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
    List<String>? suggestions,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
      suggestions: suggestions ?? this.suggestions,
    );
  }

  @override
  List<Object?> get props => [messages, isTyping, error, suggestions];
}

class ChatErrorState extends ChatState {
  final String message;

  const ChatErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
