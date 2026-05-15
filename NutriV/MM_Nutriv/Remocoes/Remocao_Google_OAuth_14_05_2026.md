# Remoção Temporária do Login Google OAuth

**Data:** 14/05/2026  
**Motivo:** Simplificar autenticação - usuário principal usa apenas email/senha  

---

## Alterações Realizadas

### 1. login_page.dart
- Botão "Continuar com Google" comentado (linha ~333)

### 2. onboarding_page.dart
- Botão "Continuar com Google" comentário (linha ~190)

---

## Como Reativar

Para reabilitar o login Google, descomentar os trechos marcados com:
```
// Temporariamente desabilitado - login por email apenas
```

### Arquivos a modificar:

1. **lib/presentation/pages/login/login_page.dart**
   - Descomentar linhas 331-335

2. **lib/presentation/pages/onboarding/onboarding_page.dart**
   - Descomentar linhas 187-212

---

## Pré-requisitos para reativar

1. ✅ Configurar OAuth no Google Cloud Console
2. ✅ Configurar deep link `nutrivision-app://callback` no Android
3. ✅ Adicionar SHA-1 do Android ao Firebase/Google Cloud
4. ✅ Verificar variáveis de ambiente (SUPABASE_URL, etc)

---

## Alternativas Futures

Considerar implementar login Apple (iOS) quando necessário.