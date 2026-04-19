# Falhas e Pendências do APK - NutriV

> Este arquivo deve ser atualizado a cada build para registrar problemas conhecidos e pendências do app.

---

## Build: 18/04/2026 - 

### ⚠️ Pendências/Tarefas

- O registro de usuario no aplicativo, não consigo acessar o app com a conta google e criando uma nova, não houve registro no supabase do usario;
- Continuar com a conta google está indisponivel;
- Quando crio um usario novo, ele não cria na tabela do supa;


---

## Histórico de Builds

### Build 5 - 18/04/2026
- Login separado em 2 telas (Login + Registro)
- Fluxo: Login → Registro → App

### Build 4 - 18/04/2026
- Remoção total do Firebase/Google Sign-In
- AuthService com Supabase Auth
- Login com e-mail funcionando

### Build 3 - 18/04/2026
- Login e-mail implementado
- AI com melhor fallback

### Build 2 - 18/04/2026
- Quick Actions conectados
- VoiceInputWidget integrado
- Funções do Perfil implementadas

### Build 1 - 18/04/2026
- Versão inicial com problemas