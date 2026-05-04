# Checklist de Configuração OAuth - Google Login

## URLs Configuradas no Código

| Plataforma | URL de Callback |
|------------|-----------------|
| Web | `https://nutrivisionh.netlify.app/auth-callback` |
| Mobile | `nutrivision-app://callback` (deep link) |

---

## 1. VERIFICAÇÃO NO SUPABASE

Acesse: https://supabase.com/dashboard/project/lkfefyucixmcrmpvpcazg

### 1.1 URL Configuration (Authentication > URL Configuration)
- [ ] **Site URL**: `https://nutrivisionh.netlify.app`
- [ ] **Redirect URLs**:
  - `https://nutrivisionh.netlify.app/auth-callback`
  - `https://nutrivisionh.netlify.app/**`
  - `nutrivision-app://callback` (para mobile deep link)

### 1.2 Google Provider (Authentication > Providers > Google)
- [ ] **Client ID**: `510166294031-c0sv4lioe9dagtc9nvt023p6ca5s5gc1.apps.googleusercontent.com`
- [ ] **Client Secret**: [preenchido - não vazio]
- [ ] **Status**: ✅ Enabled
- [ ] **Skip nonce checks**: Deixar OFF (mais seguro)
- [ ] **Allow users without an email**: Deixar OFF

### 1.3 Callback URL do Supabase (mostrada no painel)
```
https://lkfefyucixmcrmpvpcazg.supabase.co/auth/v1/callback
```

---

## 2. VERIFICAÇÃO NO GOOGLE CLOUD CONSOLE

Acesse: https://console.cloud.google.com/apis/credentials

### 2.1 Tela de Consentimento OAuth (APIs & Services > OAuth consent screen)
- [ ] **Status**: "In production" (não "Testing")
- [ ] **User type**: External
- [ ] **App name**: NutriV (ou nome do app)
- [ ] **User support email**: [seu-email]@gmail.com
- [ ] **Authorized domains**:
  - `nutrivisionh.netlify.app`
  - `lkfefyucixmcrmpvpcazg.supabase.co`

### 2.2 Credenciais OAuth 2.0 (APIs & Services > Credentials)
Crie/editar cliente **Web application**:

#### Authorized JavaScript origins:
```
https://nutrivisionh.netlify.app
https://lkfefyucixmcrmpvpcazg.supabase.co
http://localhost:3000        (para teste local)
http://localhost:8080        (para teste local)
```

#### Authorized redirect URIs:
```
https://nutrivisionh.netlify.app/auth-callback
http://localhost:3000/auth-callback    (para teste local)
http://localhost:8080/auth-callback    (para teste local)
```

**⚠️ IMPORTANTE PARA MOBILE**: Não adicione a URL do Supabase aqui. O fluxo mobile usa deep link nativo (`nutrivision-app://callback`) que é tratado pelo app diretamente.

---

## 3. VERIFICAÇÃO NO NETLIFY

Acesse: https://app.netlify.com/sites/nutrivisionh

### 3.1 Site Settings
- [ ] **Site name**: nutrivisionh
- [ ] **Domain**: `nutrivisionh.netlify.app`

### 3.2 Environment Variables (Site settings > Environment variables)
Verifique se existem:
- [ ] `SUPABASE_URL`: `https://lkfefyucixmcrmpvpcazg.supabase.co`
- [ ] `SUPABASE_ANON_KEY`: [sua-chave-anon]

### 3.3 Redirects/Rewrites (opcional)
Se necessário, adicione em `_redirects` ou `netlify.toml`:
```toml
[[redirects]]
  from = "/auth-callback"
  to = "/auth-callback"
  status = 200
```

---

## 4. TESTE LOCAL

Para testar localmente, crie um arquivo `.env` na raiz:
```
SUPABASE_URL=https://lkfefyucixmcrmpvpcazg.supabase.co
SUPABASE_ANON_KEY=sua_chave_anon_aqui
```

E execute:
```bash
flutter run -d chrome
```

---

## 5. FLUXO MOBILE (Android/iOS)

O fluxo mobile usa **deep links** nativos:

1. Usuário clica "Login com Google" no app
2. App abre navegador com tela de login Google
3. Após login, Google redireciona para `nutrivision-app://callback`
4. Android/iOS captura o deep link e volta para o app
5. App processa o callback e finaliza autenticação

### 5.1 AndroidManifest.xml (já configurado)
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW"/>
    <category android:name="android.intent.category.DEFAULT"/>
    <category android:name="android.intent.category.BROWSABLE"/>
    <data android:scheme="nutrivision-app"/>
    <data android:host="callback"/>
</intent-filter>
```

### 5.2 Teste o deep link via ADB
```bash
adb shell am start -W -a android.intent.action.VIEW -d "nutrivision-app://callback"
```

## 6. DEBUG DO ERRO 400

Se o erro 400 persistir, verifique no console do navegador (F12 > Network):

1. Procure por requisições à URL do Google OAuth
2. Clique na requisição que retorna 400
3. Verifique a aba **Preview** ou **Response**

Mensagens comuns:
- `invalid_client`: Client ID incorreto no Supabase
- `redirect_uri_mismatch`: URL de callback não autorizada no Google Cloud
- `unauthorized_client`: Aplicativo não está em produção no Google Cloud

## 7. COMANDOS ÚTEIS

```bash
# Limpar cache e reinstalar
cd nutriv
flutter clean
flutter pub get

# Rodar em modo verbose
flutter run -v

# Build release APK
flutter build apk --release
```

---

## Contatos Úteis

- **Supabase Docs**: https://supabase.com/docs/guides/auth/social-login/auth-google
- **Google Cloud Console**: https://console.cloud.google.com
- **Netlify Dashboard**: https://app.netlify.com
