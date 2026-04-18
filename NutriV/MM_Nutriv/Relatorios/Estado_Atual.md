# NutriV - Mapa Mental Analítico

> Este documento faz parte do [[NutriV_Anotacoes_Gerais]] - Visão Geral do Projeto

## Visão Geral do Projeto

**NutriV** é um aplicativo mobile de controle alimentar com IA, desenvolvido em Flutter. O app permite acompanhamento da ingestão alimentar através de fotos, scanner de código de barras, busca manual e entrada por voz.

---

## Cronologia de Desenvolvimento

### Fase 1: Fundação (Início)
- Projeto Flutter inicial
- Estrutura base com BLoC pattern
- Navegação com go_router

### Fase 2: Integrações (Tentativas)
- Firebase Cloud Firestore (implementado mas não utilizado)
- Supabase como backend principal
- Google Sign-In para autenticação
- Multiple APIs de alimentos (USDA, OpenFoodFacts)

### Fase 3: Funcionalidades Core
- Scanner de alimentos por IA (Google Gemini + OpenAI GPT-4o-mini)
- Scanner de código de barras
- Registro de refeições
- Controle de hidratação
- Dashboard com macros
- Histórico diário

### Fase 4: Refinamento e Migração
- Remoção completa do Firebase
- Atualização de dependências
- Documentação técnica

---

## Arquitetura Técnica

### Stack Tecnológico
| Categoria | Tecnologia |
|-----------|------------|
| Framework | Flutter 3.11+ |
| Estado | flutter_bloc (BLoC Pattern) |
| Navegação | go_router |
| HTTP Client | dio |
| Armazenamento Local | shared_preferences, sqflite |
| Backend | Supabase (PostgreSQL) |
| Autenticação | Google Sign-In (OAuth) |
| IA | Google Gemini, OpenAI GPT-4o-mini |
| APIs Externas | USDA FoodData Central, OpenFoodFacts |

### Estrutura de Pastas
```
lib/
├── core/
│   ├── constants/     # Constantes globais
│   ├── di/            # Injeção de dependências (GetIt)
│   ├── theme/         # Tema visual (Material 3)
│   └── utils/         # Utilitários
├── data/
│   ├── datasources/   # Serviços externos (AI, USDA, Auth, Local)
│   ├── models/        # Modelos de dados
│   └── repositories/  # Repositórios de dados
├── domain/
│   └── entities/      # Entidades de domínio
└── presentation/
    ├── bloc/          # BLoCs (User, Meal, Water, FoodScanner, Barcode)
    ├── pages/         # Páginas da UI
    └── widgets/       # Componentes reutilizáveis
```

---

## Decisões Técnicas Importantes

### 1. Padrão de Estado
- **BLoC Pattern** para gerenciamento de estado
- 5 BLoCs principais: UserBloc, MealBloc, WaterBloc, FoodScannerBloc, BarcodeScannerBloc

### 2. Camada de Dados
- Modelo Repository com LocalDataSource
- SyncMealRepository para sincronização com Supabase
- SharedPreferences para dados locais (água, refeições)

### 3. Serviços de IA
- **Primário**: Google Gemini 2.0 Flash
- **Fallback**: OpenAI GPT-4o-mini
- **Terceário**: OpenFoodFacts API