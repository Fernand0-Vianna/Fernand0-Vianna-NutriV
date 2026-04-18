# Melhorias - NutriV

> Ver também: [[Ideias/Ideias_e_Casos_Uso]] | [[Lista_Adicoes]] | [[NutriV_Anotacoes_Gerais]]

## Melhorias Técnicas Recomendadas

### 1. Arquitetura - ver [[Estado_Atual#Arquitetura]]
- [ ] Implementar Clean Architecture completo
- [ ] Adicionar injeção de dependência com GetIt (já parcialmente implementado)
- [ ] Criar casos de uso (Use Cases) para operações de negócio
- [ ] Adicionar testes unitários e de integração

### 2. Estado Global - ver [[NutriV_Anotacoes_Gerais#BLoCs]]
- [ ] Migrar para flutter_bloc com melhor organização de eventos
- [ ] ImplementarHydratedBloc para persistência automática de estado
- [ ] Adicionar estado de erro tratadas uniformemente

### 3. Rede - ver [[Estado_Atual#Stack-Tecnológico]]
- [ ] Implementar retry automático em falhas de rede
- [ ] Adicionar interceptors no Dio para logging e auth
- [ ] Criar cache de respostas de API

### 4. UI/UX - ver [[Ideias/Ideias_e_Casos_Uso#Melhorias-Identificadas]]
- [x] ~~Corrigir botões de ação rápida na HomePage~~ → está na lista [[Adicoes/Lista_Adicoes]] como problema
- [ ] Adicionar skeletons de carregamento
- [ ] Implementar animações de transição
- [ ] Melhorar feedback visual em operações

---

## Melhorias de Funcionalidade

### Scanner de Alimentos - ver [[Adicoes/Lista_Adicoes#scanner-de-código-de-barras]]
- [ ] Integrar completamente BarcodeScanPage ao fluxo - ver [[Lista_Adicoes]] Status: parcialmente integrado
- [ ] Adicionar histórico de alimentos escaneados
- [ ] Implementar sugere alimentos frequentes

### Entrada por Voz - ver [[Adicoes/Lista_Adicoes#entrada-por-voz]]
- [ ] Conectar VoiceInputWidget ao FoodScannerBloc - Status: não integrado
- [ ] Melhorar reconhecimento de comandos
- [ ] Adicionar feedback visual

### Diary - ver [[NutriV_Anotacoes_Gerais#Pages]]
- [ ] Permitir editar refeições passadas
- [ ] Adicionar notas às refeições
- [ ] Duplicar refeições anteriores

### Progresso - ver [[Adicoes/Lista_Adicoes#página-de-progresso]]
- [ ] Conectar dados reais ao gráfico - Status: dados limitados
- [ ] Adicionar previsões de tendência
- [ ] Relatórios exportáveis (PDF/CSV)

---

## Melhorias de Performance

### Carregamento - ver [[Ideias/Ideias_e_Casos_Uso#Performance]]
- [ ] Lazy loading em listas (ListView.builder everywhere)
- [ ] Cache de imagens local
- [ ] Progressive loading de dados

### Memória
- [ ] Limitar cache de imagens
- [ ] Dispose de controllers corretamente
- [ ] Memory leak fixes

### Build
- [ ] Otimizar tamanho do APK
- [ ] Código splitting
- [ ] Tree shaking

---

## Melhorias de Segurança

### Dados
- [ ] Criptografar dados sensíveis localmente
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

### Alta Prioridade → items de [[Adicoes/Lista_Adicoes]] com problema
1. Corrigir botões não funcionais na Home - ver [[Ideias/Ideias_e_Casos_Uso#UI/UX]]
2. Integrar scanner de código de barras completamente - ver [[Adicoes/Lista_Adicoes]]
3. Conectar entrada por voz - ver [[Adicoes/Lista_Adicoes]]

### Média Prioridade
4. Melhorar gráficos de progresso - ver [[Adicoes/Lista_Adicoes#página-de-progresso]]
5. Adicionar tratamento de erros uniforme
6. Implementar lazy loading

### Baixa Prioridade
7. Animações e transições
8. Modo offline completo - ver [[Ideias/Ideias_e_Casos_Uso#7-modo-offline]]
9. Integração com dispositivos - ver [[Ideias/Ideias_e_Casos_Uso#6-integração-com-dispositivos]]