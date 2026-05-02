# 📖 NutriV Documentation Map - All Files Linked

> Atualizado em: 02 de Maio de 2026
> Commit: 2dee6c8 (fix: correções críticas QA)

---

## 🗺️ Visual Map

```
                   📚 NutriV_Anotacoes_Gerais
                            |
           +-------------+-------------+-------------+
           |             |             |             |
    📁 Atualizacao   📋 Lista_Adicoes  📝 Lista_Remocoes
           |             |             |
           +------+------+------+------+
                  |             |
           📈 Estado_Atual (arquitetura)
           /   |   \    \     \
          /    |    \    \     \
    📊 Analise_FitCal  🐛 Falhas_Apk  📅 Pendencias_Amanha
          \         |          /
           \        |         /
         📋 Lista_Melhorias
           /    \
          /      \
    💡 Ideias/Ideias_e_Casos_Uso
          |
     🎨 NutriV_Mapa_Mental.canvas

---

## 📂 Reports Folder (Relatorios/) - QA Chain

### Sequence:
1. **[[Relatorios/Relatorio_QA_Completo]]** (Primeira análise)
   ↓ Correções aplicadas
2. **[[Relatorios/Relatorio_QA_Completo_Revisao_Final]]** (Segunda análise pós-correções)
   ↓ Nova sessão de QA
3. **[[Relatorios/Sessao_QA_Correcoes_Criticas_02_05_2026]]** (Sessão completa)
   ↓ Log detalhado
4. **[[Relatorios/Correcoes_QA_02_05_2026]]** (Log de mudanças)
   ↓ Resumo executivo
5. **[[Relatorios/QA_Session_Summary_02_05_2026]]** (Resumo da sessão)

### Connection to Code:
- Git Log → [[Relatorios/Correcoes_QA_02_05_2026]]
- Commit 2dee6c8 → [[Relatorios/QA_Session_Summary_02_05_2026]]
- GitHub Push → `main` branch atualizada

---

## 🔗 Interconnections (How Files Link Together)

### Core Docs (Central Hubs)
| Document | Links To | Linked From |
|-----------|----------|-------------|
| **NutriV_Anotacoes_Gerais** | All docs | - |
| **Estado_Atual** | Falhas_Apk, Pendencias_Amanha, Analise_FitCal | Anotacoes, Atualizacao |
| **Indice.md** | All docs (master index) | - |

### Problem Tracking Chain
1. **Falhas_Apk** (Sync Bug Report)
   → Links to: `Pendencias_Amanha`, `sync_meal_repository.dart`
   → Fixed by: Auth corrections in Commit 2dee6c8

2. **Pendencias_Amanha** (Next Session Tasks)
   → Links to: `Falhas_Apk`, `Analise_FitCal`
   → Status: Most critical tasks completed ✅

3. **Lista_Melhorias** (Improvement Priority List)
   → Links to: `Ideias`, `Adicoes`, `Estado_Atual`
   → Status: High-priority items fixed ✅

### Feature Documentation Chain
1. **Lista_Adicoes** (Added Features)
   → Links to: `Melhorias`, `Ideias`
   → Referenced by: `Estado_Atual`, `Indice`

2. **Ideias/Ideias_e_Casos_Uso** (Ideas & Use Cases)
   → Links to: `Melhorias`, `Adicoes`
   → Referenced by: `Estado_Atual`, `Indice`

3. **Lista_Remocoes** (Removed Features)
   → Links to: `Atualizacao`
   → Referenced by: `Estado_Atual`

### QA Report Chain (Timeline)
```
Analise_FitCal → Identified gaps vs FitCal
       ↓
Relatorio_QA_Completo → First QA pass (18 issues)
       ↓
Correcoes applied → (Commit: ae79032, d29eedb, etc)
       ↓
Relatorio_QA_Completo_Revisao_Final → Second pass (verified fixes)
       ↓
Sessao_QA_Correcoes_Criticas → Full QA session
       ↓
Correcoes_QA_02_05_2026 → Detailed change log
       ↓
