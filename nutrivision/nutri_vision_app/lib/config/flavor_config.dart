import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { dev, prod }

class FlavorConfig {
  final Flavor flavor;
  final String apiBaseUrl;
  final String appName;

  FlavorConfig._({
    required this.flavor,
    required this.apiBaseUrl,
    required this.appName,
  });

  static late FlavorConfig _instance;

  static void init({required Flavor flavor}) {
    String envFileName = flavor == Flavor.dev ? ".env.dev" : ".env.prod";
    dotenv.load(fileName: envFileName);

    _instance = FlavorConfig._(
      flavor: flavor,
      apiBaseUrl: dotenv.env['BASE_URL_API']!,
      appName: dotenv.env['APP_NAME']!,
    );
  }

  static FlavorConfig get instance {
    // Garantir que init() foi chamado
    if (!(_instance is FlavorConfig)) {
      throw Exception("FlavorConfig must be initialized before use.");
    }
    return _instance;
  }
}

// No main.dart, você chamaria:
// main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   FlavorConfig.init(flavor: Flavor.dev); // Ou Flavor.prod
//   runApp(const NutriVisionApp());
// }