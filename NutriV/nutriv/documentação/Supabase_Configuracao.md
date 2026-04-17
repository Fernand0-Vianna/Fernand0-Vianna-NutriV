# 🚀 Configuração do Supabase - NutriV

## Visão Geral

Este documento explica de forma simples como o Supabase está configurado no projeto NutriV.

---

## 1. Dependência

No arquivo `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.5.0
```

---

## 2. Arquivo de Configuração (.env)

Na raiz do projeto, crie um arquivo `.env` com:

```
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-publica-aqui
```

---

## 3. Como Funciona a Inicialização

### Padrão Singleton

O Supabase no Flutter usa um padrão chamado **Singleton** - ele se auto-inicializa quando você acessa pela primeira vez.

```dart
// O cliente é acessado via:
Supabase.instance.client
```

### Fluxo de Inicialização

```
1. main.dart → Carrega .env (dotenv)
2. setupDependencies() → Injeta SyncMealRepository
3. SyncMealRepository recebe Supabase.instance.client
4. Supabase auto-inicializa com dados do .env
```

---

## 4. Onde é Usado

### Arquivo: `lib/data/repositories/sync_meal_repository.dart`

```dart
class SyncMealRepository {
  final SupabaseClient _supabase;
  
  SyncMealRepository(this._prefs, this._supabase);
```

### Funções Principais

#### Sincronizar Refeição

```dart
Future<void> syncToSupabase(Meal meal) async {
  await _supabase.from('meals').upsert({
    'id': meal.id,
    'name': meal.name,
    'date_time': meal.dateTime.toIso8601String(),
    'meal_type': meal.mealType,
    'foods': jsonEncode(meal.foods),
    'notes': meal.notes,
    'user_id': _supabase.auth.currentUser?.id,
  });
}
```

#### Streaming em Tempo Real

```dart
Stream<List<Meal>> watchMeals() {
  return _supabase
      .from('meals')
      .stream(primaryKey: ['id'])
      .map((maps) => maps.map((m) => _parseSupabaseMeal(m)).toList());
}
```

---

## 5. Injeção de Dependência

### Arquivo: `lib/core/di/injection.dart`

```dart
Future<void> setupDependencies() async {
  // ... outras dependências ...
  
  getIt.registerSingleton<SyncMealRepository>(
    SyncMealRepository(
      getIt<SharedPreferences>(), 
      Supabase.instance.client  // ← Cliente Supabase
    ),
  );
}
```

---

## 6. Estrutura da Tabela no Supabase

### Tabela: `meals`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | uuid | ID único da refeição |
| name | text | Nome da refeição |
| date_time | timestamp | Data e hora |
| meal_type | text | Tipo (café, almoço, etc) |
| foods | json | Lista de alimentos |
| notes | text | Observações |
| user_id | uuid | ID do usuário (autenticação) |

---

## 7. Resumo Visual

```
┌─────────────────┐
│   main.dart     │
│  (inicia app)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   .env file     │
│ (credenciais)   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  injection.dart │
│ (registra deps) │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│   SyncMealRepository    │
│  (usa Supabase.client)  │
└─────────────────────────┘
         │
         ▼
┌─────────────────────────┐
│    Supabase Cloud       │
│   (banco de dados)      │
└─────────────────────────┘
```

---

## 8. Observações Importantes

- ✅ O Supabase é usado apenas para **sincronização de refeições**
- ✅ Dados ficam salvos localmente no `SharedPreferences` e `SQLite`
- ✅ A autenticação é implícita via `auth.currentUser?.id`
- ⚠️ Se o `.env` não existir, o Supabase não funcionará

---

## 9. Links Úteis

- [Documentação Supabase Flutter](https://supabase.com/docs/guides/getting-started/tutorials/with-flutter)
- [Dashboard do Supabase](https://supabase.com/dashboard)

---

*Documento gerado em: Abril 2026*
*Projeto: NutriV*
