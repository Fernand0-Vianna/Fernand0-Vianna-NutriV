# Comparativo: NutriV vs FitCal

> Análise baseada na Play Store: https://play.google.com/store/apps/details?id=com.lucasqueiroga.fitcal

---

## 📊 Funcionalidades FitCal vs NutriV

| Funcionalidade | FitCal | NutriV | Status |
|---------------|-------|--------|--------|
| **AI Food Recognition** | ✅ 97% accuracy | ⚠️ Parcial | Melhorar |
| **Diário Alimentar** | ✅ Completo | ✅ Parcial | OK |
| **Criar Pratos Favoritos** | ✅ | ⚠️ Parcial | Melhorar |
| **Scanner Barcode** | ✅ | ✅ | OK |
| **Entrada por Voz** | ❌ Mencionado | ⚠️ Widget existe | Integrar |
| **Rastrear Peso** | ✅ Com histórico | ✅ | OK |
| **Rastrear Atividade** | ✅ Incluindo passos | ✅ Steps via sensor | OK |
| **Metas Personalizadas** | ✅ Baseado no perfil | ✅ | OK |
| **Modo Offline** | ❓ | ❌ | Implementar |
| **Planos (Freemium)** | ✅ Assinatura | ❌ |later |

---

## 🎯 Funcionalidades Prioritárias para NutriV

### 🔴 Alta Prioridade

1. **AI Food Recognition Melhorado**
   - Usar Google Cloud Vision API
   - Melhorar precisão para 90%+
   - Adicionar feedback do usuário

2. **Diário Completo**
   - Editar refeições passadas
   - Adicionar notas
   - Duplicar refeições para outro dia

3. **Modo Offline**
   - Cache local com Sqflite
   - Sync automático online
   - Resolver conflitos

4. **Pratos Favoritos**
   - Criar/editar favoritos
   - Copiar para hoje
   - Histórico de uso

### 🟡 Média Prioridade

5. **Entrada por Voz Integrada**
   - Conectar ao FoodScannerBloc
   - Melhorar reconhecimento

6. **Gráficos de Progresso**
   - Dados reais conectados
   - Tendências
   - Exportação (CSV/PDF)

7. **Atividade Física**
   - Historico de exercícios
   - Calorias queimadas

---

## 📱 UI/UX - O que o FitCal Tem

### Home Screen
- Ring de progresso calórico
- macros visualizados
- Quick add buttons
- Recent foods

### Diary
- Visualização por dia/semana
- Breakfast/Lunch/Dinner/Snack tabs
- Quick add

### Scanner
- Câmera com AI overlay
- Resultado instantâneo

### Profile/Progress
- Charts de peso
- Metas
- Histórico

---

## gaps Técnico

### Auth/Registro
- [ ] Criar user_profiles no Supabase após registro
- [ ] Testar login Google OAuth completo
- [ ] Session management

### Sync
- [ ] Migrar para schema V2 (meals + meal_items)
- [ ] Implementar offline com Sqflite
- [ ] Tratamento de conflitos

### Dados
- [ ] Adicionar micronutrientes ao FoodItem
- [ ] Buscar na USDA API completo
- [ ] Cache de alimentos

---

## Implementações Realizadas (24/04/2026)

### AI Food Recognition ✅
- [x] HuggingFace Inference API integrado
- [x] Banco local com 30 alimentos brasileiros
- [x] Fallback Gemini + OpenFoodFacts
- [x] Busca por nome com múltiplos fallbacks

### Dark/Light Theme ✅
- [x] Toggle implementado na página de perfil
- [x] Preferência salva no SharedPreferences

---

## Referências

- FitCal: https://fitcalai.app/
- HuggingFace Model: https://huggingface.co/BinhQuocNguyen/food-recognition-model
- Schema V2: `DATABASE_SCHEMA_V2.md`
- Pendências: `../Pendencias_Amanha.md`