# Relatório - Correções Sync e Múltiplos Pratos

**Data:** 03/05/2026  
**Problema:** SyncRepository com erros assíncronos e impossibilidade de adicionar múltiplos pratos/itens.

---

## 🔴 Problemas Identificados

### 1. SyncMealRepository Assíncrono
**Erro:** `getAllMeals()` era síncrono mas chamava `_pullFromSupabase()` (async) sem await.
**Impacto:** Ao abrir o app, lista vazia mesmo tendo dados no Supabase.

### 2. Múltiplos Pratos no Dia
**Erro:** ID gerado sem timestamp, causando sobrescrita de refeições do mesmo tipo.
**Impacto:** Não era possível ter dois "Almoço" diferentes no mesmo dia.

### 3. Chamadas sem Await
**Erro:** `saveMeal()`, `deleteMeal()` e `profile_page.dart` usavam `getAllMeals()` sem `await`.
**Impacto:** Build falhava com erro de tipo `Future<List<Meal>>` vs `List<Meal>`.

---

## ✅ Correções Aplicadas

### 1. getAllMeals() Agora é Async
**Arquivo:** `lib/data/repositories/sync_meal_repository.dart:16-31`

```dart
// ANTES (síncrono)
List<Meal> getAllMeals() { ... }

// DEPOIS (assíncrono)
Future<List<Meal>> getAllMeals() async { ... }
```

**Melhoria:** Agora aguarda o pull do Supabase antes de retornar.

### 2. ID Único para Refeições
**Arquivo:** `lib/presentation/bloc/meal/meal_bloc.dart:120-152`

```dart
// ANTES
id: '${event.date.toIso8601String()}_$mealTypeKey'

// DEPOIS  
final uniqueId = '${event.date.toIso8601String()}_${mealTypeKey}_${DateTime.now().millisecondsSinceEpoch}';
```

**Resultado:** Permite múltiplos pratos do mesmo tipo no mesmo dia.

### 3. Await em Todas as Chamadas
**Arquivos Corrigidos:**
- `sync_meal_repository.dart`: `saveMeal()`, `deleteMeal()`
- `meal_bloc.dart`: `_onLoadMeals()`, `_onAddMeal()`, `_onUpdateMeal()`, `_onDeleteMeal()`
- `profile_page.dart`: `_exportDiary()`

### 4. Sync Robusto (Já implementado anteriormente)
- ✅ Retry automático (3 tentativas)
- ✅ Fila de pendências (SharedPreferences)
- ✅ Pull-from-Supabase (download ao iniciar)
- ✅ Init no startup (`setupDependencies()`)

---

## 📊 Validação

| Teste | Status |
|-------|--------|
| Build APK Debug | ✅ Sucesso (16.0s) |
| Análise (`flutter analyze`) | ✅ 0 erros |
| Múltiplos pratos/dia | ✅ Permitido (ID único) |
| Sync assíncrono | ✅ Corrigido (await) |
| Pull-from-Supabase | ✅ Funcionando |

---

## 🔧 Como Testar

1. **Adicionar múltiplos pratos:**
   - Diário → "+" no Almoço → adicionar Arroz
   - "+" novamente no Almoço → adicionar Feijão
   - **Esperado:** Dois cards de "Almoço" aparecem

2. **Sync ao iniciar:**
   - Limpe o cache do app
   - Abra o app (deve baixar do Supabase)
   - **Esperado:** Refeições anteriores aparecem

3. **Fila de pendências:**
   - Desligue a internet
   - Adicione uma refeição
   - Ligue a internet
   - Reinicie o app
   - **Esperado:** Refeição sincroniza automaticamente

---

## 📝 Arquivos Alterados

| Arquivo | Alteração |
|---------|------------|
| `lib/data/repositories/sync_meal_repository.dart` | Async, Retry, Pull, Pending Queue |
| `lib/presentation/bloc/meal/meal_bloc.dart` | ID único, await em todos os métodos |
| `lib/presentation/pages/profile/profile_page.dart` | Corrigido await no export |
| `lib/core/di/injection.dart` | Chamada ao `init()` |

---

## 🚀 Pendências Futuras

1. **Adicionar múltiplos itens a prato existente** (usar `AddFoodToMeal` event)
2. **UI para editar quantidade** de alimentos no card
3. **Merge de dados** (local + servidor) em vez de sobrescrever

---

*Relatório criado em: 03/05/2026*  
*Build validado: app-debug.apk (16.0s)*
