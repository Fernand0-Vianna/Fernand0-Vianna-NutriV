-- NutriV Database Schema v2.0
-- Baseline Migration: Captures current state as of 2026-05-08

-- ============================================================
-- EXTENSIONS
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pgjwt";

-- ============================================================
-- TABLES
-- ============================================================

-- User profiles
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  avatar_url TEXT,
  birth_date DATE,
  gender TEXT,
  height_cm NUMERIC,
  current_weight_kg NUMERIC,
  activity_level TEXT,
  goal_type TEXT,
  target_weight_kg NUMERIC,
  weekly_goal_kg NUMERIC DEFAULT 0.5,
  bmr_calories NUMERIC,
  tdee_calories NUMERIC,
  daily_calories_target NUMERIC DEFAULT 2000,
  protein_target_g NUMERIC DEFAULT 150,
  carbs_target_g NUMERIC DEFAULT 200,
  fat_target_g NUMERIC DEFAULT 65,
  water_target_ml NUMERIC DEFAULT 2500,
  daily_steps_target INTEGER DEFAULT 10000,
  measurement_unit TEXT DEFAULT 'metric',
  language TEXT DEFAULT 'pt-BR',
  timezone TEXT DEFAULT 'America/Sao_Paulo',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  last_active_at TIMESTAMPTZ DEFAULT now()
);

-- Profiles (legacy)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT,
  height NUMERIC,
  weight NUMERIC,
  goal TEXT,
  activity_level TEXT,
  daily_calories_target NUMERIC,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Meals
CREATE TABLE IF NOT EXISTS meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  meal_type TEXT,
  consumed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  ai_scan_image_url TEXT,
  ai_recognition_data JSONB,
  ai_confidence_score NUMERIC,
  ai_was_edited BOOLEAN DEFAULT FALSE,
  input_method TEXT DEFAULT 'manual',
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_meals_user_date ON meals(user_id, date);
CREATE INDEX IF NOT EXISTS idx_meals_consumed_at ON meals(user_id, consumed_at);

