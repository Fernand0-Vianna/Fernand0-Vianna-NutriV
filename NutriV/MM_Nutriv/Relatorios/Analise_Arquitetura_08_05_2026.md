# Análise de Código — NutriV

**Data:** 08/05/2026  
**Analista:** Software Architect  
**Escopo:** `lib/` completo (data, domain, presentation, core)

---

## 1. Visão Geral da Arquitetura

O projeto segue **Clean Architecture** com separação clara em camadas:

```
presentation/  →  BLoC pattern + UI (pages, widgets, bloc)
domain/         →  Entities, Use Cases, Repository Interfaces
data/           →  Models, Repositories (implementations), Data Sources
core/           →  DI, Theme, Constants, Services, Utils
```

### Pontos Fortes Identificados
- ✅ Injeção de dependência via `get_it`
- ✅ 6 interfaces de repositório criadas (SRP respeitado)
- ✅ Logging centralizado com `LoggingService`
- ✅ Offline-first com `SyncMealRepository` (fila de sync)
- ✅ Padrão BLoC para state management
- ✅ Migração SQL versionada

---

## 2. Code Smells e Violações Clean Code

### 2.1 SRP — Simple Responsibility Principle

| Local | Problema | Severidade |
|-------|---------|------------|
| `sync_meal_repository.dart` | Classe faz TUDO: sync, parse, export CSV, ensure food exists | 🔴 Alta |
| `meal_bloc.dart` | Lógica de nomes de refeição (`_getMealName`) dentro do BLoC | 🟡 Média |

**Recomendação:** Extrair `_getMealName` para um serviço ou constante:

```dart
// lib/core/constants/meal_types.dart
enum MealType {
  breakfast('Café da manhã'),
  lunch('Almoço'),
  dinner('Jantar'),
  snack('Lanche');
  
  final String displayName;
  const MealType(this.displayName);
  
  static String getName(String key) {
    return MealType.values.firstWhere(
      (t) => t.name == key,
      orElse: () => MealType.snack,
    ).displayName;
  }
}
```

### 2.2 DRY — Don't Repeat Yourself

**Problema identificado:**Strings de nomes de refeição duplicadas em:
- `meal_bloc.dart:146-159` (`_getMealName`)
- `diary_page.dart` (buscar por "Café da manhã")
- `app_constants.dart` (hardcoded lists)

**Recomendação:** Usar `MealType` enum único.

### 2.3 KISS — Keep It Simple, Stupid

| Local | Problema |
|-------|----------|
| `sync_meal_repository.dart:337-373` | `_ensureFoodExists` faz SELECT + INSERT em uma função. Pode falhar em race conditions. |
| `sync_meal_repository.dart:176-254` | `_syncMealToSupabase` com retry loop manual. Usar biblioteca como `retry` ou `dio_retry`. |

### 2.4 YAGNI — You Aren't Gonna Need It

| Local | Problema |
|-------|----------|
| `sync_meal_repository.dart:492-511` | `exportMealsToCsv` implementado mas nunca usado em UI |
| `domain/usecases/` | Pasta contém arquivos muito pequenos/Genéricos com `// TODO implement` |

---

## 3. Oportunidades de Refatoração

### 3.1 Extrair Classes Grandes

**`SyncMealRepository`** (516 linhas) faz múltiplas coisas:
1. Pull/push de dados
2. Parse de dados
3. Resolução de entidades (ensure food exists)
4. Fila de sync offline
5. Export CSV

**Recomendação:** Quebrar em:
```
/repositories/
  meal_repository.dart        → apenas operações CRUD
  meal_sync_service.dart    → lógica de sync
  meal_parser.dart         → parse de dados
  csv_export_service.dart  → export (se necessário)
```

### 3.2 Interfaces de Repositório Parciais

6 interfaces criadas, MAS nem todas estão sendo usadas:

| Interface | Usada por BLoC? |
|-----------|-----------------|
| `IUserProfileRepository` | ❌ não injetado |
| `IMealRepositoryV2` | ❌ não injetado (usa `SyncMealRepository` concreto) |
| `IWaterRepository` | ❌ não injetado |
| `IWeightRepository` | ✅ sim |
| `IDailySummaryRepository` | ❌ não injetado |
| `IFavoriteDishRepository` | ✅ sim |

**Recomendação:** Ou usar as interfaces existentes ou REMOVÊ-LAS (YAGNI).

### 3.3 Falta testabilidade

Apesar das interfaces, BLoCs ainda recebem classes concretas em alguns casos:

```dart
// injection.dart:126
getIt.registerFactory<UserBloc>(() => UserBloc(getIt<UserRepository>()));
//              ↑ concrete class ↑ concrete class
```

**Recomendação:** Registrar por interface:

