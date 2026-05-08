# Core Layer

Infraestrutura compartilhada entre todas as camadas.

## Estrutura

- **`constants/`** — Constantes do app + enum `MealType`
- **`di/`** — Injeção de dependência (`GetIt`), registro centralizado em `injection.dart`
- **`interceptors/`** — Interceptors Dio (logging, auth)
- **`services/`** — Serviços globais (`LoggingService`, `ErrorTrackingService`, `HapticService`)
- **`theme/`** — Tema visual do app
- **`utils/`** — Utilitários diversos
