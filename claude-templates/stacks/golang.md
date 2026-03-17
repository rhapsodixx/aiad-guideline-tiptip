# TipTip Go Stack Conventions

## Base Assumptions
- Go version 1.22+.
- Follow standard Go module structures.

## Error Handling
- Wrap errors using `fmt.Errorf("failed to do X: %w", err)`.
- Use custom error types for domain-level errors that need to be checked via `errors.As` or `errors.Is`.
- Do not silently swallow errors.

## Design & Architecture
- Interface design: Keep interfaces small (1-2 methods). Accept interfaces, return structs.
- Concurrency: Never start a goroutine without knowing how and when it will stop. Prefer worker pools over unbounded goroutines.
- Context: ALWAYS pass `context.Context` as the first argument to functions doing I/O. NEVER store `context.Context` inside a struct.
- Database access: Use the Repository pattern. We typically use `pgx` for PostgreSQL access (unless otherwise specified in the repo).
- Dependency Injection: Pass dependencies explicitly (e.g., via struct fields on server or handler structs), avoid global state.
- Logging: Use structured logging with `zap`. Respect log levels (Info, Warn, Error, Debug).

## Testing
- Use Table-Driven tests for multiple scenarios.
- Name tests descriptively: `TestFunctionName_Scenario_Outcome`.
- Use localized mocks (not massive global mocks) for dependencies.

## Anti-Patterns to Avoid
- Avoid `init()` functions unless strictly necessary for registering drivers.
- Avoid using `sqlx` in modern services unless the repo explicitly configures it.
- Avoid panic-driven control flow. Return errors.
