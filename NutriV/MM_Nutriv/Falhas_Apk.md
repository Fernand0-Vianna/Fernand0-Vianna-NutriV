# Bug Report - Sync de Refeições com Supabase

## Data: 25/04/2026 (Atualizado: 03/05/2026)

---

## Problema

- Usuário limpou o cache do app
- Todas as refeições registradas **sumiram**
- Refeições **não estão sendo salvas** corretamente no Supabase
- Ao iniciar o app após clear cache, não há "pull" dos dados do servidor

---

## Causa Raiz

O `SyncMealRepository` (localizado em `nutriv/lib/data/repositories/sync_meal_repository.dart`) apresenta as seguintes falhas:

### 1. Arquitetura Problemática
- Armazenamento primário em **SharedPreferences** (não é banco de dados)
- Sync com Supabase era **fire-and-forget** (sem retry)
- Não havia fallback: se sync falhar, dados eram perdidos

### 2. Falta de Pull ao Iniciar
```dart
// Nenhum código buscava dados do Supabase ao iniciar o app
// Só salva localmente e tenta sync, mas se falhar → perda de dados
```

### 3. possiveis Erros Silenciados
- `_ensureFoodExists` podia falhar se tabela `foods` não existir
- `_syncMealToSupabase` try/catch ocultava erros com `debugPrint`

---

## ✅ Correções Aplicadas (03/05/2026)

### 1. Retry Automático
- Implementado retry com 3 tentativas no `_syncMealToSupabase()`
- Delay progressivo entre tentativas (500ms, 1000ms, 1500ms)

### 2. Fila de Pendências
- Adicionado `_saveToPendingQueue()` para salvar refeições que falharam no sync
- Chave no SharedPreferences: `pending_sync`
- Método `processPendingSync()` processa itens pendentes ao iniciar

### 3. Pull-from-Supabase
- Adicionado método `_pullFromSupabase()` que baixa refeições do servidor
- Chamado automaticamente quando cache local está vazio (`getAllMeals()`)
- Inclui meal_items e foods relacionados

### 4. Inicialização no Startup
- Adicionado método `init()` no SyncMealRepository
- Chamado em `setupDependencies()` após registrar dependências
- Executa: processPendingSync() + _pullFromSupabase()

### 5. Tratamento de Erros
- Substituído upsert de meal_items por delete + insert (evita duplicatas)
- Erros agora são logados com `_logDebug()` e não silenciados

---

## Arquivos Alterados

| Arquivo | Alteração |
|---------|------------|
| `lib/data/repositories/sync_meal_repository.dart` | Retry, Pull, Pending Queue, Init |
| `lib/core/di/injection.dart` | Chamada ao `init()` do SyncMealRepository |

---

## Resultado Esperado

1. ✅ Refeições não somem mais ao limpar cache (pull do Supabase)
2. ✅ Se sync falhar, refeição vai para fila e sincroniza depois
3. ✅ Retry automático em caso de falha de rede
4. ✅ Logs detalhados para debug

---

## Referências

- Código atual: `nutriv/lib/data/repositories/sync_meal_repository.dart`
- Pendências: `Pendencias_Amanha.md` (Offline Mode)
- Relatório: `Relatorios/Analise_Falhas_Visuais_03_05_2026.md`

---

## 🆕 Novas Falhas Reportadas (08/05/2026)

### 1. Falhas Visuais na Página Inicial
- **Textos em vermelho** aparecem indevidamente na interface
- **Barras pretas e amarelas** na página inicial com status e botão '+'
- Interface poluída visualmente prejudicando UX

### 2. Menu Iniciar Não Funcional
- Menu iniciar **não adiciona de fato** os pratos no diário
- Usuário seleciona prato mas não é registrado no sistema
- Falha na comunicação entre UI e repositório de dados

### 3. Refeições de Hoje - Registro Incompleto
- Na aba início, "Refeições de Hoje" só registra o **primeiro item** informado
- Exemplo: almoço "peixe 100g, batata 200g" → só mostra "peixe"
- Perda de dados nutricionais importantes

### 4. Metas Diárias Desajustadas
- Metas **não se ajustam** com peso e altura dos usuários
- Cálculos fixos sem personalização
- Possível erro nas fórmulas de TMB e necessidades calóricas

### 5. Validação de Dados - Pratos no Banco
- **Validar se pratos adicionados** estão sendo salvos no Supabase
- Possível falha no sync entre app e banco de dados
- Risco de perda de dados dos usuários

### 6. IA - Reconhecimento de Alimentos
- **Validar se IA reconhece alimentos** corretamente
- Verificar se calorias e macronutrientes estão corretos
- Sugerir: registrar alimentos identificados no Supabase para cache

---

*Reportado: 25/04/2026*  
*Atualizado: 08/05/2026 - Novas falhas visuais e funcionais identificadas*