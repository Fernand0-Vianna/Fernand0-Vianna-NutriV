import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatHistory extends ChatEvent {
  const LoadChatHistory();
}

class SendMessage extends ChatEvent {
  final String message;

  const SendMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class ReceiveResponse extends ChatEvent {
  final String response;

  const ReceiveResponse(this.response);

  @override
  List<Object?> get props => [response];
}

class ClearChat extends ChatEvent {
  const ClearChat();
}

class ChatError extends ChatEvent {
  final String error;

  const ChatError(this.error);

  @override
  List<Object?> get props => [error];
}

class SelectSuggestion extends ChatEvent {
  final String suggestion;

  const SelectSuggestion(this.suggestion);

  @override
  List<Object?> get props => [suggestion];
}

class SetTyping extends ChatEvent {
  final bool isTyping;

  const SetTyping(this.isTyping);

  @override
  List<Object?> get props => [isTyping];
}
