# Correção do Erro 500 no Registro de Usuários - NutriV

**Data:** 15/05/2026  
**Status:** ✅ Resolvido

---

## Problema

Ao tentar registrar um novo usuário, o app retornava:
```
AuthRetryableFetchException(message: {"code":"unexpected_failure","message":"Database error saving new user"}, statusCode: 500)
```

O erro acontecia **dentro do Supabase Auth**, antes do código Dart rodar.

---

## Diagnóstico

### Causa Raiz
Existiam **DOIS triggers conflitantes** na tabela `auth.users`:
1. `on_auth_user_created_clientes` — trigger quebrado que causava o erro 500
2. `on_auth_user_created` — nosso trigger (também quebrado por conflito)

### Evidências
- Criar usuário pelo **Supabase Dashboard → Authentication → Add user** também falhava com o mesmo erro
- `SELECT tgname FROM pg_trigger WHERE tgrelid = 'auth.users'::regclass` retornava ambos os triggers
- Após remover os triggers, o signup funcionou normalmente

### Fatores Secundários
- Tabela `profiles` sem política de INSERT
- Rate limit de emails configurado em 2/hora (muito baixo)
- "Confirm email" ativado enviando emails desnecessários

---

## Solução Aplicada

### 1. SQL - Limpeza de Triggers
```sql
-- Remover TODOS os triggers do auth.users
DROP TRIGGER IF EXISTS on_auth_user_created_clientes ON auth.users;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- Remover funções associadas
DROP FUNCTION IF EXISTS public.handle_new_user();
DROP FUNCTION IF EXISTS public.handle_new_user_clientes();

-- Recriar trigger limpo com ON CONFLICT DO NOTHING
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_profiles (id, name, email, created_at)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', split_part(NEW.email, '@', 1)),
    NEW.email,
    now()
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();
```

### 2. SQL - Políticas de INSERT
```sql
-- Adicionar INSERT policy na tabela profiles (estava faltando)
DROP POLICY IF EXISTS "Enable insert for profiles" ON profiles;
CREATE POLICY "Enable insert for profiles" ON profiles FOR INSERT WITH CHECK (true);

-- Adicionar INSERT policy na tabela user_profiles
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON user_profiles;
CREATE POLICY "Enable insert for authenticated users" ON user_profiles FOR INSERT WITH CHECK (true);
```

### 3. Supabase Dashboard
- **Authentication → Providers → Email:** Desabilitar "Confirm email"
- **Authentication → Settings → Rate Limits:** Aumentar rate limit de emails se necessário

### 4. Código Dart - auth_service.dart
- `signUpWithEmail()` agora aceita parâmetro opcional `name`
- Passa `name` como `user_metadata` no `signUp()`
- `_createUserProfile()` simplificado para usar `upsert()` único (sem insert+upsert duplicado)

### 5. Código Dart - register_page.dart
- Passa `name: _nameController.text.trim()` pro `signUpWithEmail()`
- `_updateProfileInSupabase()` mudou de `update()` para `upsert()` com `onConflict: 'id'`

### 6. Código Dart - onboarding_page.dart
- Passa `name` pro `signUpWithEmail()`
- Adicionado método `_updateProfileInSupabase()` (copiado do register_page)
- Chamada de `_updateProfileInSupabase()` após `SaveUser` no fluxo de signup
- `_saveProfile()` corrigido: removeu fallback de ID fake, agora exige `currentUser != null`

---

## Arquivos Modificados

| Arquivo | Alteração |
|---------|-----------|
| `lib/data/datasources/auth_service.dart` | Simplificado `_createUserProfile`, adicionado parâmetro `name` |
| `lib/presentation/pages/login/register_page.dart` | Passa `name`, usa `upsert()` no perfil |
| `lib/presentation/pages/onboarding/onboarding_page.dart` | Adicionado `_updateProfileInSupabase`, corrigido `_saveProfile` |

---

## Testes Realizados

1. ✅ Registro com email real (`sfernandovianna@proton.me`) — SUCESSO
2. ✅ Perfil criado automaticamente no `user_profiles` via trigger
3. ✅ Dados do formulário (peso, altura, metas) salvos via `upsert()`
4. ✅ Login com usuário recém-criado — SUCESSO

---

## Lições Aprendidas

1. **Sempre verificar triggers existentes** no `auth.users` antes de criar novos
2. **Usar `ON CONFLICT DO NOTHING`** em triggers que inserem perfis
3. **Remover triggers antigos** antes de aplicar novos
4. **Rate limits do Supabase** podem bloquear testes com emails de teste
5. **"Confirm email"** deve ser desabilitado para desenvolvimento/testes

---

*Relatório criado em: 15/05/2026*
