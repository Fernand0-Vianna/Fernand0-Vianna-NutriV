# 🗄️ Esquema do Banco de Dados NutriV v2.0

Baseado no FitCal - AI Diet App

---

## 📊 Visão Geral das Tabelas

| Tabela | Propósito |
|--------|-----------|
| `user_profiles` | Perfil completo do usuário com metas |
| `meals` | Refeições com suporte a AI Scanner |
| `meal_items` | Itens/alimentos dentro de cada refeição |
| `food_entries` | Diário alimentar (entradas individuais) |
| `water_intake` | Controle de hidratação |
| `weight_logs` | Histórico de peso (Progress Chart) |
| `daily_summaries` | Resumo diário calculado (cache) |
| `activity_logs` | Atividades físicas |
| `ai_recognition_cache` | Cache de reconhecimento de imagens |
| `foods` | Base de dados de alimentos (mantida) |

---

## 👤 user_profiles

Perfil completo e metas do usuário.

```sql
id UUID PK REFERENCES auth.users
name TEXT NOT NULL
email TEXT UNIQUE
avatar_url TEXT

-- Dados físicos
birth_date DATE
gender TEXT (male|female|other)
height_cm NUMERIC
current_weight_kg NUMERIC

-- Objetivo
activity_level TEXT (sedentary|light|moderate|active|very_active)
goal_type TEXT (lose|maintain|gain)
target_weight_kg NUMERIC
weekly_goal_kg NUMERIC DEFAULT 0.5

-- Metas calculadas
bmr_calories NUMERIC
tdee_calories NUMERIC
daily_calories_target NUMERIC DEFAULT 2000

-- Macros
protein_target_g NUMERIC DEFAULT 150
carbs_target_g NUMERIC DEFAULT 200
fat_target_g NUMERIC DEFAULT 65

-- Outras metas
water_target_ml NUMERIC DEFAULT 2500
daily_steps_target INTEGER DEFAULT 10000

-- Preferências
measurement_unit TEXT (metric|imperial)
language TEXT
timezone TEXT

-- Timestamps
created_at, updated_at, last_active_at
```

---

## 🍽️ meals

Refeições principais com suporte a AI Scanner.

```sql
id UUID PK DEFAULT gen_random_uuid()
user_id UUID FK → auth.users

-- Identificação
name TEXT (ex: "Café da manhã", "Almoço")
meal_type TEXT (breakfast|lunch|dinner|snack|pre_workout|post_workout|other)

-- Data/hora
consumed_at TIMESTAMPTZ
date DATE

-- AI Scanner
ai_scan_image_url TEXT
ai_recognition_data JSONB
ai_confidence_score NUMERIC (0-1)
ai_was_edited BOOLEAN

-- Input
input_method TEXT (ai_scan|voice|barcode|manual|search|recipe)

-- Notas
notes TEXT

created_at, updated_at
```

### Tipos de Refeição (meal_type)
- `breakfast` - Café da manhã
- `lunch` - Almoço
- `dinner` - Jantar
- `snack` - Lanche
- `pre_workout` - Pré-treino
- `post_workout` - Pós-treino
- `other` - Outro

---

## 🥗 meal_items

Alimentos dentro de uma refeição.

```sql
id UUID PK
meal_id UUID FK → meals

-- Alimento
food_id UUID FK → foods (nullable)
food_name TEXT (denormalizado)

-- Quantidade
quantity_g NUMERIC DEFAULT 100
quantity_serving NUMERIC
serving_description TEXT ("1 fatia", "1 colher")

-- Nutrientes (denormalizados para performance)
calories NUMERIC
protein_g NUMERIC
carbs_g NUMERIC
fat_g NUMERIC
fiber_g NUMERIC
sugar_g NUMERIC
sodium_mg NUMERIC

-- Micronutrientes
micronutrients JSONB

display_order INTEGER
created_at TIMESTAMPTZ
```

---

## 📓 food_entries

Diário alimentar - entradas individuais.

