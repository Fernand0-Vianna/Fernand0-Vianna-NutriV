# 📋 Relatório de Análise - NutriV
**Data:** 23/04/2026  
**Analista:** Agent Code Analyzer

---

## ✅ PONTOS POSITIVOS

1. **Clean Architecture** bem implementada (presentation/domain/data)
2. **State Management** com BLoC - padrão consistente
3. **Dependency Injection** com get_it
4. **Null Safety** - 100% (sem issues no dart analyze)
5. **UI** - Material Design 3 bem aplicado
6. **Dart Analyze** - Zero issues encontradas

---

## 🔴 CRÍTICO - Segurança

### Issue 1: API Keys Expostas no Repositório
**Arquivo:** `.env:3-5`  
**Severidade:** CRITICAL

```env
GEMINI_API_KEY=AIzaSyDk7TYt19saxY2ZxAxV0H_ossVDusBmQlk
SUPABASE_URL=https://lkfefyucixmcrmpvcazg.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Problema:** Chaves de API estão commitadas no repositório.

**Recomendação:**
- Remover `.env` do git tracking
- Usar Supabase Runtime Config ou variáveis de ambiente do Netlify
- Configurar secrets no Google Cloud Console

---

### Issue 2: Leitura de API Keys Sem Validação
**Arquivo:** `lib/core/constants/app_constants.dart:4,9`

```dart
static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
```

**Problema:** Retorna string vazia se key não existir, pode causar falhas silenciosas.

**Recomendação:**
```dart
static String get geminiApiKey {
  final key = dotenv.env['GEMINI_API_KEY'];
  if (key == null || key.isEmpty) {
    throw Exception('GEMINI_API_KEY não configurada');
  }
  return key;
}
```

---

## 🟠 ALTO - Arquitetura

### Issue 1: Repositórios Duplicados
**Arquivos:**
- `lib/data/repositories/meal_repository.dart`
- `lib/data/repositories/meal_repository_v2.dart`

**Problema:** Dois reposositórios com responsabilidade similar causam confusão.

**Recomendação:** Unificar em `MealRepository` com suporte a local + remote via Strategy Pattern.

---

### Issue 2: SyncMealRepository Viola SRP
**Arquivo:** `lib/data/repositories/sync_meal_repository.dart`

**Problema:** Classe faz 3 coisas:
1. Persistência local (SharedPreferences)
2. Comunicação remota (Supabase)
3. Sincronização entre local e remote

**Recomendação:**
```dart
// Estrutura sugerida:
LocalMealRepository      // Apenas SharedPreferences
RemoteMealRepository     // Apenas Supabase
MealSyncService          // Apenas sincronização
```

---

## 🟡 MÉDIO - Performance

### Issue 1: ListView dentro de ListView
**Arquivo:** `lib/presentation/pages/home/home_page.dart:558`

**Problema:** `ListView.builder` dentro de `CustomScrollView` causa warning de render.

**Solução:**
```dart
// Substituir ListView por SliverList
SliverList(
  delegate: SliverChildBuilderDelegate(
    (context, index) => MealCard(meal: state.meals[index]),
    childCount: state.meals.length,
  ),
)
```

---

### Issue 2: ImagePicker Recriado a Cada Build
**Arquivo:** `lib/presentation/pages/scanner/scanner_page.dart:26`

```dart
final ImagePicker _picker = ImagePicker(); // Recriado
```

**Solução:**
```dart
// No initState
@override
void initState() {
  super.initState();
  _picker = ImagePicker();
}
```

---

### Issue 3: Google Fonts Carregadas em Runtime
**Impacto:** Primeira tela pode ter delay de renderização.

**Solução:** Usar `fonts` assets locally ou cachear.

---

## 🟢 MELHORIAS SUGERIDAS

### 1. Adicionar Tests
```bash
# Falta pasta de testes para:
- BLoCs
- Repositories
- Services
```

### 2. Adicionar Rate Limiting
**Arquivo:** `lib/data/datasources/ai_food_service.dart`

Adicionar controle de requisições para evitar exceder limites da API.

### 3. Error Boundaries
Adicionar widget de error boundary para crashes parciais.

### 4. Logging Centralizado
Substituir `debugPrint` por logger estruturado (package:logger).

---

## 📊 Resumo

| Severidade | Quantidade |
|------------|------------|
| 🔴 CRITICAL | 2 |
| 🟠 ALTO | 2 |
| 🟡 MÉDIO | 3 |
| 🟢 MELHORIA | 4 |

**Prioridade:** Corrigir segurança primeiro (API keys expostas).

---

## 🚀 Ações Recomendadas

1. [ ] Mover `.env` para `.gitignore` imediatamente
2. [ ] Configurar Supabase Environment Variables no Netlify
3. [ ] Unificar repositories duplicados
4. [ ] Adicionar testes unitários
5. [ ] Implementar error boundaries