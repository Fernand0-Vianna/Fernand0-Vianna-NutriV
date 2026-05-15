# NutriV - Relatório e Pendências

**Data: 15/05/2026**

---

## 📊 Status Atual do Projeto

### ✅ Funcionalidades Funcionando
- Login por email/senha
- Registro de novos usuários (trigger corrigido 15/05)
- Página inicial com refeições do dia
- Registro manual de alimentos
- Busca por nome de alimentos
- Análise de imagem (combo de APIs)
- Barcode scanner (código de barras)
- Integração com Supabase (database)

### ⚠️ Problemas Conhecidos
- Login Google OAuth removido temporariamente
- Câmera pode ter problemas de permissão no Android

---

## 🔧 Alterações Recentes (15/05/2026)

### 1. Login Google Removido Temporariamente
- Motivo: OAuth estava com problemas e usuário principal usa email/senha
- Arquivos modificados:
  - `lib/presentation/pages/login/login_page.dart`
  - `lib/presentation/pages/onboarding/onboarding_page.dart`
- Como reativar: ver `/MM_Nutriv/Remocoes/Remocao_Google_OAuth_14_05_2026.md`

### 2. Combo de APIs para Análise de Alimentos
- Groq Vision (prioritário para imagem)
- Gemini (fallback para imagem)
- FatSecret (busca por nome)
- USDA (busca por nome)
- AiFoodService (fallback geral)
- Arquivos criados:
  - `lib/data/datasources/gemini_food_service.dart`
  - `lib/data/datasources/fatsecret_service.dart`

### 3. Correção de Registro - RESOLVIDO (15/05/2026)
- Aplicado trigger `handle_new_user()` no Supabase (SECURITY DEFINER) para auto-criar perfil no signup
- Simplificado `_createUserProfile()` no auth_service.dart (upsert único ao invés de insert+upsert)
- Alterado `_updateProfileInSupabase()` de `update()` para `upsert()` (cria se não existir)
- Nome agora passado como user_metadata no signUp
- Arquivos: `auth_service.dart`, `register_page.dart`, `onboarding_page.dart`

### 4. Melhorias no Barcode Scanner
- Adicionado fallback com múltiplas URLs da OpenFoodFacts
- Arquivo: `lib/presentation/bloc/barcode/barcode_scanner_bloc.dart`

---

## 📋 Tarefas para Amanhã (16/05/2026)

### Prioridade Alta
1. [x] Testar criação de novo usuário e verificar se erro 500 foi resolvido
2. [ ] Verificar funcionamento da câmera para scan de alimentos
3. [ ] Testar análise de imagem com as novas APIs (Groq + Gemini)
4. [ ] Testar busca por nome de alimentos

### Prioridade Média
5. [ ] Verificar se meal items estão sendo salvos corretamente no banco
6. [ ] Testar sync de refeições com Supabase
7. [ ] Verificar erros visuais na página inicial (textos em vermelho, overflow)
8. [ ] Testar menu "Iniciar" - verificar se adiciona pratos ao diário

### Prioridade Baixa
9. [ ] Reativar login Google quando o app estiver estável
10. [ ] Implementar fallback para quando API de imagem falhar
11. [ ] Adicionar mais alimentos na base de dados local (offline)
12. [ ] Testar em diferentes tamanhos de tela

---

## 🔍 Problemas a Investigar

### 1. Erro 500 no Registro
- **Status**: ✅ Resolvido (15/05/2026)
- Trigger `handle_new_user()` aplicado no Supabase Dashboard
- Código simplificado para usar `upsert()` em vez de `update()`
- Próximo passo: testar no app instalado com conta nova

### 2. Câmera Não Funciona
- **Sintoma**: Não abre ou não captura imagem
- **Possíveis causas**:
  - Permissão negada no Android
  - Problema no hardware/camera do celular
  - Bug no MobileScanner

### 3. Análise de Imagem Não Funciona
- **Sintoma**: Não retorna alimentos identificados
- **Possíveis causas**:
  - API Groq sem crédito
  - API Gemini com quota esgotada
  - Problema de rede

### 4. Meal Items Não São Salvos
- **Sintoma**: Apenas primeiro item é registrado
- **referência**: Falhas_Apk.md (item 3)

---

## 📁 Arquivos Importantes

| Arquivo | Descrição |
|---------|-----------|
| `DATABASE_SCHEMA_V2.md` | Estrutura do banco de dados |
| `Falhas_Apk.md` | Lista de bugs conhecidos |
| `Correcoes_08_05_2026.md` | Correções já aplicadas |
| `Remocao_Google_OAuth_14_05_2026.md` | Documentação da remoção do Google |

---

## 🔑 Configurações (.env)

> ⚠️ Chaves removidas para segurança. Adicione no arquivo `.env` local.

```
SUPABASE_URL=https://seu-projeto.supabase.co
GROQ_API_KEY=sua_chave_groq
GEMINI_API_KEY=sua_chave_gemini
FATSECRET_API_KEY=sua_chave_fatsecret
```

---

*Relatório criado em: 15/05/2026*