Commit 2dee6c8 → Pushed to GitHub
```

---

## 📝 File-by-File Breakdown

### 📁 Atualizacao/Historico_Atualizacoes
- **Purpose:** Chronological update history
- **Links:** Remoções, Adições
- **Status:** Updated with recent commits

### 📋 Lista_Adicoes
- **Purpose:** Features added to NutriV
- **Links:** Melhorias, Ideias
- **Key Content:** QuickActions, VoiceInput, BarcodeScanner, WaterTracker

### 📝 Lista_Remocoes
- **Purpose:** Features removed from NutriV
- **Links:** Atualizacao
- **Key Content:** Firebase removal, deprecated widgets

### 📈 Estado_Atual
- **Purpose:** Technical architecture documentation
- **Links:** Falhas_Apk, Pendencias_Amanha, Analise_FitCal, Anotacoes
- **Key Content:** Stack, folder structure, BLoC patterns

### 📊 Analise_FitCal_VS_NutriV
- **Purpose:** Competitive analysis vs FitCal app
- **Links:** Estado_Atual, Pendencias_Amanha
- **Key Finding:** 6 missing features identified

### 🐛 Falhas_Apk
- **Purpose:** Bug report - Supabase sync issues
- **Links:** sync_meal_repository.dart, Pendencias_Amanha
- **Status:** Root cause identified, partially fixed ✅

### 📅 Pendencias_Amanha
- **Purpose:** Tasks for next session
- **Links:** Falhas_Apk, Analise_FitCal
- **Status:** Critical items completed ✅

### 🎨 NutriV_Mapa_Mental.canvas
- **Purpose:** Visual interactive map (Obsidian Canvas)
- **Links:** All major components visually
- **Key Content:** Tech stack, BLoCs, Pages, Services

### 💡 Ideias/Ideias_e_Casos_Uso
- **Purpose:** Ideas and use cases
- **Links:** Melhorias, Adições
- **Key Content:** Use case examples, feature suggestions

### 📋 Lista_Melhorias
- **Purpose:** Prioritized improvement list
- **Links:** Ideias, Adições, Estado_Atual
- **Status:** High-priority items fixed ✅

---

## 🔍 Quick Reference by Topic

### 🐛 Bugs & Fixes
- **Report:** `Falhas_Apk`
- **Tasks:** `Pendencias_Amanha#Priority-1`
- **Fixes:** Commit 2dee6c8
- **QA Log:** `Relatorios/Correcoes_QA_02_05_2026`

### 🏗️ Architecture
- **Current State:** `Estado_Atual`
- **Visual Map:** `NutriV_Mapa_Mental.canvas`
- **Updates:** `Atualizacao/Historico_Atualizacoes`
- **Removals:** `Lista_Remocoes`

### ✨ Features
- **Added:** `Lista_Adicoes`
- **Suggested:** `Ideias/Ideias_e_Casos_Uso`
- **Improvements:** `Lista_Melhorias`
- **Comparison:** `Analise_FitCal_VS_NutriV`

### ✅ QA Process
- **Reports:** `Relatorios/` folder (5 reports)
- **Sessions:** 2 complete QA passes
- **Issues Found:** 18 total
- **Issues Fixed:** 14 critical/high (Commit 2dee6c8)
- **Remaining:** 4 medium/low priority

---

## 🚀 Code Files Referenced

### Recent Fixes (Commit 2dee6c8)
| File | Issue Fixed | Referenced in |
|------|------------|---------------|
| `onboarding_page.dart` | Auth real Supabase | `Correcoes_QA_02_05_2026` |
| `login_page.dart` | Google login fix | `Pendencias_Amanha` |
| `profile_page.dart` | Logout path fix | `Falhas_Apk` |
| `progress_page.dart` | Dados reais | `Relatorio_QA_Completo_Revisao_Final` |
| `scanner_page.dart` | Unique IDs | `Correcoes_QA_02_05_2026` |
| `ai_food_service.dart` | API fix + fallback | `Lista_Adicoes` |
| `auth_service.dart` | resetPassword | `Pendencias_Amanha#Priority-1` |
| `sync_meal_repository.dart` | ID collision fix | `Falhas_Apk` |

---

## 🎯 How to Navigate This Knowledge Base

### For Developers
1. Start: `Estado_Atual` (understand architecture)
2. Issues: `Falhas_Apk` → `Pendencias_Amanha`
3. Fixes: `Relatorios/Correcoes_QA_02_05_2026`
4. Code: `nutriv/lib/` (see file references above)

### For Product Managers
1. Start: `Analise_FitCal_VS_NutriV` (competitive analysis)
2. Features: `Lista_Adicoes` (what's built)
3. Ideas: `Ideias/Ideias_e_Casos_Uso` (what's next)
4. Improvements: `Lista_Melhorias` (priorities)

### For QA Engineers
1. Start: `Relatorios/Relatorio_QA_Completo` (first pass)
2. Verify: `Relatorios/Relatorio_QA_Completo_Revisao_Final` (second pass)
3. Latest: `Relatorios/Sessao_QA_Correcoes_Criticas_02_05_2026`
4. Log: `Relatorios/Correcoes_QA_02_05_2026`

---

## 📌 Obsidian Tips

### Backlinks
- Every document has `[[backlinks]]` automatically tracked by Obsidian
- Use `Ctrl+Shift+click` to follow links
- Use `Alt+Shift+F` to search for references

### Canvas View
- Open `NutriV_Mapa_Mental.canvas` in Obsidian for visual navigation
- Click nodes to jump to documents
- See connections visually

### Dataview (if plugin installed)
```dataview
TABLE file.ctime as "Created", file.mtime as "Modified"
FROM "MM_NutriV"
SORT file.mtime DESC
```

---

*Generated: 02/05/2026*
*Total Documents: 16*
*Total Code Files Referenced: 21*
*Commit: 2dee6c8 (fix: correções críticas QA)*
*GitHub: https://github.com/Fernand0-Vianna/NutriV*
