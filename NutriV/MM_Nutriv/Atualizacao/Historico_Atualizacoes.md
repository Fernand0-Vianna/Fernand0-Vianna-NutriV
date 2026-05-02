# Atualizações - NutriV

> Parte do [[NutriV_Anotacoes_Gerais]] | Ver também: [[Estado_Atual]] | [[Lista_Adicoes]] | [[Lista_Remocoes]] | [[Relatorio_Alteracoes_Recentes]]

---

## 📅 02 de Maio de 2026 - QA Completa e Correções Críticas

### 🎯 Resumo
Auditoria QA completa do aplicativo com identificação e correção de 15 issues críticos, incluindo autenticação quebrada, logout falhando, adição de alimentos com bugs e análise de IA instável.

### ✅ Concluído

#### 1. Autenticação e Usuários
- **Login por email no onboarding**: Agora usa `AuthService.signUpWithEmail()` e `signInWithEmail()` com Supabase real
- **Forgot Password**: Implementado `resetPasswordForEmail()` no AuthService
- **Password visibility toggle**: Adicionado botão para mostrar/esconder senha
- **Loading states**: Adicionado `_isLoading` em formulários de auth para prevenir cliques múltiplos
- **Logout**: Corrigido para navegar para `/login` ao invés de `/onboarding` (rota inexistente)

#### 2. Adição de Alimentos (Scanner)
- **IDs únicos**: Alimentos agora recebem IDs com formato `timestamp_counter` para evitar sobrescrita
- **Sync meal_items**: Cada item recebe ID único no Supabase
- **Meal type**: Normalizado para lowercase para consistência com o banco
- **Mensagem de feedback**: Mostra quantidade de alimentos e tipo de refeição adicionados

#### 3. Análise de IA (Food Scanner)
- **Gemini API fix**: Removido `responseMimeType: 'text/plain'` que causava falha na API
- **Prompt corrigido**: Corrigido typo "umnutricionista" para "um nutricionista"
- **Fallback local garantido**: Quando IA falha, busca em banco local de 30 alimentos brasileiros
- **Debug logging**: Adicionado log quando fallback é acionado

#### 4. Progress Page (Estatísticas)
- **Dados reais**: Conectada ao UserBloc e MealBloc para exibir dados reais do usuário
- **Gráficos responsivos**: `maxY` calculado dinamicamente baseado nos dados
- **Cores padronizadas**: Usando `AppTheme.proteinColor`, `carbsColor`, `fatColor`
- **Insights dinâmicos**: Texto baseado no consumo real vs meta calórica
- **SafeArea**: Adicionado para prevenir sobreposição com notch

#### 5. Recipes Page
- **Error handling**: Estados de erro, loading e empty com botão "Tentar novamente"
- **Search funcional**: Botão de busca agora abre dialog e pesquisa receitas
- **Empty state**: Mensagem amigável quando nenhuma receita é encontrada

#### 6. Acessibilidade
- **Semantic labels**: Main shell, home, diary, water tracker, meal card agora com labels para screen readers
- **Touch targets**: Water tracker buttons com mínimo 48x48px

#### 7. Melhorias Gerais
- **Export data**: Mensagem amigável ao invés de expor stack trace
- **Notification badge**: Removido badge fantasma '3'
- **Copyright year**: Atualizado para 2026
- **BLoC error handling**: UserBloc, MealBloc, FoodScannerBloc com try-catch e mensagens em português

### 🔧 Arquivos Modificados (21)
- `lib/data/datasources/auth_service.dart` - Adicionado resetPassword
- `lib/data/datasources/ai_food_service.dart` - Gemini fix + fallback local
- `lib/data/repositories/sync_meal_repository.dart` - IDs únicos em meal_items
- `lib/presentation/bloc/user/user_bloc.dart` - Error handling
- `lib/presentation/bloc/meal/meal_bloc.dart` - Error handling completo
- `lib/presentation/bloc/food_scanner/food_scanner_bloc.dart` - Mensagens contextuais
- `lib/presentation/pages/onboarding/onboarding_page.dart` - Auth real, loading, toggle senha
- `lib/presentation/pages/login/login_page.dart` - Melhor error handling Google
- `lib/presentation/pages/profile/profile_page.dart` - Logout corrigido, badge removido
- `lib/presentation/pages/profile/progress_page.dart` - Dados reais, SafeArea
- `lib/presentation/pages/recipes/recipes_page.dart` - Error handling, search funcional
- `lib/presentation/pages/scanner/scanner_page.dart` - IDs únicos
- `lib/presentation/pages/main/main_shell.dart` - Semantic labels
- `lib/presentation/pages/diary/diary_page.dart` - Semantic labels
- `lib/presentation/pages/home/home_page.dart` - Semantic labels, pull-to-refresh
- `lib/presentation/pages/scanner/barcode_scan_page.dart` - Fallback manual entry
- `lib/presentation/widgets/meal_card.dart` - Semantic labels
- `lib/presentation/widgets/water_tracker_widget.dart` - Touch targets

### 📊 Métricas
- **Issues corrigidos**: 15 (6 críticos, 5 altos, 4 médios/baixos)
- **Linhas adicionadas**: 2.180
- **Linhas removidas**: 462
- **Git commit**: `2dee6c8`

### 📄 Documentação
- [[Relatorios/Relatorio_QA_Completo.md]] - Primeira rodada de análise
- [[Relatorios/Relatorio_QA_Completo_Revisao_Final.md]] - Segunda rodada pós-correções
- [[Relatorios/Correcoes_QA_02_05_2026.md]] - Log detalhado das correções
- [[Relatorios/Sessao_QA_Correcoes_Criticas_02_05_2026.md]] - Resumo completo da sessão

### 🚀 Próximos Passos
1. Testes em dispositivo físico Android/iOS
2. Implementar crash reporting (Sentry/Crashlytics)
3. Modo offline mais robusto
4. Progress page com dados históricos reais (semanal/mensal)
5. Persistência de configurações do perfil

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