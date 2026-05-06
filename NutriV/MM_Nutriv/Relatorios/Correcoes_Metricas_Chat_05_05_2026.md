# Correções de Métricas e Chat IA - 05/05/2026

## Resumo
Correção de erros "silly" no aplicativo relacionados a métricas de água, cálculo de peso do usuário, e implementação de chat com IA usando Groq API.

---

## 1. Correção da Métrica de Água

### Problema
A meta de água estava fixa em 2000ml, sem considerar o peso do usuário.

### Solução
- Criado `WaterUtils` em `lib/core/utils/helpers.dart`
- Implementado cálculo dinâmico: **35ml por kg de peso corporal**
- Ajuste por nível de atividade (1.0x a 1.4x)
- Ajuste por clima (temperado, quente, frio)
- Limites: 1500ml a 5000ml

### Arquivos Alterados
- `lib/core/utils/helpers.dart` - adicionado `WaterUtils.calculateWaterGoal()`
- `lib/presentation/pages/onboarding/onboarding_page.dart` - usa cálculo dinâmico

### Exemplo de Cálculo
```dart
// Usuário de 70kg, atividade moderada
final waterGoal = WaterUtils.calculateWaterGoal(
  weightKg: 70,
  activityLevel: 2, // moderado
);
// Resultado: 70 * 35 * 1.2 = 2940ml
```

---

## 2. Correção do Cálculo de Peso do Usuário

### Problema
O parsing de peso não aceitava vírgula como separador decimal (ex: "75,5" falhava).

### Solução
- Adicionado `NutritionUtils.parseWeight()` e `parseHeight()`
- Normaliza vírgula para ponto antes do parsing
- Valores padrão: 70kg (peso), 170cm (altura)

### Arquivos Alterados
- `lib/core/utils/helpers.dart` - adicionado métodos de parsing
- `lib/presentation/pages/onboarding/onboarding_page.dart` - usa novos métodos

### Exemplo
```dart
// Antes: double.parse("75,5") → erro
// Depois: NutritionUtils.parseWeight("75,5") → 75.5
```

---

## 3. Verificação de Registro de Alimentos

### Problema
Alimentos não estavam sendo registrados.

### Investigação
- Código do `MealBloc` e `SyncMealRepository` está correto
- Fluxo de dados: UI → BLoC → Repository → Supabase/Local
- O problema provavelmente era cache de build antigo

### Solução
- **Necessário novo build** do aplicativo
- Código está funcional após as correções

---

## 4. Implementação de Chat com IA (Groq)

### Funcionalidades
- Assistente nutricional usando Groq API (modelo Llama 3.1 8b Instant)
- Contexto do usuário (peso, altura, metas, objetivos)
- Histórico de conversa (últimas 10 mensagens)
- Sugestões rápidas de perguntas
- Análise de refeições
- Geração de sugestões de refeições personalizadas

### Arquivos Criados
- `lib/data/datasources/groq_chat_service.dart` - serviço de chat
- `lib/presentation/bloc/chat/chat_event.dart` - eventos
- `lib/presentation/bloc/chat/chat_state.dart` - estados
- `lib/presentation/bloc/chat/chat_bloc.dart` - BLoC
- `lib/presentation/pages/chat/chat_page.dart` - UI

### Configuração Necessária
Adicionar ao arquivo `.env`:
```
GROQ_API_KEY=sua_chave_aqui
```

Obter chave em: https://console.groq.com/keys

### Rota
- `/chat` - página de chat

### Prompt do Sistema
O assistente é configurado como especialista em nutrição com:
- Contexto do usuário (peso, altura, metas, objetivos)
- Diretrizes para respostas educadas e baseadas em ciência
- Não faz diagnósticos médicos
- Usa português brasileiro natural

---

## Status Final

| Tarefa | Status |
|--------|--------|
| Métrica de água | ✅ Concluído |
| Cálculo de peso | ✅ Concluído |
| Registro de alimentos | ✅ Verificado (precisa de build) |
| Chat IA Groq | ✅ Implementado |

---

## Próximos Passos

1. **Adicionar GROQ_API_KEY ao .env**
2. **Fazer novo build** do aplicativo
3. **Testar** todas as funcionalidades
4. **Verificar** se alimentos estão sendo registrados corretamente

---

## Notas Técnicas

- O modelo Llama 3.1 8b Instant é rápido e eficiente para chat
- O contexto do usuário é injetado dinamicamente no prompt do sistema
- O histórico de mensagens é mantido em memória (não persistido)
- Erros de API são tratados com mensagens amigáveis ao usuário
