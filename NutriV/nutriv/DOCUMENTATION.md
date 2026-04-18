# NutriV - Documentação

## Firebase - Removido

O Firebase foi **removido** do projeto por não estar em operação no momento.

### Motivo
- Firebase requer configuração ativa no Google Cloud Console
- Sem projeto Firebase configurado, o app apresenta erros na inicialização

### Como restaurar

Se desejar usar o Firebase posteriormente:

1. **Adicionar dependências no pubspec.yaml:**
```yaml
firebase_core: ^3.13.0
cloud_firestore: ^5.6.6
```

2. **Criar projeto Firebase:**
   - Acesse [console.firebase.google.com](https://console.firebase.google.com)
   - Crie um novo projeto
   - Configure o SHA-1 do app

3. **Criar arquivo `android/app/src/main/res/values/strings.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">SEU_CLIENT_ID.apps.googleusercontent.com</string>
    <string name="gcm_defaultSenderId">SEU_PROJECT_NUMBER</string>
</resources>
```

4. **Configurar Google Sign-In:**
   - No Google Cloud Console, habilite Google Sign-In API
   - Adicione o SHA-1 do debug keystore

## Stack atual

- **Autenticação**: Google Sign In (OAuth) + Supabase Auth
- **Banco de dados**: Supabase (PostgreSQL)
- **Armazenamento local**: SharedPreferences

## Supabase

O app usa Supabase para sincronização de dados:
- URL: `https://lkfefyucixmcrmpvcazg.supabase.co`
- Chave ANON configurada no arquivo `.env`

## Netlify Deploy

O projeto está configurado para deploy no Netlify:
- **Site**: http://nutrivisionh.netlify.app
- **Configuração**: `netlify.toml` na raiz do projeto
- **Build**: `flutter build web --release`
- **Publish directory**: `build/web`

### Deploy manual
```bash
flutter build web --release
# Ou use o Netlify CLI: netlify deploy --prod
```