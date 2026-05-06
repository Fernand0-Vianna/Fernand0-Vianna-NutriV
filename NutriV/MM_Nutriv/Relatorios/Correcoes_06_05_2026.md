# Relatório de Correções - NutriV

**Data:** 06/05/2026

---

## Problemas Identificados e Corrigidos

### 1. Adição de Alimentos - Múltiplos Pratos
**Problema:** Ao adicionar mais alimentos em uma refeição (ex: "+" no café da manhã), o código criava uma nova refeição em vez de adicionar ao card existente.

**Solução:** Modificado `diary_page.dart` para:
1. Verificar se já existe refeição do tipo no dia
2. Se existir: usar `AddFoodToMeal` → adiciona ao card existente
3. Se não existir: usar `AddMealFood` → cria novo card

**Arquivos modificados:**
- `lib/presentation/pages/diary/diary_page.dart`

---

### 2. Login Google - App Congelando
**Problema:** Ao fazer login com Google, o app congelava porque o fluxo navegava imediatamente antes do OAuth completar.

**Solução:** 
- Modificado `onboarding_page.dart` para não navegar imediatamente após chamar signInWithGoogle
- Adicionado listener de auth state no `main.dart` para detectar mudanças de autenticação
- Adicionado método `createProfileIfNotExists` no `auth_service.dart` para criar perfil no Supabase

**Arquivos modificados:**
- `lib/main.dart`
- `lib/presentation/pages/onboarding/onboarding_page.dart`
- `lib/data/datasources/auth_service.dart`

---

### 3. Integração com APIs de IA
**Status:**
| API | Status |
|-----|--------|
| Groq (Chat) | ✅ Funcionando |
| FoodAPI | ❌ Limite esgotado |
| LogMeal | ❌ Precisa plano pago |
| Banco local | ✅ 30 alimentos |

**Chat IA disponível:** Pergunte sobre macros como "Quantas proteínas tem um ovo?"

---

## Build
- **APK:** `build/app/outputs/flutter-apk/app-debug.apk`
- **Data do build:** 06/05/2026

---

## Próximos Passos
1. Testar login Google em dispositivo físico
2. Testar adição de múltiplos alimentos na mesma refeição
3. Verificar se ainda há falhas visuais
4. Implementar crash reporting (Sentry/Crashlytics)