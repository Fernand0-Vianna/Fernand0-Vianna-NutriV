# Relatório - Diagnóstico de APIs e Correções

**Data:** 20/05/2026
**Projeto:** NutriV
**Status:** 🔧 Parcialmente resolvido

---

## 🔍 Diagnóstico das APIs (testado via curl)

| API | Status | Motivo |
|-----|--------|--------|
| Gemini (gemini-2.5-flash) | ✅ OK | 200, respondeu com JSON array |
| Groq Llama 4 Scout | ✅ OK | 200, respondeu com JSON array |
| Groq llama-3.2-90b-vision-preview | ❌ Descontinuado | Modelo removido pela Groq |
| OpenAI (gpt-4o-mini) | ❌ 429 | Sem créditos na chave |
| FoodAPI (devco.solutions) | ❌ 429 | Cota mensal excedida |
| USDA (DEMO_KEY) | ❌ Timeout | `DEMO_KEY` muito lenta / rate-limited |
| LogMeal | ❌ Sem chave | `LOGMEAL_API_KEY` ausente do `.env` |

---

## 🐛 Bugs Críticos Encontrados e Corrigidos

### 1. AuthInterceptor sobrescrevia Authorization de APIs externas

| Campo | Detalhe |
|-------|---------|
| **Arquivo** | `lib/core/interceptors/dio_interceptors.dart:36-39` |
| **Problema** | O interceptor `AuthInterceptor` adicionava `Authorization: Bearer <token_supabase>` em **TODAS** as requisições HTTP, sobrescrevendo as chaves de API de serviços externos (Groq, OpenAI, FoodAPI, LogMeal). |
| **Impacto** | Qualquer API que usa header `Authorization` para autenticação falhava com 401. Apenas Gemini funcionava porque usa `?key=` na URL. |
| **Correção** | Adicionado `if (uri.contains('supabase.co'))` para só injetar token em chamadas ao Supabase. |
| **Commit** | `lib/core/interceptors/dio_interceptors.dart` |

### 2. Modelo Groq descontinuado

| Campo | Detalhe |
|-------|---------|
| **Arquivo** | `lib/data/datasources/groq_vision_service.dart:14-15` |
| **Problema** | `llama-3.2-90b-vision-preview` e `llama-3.2-11b-vision-preview` foram descontinuados pela Groq. Retornavam HTTP 400. |
| **Correção** | Substituído por `meta-llama/llama-4-scout-17b-16e-instruct` (funciona perfeitamente com visão). |
| **Commit** | `lib/data/datasources/groq_vision_service.dart` |

### 3. response_format: json_object no Groq

| Campo | Detalhe |
|-------|---------|
| **Arquivo** | `lib/data/datasources/groq_vision_service.dart:70,148` |
| **Problema** | O parâmetro `response_format: {"type": "json_object"}` força a API a retornar um objeto `{...}` em vez de array `[...]`. O prompt pedia array, mas o format forcing fazia o modelo retornar `{"foods": [...]}`, que o parser `_extractJsonFromText` conseguia extrair... porém em alguns casos o modelo retornava objeto único `{...}` quebrava a interpretação. |
| **Correção** | Removido `response_format` das duas chamadas (principal e fallback). Groq agora retorna array JSON puro diretamente. |
| **Commit** | `lib/data/datasources/groq_vision_service.dart` |

---

## ✅ Status Final da Cadeia de Análise

```
1. GeminiFoodService     → ✅ Funciona (key na URL, não afetada pelo AuthInterceptor)
2. GroqVisionService     → ✅ Agora funciona (modelo atualizado + response_format removido)
3. AiFoodService         → ⚠️ Parcial (Gemini funciona, OpenAI sem crédito, FoodAPI sem cota)
4. Fallback Local DB     → ✅ Sempre funciona (30 alimentos hardcoded)
```

### Fluxo completo após correções

```
Usuário tira foto
  → GeminiFoodService.analyzeFoodImage()  →  ✅ Deve retornar alimentos
  → USDA validation (DEMO_KEY lento, pode falhar silenciosamente)
  → Se falhar: GroqVisionService          →  ✅ Agora funciona (Llama 4 Scout)
  → Se falhar: AiFoodService              →  ⚠️ Gemini (OK), OpenAI (429), FoodAPI (429)
  → Fallback: Local DB                    →  ✅ Sempre retorna algo
```

---

## 📋 Pendências para Amanhã (21/05/2026)

### Prioridade Alta
1. [ ] **Criar chave USDA gratuita** em https://fdc.nal.usda.gov/api-guide.html e substituir `DEMO_KEY`
2. [ ] **Verificar se Gemini API tem cota ativa** no Google Cloud Console (console.cloud.google.com)
3. [ ] **Testar análise de imagem** no app físico com as correções aplicadas

### Prioridade Média
4. [ ] **Adicionar `LOGMEAL_API_KEY`** no `.env` se houver chave disponível (API especializada em food recognition)
5. [ ] **Testar registro de refeição** (meal + meal_items) no Supabase após análise
6. [ ] **Verificar logs do app** no device para confirmar que as APIs estão sendo chamadas corretamente
7. [ ] **Substituir `DEMO_KEY`** do USDA por chave real registrada

### Prioridade Baixa
8. [ ] **Criar conta OpenAI com créditos** para usar GPT-4o-mini como fallback
9. [ ] **Expandir base local** de alimentos (30 alimentos é muito pouco para fallback)
10. [ ] **Adicionar timeout handling** mais robusto para APIs lentas

---

## 🔑 Chaves no `.env` (status atual)

| Chave | Status | Observação |
|-------|--------|------------|
| `SUPABASE_URL` | ✅ OK | |
| `SUPABASE_ANON_KEY` | ✅ OK | |
| `GROQ_API_KEY` | ✅ OK | Funcionando com Llama 4 Scout |
| `GEMINI_API_KEY` | ⚠️ Não verificado no app | Funciona via curl, confirmar cota |
| `OPENAI_API_KEY` | ❌ Sem créditos | 429 Too Many Requests |
| `FOODAPI_KEY` | ❌ Cota excedida | 429 Monthly limit |
| `FATSECRET_API_KEY` | ❌ Não testado | Pode ter OAuth issues |
| `USDA_API_KEY` | ❌ DEMO_KEY instável | Timeout consistente |
| `LOGMEAL_API_KEY` | ❌ Ausente | Não está no `.env` |

---

## 📁 Arquivos Modificados

| Arquivo | Alteração |
|---------|-----------|
| `lib/core/interceptors/dio_interceptors.dart` | AuthInterceptor só adiciona token em URLs do Supabase |
| `lib/data/datasources/groq_vision_service.dart` | Modelo atualizado + `response_format` removido |
| `lib/presentation/pages/login/login_page.dart` | Limpeza de código morto (11 erros do analyzer resolvidos) |

---

*Relatório criado em: 20/05/2026*
