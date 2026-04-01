import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'config/firebase_options.dart'; // Será gerado pelo Firebase CLI

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carregar variáveis de ambiente
  await dotenv.load(fileName: ".env.dev"); // Ou .env.prod dependendo do flavor

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NutriVisionApp());
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // TODO: Implementar configuração do Firebase para cada plataforma
    throw UnimplementedError('DefaultFirebaseOptions not implemented');
  }
}
