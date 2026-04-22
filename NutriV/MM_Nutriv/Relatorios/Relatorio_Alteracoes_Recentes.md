# Relatório de Alterações Recentes - NutriV

**Data:** 21 de Abril de 2026
**Autor:** NutriV Assistant

## Resumo Executivo
As últimas atualizações focaram na estabilização da autenticação via Google, expansão das funcionalidades de saúde (pedômetro, peso) e melhoria da experiência do usuário com novos componentes de UI e otimização do fluxo de scanner.

---

## Detalhamento das Alterações

### 1. Autenticação e Segurança
- **Google Sign-In:** Finalizada a implementação e correção do fluxo de login com Google.
- **Configuração Android:** Atualização do `google-services.json` e `AndroidManifest.xml` para suporte ao OAuth.
- **Validação:** Implementação de validadores para tokens do Google e redirecionamentos.

### 2. Novas Funcionalidades (Backend & Domain)
- **Gerenciamento de Perfil:** Implementação completa de `UserProfileModel` e `UserProfileRepository`.
- **Rastreamento de Saúde:** Adição do `PedometerService` para contagem de passos e `WeightRepository` para controle de peso.
- **Favoritos:** Novo sistema de pratos favoritos (`FavoriteDishBloc`, `FavoriteDishRepository`).
- **Resumo Diário:** Implementação do `DailySummaryRepository` para consolidar métricas do dia.
- **Refatoração de Refeições:** Introdução do `MealRepositoryV2` para melhor escalabilidade.

### 3. Interface e Experiência do Usuário (UI/UX)
- **Skeleton Loaders:** Adição de animações de carregamento (`skeleton_loader.dart`) para uma percepção de velocidade aprimorada.
- **Página de Login:** Redesign e integração com o novo fluxo de autenticação.
- **Página de Perfil:** Atualizada para exibir dados do novo repositório de perfil.
- **Página de Scanner:** Refatoração significativa para melhorar a precisão e feedback visual.

### 4. Infraestrutura e Manutenção
- **Netlify:** Configuração inicial para deploy/hosting através do `netlify.toml` e plugins.
- **Análise de Código:** Ajustes no `analysis_options.yaml` para manter a qualidade do código.
- **Vscode:** Adição de extensões recomendadas e configurações de workspace.

---

## Últimos 10 Commits
- `027004a` - Correção Login com google
- `0969005` - validador google
- `e10a5a2` - validador google
- `5f86e5f` - Entrar com a conta Google
- `187df5b` - Merge branch 'main'
- `1c81c4a` - correção do flutter
- `7b1cd94` - teste
- `c490cc4` - teste
- `8c484ad` - Maior Up até agora
- `1009b51` - Corrige redirect URL do Google OAuth

---

## Próximos Passos Sugeridos
1. Validar a sincronização do Pedômetro em segundo plano.
2. Testar o fallback de IA (Gemini -> GPT-4o-mini) sob condições de alta latência.
3. Finalizar a integração do `MealRepositoryV2` nas telas remanescentes.