-- Foods base
CREATE TABLE IF NOT EXISTS foods (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  calories NUMERIC,
  protein NUMERIC,
  carbs NUMERIC,
  fat NUMERIC,
  fiber NUMERIC DEFAULT 0,
  serving_size NUMERIC,
  category TEXT,
  image_url TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_foods_name ON foods(name);

-- Food nutrition history
CREATE TABLE IF NOT EXISTS food_nutrition_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  food_id UUID,
  user_id UUID,
  calories NUMERIC,
  protein NUMERIC,
  carbs NUMERIC,
  fat NUMERIC,
  fiber NUMERIC DEFAULT 0,
  serving_size NUMERIC DEFAULT 100,
  source TEXT,
  registered_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Meal items
CREATE TABLE IF NOT EXISTS meal_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  meal_id UUID NOT NULL REFERENCES meals(id) ON DELETE CASCADE,
  food_id UUID REFERENCES foods(id) ON DELETE SET NULL,
  food_name TEXT NOT NULL,
  quantity_g NUMERIC NOT NULL DEFAULT 100,
  quantity_serving NUMERIC,
  serving_description TEXT,
  calories NUMERIC NOT NULL DEFAULT 0,
  protein_g NUMERIC DEFAULT 0,
  carbs_g NUMERIC DEFAULT 0,
  fat_g NUMERIC DEFAULT 0,
  fiber_g NUMERIC DEFAULT 0,
  sugar_g NUMERIC DEFAULT 0,
  sodium_mg NUMERIC DEFAULT 0,
  micronutrients JSONB,
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_meal_items_meal ON meal_items(meal_id);

-- Food entries
CREATE TABLE IF NOT EXISTS food_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  food_id UUID,
  food_name TEXT NOT NULL,
  meal_id UUID,
  meal_type TEXT,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  consumed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  quantity_g NUMERIC NOT NULL DEFAULT 100,
  calories NUMERIC NOT NULL DEFAULT 0,
  protein_g NUMERIC DEFAULT 0,
  carbs_g NUMERIC DEFAULT 0,
  fat_g NUMERIC DEFAULT 0,
  fiber_g NUMERIC DEFAULT 0,
  input_method TEXT DEFAULT 'manual',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_food_entries_user_date ON food_entries(user_id, entry_date);

-- Water intake
CREATE TABLE IF NOT EXISTS water_intake (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  amount_ml NUMERIC NOT NULL,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  consumed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  drink_type TEXT DEFAULT 'water',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_water_intake_user_date ON water_intake(user_id, entry_date);

-- Weight logs
CREATE TABLE IF NOT EXISTS weight_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  weight_kg NUMERIC NOT NULL,
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  recorded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  body_fat_percentage NUMERIC,
  notes TEXT,
  source TEXT DEFAULT 'manual',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_weight_logs_user_date ON weight_logs(user_id, entry_date);

-- Daily summaries
CREATE TABLE IF NOT EXISTS daily_summaries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  summary_date DATE NOT NULL DEFAULT CURRENT_DATE,
  total_calories NUMERIC DEFAULT 0,
  total_protein_g NUMERIC DEFAULT 0,
  total_carbs_g NUMERIC DEFAULT 0,
  total_fat_g NUMERIC DEFAULT 0,
  total_fiber_g NUMERIC DEFAULT 0,
  water_consumed_ml NUMERIC DEFAULT 0,
  calories_target NUMERIC DEFAULT 2000,
  calories_remaining NUMERIC,
  is_goal_met BOOLEAN,
  meals_count INTEGER DEFAULT 0,
  entries_count INTEGER DEFAULT 0,
  last_calculated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_daily_summaries_user ON daily_summaries(user_id, summary_date);

-- Activity logs
CREATE TABLE IF NOT EXISTS activity_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  activity_type TEXT NOT NULL,
  duration_minutes INTEGER NOT NULL,
  calories_burned NUMERIC,
  steps_count INTEGER,
  distance_km NUMERIC,
  activity_date DATE NOT NULL DEFAULT CURRENT_DATE,
  started_at TIMESTAMPTZ,
  ended_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activity_logs_user_date ON activity_logs(user_id, activity_date);

-- Favorite dishes
CREATE TABLE IF NOT EXISTS favorite_dishes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  items JSONB NOT NULL DEFAULT '[]'::jsonb,
  total_calories NUMERIC DEFAULT 0,
  total_protein NUMERIC DEFAULT 0,
  total_carbs NUMERIC DEFAULT 0,
  total_fat NUMERIC DEFAULT 0,
  times_used INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_favorite_dishes_user ON favorite_dishes(user_id);

-- AI recognition cache
CREATE TABLE IF NOT EXISTS ai_recognition_cache (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  image_hash TEXT NOT NULL,
  image_url TEXT,
  recognized_foods JSONB NOT NULL,
  total_calories_estimated NUMERIC,
  user_corrections JSONB,
  was_helpful BOOLEAN,
  usage_count INTEGER DEFAULT 1,
  last_used_at TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_ai_cache_hash ON ai_recognition_cache(image_hash);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

-- user_profiles
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can view own profile' AND tablename = 'user_profiles') THEN
    CREATE POLICY "Users can view own profile" ON user_profiles FOR SELECT USING (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Enable insert for trigger' AND tablename = 'user_profiles') THEN
    CREATE POLICY "Enable insert for trigger" ON user_profiles FOR INSERT WITH CHECK (auth.uid() = id);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can update own profile' AND tablename = 'user_profiles') THEN
    CREATE POLICY "Users can update own profile" ON user_profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
END $$;

-- profiles (legacy)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'profiles') THEN
    CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
    CREATE POLICY "Enable insert for authenticated users" ON profiles FOR INSERT WITH CHECK (true);
    CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
  END IF;
END $$;

-- meals
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE policyname = 'Users can view own meals' AND tablename = 'meals') THEN
    CREATE POLICY "Users can view own meals" ON meals FOR SELECT USING (auth.uid() = user_id);
    CREATE POLICY "Users can insert own meals" ON meals FOR INSERT WITH CHECK (auth.uid() = user_id);
    CREATE POLICY "Users can update own meals" ON meals FOR UPDATE USING (auth.uid() = user_id);
    CREATE POLICY "Users can delete own meals" ON meals FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- meal_items
ALTER TABLE meal_items ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'meal_items') THEN
    CREATE POLICY "Users can view meal items" ON meal_items FOR SELECT USING (
      EXISTS (SELECT 1 FROM meals WHERE meals.id = meal_items.meal_id AND meals.user_id = auth.uid())
    );
    CREATE POLICY "Users can insert meal items" ON meal_items FOR INSERT WITH CHECK (
      EXISTS (SELECT 1 FROM meals WHERE meals.id = meal_items.meal_id AND meals.user_id = auth.uid())
    );
    CREATE POLICY "Users can update meal items" ON meal_items FOR UPDATE USING (
      EXISTS (SELECT 1 FROM meals WHERE meals.id = meal_items.meal_id AND meals.user_id = auth.uid())
    );
    CREATE POLICY "Users can delete meal items" ON meal_items FOR DELETE USING (
      EXISTS (SELECT 1 FROM meals WHERE meals.id = meal_items.meal_id AND meals.user_id = auth.uid())
    );
  END IF;
END $$;

-- food_entries
ALTER TABLE food_entries ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'food_entries') THEN
    CREATE POLICY "Users can view own entries" ON food_entries FOR SELECT USING (auth.uid() = user_id);
    CREATE POLICY "Users can insert own entries" ON food_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
    CREATE POLICY "Users can update own entries" ON food_entries FOR UPDATE USING (auth.uid() = user_id);
    CREATE POLICY "Users can delete own entries" ON food_entries FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- water_intake
