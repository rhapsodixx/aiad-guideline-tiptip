# TipTip Flutter Stack Conventions

## Base Assumptions
- Flutter 3.19+ and Dart 3.3+.
- Sound null safety is strictly enforced.

## Architecture & State
- State Management: Default to **Riverpod** for state management and dependency injection.
- Folder Structure: Use a Feature-First structure (e.g., `lib/features/auth/presentation`, `lib/features/auth/domain`).
- Navigation: Use `GoRouter` for declarative routing.

## UI & Widgets
- Prefer `StatelessWidget` with Riverpod's `ConsumerWidget` over `StatefulWidget` where possible.
- Use `StatefulWidget` only for local, ephemeral UI state (e.g., animation controllers, scroll controllers).
- Keep `build()` methods small. Extract complex widget trees into separate widget classes (prefer classes over functions returning widgets).
- Follow TipTip's centralized design tokens and Theming system (do not hardcode hex colors throughout the app).

## API & Data
- Use `Dio` (or Retrofit for Dio) for network requests.
- Parse JSON using code generation tools (e.g., `json_serializable` or `freezed`).
- Include robust error handling and user feedback (snackbars/dialogs) for network timeouts or failures.

## Testing & Quality
- Write unit tests for business logic (Providers, Notifiers).
- Write widget tests for critical UI components.
- Platform awareness: Ensure the UI handles SafeArea properly and gracefully adapts if there are specific iOS vs Android UX discrepancies needed by TipTip.

## Anti-Patterns to Avoid
- Do not perform heavy synchronous computations on the UI isolate. Use `compute()` or isolates.
- Avoid deeply nested widget trees ("Callback hell"); use extraction to flatten the hierarchy.
