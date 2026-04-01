# File Tree: nutrivision

**Generated:** 20/03/2026, 16:18:16
**Root Path:** `/media/nando/TERA/NutriV/nutrivision`

```nutri_vision_app/
├── .env.dev                 # Variáveis de ambiente para desenvolvimento (ex: BASE_URL_API=...)
├── .env.prod                 # Variáveis de ambiente para produção
├── lib/
│   ├── main.dart             # Ponto de entrada principal do app
│   ├── app.dart              # Configuração global do app (temas, rotas, providers)
│   ├── config/
│   │   ├── app_constants.dart    # Constantes globais (ex: app_name, version)
│   │   ├── flavor_config.dart    # Configuração de flavors (dev/prod)
│   │   └── firebase_options.dart # Configuração do Firebase (gerado automaticamente)
│   ├── core/
│   │   ├── errors/               # Definições de erros e exceções customizadas
│   │   │   ├── exceptions.dart
│   │   │   └── failures.dart
│   │   ├── providers/            # Providers globais (ex: AuthProvider)
│   │   │   └── auth_provider.dart
│   │   ├── services/             # Serviços globais (ex: API, Autenticação Firebase)
│   │   │   ├── api_service.dart      # Serviço para interagir com seu backend Node.js
│   │   │   ├── auth_service.dart     # Serviço para autenticação (Firebase Auth)
│   │   │   └── local_storage_service.dart # Serviço para dados locais (ex: SharedPreferences)
│   │   ├── theme/                # Definições de tema, cores, fontes, estilos
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── utils/                # Utilitários globais (ex: validadores, formatadores)
│   │       ├── app_logger.dart
│   │       ├── date_formatter.dart
│   │       └── validators.dart
│   ├── data/                     # Camada de dados (Modelos, Repositórios, Data Sources)
│   │   ├── datasources/          # Origens de dados (remoto, local)
│   │   │   ├── auth_remote_datasource.dart
│   │   │   └── daily_log_remote_datasource.dart
│   │   ├── models/               # Modelos de dados (como os dados são estruturados)
│   │   │   ├── daily_entry_model.dart
│   │   │   ├── food_item_model.dart
│   │   │   ├── meal_model.dart
│   │   │   ├── user_model.dart
│   │   │   └── document_model.dart
│   │   └── repositories/         # Repositórios (interface entre UI e datasources)
│   │       ├── auth_repository.dart
│   │       └── daily_log_repository.dart
│   ├── features/                 # Módulos/Funcionalidades específicas do app
│   │   ├── archives/             # Tela de Arquivos
│   │   │   ├── data/             # (Opcional: Repositórios/Modelos específicos da feature)
│   │   │   ├── domain/           # (Opcional: Entidades/Usecases específicos da feature)
│   │   │   └── presentation/     # UI, Providers, Widgets da feature
│   │   │       ├── providers/        # Providers específicos para a tela de arquivos
│   │   │       │   └── archives_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── archives_screen.dart
│   │   │       └── widgets/
│   │   │           ├── activity_chart.dart
│   │   │           ├── document_card.dart
│   │   │           └── macro_tendency_chart.dart
│   │   ├── auth/                 # Autenticação (Login, Cadastro)
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── auth_screen_provider.dart
│   │   │       ├── screens/
│   │   │       │   ├── login_screen.dart
│   │   │       │   └── signup_screen.dart
│   │   │       └── widgets/
│   │   ├── capture/              # Funcionalidade de "Capturar" (Escanear Alimentos)
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── capture_provider.dart
│   │   │       └── screens/
│   │   │           └── capture_screen.dart
│   │   ├── daily_log/            # Diário Alimentar
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── daily_log_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── daily_log_screen.dart
│   │   │       └── widgets/
│   │   │           ├── meal_entry_card.dart
│   │   │           ├── nutrient_summary_card.dart
│   │   │           └── search_food_bar.dart
│   │   ├── home/                 # Tela Inicial/Dashboard
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── home_provider.dart
│   │   │       ├── screens/
│   │   │       │   └── home_screen.dart
│   │   │       └── widgets/
│   │   │           ├── custom_banner_card.dart
│   │   │           ├── feature_button.dart
│   │   │           └── weekly_goal_progress.dart
│   │   ├── profile/              # Perfil do Usuário
│   │   │   └── presentation/
│   │   │       ├── providers/
│   │   │       │   └── profile_provider.dart
│   │   │       └── screens/
│   │   │           └── profile_screen.dart
│   │   ├── splash/               # Tela de Splash (Logo)
│   │   │   └── presentation/
│   │   │       └── screens/
│   │   │           └── splash_screen.dart
│   │   └── training/             # Funcionalidade de Treino
│   │       └── presentation/
│   │           ├── providers/
│   │           │   └── training_provider.dart
│   │           └── screens/
│   │               └── training_screen.dart
│   ├── routes/                   # Definição e gerenciamento de rotas
│   │   ├── app_router.dart         # Configuração do GoRouter
│   │   └── app_routes.dart         # Nomes das rotas como constantes
│   └── shared/                   # Componentes e utilitários reutilizáveis globalmente
│       ├── widgets/              # Widgets customizados reutilizáveis
│       │   ├── custom_app_bar.dart
│       │   ├── custom_bottom_nav_bar.dart
│       │   ├── custom_fab_button.dart # O botão "Capturar" especial
│       │   ├── empty_state_widget.dart
│       │   ├── progress_circle.dart
│       │   └── loading_indicator.dart
│       └── extensions/           # Extensões para tipos Dart (ex: String, DateTime)
│           └── context_extensions.dart # Ex: `context.theme`, `context.size`
├── assets/                       # Recursos estáticos
│   ├── images/                   # Imagens (logo, ícones, fundos, fotos de alimentos)
│   │   ├── logo_nutrivision.png
│   │   ├── avatar_placeholder.png
│   │   ├── food_salad.png
│   │   └── food_toast.png
│   ├── icons/                    # Ícones SVG ou PNG
│   └── fonts/                    # Fontes customizadas
├── pubspec.yaml                  # Metadados do projeto e dependências
├── README.md                     # Documentação do projeto
├── build_scripts/                # Scripts para build e release (ex: shell scripts)
│   ├── build_apk_dev.sh
│   ├── build_apk_prod.sh
│   ├── build_ipa_dev.sh
│   └── build_ipa_prod.sh
└── .github/                      # Configurações do GitHub (opcional: CI/CD, issue templates)
    └── workflows/
        └── flutter_ci.yaml
```

---
*Generated by FileTree Pro Extension*