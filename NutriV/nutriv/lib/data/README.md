# Data Layer

Responsável pela implementação concreta de acesso a dados.

## Estrutura

- **`database/`** — SQLite local (`sqflite`) para cache offline e fila de sincronização (`sync_queue`)
- **`datasources/`** — Serviços externos: Supabase Auth, Groq/Gemini/OpenAI Vision, USDA Food API, pedômetro
- **`models/`** — Objetos de transferência de dados (DTOs) com `fromJson`/`toJson`
- **`repositories/`** — Implementações concretas dos contratos definidos em `domain/repositories/`

## Padrões

- Repositories implementam interfaces do `domain/` para permitir mocking em testes
- `SyncMealRepository` gerencia sincronização offline-first (local SQLite → Supabase)
- Datasources são injetados via DI (`GetIt`)
