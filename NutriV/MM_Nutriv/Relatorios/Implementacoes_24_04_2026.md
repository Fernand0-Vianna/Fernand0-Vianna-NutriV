# Relatório de Implementações - NutriV

**Data:** 24/04/2026  
**Session:** Trabalho conjunto

---

## ✅ Implementações Realizadas

### 1. Dark/Light Theme
- [x] Toggle implementado na página de perfil
- [x] Preferência salva no SharedPreferences
- [x] ThemeNotifier criado

### 2. Busca de Alimentos (Diário)
- [x] Busca por texto no diário
- [x] Múltiplos fallbacks (USDA → Gemini → OpenFoodFacts → Banco local)
- [x] Adicionar mais alimentos a refeições existentes

### 3. AI Food Recognition
- [x] Google Gemini integrado (gratuito)
- [x] Fallback com banco local (30 alimentos brasileiros)
- [x] Melhorias no tratamento de erros

### 4. Código de Barras
- [x] Gemini como fallback quando macros vierem zerados

### 5. Auth/Login
- [x] Criação automática de user_profiles no Supabase
- [x] Criação de perfil no login Google
- [x] Logout corrigido

### 6. Logo do App
- [x] Novos ícones gerados (Android + iOS)
- [x] Logo com "V" verde

### 7. Data Export
- [x] Menu de exportação no Perfil
- [x] CSV do diário implementado
- [x] CSV de peso (estrutura pronta)

---

## Pendências Remanescentes

| # | Pendência | Status |
|---|-----------|--------|
| 1 | Modo Offline | ⏳ Não implementado |
| 2 | Copy Meals | ⏳ Problemas técnicos |
| 3 | Testes unitários | ⏳ Não implementado |

---

## Issues Técnicas (Menores)

```
- 2 infos: Variável Ingredients em recipe_service.dart
- 1 warning: Unused import em meal_bloc.dart
- 1 warning: CSV não usado em profile_page.dart
- 1 warning: MealCard.onCopy não final
```

---

## Estrutura do Projeto

```
lib/
├── core/
│   ├── constants/app_constants.dart
│   ├── di/injection.dart
│   ├── theme/app_theme.dart
│   ├── theme/theme_notifier.dart
│   └── utils/helpers.dart
├── data/
│   ├── datasources/ (8 arquivos)
│   ├── models/ (8 arquivos)
│   └── repositories/ (11 arquivos)
├── domain/
│   └── entities/ (5 arquivos)
├── presentation/
│   ├── bloc/ (9 blocs)
│   ├── pages/ (11 páginas)
│   └── widgets/ (7 widgets)
└── main.dart
```

---

## APIs Configuradas

| API | Chave | Status |
|-----|-------|--------|
| Supabase | ✅ | OK |
| Gemini | ✅ | OK |
| USDA | demokey | Precisa configurar |
| HuggingFace | - | Não configurado |

---

## Próximos Passos Sugeridos

1. Configurar USDA API key (gratuita)
2. Implementar Modo Offline com Sqflite
3. Adicionar testes unitários
4. Implementar Copy Meals

---

*Relatório gerado em 24/04/2026*