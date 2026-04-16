# NutriV - Documentação do Projeto

## 1. Visão Geral do Projeto

**NutriV** é um aplicativo mobile de contador de calorias com inteligência artificial, desenvolvido em Flutter. O aplicativo permite que usuários acompanhem sua ingestão alimentar através de fotos de alimentos, scanner de código de barras, busca manual e entrada por voz.

### Principais Funcionalidades
- 📷 Reconhecimento de alimentos por imagem (IA)
- 📱 Scanner de código de barras
- 🔍 Busca em banco de dados USDA e OpenFoodFacts
- 💧 Controle de hidratação diário
- 📊 Acompanhamento de progresso e metas
- 🎯 Cálculo automático de metas calóricas e de macronutrientes

---

## 2. Arquitetura Técnica

### Stack Tecnológico

| Categoria | Tecnologia |
|-----------|------------|
| **Framework** | Flutter 3.11+ |
| **Linguagem** | Dart |
| **Estado** | flutter_bloc (BLoC Pattern) |
| **Navegação** | go_router |
| **HTTP Client** | dio |
| **Armazenamento Local** | shared_preferences, sqflite |
| **Backend** | Supabase |
| **Autenticação** | Google Sign-In |
| **IA** | Google Gemini, OpenAI GPT-4 |
| **APIs Externas** | USDA FoodData Central, OpenFoodFacts |

---

## 3. Backend e Serviços

### 3.1 Firebase
- **Cloud Firestore**: Armazenamento de refeições e logs diários

### 3.2 Supabase
- **Backend as a Service**: Suporte adicional para sync de refeições

### 3.3 Autenticação
- **Google Sign-In**: Login social via Google

### 3.4 APIs de Alimentos

#### USDA FoodData Central
- API oficial do Departamento de Agricultura dos EUA
- Endpoint: `https://api.nal.usda.gov/fdc/v1/`

#### OpenFoodFacts
- Banco de dados colaborativo de alimentos
- API gratuita e aberta

#### Google Gemini (IA)
- Análise de imagens de alimentos
- Fallback: OpenAI GPT-4o-mini

---

## 4. Telas do App

| Página | Descrição |
|--------|-----------|
| Splash | Tela de carregamento inicial |
| Login | Login com Google |
| Register | Registro de novo usuário |
| Onboarding | Tutorial inicial |
| Home | Dashboard principal com macros e refeições |
| Diary | Registro diário de alimentação |
| Scanner | Câmera para capturar alimentos |
| Barcode Scan | Scanner de código de barras |
| Search | Busca manual de alimentos |
| Profile | Perfil do usuário e configurações |
| Progress | Gráficos de progresso |

---

## 5. Estado Global (BLoC)

| BLoC | Descrição |
|------|-----------|
| **UserBloc** | Gerencia dados do usuário e perfil |
| **MealBloc** | Gerencia refeições e diário alimentar |
| **FoodScannerBloc** | Controla scanner de alimentos por IA |
| **WaterBloc** | Controle de hidratação |
| **BarcodeScannerBloc** | Scanner de código de barras |

---

## 6. Dependências Principais

```yaml
dependencies:
  flutter_bloc: ^9.1.1
  go_router: ^14.8.1
  dio: ^5.8.0
  shared_preferences: ^2.5.3
  sqflite: ^2.4.2
  mobile_scanner: ^7.0.1
  fl_chart: ^0.71.0
  firebase_core: ^3.13.0
  cloud_firestore: ^5.6.6
  supabase_flutter: ^2.5.0
  google_sign_in: ^6.2.2
  google_fonts: ^6.2.1
```

---

## 7. Configuração

### Variáveis de Ambiente (.env)
```
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
GEMINI_API_KEY=...
OPENAI_API_KEY=...
USDA_API_KEY=...
```

### Firebase
Configure o arquivo `google-services.json` em `android/app/`

---

## 8. Build

```bash
flutter pub get
flutter build apk --debug
```

---

*Documento gerado automaticamente - NutriV Project Documentation*
