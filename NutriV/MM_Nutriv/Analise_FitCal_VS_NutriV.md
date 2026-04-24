# Análise FitCal vs NutriV - GAP Analysis

## 📊 Comparativo de Funcionalidades

| # | Funcionalidade | FitCal | NutriV | Status |
|---|--------------|-------|--------|--------|
| 1 | AI Food Recognition (Foto) | ✅ Premium | ✅ Implementado | 🟢 |
| 2 | AI Voice Input | ✅ | ⚠️ Parcial | 🟡 |
| 3 | AI Text Input | ✅ | ✅ Implementado | 🟢 |
| 4 | Barcode Scanner | ✅ | ✅ Implementado | 🟢 |
| 5 | Banco de Dados de Alimentos | ✅ | ✅ USDA | 🟢 |
| 6 | Nutritional Table Input | ✅ | ❌ Falta | 🔴 |
| 7 | Food Diary Completo | ✅ | ✅ Implementado | 🟢 |
| 8 | Favorite Dishes | ✅ | ✅ Implementado | 🟢 |
| 9 | Meal History | ✅ | ✅ Implementado | 🟢 |
| 10 | Weight Tracking | ✅ | ✅ Implementado | 🟢 |
| 11 | Progress Charts | ✅ | ✅ fl_chart | 🟢 |
| 12 | Hydration/Water Tracker | ✅ | ✅ Implementado | 🟢 |
| 13 | Activity/Steps Tracking | ✅ | ✅ Pedometer | 🟢 |
| 14 | Daily Summary Dashboard | ✅ | ✅ Implementado | 🟢 |
| 15 | Macro Tracking | ✅ | ✅ Implementado | 🟢 |
| 16 | Calorie Goals | ✅ | ✅ Implementado | 🟢 |
| 17 | Goal Setting (lose/gain/maintain) | ✅ | ✅ Implementado | 🟢 |
| 18 | Portion Editing | ✅ | ✅ Implementado | 🟢 |
| 19 | Micronutrients | ✅ Opcional | ⚠️ Falta | 🔴 |
| 20 | Challenges/Groups | ✅ Premium | ❌ Falta | 🔴 |
| 21 | Recipe Creator | ⚠️ | ✅ Implementado | 🟢 |
| 22 | Copy Meals | ✅ | ⚠️ Parcial | 🟡 |
| 23 | Offline Mode | ⚠️ | ⚠️ Falta | 🔴 |
| 24 | Data Export | ✅ | ❌ Falta | 🔴 |
| 25 | Dark/Light Theme | ✅ | ❌ Falta | 🔴 |

---

## 🔴 Funcionalidades FALTANTES

### 1. Nutritional Table Input (OCR)
- **Descrição:** Capturar tabela nutricional de alimentos industrializados
- **API Recomendada:** Google ML Kit Text Recognition ou Google Cloud Vision API
- **Alternativa:** OpenAI GPT-4 Vision analisar imagem da tabela

### 2. Micronutrients Tracking
- **Descrição:** Vitamins (A, C, D, etc), Minerals (Iron, Calcium, etc)
- **Dados:** Adicionar campos no FoodItem model
- **API:** USDA FoodData Central já fornece micronutrients

### 3. Challenges/Groups (Social)
- **Descrição:** Desafios entre usuarios, rankings, grupos
- **Complexidade:** Alta (需要 backend adicional)
- **Prioridade:** Baixa (pode ser premium)

### 4. Offline Mode
- **Descrição:** Funcionar sem internet
- **Implementação:** SQLite + Sync com Supabase quando online
- **Prioridade:** Alta

### 5. Data Export
- **Descrição:** Exportar dados (CSV, PDF)
- **Implementação:** gerar CSV/PDF do diary
- **Prioridade:** Média

### 6. Dark/Light Theme
- **Descrição:** Toggle de tema
- **Implementação:** ThemeMode.toggle ou Provider
- **Prioridade:** Média

---

## 🟡 Funcionalidades PARCIAIS

### 1. Voice Input
- **Problema:** speech_to_text tem limitações em português
- **Solução:** Usar API de speech-to-text com suporte PT-BR
- **API Sugerida:** Google Cloud Speech-to-Text

### 2. Copy Meals
- **Problema:** Funcionalidade pode não estar completa
- **Solução:** Implementar "Copy to Today" em meals anteriores

---

## 🆚 APIs Necessárias

### Para igualar FitCal, adicionar:

| API | Função | Custo |
|-----|-------|------|
| Google Cloud Vision | OCR Tabela Nutricional | $1.50/1000 img |
| Google Cloud Speech | Voice input PT-BR | $0.006/15seg |
| Firebase Remote Config | Controle de features | Grátis |
| Firebase Analytics | Eventos/usage | Grátis |
| Firebase Crashlytics | Erros/app | Grátis |

---

## 📋 Plano de Implementação

### Fase 1 - Offline & Sync (Alta Prioridade)
- [ ] Implementar sync offline com Sqflite
- [ ] Cache de alimentos USDA
- [ ] Sync automático quando online

### Fase 2 - Melhorias UI/UX
- [ ] Dark/Light Theme
- [ ] Data Export (CSV)
- [ ] Copy Meals completo

### Fase 3 - Funcionalidades Avançadas
- [ ] Nutritional Table OCR
- [ ] Micronutrients
- [ ] Desafios/Grupos (opcional premium)

---

*Analise gerada em: 24/04/2026*
*FitCal ref: https://fitcalai.app/*