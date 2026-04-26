# Bug Report - Sync de Refeições com Supabase

## Data: 25/04/2026

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
- Sync com Supabase é **fire-and-forget** (sem retry)
- Não há fallback: se sync falhar, dados são perdidos

### 2. Falta de Pull ao Iniciar
```dart
// Nenhum código busca dados do Supabase ao iniciar o app
// Só salva localmente e tenta sync, mas se falhar → perda de dados
```

### 3. possiveis Erros Silenciados
- `_ensureFoodExists` pode falhar se tabela `foods` não existir
- `_syncMealToSupabase`try/catch oculta erros com `debugPrint`

---

## Solução Proposta

### Phase 1: Backup Imediato
- [ ] Adicionar função de **export CSV** manual (já existe no código)
- [ ] Adicionar botão "Exportar Refeições" na tela de perfil

### Phase 2: Corrigir Sync
- [ ] Implementar **retry automatique** quando sync falhar
- [ ] Adicionar **fila de sync** para refeições pendentes
- [ ] Usar **Sqflite** вместо SharedPreferences (banco local robusto)

### Phase 3: Adicionar Pull ao Iniciar
- [ ] Ao iniciar app, verificar se há dados locais
- [ ] Se não houver dados locais, **buscar do Supabase**
- [ ] Implementar **merge** de dados (local + servidor)

---

## Arquivos Afetados

| Arquivo | Problema |
|---------|----------|
| `sync_meal_repository.dart` | Sync fire-and-forget |
| `local_data_source.dart` | Não é usado para refeições |

---

## Referências

- Código atual: `nutriv/lib/data/repositories/sync_meal_repository.dart`
- Pendências: `Pendencias_Amanha.md` (Offline Mode)

---

*Reportado: 25/04/2026*