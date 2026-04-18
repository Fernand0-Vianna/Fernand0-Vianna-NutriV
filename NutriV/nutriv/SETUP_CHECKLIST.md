# Checklist de Configuração - NutriV Backend

## ✅ Configuração Concluída Automaticamente

### Supabase (Banco de Dados & Auth)
- ✅ **Projeto**: `lkfefyucixmcrmpvcazg` (sa-east-1)
- ✅ **URL**: `https://lkfefyucixmcrmpvcazg.supabase.co`
- ✅ **Google OAuth**: Já configurado e funcionando
- ✅ **Tabelas**: Criadas com RLS habilitado
- ✅ **Trigger**: Cria perfil automaticamente para novos usuários

### Netlify (Deploy)
- ✅ **Site**: `nutrivisionh.netlify.app`
- ✅ **Arquivo `netlify.toml`**: Configurado
- ✅ **SPA Redirects**: Configurados

### Código Flutter
- ✅ **Login Google**: Implementado via `signInWithOAuth`
- ✅ **Login Email**: Funcionando via `AuthService`
- ✅ **Callback OAuth**: Página criada (`/auth/callback`)

---

## ⚠️ Ações Manuais Necessárias

### 1. Configurar Variáveis de Ambiente no Netlify

Acesse: https://app.netlify.com/sites/nutrivisionh/configuration/env

Adicione estas variáveis:

```
SUPABASE_URL = https://lkfefyucixmcrmpvcazg.supabase.co
SUPABASE_ANON_KEY = eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrZmVmeXVjaXhtY3JtcHZjYXpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3ODA1MDYsImV4cCI6MjA5MDM1NjUwNn0.htfiUaWpgvyvj7CfnYwfBh2XNdq382-dRlaLwlhW5TA
```

> **Importante**: Marque `SUPABASE_ANON_KEY` como **"Sensitive"**

### 2. Verificar URL de Redirecionamento no Supabase

Acesse: https://supabase.com/dashboard/project/lkfefyucixmcrmpvcazg/auth/url-configuration

Verifique se estas URLs estão configuradas:
- `https://nutrivisionh.netlify.app/`
- `https://nutrivisionh.netlify.app/auth/callback`

### 3. Criar arquivo `.env` local

```bash
cd /media/nando/TERA/NutriV/NutriV/nutriv
cp .env.example .env
```

O arquivo `.env` já contém as credenciais corretas.

---

## 🚀 Testar o Deploy

### Build Local
```bash
flutter build web --release
```

### Deploy
```bash
# Via git (recomendado)
git add .
git commit -m "Configura Netlify + Supabase Auth"
git push origin main

# Ou via Netlify CLI
netlify deploy --prod --dir=build/web
```

---

## 🔐 Credenciais do Projeto

### Supabase
- **URL**: `https://lkfefyucixmcrmpvcazg.supabase.co`
- **Anon Key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrZmVmeXVjaXhtY3JtcHZjYXpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3ODA1MDYsImV4cCI6MjA5MDM1NjUwNn0.htfiUaWpgvyvj7CfnYwfBh2XNdq382-dRlaLwlhW5TA`

### Netlify
- **Site ID**: `c6608958-15ae-489a-95fc-87f68551d2f2`
- **URL**: `https://nutrivisionh.netlify.app`

---

## 📱 Funcionalidades Implementadas

### Autenticação
1. **Login com Google**: Botão na tela de onboarding → Redireciona para Google → Volta para app
2. **Login com Email**: Formulário de email/senha na tela de onboarding
3. **Perfil Automático**: Quando usuário é criado, perfil é criado automaticamente

### Rotas
- `/onboarding` - Tela inicial com login
- `/auth/callback` - Processa retorno do OAuth
- `/` - Home (após login)

---

## 🐛 Troubleshooting

### "Login Google não funciona"
1. Verifique se `SUPABASE_URL` e `SUPABASE_ANON_KEY` estão no Netlify Dashboard
2. Verifique se as URLs de redirecionamento estão configuradas no Supabase
3. Limpe o cache do navegador

### "App não carrega após deploy"
1. Verifique se o build foi bem-sucedido
2. Verifique os logs no Netlify Dashboard
3. Verifique se `netlify.toml` está na raiz do projeto

### "Supabase não inicializa no Flutter"
1. Verifique se `.env` existe na raiz do projeto
2. Verifique se `pubspec.yaml` inclui `.env` em assets
3. Execute `flutter clean && flutter pub get`

---

## 📚 Documentação Criada

- `NETLIFY_SUPABASE_SETUP.md` - Guia completo de configuração
- `.env.example` - Template de variáveis de ambiente
- `lib/presentation/pages/auth/auth_callback_page.dart` - Página de callback OAuth

---

## Próximos Passos (Opcional)

- [ ] Adicionar recuperação de senha por email
- [ ] Configurar email de confirmação de cadastro
- [ ] Adicionar outros provedores OAuth (Apple, Facebook)
- [ ] Implementar refresh token automático
