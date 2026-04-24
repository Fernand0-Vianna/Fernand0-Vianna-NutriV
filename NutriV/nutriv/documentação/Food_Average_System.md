# 🍎 Sistema de Média Nutricional - NutriV

## Visão Geral

Quando um alimento é registrado (ex: 'banana' com proteína, carbo, gordura), o sistema calcula automaticamente a média dos valores nutricionais de todos os registros e atualiza a tabela `foods` para uso de todos os usuários.

---

## Como Funciona

### Fluxo de Dados

```
Usuário registra "Banana" (100g)
    ├── 20g proteína, 15g carbo, 5g gordura
    │
    ↓
SyncMealRepository._ensureFoodExists()
    ├── Busca alimento existente na tabela foods
    ├── Se não existir: cria novo registro
    │
    ↓
INSERT INTO food_nutrition_history
    ├── food_id, user_id, valores nutricionais, source
    │
    ↓
TRIGGER automático (PostgreSQL)
    ├── Chama calculate_food_nutrition_average(food_id)
    │
    ↓
UPDATE foods (valores médios)
    ├── calories = AVG(calories) dos últimos 365 dias
    ├── protein = AVG(protein)
    ├── carbs = AVG(carbs)
    ├── fat = AVG(fat)
    └── fiber = AVG(fiber)
```

---

## Estrutura do Banco

### Tabela `food_nutrition_history`

Armazena cada registro individual de alimentos.

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | UUID | ID único |
| `food_id` | UUID | FK → foods.id |
| `user_id` | UUID | FK → auth.users.id |
| `calories` | NUMERIC | Calorias registradas |
| `protein` | NUMERIC | Proteína (g) |
| `carbs` | NUMERIC | Carboidratos (g) |
| `fat` | NUMERIC | Gorduras (g) |
| `fiber` | NUMERIC | Fibras (g) |
| `serving_size` | NUMERIC | Porção (g) |
| `source` | TEXT | 'manual', 'ai_scan', 'barcode', 'voice' |
| `registered_at` | TIMESTAMPTZ | Data do registro |

### Função SQL `calculate_food_nutrition_average`

Calcula e atualiza automaticamente a média dos valores nutricionais.

```sql
-- Parâmetro: p_food_id (UUID)
-- Calcula média dos últimos 365 dias
-- Atualiza tabela foods automaticamente
```

---

## Exemplo Prático

### Cenário: Múltiplos usuários registram "Banana"

**Registro 1 (Usuário A):**
- Banana 100g
- Proteína: 1.1g, Carbo: 23g, Gordura: 0.3g

**Registro 2 (Usuário B):**
- Banana 100g
- Proteína: 1.3g, Carbo: 25g, Gordura: 0.2g

**Registro 3 (Usuário C):**
- Banana 100g
- Proteína: 1.0g, Carbo: 22g, Gordura: 0.3g

**Resultado na tabela `foods`:**
- Banana 100g
- Proteína: **1.13g** (média)
- Carbo: **23.33g** (média)
- Gordura: **0.27g** (média)

---

## Código Flutter

### Onde está implementado

Arquivo: `lib/data/repositories/sync_meal_repository.dart`

```dart
// Método: _ensureFoodExists()
// Linha: ~117

// 1. Busca ou cria alimento na tabela foods
// 2. Insere no food_nutrition_history
// 3. Trigger SQL calcula média automaticamente
```

### Uso no código

```dart
// Quando salvar uma refeição:
await syncMealRepository.saveMeal(meal);

// Automaticamente:
// 1. Cada alimento é registrado no histórico
// 2. Média é recalculada
// 3. Tabela foods é atualizada
```

---

## Edge Function (Opcional)

Para recalcular manualmente a média de um alimento:

```bash
curl -X POST https://seu-projeto.supabase.co/functions/v1/recalculate-food-average \
  -H "Authorization: Bearer SEU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"food_id": "uuid-do-alimento"}'
```

---

## Benefícios

1. **Dados colaborativos** - Todos os usuários contribuem para a precisão
2. **Médias dinâmicas** - Valores melhoram com mais registros
3. **Automático** - Sem necessidade de ação manual
4. **Focado** - Usa apenas dados dos últimos 365 dias

---

## Segurança

- **RLS ativado** - Usuários só veem seus próprios registros no histórico
- **Média pública** - A tabela `foods` é visível para todos (dados anonimizados)
- **Trigger seguro** - Função roda com SECURITY DEFINER

---

*Documento criado em: Abril 2026*
*Projeto: NutriV*
