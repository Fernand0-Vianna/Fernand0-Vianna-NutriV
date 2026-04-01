# NutriVision App

Um aplicativo móvel nativo (Flutter) para rastreamento nutricional e bem-estar, com uma interface intuitiva e modular.

## 🎯 Visão Geral do Projeto

O NutriVision é um aplicativo projetado para ajudar usuários a monitorar sua ingestão diária de alimentos, macros e calorias, acompanhar metas de saúde e acessar documentos nutricionais. A arquitetura foi pensada para ser escalável e fácil de manter, permitindo a adição de novas funcionalidades com mínima refatoração.

## 🧱 Arquitetura

O projeto segue uma arquitetura modular baseada em "features", onde cada funcionalidade principal do aplicativo (e.g., Diário Alimentar, Home, Arquivos) tem seu próprio módulo. Isso promove a separação de preocupações e facilita o desenvolvimento paralelo e a manutenção.

### Camadas Principais:

-   **`lib/main.dart`**: Ponto de entrada do aplicativo.
-   **`lib/app.dart`**: Configurações globais, providers e tema.
-   **`lib/config/`**: Configurações de ambiente (dev/prod), constantes e Firebase.
-   **`lib/core/`**: Componentes e lógicas de baixo nível reutilizáveis em todo o aplicativo (serviços, tema, utilitários, tratamento de erros).
-   **`lib/data/`**: Camada de dados, incluindo modelos (models), fontes de dados (datasources) e repositórios (repositories) para abstrair a origem dos dados (API, Firebase, cache local).
-   **`lib/features/`**: Contém todos os módulos de funcionalidades. Cada módulo (`auth`, `home`, `daily_log`, `archives`, `profile`, `capture`, `training`, `splash`) possui sua própria estrutura (`presentation`, `domain`, `data` - se necessário).
    -   **`presentation/`**: Contém a UI (telas, widgets) e os providers de estado específicos da feature.
    -   **`domain/` (Opcional)**: Contém as entidades de negócio e use cases.
-   **`lib/routes/`**: Gerenciamento de rotas usando `go_router`.
-   **`lib/shared/`**: Componentes de UI reutilizáveis (widgets) e extensões que não pertencem a uma feature específica.
-   **`assets/`**: Recursos estáticos como imagens, ícones e fontes.
-   **`build_scripts/`**: Scripts shell para automatizar o processo de build e release.

### Tecnologias Principais:

-   **Frontend:** Flutter
-   **Gerenciamento de Estado:** Provider
-   **Navegação:** GoRouter
-   **Configuração de Ambiente:** `flutter_dotenv` (com `dart-defines` para flavors)
-   **Backend (Conceitual):** Node.js + Express (API REST/GraphQL)
-   **Banco de Dados (Conceitual):** Firebase Firestore (dados em tempo real, autenticação, storage)

## 🚀 Como Iniciar

### Pré-requisitos

-   [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado e configurado.
-   [VS Code](https://code.visualstudio.com/) ou [Android Studio](https://developer.android.com/studio) com os plugins Flutter instalados.
-   [Firebase CLI](https://firebase.google.com/docs/cli) instalado e configurado para seu projeto Firebase.

### Configuração do Projeto

1.  **Clone o repositório:**
    ```bash
    git clone [URL_DO_SEU_REPOSITORIO]
    cd nutri_vision_app
    ```

2.  **Obtenha as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Configurar Firebase:**
    -   Crie um projeto no [Firebase Console](https://console.firebase.google.com/).
    -   Adicione seu aplicativo Android e iOS ao projeto Firebase.
    -   Execute o comando `flutterfire configure` na raiz do projeto para gerar `lib/config/firebase_options.dart`.

4.  **Variáveis de Ambiente:**
    -   Crie os arquivos `.env.dev` e `.env.prod` na raiz do projeto.
    -   Preencha-os com as variáveis necessárias (ex: `BASE_URL_API`, `APP_NAME`).
        ```
        # .env.dev
        BASE_URL_API=http://localhost:3000/api/v1
        APP_NAME="NutriVision (DEV)"

        # .env.prod
        BASE_URL_API=https://api.nutrivision.com/api/v1
        APP_NAME="NutriVision"
        ```

5.  **Gerar Ícones e Splash Screen:**
    -   Certifique-se de que a imagem do logo (`assets/images/logo_nutrivision.png`) esteja no local correto.
    -   Execute:
        ```bash
        flutter pub run flutter_launcher_icons:main
        flutter pub run flutter_native_splash:create
        ```

### Executando o Aplicativo

Para rodar o aplicativo em modo de desenvolvimento:

```bash
flutter run --flavor dev -t lib/main.dart --dart-define=FLAVOR=dev