# NutriV - AI Calorie Counter

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.11+-blue.svg" alt="Flutter Version">
  <img src="https://img.shields.io/badge/Platform-Android-green.svg" alt="Platform">
  <img src="https://img.shields.io/badge/License-MIT-purple.svg" alt="License">
</p>

NutriV é um aplicativo mobile de contador de calorias com inteligência artificial, desenvolvido em Flutter. Permite o acompanhamento da ingestão alimentar através de fotos, scanner de código de barras, busca manual e entrada por voz.

## 🚀 Funcionalidades Principais

| Feature | Descrição |
|---------|-----------|
| 📷 **Reconhecimento por IA** | Analisa fotos de alimentos usando Google Gemini / OpenAI |
| 🔍 **Busca de Alimentos** | Integração com USDA FoodData Central e OpenFoodFacts |
| 📱 **Scanner de Barras** | Leitura de código de barras para identificação rápida |
| 💧 **Controle de Água** | Acompanhamento diário de hidratação |
| 📊 **Metas Personalizadas** | Cálculo automático de calorias e macros |
| 📈 **Gráficos de Progresso** | Visualização de evolução ao longo do tempo |
| ☁️ **Sincronização** | Dados salvos no Firebase Firestore e Supabase |

## 🛠️ Tecnologias

- **Framework**: Flutter 3.11+
- **State Management**: flutter_bloc (BLoC Pattern)
- **Navigation**: go_router
- **HTTP**: dio
- **Backend**: Firebase (Firestore), Supabase
- **Auth**: Google Sign-In
- **IA**: Google Gemini, OpenAI GPT-4

## 📁 Estrutura do Projeto

```
nutriv/
├── lib/
│   ├── core/           # Configurações, DI, Theme
│   ├── data/           # Models, Datasources, Repositories
│   ├── domain/         # Entities
│   └── presentation/   # Pages, Widgets, BLoCs
├── android/            # Configurações Android
├── documentação/       # Documentação completa do projeto
└── README.md           # Este arquivo
```

## ⚙️ Configuração

### 1. Variáveis de Ambiente
Crie um arquivo `.env` na raiz do projeto:

```env
# Supabase
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# APIs de IA
GEMINI_API_KEY=your_gemini_key
OPENAI_API_KEY=your_openai_key

# USDA
USDA_API_KEY=your_usda_api_key
```

### 2. Firebase
Configure o arquivo `google-services.json` em `android/app/`

### 3. Build
```bash
# Install dependencies
flutter pub get

# Build debug APK
flutter build apk --debug
```

## 📱 Telas do App

- **Splash** - Tela de carregamento
- **Login/Register** - Autenticação Google
- **Onboarding** - Configuração inicial do perfil
- **Home** - Dashboard com resumo diário
- **Diary** - Registro completo de refeições
- **Scanner** - Câmera com IA para fotos de comida
- **Search** - Busca manual em banco de dados
- **Profile** - Perfil e configurações do usuário
- **Progress** - Gráficos e histórico

## 📦 Dependências

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

## 📄 Licença

MIT License

## 👨‍💻 Autor
Fernando Santos Viana
Douglas
Jhonathan

Desenvolvido com ❤️ usando Flutter
