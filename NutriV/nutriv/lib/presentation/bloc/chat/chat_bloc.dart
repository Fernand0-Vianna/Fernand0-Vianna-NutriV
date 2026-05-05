import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../data/datasources/groq_chat_service.dart';
import '../../../domain/entities/user.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GroqChatService _chatService;
  User? _currentUser;

  ChatBloc(this._chatService) : super(const ChatInitial()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<ClearChat>(_onClearChat);
    on<SelectSuggestion>(_onSelectSuggestion);
    on<SetTyping>(_onSetTyping);
    on<ReceiveResponse>(_onReceiveResponse);
    on<ChatError>(_onChatError);
  }

  void setUser(User? user) {
    _currentUser = user;
  }

  Future<void> _onLoadChatHistory(
    LoadChatHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());
    try {
      final messages = _chatService.messageHistory;
      emit(ChatLoaded(
        messages: messages,
        suggestions: GroqChatService.getQuickSuggestions(),
      ));
    } catch (e) {
      emit(ChatErrorState('Erro ao carregar histórico: $e'));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      // Adiciona mensagem do usuário imediatamente
      final updatedMessages = List<ChatMessage>.from(currentState.messages)
        ..add(ChatMessage(role: 'user', content: event.message));

      emit(currentState.copyWith(
        messages: updatedMessages,
        isTyping: true,
        error: null,
      ));

      try {
        // Envia para a API
        final response = await _chatService.sendMessage(
          event.message,
          userContext: _currentUser,
        );

        // Adiciona resposta do assistente
        final finalMessages = List<ChatMessage>.from(updatedMessages)
          ..add(ChatMessage(role: 'assistant', content: response));

        emit(currentState.copyWith(
          messages: finalMessages,
          isTyping: false,
          error: null,
        ));
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Erro no ChatBloc: $e');
        }

        String errorMessage = 'Erro ao enviar mensagem';
        if (e.toString().contains('API Key')) {
          errorMessage = 'Erro de autenticação com a API';
        } else if (e.toString().contains('Limite')) {
          errorMessage = 'Limite de requisições atingido';
        }

        emit(currentState.copyWith(
          messages: updatedMessages,
          isTyping: false,
          error: errorMessage,
        ));
      }
    }
  }

  Future<void> _onReceiveResponse(
    ReceiveResponse event,
    Emitter<ChatState> emit,
  ) async {
    // Este evento é processado internamente pelo _onSendMessage
  }

  Future<void> _onClearChat(
    ClearChat event,
    Emitter<ChatState> emit,
  ) async {
    _chatService.clearHistory();
    final suggestions = GroqChatService.getQuickSuggestions();
    emit(ChatLoaded(
      messages: const [],
      suggestions: suggestions,
    ));
  }

  Future<void> _onSelectSuggestion(
    SelectSuggestion event,
    Emitter<ChatState> emit,
  ) async {
    // Dispara o evento de enviar mensagem com a sugestão
    add(SendMessage(event.suggestion));
  }

  Future<void> _onSetTyping(
    SetTyping event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(isTyping: event.isTyping));
    }
  }

  Future<void> _onChatError(
    ChatError event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(
        error: event.error,
        isTyping: false,
      ));
    }
  }
}
