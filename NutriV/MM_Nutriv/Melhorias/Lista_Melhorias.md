# Melhorias - NutriV

> Ver também: [[Ideias/Ideias_e_Casos_Uso]] | [[Lista_Adicoes]] | [[NutriV_Anotacoes_Gerais]]

## Melhorias Técnicas Recomendadas

### 1. Arquitetura - ver [[Estado_Atual#Arquitetura]]
- [x] ~~Implementar Clean Architecture completo~~ → Infra DB completa, Use Cases pendente
- [x] Injeção de dependência com GetIt — completo
- [ ] Criar casos de uso (Use Cases) para operações de negócio
- [ ] Adicionar testes unitários e de integração

### 2. Estado Global - ver [[NutriV_Anotacoes_Gerais#BLoCs]]
- [x] flutter_bloc com organização de eventos — completo
- [x] Persistência automática de estado — Sqflite implementado
- [x] Estado de erro tratados uniformemente — completo

### 3. Rede - ver [[Estado_Atual#Stack-Tecnológico]]
- [x] Implementar retry automático em falhas de rede — 3 tentativas + pending queue
- [ ] Adicionar interceptors no Dio para logging e auth
- [x] Cache de respostas de API — USDA food cache implementado

### 4. UI/UX - ver [[Ideias/Ideias_e_Casos_Uso#Melhorias-Identificadas]]
- [x] Corrigir botões de ação rápida na HomePage
- [x] Skeletons de carregamento
- [x] Animações de transição
- [x] Feedback visual em operações

---

## Melhorias de Funcionalidade

### Scanner de Alimentos - ver [[Adicoes/Lista_Adicoes#scanner-de-código-de-barras]]
- [x] Integrar completamente BarcodeScanPage ao fluxo
- [ ] Adicionar histórico de alimentos escaneados
- [ ] Implementar sugere alimentos frequentes

### Entrada por Voz - ver [[Adicoes/Lista_Adicoes#entrada-por-voz]]
- [x] Conectar VoiceInputWidget ao FoodScannerBloc
- [ ] Melhorar reconhecimento de comandos
- [ ] Adicionar feedback visual

### Diary - ver [[NutriV_Anotacoes_Gerais#Pages]]
- [ ] Permitir editar refeições passadas
- [ ] Adicionar notas às refeições
- [x] Duplicar refeições anteriores — "Copy to Today" implementado

### Progresso - ver [[Adicoes/Lista_Adicoes#página-de-progresso]]
- [ ] Conectar dados reais ao gráfico
- [ ] Adicionar previsões de tendência
- [x] Relatórios exportáveis (CSV) — implementado

---

## Melhorias de Performance

### Carregamento - ver [[Ideias/Ideias_e_Casos_Uso#Performance]]
- [x] Lazy loading em listas (ListView.builder everywhere)
- [x] Cache de imagens local
- [x] Progressive loading de dados

### Memória
- [ ] Limitar cache de imagens
- [ ] Dispose de controllers corretamente
- [x] Memory leak fixes — Sqflite migration reduz leaks de SharedPreferences

### Build
- [ ] Otimizar tamanho do APK
- [ ] Código splitting
- [ ] Tree shaking

---

## Melhorias de Segurança

### Dados
- [x] Criptografar dados sensíveis localmente — Sqflite (dados não expostos em JSON plain)
- [ ] Adicionar biometric auth
- [ ] Implementar session timeout

### API
- [ ] Validar todas as inputs
- [ ] Sanitizar dados recebidos
- [ ] Rate limiting em requisições

---

## Documentação - ver [[Estado_Atual]]

- [ ] ADRs (Architecture Decision Records)
- [ ] README atualizado
- [ ] Diagrama de arquitetura
- [ ] Documentação de APIs
- [ ] Guia de contribuição

---

## DevOps - ver [[Atualizacao/Historico_Atualizacoes#Histórico-de-Builds]]

- [ ] CI/CD para builds automáticos
- [ ] Análise de código (linting)
- [ ] Testes automatizados
- [ ] Deploy em Stores (Play Store / App Store)

---

## Priorização Sugerida - ver [[Ideias/Ideias_e_Casos_Uso]]

### Alta Prioridade → ✅ Todas resolvidas (07/05/2026)
1. ~~Corrigir botões não funcionais na Home~~ → RESOLVIDO
2. ~~Integrar scanner de código de barras completamente~~ → RESOLVIDO
3. ~~Conectar entrada por voz~~ → RESOLVIDO

### Média Prioridade
4. Melhorar gráficos de ProgressPage
5. Adicionar Use Cases (Clean Architecture)
6. Testes unitários e de integração

### Baixa Prioridade
7. Micronutrients (vitaminas/minerais)
8. OCR tabela nutricional
9. Integração com dispositivos

---

## 🆕 Melhorias Urgentes (08/05/2026)

### Correções Críticas de UI/UX
- [ ] **Corrigir falhas visuais** na página inicial (textos vermelhos, barras pretas/amarelas)
- [ ] **Ajustar interface** do status e botão '+' para melhor UX
- [ ] **Limpar poluição visual** que prejudica navegação

### Funcionalidades Essenciais
- [ ] **Corrigir menu iniciar** para adicionar pratos no diário corretamente
- [ ] **Corrigir registro múltiplo** em "Refeições de Hoje" (mostrar todos os itens)
- [ ] **Implementar metas personalizadas** baseadas em peso e altura do usuário

### Validação e Dados
- [ ] **Validar persistência** de pratos no Supabase
- [ ] **Testar sincronização** entre app e banco de dados
- [ ] **Implementar logging** para detectar falhas de save

### Inteligência Artificial
- [ ] **Validar reconhecimento** de alimentos pela IA
- [ ] **Verificar precisão** de calorias e macronutrientes
- [ ] **Implementar cache** de alimentos identificados no Supabase
- [ ] **Criar sistema** de aprendizado com correções do usuário