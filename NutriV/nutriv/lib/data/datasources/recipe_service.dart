import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class Recipe {
  final String label;
  final String imageUrl;
  final String url;
  final int calories;
  final int totalTime;
  final int yield_;
  final List<String> ingredients;
  final double protein;
  final double carbs;
  final double fat;
  final double fiber;

  Recipe({
    required this.label,
    required this.imageUrl,
    required this.url,
    required this.calories,
    required this.totalTime,
    required this.yield_,
    required this.ingredients,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final recipe = json['recipe'] ?? json;
    return Recipe(
      label: recipe['label'] ?? '',
      imageUrl: recipe['image'] ?? '',
      url: recipe['url'] ?? '',
      calories: (recipe['calories'] ?? 0).toInt(),
      totalTime: recipe['totalTime'] ?? 0,
      yield_: recipe['yield'] ?? 0,
      ingredients: List<String>.from(recipe['ingredientLines'] ?? []),
      protein: (recipe['totalNutrients']?['PROCNT']?['quantity'] ?? 0).toDouble(),
      carbs: (recipe['totalNutrients']?['CHOCDF']?['quantity'] ?? 0).toDouble(),
      fat: (recipe['totalNutrients']?['FAT']?['quantity'] ?? 0).toDouble(),
      fiber: (recipe['totalNutrients']?['FIBTG']?['quantity'] ?? 0).toDouble(),
    );
  }
}

class RecipeService {
  static const String _baseUrl = 'https://api.edamam.com/api/recipes/v2';
  String? _appId;
  String? _appKey;

  RecipeService() {
    _appId = dotenv.env['EDAMAM_APP_ID'];
    _appKey = dotenv.env['EDAMAM_APP_KEY'];
  }

  Future<List<Recipe>> searchRecipes({
    String? query,
    String? diet,
    String? cuisine,
    int? calories,
    int from = 0,
    int to = 10,
  }) async {
    try {
      if (_appId == null || _appKey == null) {
        return _getFallbackRecipes();
      }

      final queryParams = {
        'type': 'public',
        'app_id': _appId,
        'app_key': _appKey,
        'q': ?query,
        'diet': ?diet,
        'cuisineType': ?cuisine,
        if (calories != null) 'calories': '$calories',
        'from': from.toString(),
        'to': to.toString(),
      };

      final uri = Uri.parse(_baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hits = data['hits'] as List? ?? [];
        return hits.map((hit) => Recipe.fromJson(hit)).toList();
      }

      return _getFallbackRecipes();
    } catch (e) {
      return _getFallbackRecipes();
    }
  }

  Future<List<Recipe>> getHealthyRecipes({int from = 0, int to = 10}) async {
    return searchRecipes(
      query: 'healthy',
      diet: 'balanced',
      from: from,
      to: to,
    );
  }

  Future<List<Recipe>> getLowCarbRecipes({int from = 0, int to = 10}) async {
    return searchRecipes(
      query: 'low carb',
      diet: 'low-carb',
      from: from,
      to: to,
    );
  }

  Future<List<Recipe>> getHighProteinRecipes({int from = 0, int to = 10}) async {
    return searchRecipes(
      query: 'high protein',
      diet: 'high-protein',
      from: from,
      to: to,
    );
  }

  Future<List<Recipe>> getWeightLossRecipes({int from = 0, int to = 10}) async {
    return searchRecipes(
      query: 'weight loss',
      diet: 'balanced',
      calories: 600,
      from: from,
      to: to,
    );
  }

  List<Recipe> _getFallbackRecipes() {
    return [
      Recipe(
        label: 'Salada Caesar Saludável',
        imageUrl: 'https://via.placeholder.com/300x200.png?text=Salad',
        url: '',
        calories: 350,
        totalTime: 15,
        yield_: 2,
        ingredients: [
          '2 xícaras de alface romana',
          '1 peito de frango grelhado',
          '2 colheres de parmesão',
          '1 xícara croutons',
          'Molho caesar light',
        ],
        protein: 28,
        carbs: 18,
        fat: 18,
        fiber: 4,
      ),
      Recipe(
        label: 'Salmão com Brócolis',
        imageUrl: 'https://via.placeholder.com/300x200.png?text=Salmon',
        url: '',
        calories: 420,
        totalTime: 25,
        yield_: 2,
        ingredients: [
          '2 filés de salmão',
          '2 xícaras de brócolis',
          '1 limão',
          '2 colheres de azeite',
          'Alho e temperos',
        ],
        protein: 35,
        carbs: 12,
        fat: 24,
        fiber: 5,
      ),
      Recipe(
        label: 'Tigela Buddha',
        imageUrl: 'https://via.placeholder.com/300x200.png?text=Buddha',
        url: '',
        calories: 380,
        totalTime: 20,
        yield_: 1,
        ingredients: [
          '1 xícara quinoa',
          '1/2/abacate',
          '1 ovo frito',
          'Grão de bico',
          'Vegetais mistos',
        ],
        protein: 18,
        carbs: 42,
        fat: 16,
        fiber: 12,
      ),
      Recipe(
        label: 'Smoothie Proteico',
        imageUrl: 'https://via.placeholder.com/300x200.png?text=Smoothie',
        url: '',
        calories: 280,
        totalTime: 5,
        yield_: 1,
        ingredients: [
          '1 scoop proteína',
          '1 banana',
          '1 xícara leite',
          '1 colher aveia',
          'Gelo',
        ],
        protein: 30,
        carbs: 32,
        fat: 4,
        fiber: 4,
      ),
      Recipe(
        label: 'Frango Grelhado com Arroz',
        imageUrl: 'https://via.placeholder.com/300x200.png?text=Chicken',
        url: '',
        calories: 450,
        totalTime: 30,
        yield_: 2,
        ingredients: [
          '2 peitos de frango',
          '1 xícara arroz integral',
          '1 xícara brócolis',
          '2 colheres azeite',
          'Temperos',
        ],
        protein: 40,
        carbs: 38,
        fat: 14,
        fiber: 4,
      ),
      Recipe(
        label: 'Omelete de Claras',
        imageUrl: 'https://via.placeholder.com/300x200.png?text=Omelette',
        url: '',
        calories: 180,
        totalTime: 10,
        yield_: 1,
        ingredients: [
          '4 claras',
          '1/2 xícara espinafre',
          '1 tomate',
          'Queijo cottage',
          'Temperos',
        ],
        protein: 20,
        carbs: 4,
        fat: 8,
        fiber: 2,
      ),
    ];
  }
}