ALTER TABLE water_intake ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'water_intake') THEN
    CREATE POLICY "Users can view own water" ON water_intake FOR SELECT USING (auth.uid() = user_id);
    CREATE POLICY "Users can insert own water" ON water_intake FOR INSERT WITH CHECK (auth.uid() = user_id);
    CREATE POLICY "Users can update own water" ON water_intake FOR UPDATE USING (auth.uid() = user_id);
    CREATE POLICY "Users can delete own water" ON water_intake FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- weight_logs
ALTER TABLE weight_logs ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'weight_logs') THEN
    CREATE POLICY "Users can view own weight" ON weight_logs FOR SELECT USING (auth.uid() = user_id);
    CREATE POLICY "Users can insert own weight" ON weight_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
    CREATE POLICY "Users can update own weight" ON weight_logs FOR UPDATE USING (auth.uid() = user_id);
    CREATE POLICY "Users can delete own weight" ON weight_logs FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- daily_summaries
ALTER TABLE daily_summaries ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'daily_summaries') THEN
    CREATE POLICY "Users can view own summaries" ON daily_summaries FOR SELECT USING (auth.uid() = user_id);
  END IF;
END $$;

-- activity_logs
ALTER TABLE activity_logs ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'activity_logs') THEN
    CREATE POLICY "Users can view own activities" ON activity_logs FOR SELECT USING (auth.uid() = user_id);
    CREATE POLICY "Users can insert own activities" ON activity_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
    CREATE POLICY "Users can update own activities" ON activity_logs FOR UPDATE USING (auth.uid() = user_id);
    CREATE POLICY "Users can delete own activities" ON activity_logs FOR DELETE USING (auth.uid() = user_id);
  END IF;
END $$;

-- foods
ALTER TABLE foods ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'foods') THEN
    CREATE POLICY "Anyone can view foods" ON foods FOR SELECT USING (true);
    CREATE POLICY "Users can insert their own foods" ON foods FOR INSERT WITH CHECK (auth.uid() = created_by);
    CREATE POLICY "Users can update own foods" ON foods FOR UPDATE USING (auth.uid() = created_by);
    CREATE POLICY "Users can delete own foods" ON foods FOR DELETE USING (auth.uid() = created_by);
  END IF;
END $$;

-- food_nutrition_history
ALTER TABLE food_nutrition_history ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'food_nutrition_history') THEN
    CREATE POLICY "Users can view their own food history" ON food_nutrition_history FOR SELECT USING (auth.uid() = user_id);
    CREATE POLICY "Users can insert their own food history" ON food_nutrition_history FOR INSERT WITH CHECK (auth.uid() = user_id);
  END IF;
END $$;

-- favorite_dishes
ALTER TABLE favorite_dishes ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'favorite_dishes') THEN
    EXECUTE format('CREATE POLICY %I ON favorite_dishes FOR SELECT USING (auth.uid() = user_id)', 'Users can view own favorite dishes');
    EXECUTE format('CREATE POLICY %I ON favorite_dishes FOR INSERT WITH CHECK (auth.uid() = user_id)', 'Users can insert own favorite dishes');
    EXECUTE format('CREATE POLICY %I ON favorite_dishes FOR UPDATE USING (auth.uid() = user_id)', 'Users can update own favorite dishes');
    EXECUTE format('CREATE POLICY %I ON favorite_dishes FOR DELETE USING (auth.uid() = user_id)', 'Users can delete own favorite dishes');
  END IF;
END $$;

-- ai_recognition_cache
ALTER TABLE ai_recognition_cache ENABLE ROW LEVEL SECURITY;
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'ai_recognition_cache') THEN
    CREATE POLICY "Anyone can view AI cache" ON ai_recognition_cache FOR SELECT USING (auth.role() = 'authenticated');
  END IF;
END $$;

-- ============================================================
-- TRIGGERS & FUNCTIONS
-- ============================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update_updated_at trigger to tables that have updated_at
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_foods_updated_at') THEN
    CREATE TRIGGER update_foods_updated_at BEFORE UPDATE ON foods FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_meals_updated_at') THEN
    CREATE TRIGGER update_meals_updated_at BEFORE UPDATE ON meals FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_user_profiles_updated_at') THEN
    CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'update_profiles_updated_at') THEN
    CREATE TRIGGER update_profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();
  END IF;
