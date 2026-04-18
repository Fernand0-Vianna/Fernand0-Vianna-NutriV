# Adições - NutriV

> Ver também: [[Atualizacao/Historico_Atualizacoes|Historico_Atualizacoes]] | [[Lista_Melhorias]] | [[NutriV_Anotacoes_Gerais]]

## Funcionalidades Adicionadas

### 1. Scanner de Código de Barras
- Implementado `BarcodeScannerBloc`
- Página `BarcodeScanPage` para escaneamento
- Integração com OpenFoodFacts como fallback
- **Status**: Implementado, parcialmente integrado → ver [[Lista_Melhorias]]

### 2. Entrada por Voz
- Widget `VoiceInputWidget` criado
- Não conectado ao fluxo principal
- **Status**: Adicionado, não integrado → ver [[Lista_Melhorias]] e [[Ideias/Ideias_e_Casos_Uso]]

### 3. Controle de Água
- `WaterBloc` para gerenciamento
- Widget `WaterTrackerWidget` na Home
- Persistência via SharedPreferences
- **Status**: Implementado e funcional

### 4. Página de Progresso
- `ProgressPage` criada
- Gráficos com fl_chart
- Histórico de peso
- **Status**: Implementada, dados limitados → ver [[Lista_Melhorias]]

### 5. Tema Escuro
- `AppTheme.darkTheme` configurado
- Mode: system no MaterialApp
- **Status**: Implementado

### 6. Repositório de Sincronização
- `SyncMealRepository` para sync com Supabase
- Manutenção de `MealRepository` legado
- **Status**: Implementado

---

## Dependências Adicionadas

```yaml
flutter_bloc: ^9.1.1
go_router: ^14.8.1
dio: ^5.8.0
shared_preferences: ^2.5.3
sqflite: ^2.4.2
mobile_scanner: ^7.0.1
fl_chart: ^0.71.0
supabase_flutter: ^2.5.0
google_sign_in: ^6.2.2
google_fonts: ^6.2.1
google_fonts: ^6.2.1
image_picker: ^1.1.2
get_it: ^8.0.3
```

---

## Arquivos Criados/Modificados

### Páginas
- `onboarding_page.dart` - Tutorial inicial
- `home_page.dart` - Dashboard principal
- `diary_page.dart` - Diário alimentar
- `scanner_page.dart` - Adicionar alimentos
- `barcode_scan_page.dart` - Scanner código de barras
- `profile_page.dart` - Perfil do usuário
- `progress_page.dart` - Gráficos de progresso

### BLoCs
- `user_bloc.dart` + eventos + estados
- `meal_bloc.dart` + eventos + estados
- `water_bloc.dart` + eventos + estados
- `food_scanner_bloc.dart` + eventos + estados
- `barcode_scanner_bloc.dart` + eventos + estados

### Models
- `user_model.dart`
- `meal_model.dart`
- `food_item_model.dart`
- `daily_log_model.dart`
- `weight_entry_model.dart`

### Services
- `ai_food_service.dart` - Google Gemini + OpenAI
- `usda_food_service.dart` - USDA API
- `auth_service.dart` - Google Sign-In
- `local_data_source.dart` - Armazenamento local

### Repositories
- `user_repository.dart`
- `meal_repository.dart`
- `daily_log_repository.dart`
- `sync_meal_repository.dart`

---

## Conexões com Outros Documentos

| Item | Conectado a |
|------|-------------|
| Scanner Barras | [[Lista_Melhorias#scanner-barcode]] - completar integração |
| VoiceInput | [[Lista_Melhorias#entrada-voz]] - integrar ao fluxo |
| ProgressPage | [[Ideias/Ideias_e_Casos_Uso]] - Caso 2 |
| Supabase sync | [[Estado_Atual#Backend]] |