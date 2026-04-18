# Configuração Netlify + Supabase para NutriV

## Resumo da Configuração

Seu projeto já está pré-configurado para funcionar com:
- ✅ **Netlify**: Site `nutrivisionh.netlify.app` pronto
- ✅ **Supabase**: Projeto ativo com autenticação
- ✅ **Google OAuth**: Já funcionando (usuários já autenticados)
- ✅ **Email/Password**: Login tradicional funcionando

---

## 1. Configuração do Supabase (Já Feita)

### Credenciais do Projeto
```
SUPABASE_URL=https://lkfefyucixmcrmpvcazg.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrZmVmeXVjaXhtY3JtcHZjYXpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3ODA1MDYsImV4cCI6MjA5MDM1NjUwNn0.htfiUaWpgvyvj7CfnYwfBh2XNdq382-dRlaLwlhW5TA
```

### Google OAuth Configurado
- URL de redirecionamento: `https://nutrivisionh.netlify.app/`
- Provedor: Google (via Supabase Auth)

---

## 2. Configuração do Netlify (Pendente)

### 2.1 Acesse o Dashboard do Netlify
1. Acesse: https://app.netlify.com/sites/nutrivisionh
2. Clique em **"Site configuration"** → **"Environment variables"**

### 2.2 Adicione as Variáveis de Ambiente

Clique em **"Add variable"** e adicione:

| Nome | Valor |
|------|-------|
| `SUPABASE_URL` | `https://lkfefyucixmcrmpvcazg.supabase.co` |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxrZmVmeXVjaXhtY3JtcHZjYXpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3ODA1MDYsImV4cCI6MjA5MDM1NjUwNn0.htfiUaWpgvyvj7CfnYwfBh2XNdq382-dRlaLwlhW5TA` |

**Importante**: Marque `SUPABASE_ANON_KEY` como **"Sensitive value"** (valor sensível).

### 2.3 Configuração de Deploy

O arquivo `netlify.toml` já está configurado com:
```toml
[build]
  publish = "build/web"
  command = "flutter build web --release"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

---

## 3. Configuração Local (Desenvolvimento)

### 3.1 Crie o arquivo `.env`
```bash
cp .env.example .env
```

O arquivo `.env` já está configurado com as credenciais corretas.

---

## 4. Funcionalidades de Autenticação

### Login com Email/Senha
- Cadastro de novos usuários
- Login de usuários existentes
- Recuperação de senha (implementar futuramente)

### Login com Google
- Botão "Continuar com Google" na tela inicial
- Redirecionamento automático para OAuth
- Retorna para o app após autenticação

---

## 5. Testar a Configuração

### Build Local
```bash
flutter build web --release
```

### Deploy no Netlify
```bash
# Deploy via CLI (opcional)
netlify deploy --prod --dir=build/web

# Ou faça push para o GitHub (deploy automático)
git add .
git commit -m "Configura Netlify + Supabase"
git push origin main
```

---

## 6. Troubleshooting

### Problema: "Login Google não funciona"
**Solução**: Verifique se o URL `https://nutrivisionh.netlify.app/` está configurado no Supabase:
1. Acesse: https://supabase.com/dashboard/project/lkfefyucixmcrmpvcazg
2. Vá em **Authentication** → **URL Configuration**
3. Adicione: `https://nutrivisionh.netlify.app/`

### Problema: "Supabase não inicializa"
**Solução**: Verifique se as variáveis de ambiente estão configuradas no Netlify Dashboard.

---

## Checklist Final

- [ ] Variáveis de ambiente adicionadas no Netlify Dashboard
- [ ] URL do site configurada no Supabase Auth
- [ ] Teste de login com email/senha
- [ ] Teste de login com Google
- [ ] Deploy realizado com sucesso
