# Atualizações - NutriV

> Parte do [[NutriV_Anotacoes_Gerais]] | Ver também: [[Estado_Atual]] | [[Lista_Adicoes]] | [[Lista_Remocoes]]

## Atualizações Realizadas (Cronologia)

### 1. Migração de Backend
- **Firebase removido completamente** do projeto - ver [[Lista_Remocoes]]
- Motivo: Requer configuração ativa no Google Cloud Console, sem projeto configurado
- Alternativa: Supabase como backend principal
- Documentação de restauração disponível em `documentação/Supabase_Configuracao.md`

### 2. Estrutura de Estado
- Adição de múltiplos BLoCs - ver [[Lista_Adicoes]]:
  - `UserBloc`: Gerencia dados do usuário e perfil
  - `MealBloc`: Gerencia refeições e diário alimentar
  - `FoodScannerBloc`: Controla scanner de alimentos por IA
  - `WaterBloc`: Controle de hidratação
  - `BarcodeScannerBloc`: Scanner de código de barras

### 3. Integração de APIs
- USDA FoodData Central
- OpenFoodFacts (fallback)
- Google Gemini + OpenAI para análise de imagens

### 4. UI/UX
- Tema Material 3
- Navegação ShellRoute com bottom navigation
- Páginas: Home, Diary, Scanner, Profile, Progress - ver [[Estado_Atual]]

---

## Histórico de Builds

| Versão | Data | Notas |
|--------|------|-------|
| 0.0.3 | - | Build com correções |
| 0.0.2 | - | Correções iniciais |
| 0.0.1 | - | Versão inicial |