END $$;

-- Daily summary recalculation
CREATE OR REPLACE FUNCTION recalculate_daily_summary()
RETURNS TRIGGER AS $$
DECLARE
  v_user_id UUID;
  v_date DATE;
BEGIN
  IF TG_OP = 'DELETE' THEN
    SELECT m.user_id, m.date INTO v_user_id, v_date FROM meals m WHERE m.id = OLD.meal_id;
  ELSE
    SELECT m.user_id, m.date INTO v_user_id, v_date FROM meals m WHERE m.id = NEW.meal_id;
  END IF;

  INSERT INTO daily_summaries (user_id, summary_date, total_calories, total_protein_g, total_carbs_g, total_fat_g, meals_count)
  SELECT
    v_user_id, v_date,
    COALESCE((SELECT SUM(mi.calories) FROM meal_items mi JOIN meals m ON m.id = mi.meal_id WHERE m.user_id = v_user_id AND m.date = v_date), 0),
    COALESCE((SELECT SUM(mi.protein_g) FROM meal_items mi JOIN meals m ON m.id = mi.meal_id WHERE m.user_id = v_user_id AND m.date = v_date), 0),
    COALESCE((SELECT SUM(mi.carbs_g) FROM meal_items mi JOIN meals m ON m.id = mi.meal_id WHERE m.user_id = v_user_id AND m.date = v_date), 0),
    COALESCE((SELECT SUM(mi.fat_g) FROM meal_items mi JOIN meals m ON m.id = mi.meal_id WHERE m.user_id = v_user_id AND m.date = v_date), 0),
    COALESCE((SELECT COUNT(DISTINCT m.id) FROM meals m WHERE m.user_id = v_user_id AND m.date = v_date), 0)
  ON CONFLICT (user_id, summary_date) DO UPDATE SET
    total_calories = EXCLUDED.total_calories,
    total_protein_g = EXCLUDED.total_protein_g,
    total_carbs_g = EXCLUDED.total_carbs_g,
    total_fat_g = EXCLUDED.total_fat_g,
    meals_count = EXCLUDED.meals_count,
    last_calculated_at = now();

  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'recalc_summary_on_meal_item') THEN
    CREATE TRIGGER recalc_summary_on_meal_item
      AFTER INSERT OR UPDATE OR DELETE ON meal_items
      FOR EACH ROW EXECUTE FUNCTION recalculate_daily_summary();
  END IF;
END $$;

-- Food average calculation
CREATE OR REPLACE FUNCTION trigger_update_food_average()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE foods SET
    calories = (SELECT ROUND(AVG(calories), 2) FROM food_nutrition_history WHERE food_id = NEW.food_id),
    protein = (SELECT ROUND(AVG(protein), 2) FROM food_nutrition_history WHERE food_id = NEW.food_id),
    carbs = (SELECT ROUND(AVG(carbs), 2) FROM food_nutrition_history WHERE food_id = NEW.food_id),
    fat = (SELECT ROUND(AVG(fat), 2) FROM food_nutrition_history WHERE food_id = NEW.food_id),
    fiber = (SELECT ROUND(AVG(fiber), 2) FROM food_nutrition_history WHERE food_id = NEW.food_id)
  WHERE id = NEW.food_id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trg_update_food_average') THEN
    CREATE TRIGGER trg_update_food_average
      AFTER INSERT ON food_nutrition_history
      FOR EACH ROW EXECUTE FUNCTION trigger_update_food_average();
  END IF;
END $$;

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

CREATE OR REPLACE FUNCTION get_daily_totals(target_user_id UUID, target_date DATE)
RETURNS TABLE (
  total_calories NUMERIC,
  total_protein_g NUMERIC,
  total_carbs_g NUMERIC,
  total_fat_g NUMERIC,
  total_fiber_g NUMERIC,
  water_consumed_ml NUMERIC,
  meals_count BIGINT
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    COALESCE(SUM(mi.calories), 0)::NUMERIC,
    COALESCE(SUM(mi.protein_g), 0)::NUMERIC,
    COALESCE(SUM(mi.carbs_g), 0)::NUMERIC,
    COALESCE(SUM(mi.fat_g), 0)::NUMERIC,
    COALESCE(SUM(mi.fiber_g), 0)::NUMERIC,
    COALESCE((SELECT SUM(amount_ml) FROM water_intake WHERE user_id = target_user_id AND entry_date = target_date), 0)::NUMERIC,
    COUNT(DISTINCT m.id)::BIGINT
  FROM meals m
  LEFT JOIN meal_items mi ON mi.meal_id = m.id
  WHERE m.user_id = target_user_id AND m.date = target_date;
END;
$$;
