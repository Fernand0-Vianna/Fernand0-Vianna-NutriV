# NutriV - Mapa Mental do Projeto

> **Índice Completo**: [[Indice]] | **Mapa Visual**: [[NutriV_Mapa_Mental.canvas]]

> **Índice de Documentos:**
> - [[Estado_Atual]] - Visão geral técnica e arquitetura
> - [[Atualizacao/Historico_Atualizacoes]] - Cronologia de atualizações
> - [[Lista_Adicoes]] - Funcionalidades adicionadas
> - [[Lista_Remocoes]] - Funcionalidades removidas
> - [[Lista_Melhorias]] - Lista de melhorias priorizadas
> - [[Ideias/Ideias_e_Casos_Uso]] - Ideias e casos de uso

---

## Legenda
- 🔵 Azuis = Estrutura Técnica
- 🟢 Verdes = Funcionalidades
- 🟡 Amarelos = Problemas
- 🔴 Vermelhos = Pendências

---

## Visão Geral

**NutriV** é um aplicativo Flutter de controle alimentar com IA, utilizando:
- **Estado**: flutter_bloc - ver [[Estado_Atual#Decisões-Técnicas]]
- **Navegação**: go_router
- **Backend**: Supabase - ver [[Estado_Atual#Backend]]
- **IA**: Google Gemini + OpenAI - ver [[Estado_Atual#Stack-Tecnológico]]

---

## Cronologia de Desenvolvimento

### Início
- Flutter projeto base
- BLoC pattern

### Integrações
- Firebase (implementado → removido) - ver [[Lista_Remocoes]]
- Supabase
- Google Sign-In

### Funcionalidades
- Scanner IA - ver [[Lista_Adicoes#scanner-de-código-de-barras]]
- Código barras - ver [[Lista_Adicoes#entrada-por-voz]]
- Controle água - ver [[Lista_Adicoes#controle-de-água]]
- Diary - ver [[Ideias/Ideias_e_Casos_Uso#Caso-4]]
- Profile/Progress - ver [[Ideias/Ideias_e_Casos_Uso#Caso-2]]

---

## Estrutura

```
lib/
├── core/        (constants, DI, theme, utils) - ver [[Estado_Atual#Estrutura-de-Pastas]]
├── data/        (datasources, models, repositories)
├── domain/      (entities)
└── presentation/(blocs, pages, widgets)
```

---

## Páginas - ver [[Estado_Atual#Decisões-Técnicas]]

1. **Home** - Dashboard com macros + água - ver [[Ideias/Ideias_e_Casos_Uso#Caso-3]]
2. **Diary** - Registro diário de refeições
3. **Scanner** - Adicionar alimentos (foto/código/busca)
4. **Profile** - Perfil + configurações
5. **Progress** - Gráficos de progresso

---

## BLoCs - ver [[Estado_Atual#Decisões-Técnicas]]

| BLoC | Função | Ver |
|------|--------|-----|
| UserBloc | Dados do usuário e perfil | [[Lista_Adicoes#bocs]] |
| MealBloc | Refeições e diário | [[Lista_Adicoes#bocs]] |
| WaterBloc | Controle de hidratação | [[Lista_Adicoes#controle-de-água]] |
| FoodScannerBloc | Scanner de alimentos IA | [[Lista_Adicoes#scanner-de-código-de-barras]] |
| BarcodeScannerBloc | Scanner código barras | [[Lista_Adicoes#scanner-de-código-de-barras]] |

---

## APIs - ver [[Estado_Atual#Stack-Tecnológico]]

- **Google Gemini 2.0 Flash** - Análise de imagens (primário)
- **OpenAI GPT-4o-mini** - Fallback IA
- **USDA FoodData Central** - Banco de alimentos
- **OpenFoodFacts** - Código barras + fallback

---

## Problemas Atuais - ver [[Ideias/Ideias_e_Casos_Uso#Melhorias-Identificadas]] e [[Lista_Melhorias]]

⚠️ Botões "Scan", "Stats", "Receitas" na Home não funcionam - ver [[Lista_Melhorias#alta-prioridade]]
⚠️ VoiceInputWidget criado mas não integrado - ver [[Lista_Adicoes#entrada-por-voz]] e [[Lista_Melhorias#alta-prioridade]]
⚠️ BarcodeScanPage parcialmente conectado - ver [[Lista_Melhorias#scanner-de-alimentos]] e [[Lista_Adicoes#scanner-de-código-de-barras]]

---

## Próximos Passos - ver [[Lista_Melhorias#priorização-sugerida]]

### Alta Prioridade
1. Corrigir ação dos botões rápidos na Home
2. Completar integração do scanner de código de barras
3. Conectar entrada por voz

### Média Prioridade  
4. Melhorar gráficos de ProgressPage - ver [[Lista_Adicoes#página-de-progresso]]
5. Adicionar tratamento de erros uniforme
6. Implementar lazy loading

### Baixa Prioridade
7. Animações e transições
8. Modo offline completo - ver [[Ideias/Ideias_e_Casos_Uso#7-modo-offline]]
9. Gamificação - ver [[Ideias/Ideias_e_Casos_Uso#2-gamificação]]
10. Integração Apple Health/Google Fit - ver [[Ideias/Ideias_e_Casos_Uso#6-integração-com-dispositivos]]