```sql
id UUID PK
user_id UUID FK → auth.users

-- Alimento
food_id UUID FK → foods
food_name TEXT

-- Refeição associada
meal_id UUID FK → meals (nullable)
meal_type TEXT

-- Data
entry_date DATE
consumed_at TIMESTAMPTZ

-- Quantidade
quantity_g NUMERIC

-- Nutrientes
calories, protein_g, carbs_g, fat_g, fiber_g

-- Input
input_method TEXT

created_at TIMESTAMPTZ
```

---

## 💧 water_intake

Controle de hidratação.

```sql
id UUID PK
user_id UUID FK
amount_ml NUMERIC NOT NULL
entry_date DATE
consumed_at TIMESTAMPTZ
drink_type TEXT (water|coffee|tea|juice|soda|sports_drink|other)
created_at TIMESTAMPTZ
```

---

## ⚖️ weight_logs

Histórico de peso para gráficos de progresso.

```sql
id UUID PK
user_id UUID FK
weight_kg NUMERIC NOT NULL
entry_date DATE
recorded_at TIMESTAMPTZ
body_fat_percentage NUMERIC (opcional)
notes TEXT
source TEXT (manual|smart_scale|fitness_tracker)
created_at TIMESTAMPTZ
```

---

## 📊 daily_summaries

Resumo diário calculado (cache para performance).

```sql
id UUID PK
user_id UUID FK
summary_date DATE UNIQUE

-- Totais
total_calories NUMERIC
total_protein_g NUMERIC
total_carbs_g NUMERIC
total_fat_g NUMERIC
total_fiber_g NUMERIC

-- Água
water_consumed_ml NUMERIC

-- Metas
calories_target NUMERIC
calories_remaining (calculated)
is_goal_met (calculated)

-- Contadores
meals_count INTEGER
entries_count INTEGER

last_calculated_at TIMESTAMPTZ
```

---

## 🏃 activity_logs

Atividades físicas.

```sql
id UUID PK
user_id UUID FK

activity_type TEXT (walking|running|cycling|swimming|gym|yoga|sports|hiit|cardio|strength|other)
duration_minutes INTEGER
calories_burned NUMERIC

-- Opcional
steps_count INTEGER
distance_km NUMERIC

activity_date DATE
started_at, ended_at TIMESTAMPTZ
notes TEXT

created_at TIMESTAMPTZ
```

---

## 🤖 ai_recognition_cache

Cache de reconhecimento de imagens para performance.

```sql
id UUID PK
image_hash TEXT UNIQUE
image_url TEXT

recognized_foods JSONB
total_calories_estimated NUMERIC

-- Feedback
user_corrections JSONB
was_helpful BOOLEAN

usage_count INTEGER
last_used_at TIMESTAMPTZ
created_at TIMESTAMPTZ
```

---

## 🔐 Segurança (RLS)

Todas as tabelas têm **Row Level Security** ativado:
- Usuários só veem seus próprios dados
- Cada `user_id` é validado contra `auth.uid()`

---

## ⚡ Triggers Automáticos

1. **Novo usuário** → Cria perfil automaticamente em `user_profiles`
2. **Nova refeição/item** → Recalcula `daily_summaries`
3. **Updated_at** → Atualiza automaticamente

---

## 📈 Consultas Comuns

### Resumo do dia atual
```sql
SELECT * FROM daily_summaries 
WHERE user_id = auth.uid() 
AND summary_date = CURRENT_DATE;
```

### Refeições de hoje
```sql
SELECT m.*, mi.food_name, mi.calories
FROM meals m
LEFT JOIN meal_items mi ON mi.meal_id = m.id
WHERE m.user_id = auth.uid()
AND m.date = CURRENT_DATE
ORDER BY m.consumed_at;
```

### Histórico de peso (últimos 30 dias)
```sql
SELECT * FROM weight_logs
WHERE user_id = auth.uid()
AND entry_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY entry_date DESC;
```

---

## 🔄 Fluxo de Dados

```
Usuário faz login
    ↓
Trigger cria user_profiles
    ↓
Usuário adiciona refeição (manual ou AI Scan)
    ↓
INSERT INTO meals (+ meal_items)
    ↓
Trigger recalcula daily_summaries
    ↓
App mostra resumo atualizado
```

---

*Esquema criado em: Abril 2026*
*Baseado em: FitCal AI Diet App*
