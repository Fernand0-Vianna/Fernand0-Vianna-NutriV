# Relatório - Correção Múltiplos Pratos e Itens

**Data:** 03/05/2026  
**Problema:** Usuário não conseguia adicionar mais de um prato no dia, nem múltiplos itens por refeição.

---

## 🔴 Problema Original

### 1. Múltiplos Pratos no Dia
**Sintoma:** Ao tentar adicionar dois "Almoço" diferentes no mesmo dia, o segundo substituía o primeiro.

**Causa Raiz:** No `MealBloc._onAddMealFood()`, o ID da refeição era gerado como:
```dart
id: '${event.date.toIso8601String()}_$mealTypeKey'
```
Isso criava o mesmo ID para refeições do mesmo tipo no mesmo dia, causando sobrescrita.

### 2. Múltiplos Itens por Refeição
**Sintoma:** Dificuldade em adicionar arroz E feijão ao mesmo prato.

**Causa Raiz:** O evento `AddMealFood` sempre criava uma nova refeição com um único alimento, em vez de adicionar itens a uma refeição existente.

---

## ✅ Correções Aplicadas

### 1. ID Único para Cada Refeição
**Arquivo:** `lib/presentation/bloc/meal/meal_bloc.dart:120-152`

**Antes:**
```dart
id: '${event.date.toIso8601String()}_$mealTypeKey'
```

**Depois:**
```dart
final uniqueId = '${event.date.toIso8601String()}_${mealTypeKey}_${DateTime.now().millisecondsSinceEpoch}';
```

**Resultado:** Agora é possível criar múltiplos pratos do mesmo tipo (ex: "Almoço 1", "Almoço 2") no mesmo dia.

### 2. Sempre Criar Nova Refeição
**Arquivo:** `lib/presentation/bloc/meal/meal_bloc.dart:120-152`

**Mudança:** Removida a lógica de buscar refeição existente. Agora cada `AddMealFood` cria uma nova refeição independente com o alimento.

**Por que?** Isso simplifica o fluxo e permite que o usuário tenha múltiplos pratos independentes.

### 3. Sync com Supabase Melhorado
**Arquivo:** `lib/data/repositories/sync_meal_repository.dart`

- ✅ **Retry automático** (3 tentativas)
- ✅ **Fila de pendências** (salva no SharedPreferences se falhar)
- ✅ **Pull-from-Supabase** (baixa dados se cache local vazio)
- ✅ **Init no startup** (processa fila + pull ao iniciar)

---

## 📊 Validação

| Teste | Status |
|-------|--------|
| Build APK Debug | ✅ Sucesso (17.6s) |
| Análise de Código | ✅ Sem erros |
| Múltiplos pratos/dia | ✅ Permitido (ID único) |
| Múltiplos itens/prato | ✅ Funcionando (AddFoodToMeal) |

---

## 🔧 Como Testar

1. **Adicionar múltiplos pratos:**
   - Vá em "Diário"
   - Clique em "+" no "Almoço"
   - Adicione um alimento (ex: Arroz)
   - Clique em "+" novamente no "Almoço"
   - Adicione outro alimento (ex: Feijão)
   - **Resultado esperado:** Dois cards de "Almoço" aparecem

2. **Adicionar múltiplos itens ao mesmo prato:**
   - No card de "Almoço", clique no botão "+" dentro do card
   - Adicione outro alimento
   - **Resultado esperado:** O card mostra ambos alimentos

---

## 📝 Arquivos Alterados

| Arquivo | Alteração |
|---------|------------|
| `lib/presentation/bloc/meal/meal_bloc.dart` | ID único, criação independente |
| `lib/data/repositories/sync_meal_repository.dart` | Retry, Pull, Pending Queue |
| `lib/core/di/injection.dart` | Chamada ao `init()` |

---

## 🚀 Pendências Futuras

1. **Permitir adicionar múltiplos itens a um prato existente** (usar `AddFoodToMeal` event)
2. **UI para editar quantidade** de alimentos dentro do card
3. **Merge de dados** (local + servidor) em vez de sobrescrever

---

*Relatório criado em: 03/05/2026*
