# Ideias - NutriV

> Ver também: [[Lista_Melhorias]] | [[Lista_Adicoes]] | [[NutriV_Anotacoes_Gerais]]

## Funcionalidades Sugeridas

### 1. Sistema de Receitas
- Criar sistema de receitas salvas pelo usuário
- Integrar com API de receitas
- Permitir reutilizar refeições frequentes

### 2. Gamificação
- Sistema de objetivos/daily quests
- Badges por achievements (streak de água, hitting macros)
- Desafios semanais

### 3. Comunidade
- Compartilhar refeições
- Seguir outros usuários
- Feed de inspirações

### 4. Analytics Avançado
- Previsão de peso baseada em tendência
- Análise de padrões alimentares
- Relatórios semanais/mensais detalhados

### 5. Plano Alimentar
- Gerar plano de refeições automático
- Baseado em objetivo (perder/ganhar/manter)
- Sugestões de substituição de alimentos

### 6. Integração com Dispositivos
- Apple Health / Google Fit
- Balanças inteligentes
- Monitores de atividade

### 7. Modo Offline - ver [[Lista_Melhorias]]
- Sync completo offline
- Sincronização posterior quando online

### 8. Chat com Nutri
- Assistant com IA para dúvidas nutricionais
- Sugestões personalizadas de alimentos

---

## Possíveis Casos de Uso

### Caso 1: Usuário quer registrar lunch rapidamente
1. Abre app → [[NutriV_Anotacoes_Gerais#Pages|HomePage]]
2. Clica em "+" ou "Adicionar" → ScannerPage
3. Escaneia código de barras do produto
4. AI identifica produto → FoodItem
5. Usuário ajusta porção
6. Adiciona à refeição "Almoço"

### Caso 2: Usuário quer ver progresso da semana
1. Vai para [[NutriV_Anotacoes_Gerais#Pages|ProfilePage]]
2. Clica em "Ver Progresso" → ProgressPage
3. Visualiza gráficos de calorias, macros, água
4. Seleciona período (semana/mês/ano)

### Caso 3: Usuário esquece de beber água
1. Recebe notificação push
2. Abre app → [[NutriV_Anotacoes_Gerais#Pages|HomePage]]
3. Vê widget de água
4. Clica "+" para registrar 250ml

### Caso 4: Usuário não lembra o que comeu
1. Vai para DiaryPage
2. Seleciona data passado
3. Adiciona refeição manualmente
4. Busca por nome → USDA API

---

## Melhorias Identificadas - ver [[Lista_Melhorias]]

### UI/UX
- Botões de ação rápida na Home não funcionam (Scan, Stats, Receitas)
- Falta loading states em algumas operações
- Melhorar tratamento de erros

### Funcional
- Scanner de código de barras não integrado completamente
- Entrada por voz implementada mas não conectada - ver [[Lista_Adicoes]]
- Histórico de peso não visualizado

### Performance
- Otimizar carregamento de imagens
- Lazy loading em listas longas
- Cache de dados USDA