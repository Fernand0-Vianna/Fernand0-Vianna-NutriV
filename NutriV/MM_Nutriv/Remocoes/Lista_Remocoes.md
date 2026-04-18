# Remoções - NutriV

> Ver também: [[Atualizacao/Historico_Atualizacoes|Historico_Atualizacoes]] | [[Estado_Atual]] | [[NutriV_Anotacoes_Gerais]]

## Remoções Realizadas

### 1. Firebase (Total)
- **Descrição**: Remoção completa do Firebase do projeto
- **Motivo**: Requer configuração ativa no Google Cloud Console, sem projeto configurado causava erros na inicialização
- **O que foi removido**:
  - Dependências: `firebase_core`, `cloud_firestore`
  - Configurações no AndroidManifest
  - google-services.json (movido para参考)
- **Impacto**: Backend agora usa apenas Supabase - ver [[Estado_Atual#Backend]]
- **Data**: Commit "remoção total do firebase" (8baaf86) → ver [[Atualizacao/Historico_Atualizacoes]]

### 2. Cloud Firestore
- **Descrição**: Base de dados NoSQL do Firebase
- **Substituído por**: Supabase (PostgreSQL)
- **Motivo**: Unificar em um único backend

### 3. Referências Antigas
- Diretório `nutrivison/` removido
- Diretório `nutrivision/` removido
- Arquivos de build antigos

---

## O Que Não Foi Implementado

### Funcionalidades Planejadas - ver [[Ideias/Ideias_e_Casos_Uso]]
1. **Receitas**: Sistema de receitas salvas
2. **Comunidade**: Feed social
3. **Notificações Push**: Lembretes de água/refeições
4. **Apple Health/Google Fit**: Integração com dispositivos
5. **Modo Offline**: Sync offline completo
6. **Assistente Virtual**: Chat com Nutri AI

### APIs não integradas
1. **Nutritionix**: API de alimentos alternativa
2. **Edamam**: Another food database API

---

## Configurações Removidas/Obsoletas

### Android
- strings.xml com configurações Firebase (ainda existe mas não usado)
- google-services.json ainda presente (inativo)
- Firebase Gradle plugins removidos

### iOS
- Similar limpeza necessária

---

## Como Restaurar Firebase (Se Necessário)

Ver [[Estado_Atual]] ou DOCUMENTATION.md para instruções:
1. Adicionar dependências no pubspec.yaml
2. Criar projeto no Firebase Console
3. Configurar SHA-1 do app
4. Adicionar strings.xml com client IDs
5. Habilitar Google Sign-In API no Cloud Console