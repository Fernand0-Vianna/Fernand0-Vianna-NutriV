import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';

class ChatMessage {
  final String role; // 'user' ou 'assistant'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}

class GroqChatService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  static const String _model = 'llama-3.1-8b-instant'; // Modelo rápido e eficiente
  
  final String _apiKey;
  final List<ChatMessage> _messageHistory = [];
  
  GroqChatService({required String apiKey}) : _apiKey = apiKey;

  /// Envia uma mensagem para o assistente nutricional
  Future<String> sendMessage(String userMessage, {User? userContext}) async {
    try {
      // Adiciona mensagem do usuário ao histórico
      _messageHistory.add(ChatMessage(role: 'user', content: userMessage));
      
      // Mantém apenas as últimas 10 mensagens no contexto
      final contextMessages = _messageHistory.length > 10 
          ? _messageHistory.sublist(_messageHistory.length - 10)
          : _messageHistory;

      final messages = [
        {
          'role': 'system',
          'content': _buildSystemPrompt(userContext),
        },
        ...contextMessages.map((m) => {'role': m.role, 'content': m.content}),
      ];

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 1024,
          'top_p': 0.9,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final assistantMessage = data['choices'][0]['message']['content'] as String;
        
        // Adiciona resposta ao histórico
        _messageHistory.add(ChatMessage(role: 'assistant', content: assistantMessage));
        
        return assistantMessage;
      } else if (response.statusCode == 401) {
        throw Exception('API Key inválida ou expirada');
      } else if (response.statusCode == 429) {
        throw Exception('Limite de requisições atingido. Tente novamente em alguns segundos.');
      } else {
        throw Exception('Erro na API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro no GroqChatService: $e');
      }
      throw Exception('Erro ao comunicar com assistente: $e');
    }
  }

  /// Constrói o prompt do sistema com contexto nutricional
  String _buildSystemPrompt(User? user) {
    final buffer = StringBuffer();
    
    buffer.writeln('Você é NutriV Assistente, um especialista em nutrição e saúde alimentar.');
    buffer.writeln('Você ajuda usuários com dicas nutricionais, informações sobre alimentos, planejamento de refeições e orientações de dieta.');
    buffer.writeln('Seja sempre educado, profissional e baseie suas respostas em ciência nutricional.');
    buffer.writeln();
    buffer.writeln('Diretrizes importantes:');
    buffer.writeln('- Forneça informações nutricionais precisas e atualizadas');
    buffer.writeln('- Sugira alternativas saudáveis quando apropriado');
    buffer.writeln('- Respeite restrições alimentares e preferências do usuário');
    buffer.writeln('- Não faça diagnósticos médicos ou prescrições de medicamentos');
    buffer.writeln('- Encaminhe para profissionais de saúde quando necessário');
    buffer.writeln('- Use português brasileiro natural e amigável');
    buffer.writeln('- Seja conciso mas completo nas respostas');
    
    if (user != null) {
      buffer.writeln();
      buffer.writeln('Contexto do usuário:');
      buffer.writeln('- Nome: ${user.name}');
      buffer.writeln('- Peso: ${user.weight} kg');
      buffer.writeln('- Altura: ${user.height} cm');
      buffer.writeln('- Idade: ${user.age} anos');
      buffer.writeln('- Sexo: ${user.isMale ? "Masculino" : "Feminino"}');
      buffer.writeln('- Meta calórica: ${user.calorieGoal.toInt()} kcal');
      buffer.writeln('- Meta de água: ${user.waterGoal.toInt()} ml');
      
      if (user.goal == 'lose') {
        buffer.writeln('- Objetivo: Perder peso');
      } else if (user.goal == 'gain') {
        buffer.writeln('- Objetivo: Ganhar peso');
      } else {
        buffer.writeln('- Objetivo: Manter peso');
      }
    }
    
    return buffer.toString();
  }

  /// Limpa o histórico de conversação
  void clearHistory() {
    _messageHistory.clear();
  }

  /// Obtém o histórico de mensagens
  List<ChatMessage> get messageHistory => List.unmodifiable(_messageHistory);

  /// Sugestões rápidas de perguntas
  static List<String> getQuickSuggestions() => [
    'Quantas proteínas tem um ovo?',
    'Quais alimentos são ricos em proteína?',
    'Quanto carboidrato tem no arroz?',
    'Quantas calorias tem um abacate?',
    'Me sugere um café da manhã saudável',
    'O que comer antes do treino?',
  ];

  /// Analisa uma refeição e fornece feedback nutricional
  Future<String> analyzeMeal(String mealDescription, double totalCalories) async {
    final prompt = '''
Analise esta refeição e forneça um breve feedback nutricional (2-3 frases):

Refeição: $mealDescription
Calorias totais: ${totalCalories.toInt()} kcal

Forneça:
1. Uma avaliação geral do equilíbrio nutricional
2. Uma sugestão de melhoria, se aplicável
3. Mantenha um tom positivo e construtivo
''';    

    return await sendMessage(prompt);
  }

  /// Gera uma sugestão de refeição baseada nos parâmetros
  Future<String> generateMealSuggestion({
    required String mealType,
    int targetCalories = 500,
    List<String> preferences = const [],
    List<String> restrictions = const [],
  }) async {
    final prompt = '''
Sugira uma refeição completa com as seguintes características:

Tipo: $mealType
Calorias alvo: ${targetCalories}kcal
${preferences.isNotEmpty ? 'Preferências: ${preferences.join(", ")}' : ''}
${restrictions.isNotEmpty ? 'Restrições: ${restrictions.join(", ")}' : ''}

Forneça:
- Nome da refeição
- Lista de alimentos com quantidades aproximadas
- Total de calorias estimado
- Principais nutrientes (proteína, carboidratos, gorduras)
''';    

    return await sendMessage(prompt);
  }

  /// Explica a composição nutricional de alimentos em linguagem natural
  Future<String> explainNutrition({
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double? portion,
  }) async {
    final portionText = portion != null ? '${portion.toInt()}g' : '100g';
    final prompt = '''
Explique a composição nutricional do alimento "$foodName" (porção: $portionText):

Calorias: ${calories.toInt()} kcal
Proteína: ${protein.toStringAsFixed(1)}g
Carboidratos: ${carbs.toStringAsFixed(1)}g
Gordura: ${fat.toStringAsFixed(1)}g

Forneça:
1. Breve explicação do que esses valores significam para a saúde
2. Quais são os pontos positivos e negativos dessa composição
3. Uma dica de consumo, se aplicável
4. Emojis apropriados para cada nutrient (🔥calorias, 💪proteína, 🍞carbos, 🥑gordura)

Mantenha em 3-4 frases, seja didático e amigável.
''';
    return await sendMessage(prompt);
  }

  /// Busca informações detalhadas sobre vitaminas e minerais de um alimento
  Future<String> getNutritionalInfo(String foodName) async {
    final prompt = '''
Forneça informações sobre vitaminas e minerais presentes em "$foodName".

Liste:
- Quais vitaminas (A, B, C, D, E, K, etc.) estão presentes e seus benefícios
- Quais minerais (ferro, cálcio, potássio, magnnésio, etc.) estão presentes
- Benefícios gerais para a saúde
- Quantidade diária recomendada, se aplicável

Seja específico para alimentos brasileiros常见. Use emojis para vitaminais e minerais.
''';
    return await sendMessage(prompt);
  }

  /// Analisa uma lista de alimentos e fornece feedback completo
  Future<String> analyzeFoodList(List<Map<String, dynamic>> foodList) async {
    final foodsText = foodList.map((f) =>
      "- ${f['name']}: ${f['calories']}kcal, P:${f['protein']}g, C:${f['carbs']}g, G:${f['fat']}g"
    ).join('\n');

    final prompt = '''
Analise esta lista de alimentos e forneça feedback nutricional completo:

$foodsText

Forneça:
1. Total de calorias
2. Distribuição de macros (proteína, carbs, gordura)
3. Avaliação geral do equilíbrio da refeição
4. Sugestões de melhoria ou complementação
5. Pontos positivos da escolha de alimentos
''';
    return await sendMessage(prompt);
  }

  /// Sugere alternativas mais saudáveis para um alimento
  Future<String> suggestHealthyAlternatives(String foodName) async {
    final prompt = '''
Sugira alternativas mais saudáveis para "$foodName".

Para cada alternativa:
- Nome da alternativa
- Por que é mais saudável (menos calorias, mais nutrientes, etc.)
- Comparação rápida de nutrientes

Liste 3-4 alternativas práticas e easily encontrados no Brasil.
''';
    return await sendMessage(prompt);
  }

  /// Analisa o progresso nutricional diário do usuário
  Future<String> analyzeDailyProgress({
    required double consumedCalories,
    required double targetCalories,
    required double protein,
    required double targetProtein,
    required double carbs,
    required double targetCarbs,
    required double fat,
    required double targetFat,
  }) async {
    final prompt = '''
Analise meu progresso nutricional de hoje:

Consumo:
- Calorias: ${consumedCalories.toInt()} / ${targetCalories.toInt()} kcal
- Proteína: ${protein.toInt()}g / ${targetProtein.toInt()}g
- Carboidratos: ${carbs.toInt()}g / ${targetCarbs.toInt()}g
- Gordura: ${fat.toInt()}g / ${targetFat.toInt()}g

Forneça:
1. Status geral (no caminho, acima ou abaixo da meta)
2. O que está indo bem
3. O que precisa de ajuste
4. Sugestão para as próximas refeições do dia
''';
    return await sendMessage(prompt);
  }
}
