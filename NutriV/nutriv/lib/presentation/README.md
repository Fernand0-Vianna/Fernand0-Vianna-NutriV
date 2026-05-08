# Presentation Layer

UI e gerenciamento de estado com BLoC pattern.

## Estrutura

- **`bloc/`** — BLoCs organizados por feature (`meal/`, `weight/`, `water/`, `food_scanner/`, etc.)
- **`pages/`** — Telas completas (`diary/`, `profile/`, `login/`, `scanner/`, `splash/`)
- **`widgets/`** — Componentes reutilizáveis (`meal_card.dart`, etc.)

## Padrões

- Cada BLoC tem 3 arquivos: `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- BLoCs dependem de interfaces de repository (não de implementações concretas)
- Pages consomem estado via `BlocBuilder`/`BlocSelector`