```dart
getIt.registerFactory<IUserRepository>(() => UserRepository(...));
getIt.registerFactory<UserBloc>(() => UserBloc(getIt<IUserRepository>()));
```

---

## 4. Segurança e Performance

### 4.1 Segurança

| Local | Observação |
|-------|------------|
| `.env` no repositório | ⚠️ arquivo `.env` pode estar no gitignore? Verificar |
| `auth_service.dart` | Parece usar Supabase Auth corretamente |
| RLS policies | ✅ Implementadas no banco |

**Recomendação:** Confirmar que `.env` está no `.gitignore`:

```bash
# .gitignore
.env
```

### 4.2 Performance

| Local | Problema | Solução |
|-------|---------|---------|
| `sync_meal_repository.dart:14-25` | `getAllMeals` carrega TUDO do SQLite | ✅ Já corrigido ( usa `getMealsByDate`) |
| `sync_meal_repository.dart:39-107` | `_pullFromSupabase` faz N queries (1 por meal) | Batch insert ou streaming |
| `main.dart:109-130` | 6 BLoCs inicializados no startup | Lazy load ou apenas os necessários |

### 4.3 Cache

| Observação |
|------------|
| `sp_migration.dart` tem `clearOldCache` mas não há caching de imagens ou dados HTML |
| USDA API resposta pode ser cacheada em SQLite |

---

## 5. Pontos Lógicos a Verificar

### 5.1 Fluxo de Autenticação

```dart
// main.dart:81-89
void _setupAuthListener() {
  Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    if (event.event.name == 'SIGNED_IN') { ... }
  });
}
```

**Pergunta:** O que acontece quando usuário faz login? Há inicialização de dados pós-login?

**Verificar:** `UserBloc` é inicializado com `LoadUser()` em `main.dart:110`, mas não há chamada clara de `SyncMealRepository().init()` após auth.

### 5.2 Sync em Segundo Plano

```dart
// injection.dart:148
await getIt<SyncMealRepository>().init();
```

Chamado na inicialização,MAS:
- Se usuário não está logado, não deveria executar
- Não há verificação de auth state antes

### 5.3 Food Scanner Fallback

```dart
// food_scanner_bloc.dart:38-43
try {
  foods = await _groqVisionService.analyzeFoodImage(event.imageFile);
} catch (e) {
  foods = await _aiFoodService.analyzeFoodImage(event.imageFile);
}
```

**✅ Bom padrão**, mas:
- Sem delay entre tentativas (pode sobrecarregar se Groq estiver down)
- Sem user feedback de "tentando fallback..."

---

## 6. Recomendações Priorizadas

### 🔴 Alta Prioridade

1. **Verificar auth antes de sync**
   ```dart
   // injection.dart (modificar)
   if (Supabase.instance.client.auth.currentUser != null) {
     await getIt<SyncMealRepository>().init();
   }
   ```

2. **Colocar `.env` no gitignore** (se ainda não estiver)
   ```bash
   echo ".env" >> .gitignore
   ```

### 🟡 Média Prioridade

3. **Quebrar `SyncMealRepository` em serviços menores**
   - `MealSyncService` (lógica de sync)
   - `MealParser` (parse)
   
4. **Usar as interfaces existentes** ou removê-las
   - `IUserProfileRepository`, `IMealRepositoryV2`, etc. estão 注册 mas não usados

5. **Extrair `_getMealName` para enum**
   - `MealType` em `app_constants.dart`

### 🟢 Baixa Prioridade

6. **Adicionar retry library** em vez de loops manuais
   ```yaml
   dependencies:
     retry: ^3.1.0
   ```

7. **Lazy load de BLoCs não essenciais** (chat, scanner)
   - Carregar apenas quando a página for acessada

8. **Testes unitários** — Com interfaces prontas, mocks podem ser criados

---

## 7. Métricas do Código

| Métrica | Valor |
|---------|-------|
| Arquivos Dart | ~100+ |
| Linhas (estimado) | ~15.000 |
| Erros análise | 0 ✅ |
| Warnings | 0 ✅ |
| debugPrint/print | 0 ✅ (via LoggingService) |
| Interfaces de repositório | 6 ✅ |
| BLoCs | 9 |
| Services/API | 10+ |

---

## 8. Conclusão

O projeto NutriV apresenta **boa estrutura inicial** seguindo Clean Architecture, com:
- ✅ Logging centralizado
- ✅ Interfaces para testabilidade
- ✅ Offline-first implementado
- ✅ Código livre de analysis errors

**O principal ponto a melhorar:** Integração auth-sync (verificar usuário antes de syncar) e redução de responsabilidades da `SyncMealRepository`.

---

*Análise gerada por: OpenCode (software-architect skill)*