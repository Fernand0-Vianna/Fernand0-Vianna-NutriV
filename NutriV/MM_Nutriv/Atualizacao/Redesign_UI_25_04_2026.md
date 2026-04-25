# Resumo: Redesign UI NutriV - Base FitCal

> Data: 25/04/2026
> Status: Em Andamento

---

## Análise Realizada

### Estrutura do App Analisada
- `nutriv/lib/main.dart` - Routing principal
- `nutriv/lib/core/theme/app_theme.dart` - Tema atual (verde escuro)
- `nutriv/lib/presentation/pages/splash/splash_page.dart` - Splash screen
- `nutriv/lib/presentation/pages/login/login_page.dart` - Login
- `nutriv/lib/presentation/pages/login/register_page.dart` - Registro
- `nutriv/lib/presentation/pages/home/home_page.dart` - Dashboard
- `nutriv/lib/presentation/pages/diary/diary_page.dart` - Diário
- `nutriv/lib/presentation/widgets/pineapple_logo.dart` - Logo (Anime style)

### Paleta de Cores Atual
- Primary: `#006A35` (Verde escuro)
- Primary Container: `#6BFE9C` (Verde pastel)
- Secondary: `#006946`
- Surface: `#DBFFE8` (Verde claro)
- On Surface: `#003622` (Preto esverdeado)

### Referências Consultadas
- `MM_Nutriv/Analise_FitCal_VS_NutriV.md` - GAP Analysis
- `MM_Nutriv/Melhorias/Comparativo_FitCal.md` - Comparativo UI
- `MM_Nutriv/referencias/stitch_flutter_ui_design/verdant_health/DESIGN.md` - Design System

---

## Mudanças Realizadas

### ✅ Login Page (25/04/2026)
- Background alterado de gradient `surface → surfaceContainerLow` para `primary → secondary`
- Mantém a mesma estrutura e funcionalidade
- Implementa a paleta pastel amarelo/verde requested

---

## Próximos Passos (Planejado)

### 1. Splash Screen
- [ ] Adaptar animação para estilo FitCal
- [ ] Manter paleta amarelo/verde/preto/branco
- [ ]-gradient mais suave

### 2. Login/Register
- [ ] Refinar cards com sombras mais suaves
- [ ] Animação de entrada
- [ ] Consistent colors

### 3. Home/Dashboard
- [ ] Ring de progresso calórico (como FitCal)
- [ ] Quick add buttons
- [ ] Recent foods list

### 4. Diary
- [ ] Visualização por tabs (Breakfast/Lunch/Dinner/Snack)
- [ ] Quick add
- [ ] Editar refeições passadas

### 5. Scanner
- [ ] UI de câmera com AI overlay
- [ ] Resultado instantâneo

### 6. Profile/Progress
- [ ] Charts de peso
- [ ] Metas
- [ ] Histórico

### 7. Tema Consistent
- [ ] Yellow pastel (`#FFFF00` ou similar)
- [ ] Green pastel (`#6BFE9C`)
- [ ] Preto (`#1a1a1a`)
- [ ] Branco (`#FFFFFF`)

---

## Paleta Pastel Proposta

| Elemento | Cor Atual | Cor Pastel |
|----------|----------|------------|
| Primary | `#006A35` | `#7CB342` (verde pastel) |
| Yellow Accent | `#FFB800` | `#FFD54F` (amarelo pastel) |
| On Surface | `#003622` | `#1a1a1a` (preto) |
| Background | `#DBFFE8` | `#FFFFFF` (branco) |
| Cards | `#FFFFFF` | `#FAFAFA` (off-white) |

---

*Documento para rastreamento do redesign UI*