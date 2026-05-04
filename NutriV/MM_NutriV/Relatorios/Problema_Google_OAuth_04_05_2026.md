# Relatório - Problema Login Google OAuth

**Data:** 04/05/2026  
**Projeto:** NutriV  
**Status:** ❌ Não resolvido

---

## Problema

O login com Google OAuth não está funcionando no aplicativo mobile (Android). O app não retorna do fluxo de autenticação OAuth via deep link.

---

## Diagnóstico Realizado

### 1. Código verificado
- `auth_service.dart` - Configuração do OAuth
- `AndroidManifest.xml` - Deep links configurados
- `.env` - Credenciais do Supabase

### 2. Correções aplicadas
- Adicionado intent-filter para `nutrivision-app://callback` no AndroidManifest.xml
- Corrigido `pathPrefix` para `host` no intent-filter
- Alterado `LaunchMode.externalApplication` para `LaunchMode.platformDefault`

### 3. Configuração verificada (conforme Relatorio_OAuth_03_05_2026.md)
- Supabase URL: `https://lkfefyucixmcrmpvcazg.supabase.co`
- Supabase ANON KEY: ✅ Configurada
- Google OAuth Provider: ✅ Habilitado no Supabase
- Deep link: `nutrivision-app://callback` configurado

---

## Sintomas

1. Usuário clica em "Entrar com Google"
2. O log mostra: `✅ signInWithOAuth chamado com sucesso`
3. O app abre o navegador externo para autenticação Google
4. **Após autenticação bem-sucedida, o app NÃO retorna ao aplicativo**
5. O deep link `nutrivision-app://callback` não é acionado

---

## Funcionando

- ✅ Login com email/senha funcionando
- ✅ Supabase conectando corretamente
- ✅ Sync de refeições (pull do Supabase)

---

## Possíveis Causas

1. **URL de callback não registrada no Supabase** - A URL `nutrivision-app://callback` precisa estar nas "Redirect URLs" do Supabase
2. **Google Cloud Console** - Pode estar faltando a URL de callback nas configurações do OAuth
3. **Android App Links** - O sistema de deep links do Android pode não estar reconhecendo o scheme

---

## Próximos Passos Recomendados

1. Acessar painel do Supabase → Authentication → Providers → Google
2. Verificar se `nutrivision-app://callback` está nas Redirect URLs
3. No Google Cloud Console, verificar Authorized redirect URIs
4. Testar com URL HTTPS temporária para debug
5. Considerar usar Firebase Auth como alternativa

---

*Relatório criado em: 04/05/2026*  
*Investigação: opencode + contexto do projeto MM_NutriV*