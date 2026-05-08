# Relatório - Validação OAuth Google Cloud vs Supabase

**Data:** 07/05/2026  
**Projeto:** NutriV  
**Status:** ⚠️ Em análise

---

## Informações Fornecidas

### Google Cloud Console
- **Client ID:** `[CLIENT_ID_REMOVIDO]`
- **Client Secret:** `[CLIENT_SECRET_REMOVIDO]`
- **Chaves Secretas Visíveis:** 
  - `****tggu` (criada em 03/05/2026 22:07:22)
  - `****70AA` (criada em 03/05/2026 22:54:33)

### Supabase (do relatório anterior)
- **Supabase URL:** `https://lkfefyucixmcrmpvcazg.supabase.co`
- **Google OAuth Provider:** ✅ Habilitado
- **Deep Link Configurado:** `nutrivision-app://callback`

---

## Análise das Inconsistências

### ❌ Problema Identificado: Client Secret

A chave secreta fornecida (`[CLIENT_SECRET_REMOVIDO]`) **NÃO CORRESPONDE** a nenhuma das chaves secretas visíveis no Google Cloud Console:

- Chave 1 termina em: `****tggu`
- Chave 2 termina em: `****70AA`
- Chave fornecida termina em: `[CLIENT_SECRET_REMOVIDO]`

**Possíveis explicações:**
1. A chave fornecida é de outro projeto/cliente OAuth
2. A chave foi excluída e não aparece mais no console
3. A chave fornecida está incorreta ou desatualizada

---

## Validações Necessárias

### 1. No Supabase
Verificar se as seguintes configurações estão corretas:

**Authentication → Providers → Google:**
- [ ] **Google Client ID:** `[CLIENT_ID_REMOVIDO]`
- [ ] **Google Client Secret:** `[CLIENT_SECRET_REMOVIDO]`
- [ ] **Redirect URLs:**
  - [ ] `nutrivision-app://callback`
  - [ ] `https://nutrivisionh.netlify.app/auth-callback` (web)

### 2. No Google Cloud Console
Verificar as **Authorized Redirect URIs** para o client ID:

**APIs & Services → Credentials → OAuth 2.0 Client IDs:**
- [ ] `nutrivision-app://callback`
- [ ] `https://nutrivisionh.netlify.app/auth-callback`
- [ ] `https://<supabase-id>.supabase.co/auth/v1/callback`

---

## Ações Recomendadas

### Opção 1: Corrigir Client Secret (Recomendado)
1. **Gerar nova Client Secret** no Google Cloud Console:
   - Ir em APIs & Services → Credentials
   - Selecionar o client ID existente
   - Clicar em "Download JSON" ou "Add Secret"
   - Baixar nova secret

2. **Atualizar Supabase** com a nova Client Secret

3. **Testar login OAuth** novamente

### Opção 2: Verificar Configuração Atual
1. Confirmar no Supabase qual Client Secret está configurada
2. Se for diferente das chaves visíveis no Google Cloud, atualizar
3. Verificar se as Redirect URLs correspondem

### Opção 3: Debug com HTTPS
1. Configurar temporariamente uma URL HTTPS como callback
2. Testar para isolar o problema (deep link vs configuração OAuth)

---

## Próximos Passos

1. **Verificar Redirect URLs no Supabase**
2. **Verificar Authorized Redirect URIs no Google Cloud**
3. **Decidir sobre gerar nova Client Secret**
4. **Documentar configuração final**
5. **Testar login OAuth após correções**

---

*Relatório criado em: 07/05/2026*  
*Análise baseada em imagens do Google Cloud Console*  
*Status: Aguardando validação das configurações*
