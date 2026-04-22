# Atualizações - NutriV

> Parte do [[NutriV_Anotacoes_Gerais]] | Ver também: [[Estado_Atual]] | [[Lista_Adicoes]] | [[Lista_Remocoes]] | [[Relatorio_Alteracoes_Recentes]]

---

## 📅 21 de Abril de 2026 - Estabilização de Auth e Expansão de Saúde

### 🎯 Resumo
Estabilização do login com Google e implementação de novos sistemas de rastreamento (peso, pedômetro, favoritos).

### ✅ Concluído

#### 1. Autenticação Google
- Correção definitiva do fluxo de login e redirecionamento.
- Validador de credenciais Google implementado no backend/datasources.

#### 2. Novos Módulos de Saúde e Domínio
- **PedometerService**: Integração com sensor de passos.
- **WeightTracking**: Novo repositório e BLoC para histórico de peso.
- **FavoriteDishes**: Sistema de salvamento de refeições favoritas.
- **Skeleton Loaders**: Implementação de carregamento visual para uma UI mais fluida.

#### 3. Melhorias na Camada de Dados
- Finalização do `UserProfileRepository` e sincronização com Supabase.
- Implementação do `DailySummaryRepository` para métricas consolidadas.

### 🔧 Arquivos Modificados
- `lib/data/datasources/auth_service.dart` - Melhoria na validação.
- `lib/presentation/pages/login/login_page.dart` - UI atualizada.
- `lib/presentation/pages/scanner/scanner_page.dart` - Refatoração de performance.

### 📦 Novos Repositories/Services
- `PedometerService`
- `WeightRepository`
- `FavoriteDishRepository`

---

## 📅 18 de Abril de 2026 - Grande Atualização (v2.0)

### 🎯 Resumo
Configuração completa de backend + reestruturação do banco de dados inspirado no FitCal

### ✅ Concluído

#### 1. Netlify + Supabase Configurados
- **Site**: `nutrivisionh.netlify.app` deployado
- **Variáveis de ambiente**: `SUPABASE_URL` e `SUPABASE_ANON_KEY` configuradas
- **URL de callback**: `https://nutrivisionh.netlify.app/` validada
- **Auth**: Google OAuth funcionando

#### 2. Banco de Dados Reestruturado (v2.0)
**Baseado no FitCal AI** - 10 tabelas criadas:
- `user_profiles` - Perfil completo com BMR/TDEE calculados
- `meals` - Refeições com **AI Scanner support**
- `meal_items` - Itens dentro de refeições
- `food_entries` - Diário alimentar
- `water_intake` - Controle de hidratação
- `weight_logs` - Histórico de peso (Progress Chart)
- `daily_summaries` - Resumos **automáticos** (trigger)
- `activity_logs` - Atividades físicas
- `ai_recognition_cache` - Cache de reconhecimento de imagens
- `foods` - Base de alimentos (mantida)

#### 3. Segurança
- **RLS** ativado em todas as tabelas
- Políticas: cada usuário só acessa seus dados
- Triggers automáticos para recalcular summaries

#### 4. Código Flutter - Novos Repositories
Criados e registrados na DI:
- `UserProfileRepository` - Perfil e metas
- `MealRepositoryV2` - Refeições com AI support
- `WaterRepository` - Água
- `WeightRepository` - Peso/progresso
- `DailySummaryRepository` - Resumos diários

#### 5. Models
- `UserProfileModel` - Converte para/do Supabase

#### 6. Documentação
- `DATABASE_SCHEMA_V2.md` - Esquema completo
- `NETLIFY_SUPABASE_SETUP.md` - Guia de configuração
- `SETUP_CHECKLIST.md` - Checklist de deploy

### 🔧 Arquivos Modificados
- `netlify.toml` - Configurações de build
- `lib/data/datasources/auth_service.dart` - Login Google corrigido
- `lib/main.dart` - Rotas de login atualizadas
- `lib/core/di/injection.dart` - Novos repositories registrados

### 📦 Arquivos Criados
```
lib/
├── data/
│   ├── models/user_profile_model.dart
│   └── repositories/
│       ├── user_profile_repository.dart
│       ├── meal_repository_v2.dart
│       ├── water_repository.dart
│       ├── weight_repository.dart
│       └── daily_summary_repository.dart
├── presentation/pages/auth/auth_callback_page.dart
└── ...
```

### 🚀 Próximos Passos
1. Implementar telas usando novos repositories
2. Adicionar AI Scanner (foto → análise automática)
3. Criar gráficos de progresso com `weight_logs`
4. Implementar water tracking realtime

---

## Atualizações Realizadas (Cronologia)

### 1. Migração de Backend
- **Firebase removido completamente** do projeto - ver [[Lista_Remocoes]]
- Motivo: Requer configuração ativa no Google Cloud Console, sem projeto configurado
- Alternativa: Supabase como backend principal
- Documentação de restauração disponível em `documentação/Supabase_Configuracao.md`

### 2. Estrutura de Estado
- Adição de múltiplos BLoCs - ver [[Lista_Adicoes]]:
  - `UserBloc`: Gerencia dados do usuário e perfil
  - `MealBloc`: Gerencia refeições e diário alimentar
  - `FoodScannerBloc`: Controla scanner de alimentos por IA
  - `WaterBloc`: Controle de hidratação
  - `BarcodeScannerBloc`: Scanner de código de barras

### 3. Integração de APIs
- USDA FoodData Central
- OpenFoodFacts (fallback)
- Google Gemini + OpenAI para análise de imagens

### 4. UI/UX
- Tema Material 3
- Navegação ShellRoute com bottom navigation
- Páginas: Home, Diary, Scanner, Profile, Progress - ver [[Estado_Atual]]

---

## Histórico de Builds

| Versão | Data | Notas |
|--------|------|-------|
| 0.0.3 | - | Build com correções |
| 0.0.2 | - | Correções iniciais |
| 0.0.1 | - | Versão inicial |