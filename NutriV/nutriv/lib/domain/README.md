# Domain Layer

Camada puramente Dart, sem dependências externas ou de framework.

## Estrutura

- **`entities/`** — Modelos de negócio (`Meal`, `FoodItem`, `User`, `WeightEntry`, `DailyLog`)
- **`usecases/`** — Casos de uso da aplicação (ex: `GetMealsByDateUseCase`, `AddMealUseCase`)
- **`repositories/`** — Interfaces/contratos que a camada de data deve implementar

## Princípios

- Entities estendem `Equatable` para comparação por valor
- UseCases orquestram chamadas a repositórios
- Interfaces de repository permitem trocar implementação sem afetar o domínio
