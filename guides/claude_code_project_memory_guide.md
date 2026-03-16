# CLAUDE.md & Project Memory — TipTip Internal
### Series: Claude Code at TipTip | Guide 2 of N: Project Memory

> ⚠️ **Prerequisites:** Complete Guide 1 (Setup) before proceeding with this guide.

---

## 1. What is CLAUDE.md?

`CLAUDE.md` is a markdown file that Claude Code automatically reads at the start of every session. It acts as persistent project memory. Because Claude does not retain context or remember conversations between sessions, `CLAUDE.md` is how you give Claude standing instructions, conventions, and codebase knowledge that should always be in context.

Without it, every Claude Code session starts cold — it has no initial knowledge of TipTip's stack, patterns, or team conventions. With it, Claude Code immediately understands the TipTip codebase, writes idiomatic code, and avoids common mistakes.

It can live at different levels:
- **Globally** (`~/.claude/CLAUDE.md`) for cross-repo defaults.
- At the **project root** for repo-specific context.
- In **subdirectories** (e.g., `.claude/rules/` or sub-package folders) for package-specific rules.

> **Note on `/memory`:** You can use the `/memory` command at any time during a Claude Code session to verify exactly what instructions and context Claude is currently reading.

**Supporting References:**
- [How Claude remembers your project (Official)](https://docs.anthropic.com/en/docs/claude-code/memory) — Anthropic's official guide on auto memory and `CLAUDE.md`.
- [CLAUDE.md file reference (Official)](https://code.claude.com/docs/en/memory#claude-md-files) — Documentation on how `CLAUDE.md` files are loaded and parsed.
- [Writing a good CLAUDE.md (HumanLayer)](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — A practical guide explaining why less is more, progressive disclosure, and why LLMs need explicit onboarding.

---

## 2. Why CLAUDE.md — Not agents.md

An earlier direction in TipTip's AI coding tool adoption pointed toward using the open standard `agents.md` (from agents.md) as the format for writing context files. This guide intentionally steps back from that approach.

- **Lowest Common Denominator:** `agents.md` is a community standard designed for cross-tool compatibility (Claude Code, Cursor, Cline, Copilot all reading the same file). While that is its strength, it also restrains the capabilities to the lowest common denominator across all tools.
- **Claude Code-First:** TipTip is standardizing on Claude Code as the primary AI coding tool. There is no cross-tool compatibility requirement right now.
- **Richer Capabilities:** Claude Code's native `CLAUDE.md` is richer and more capable. It supports `@file` references for progressive disclosure, slash command definitions, tool permissions, and specific memory behaviors that `agents.md` does not account for.
- **No Unnecessary Abstraction:** Maintaining the `agents.md` format introduces an abstraction layer with no practical benefit for a team that is Claude Code-first. Keeping it native means TipTip engineers learn one format deeply, not two formats shallowly.
- **Future-Proofing:** If TipTip ever adopts a second AI coding tool in the future, the `CLAUDE.md` files can be adapted or translated at that point. Optimizing for multi-tool compatibility now is premature.

**Conclusion:** TipTip's context files will exclusively follow Anthropic's native `CLAUDE.md` format and conventions.

---

## 3. How Claude Code Reads CLAUDE.md

When you start a session, Claude Code loads your instructions in a specific, additive order:

1. **Global `CLAUDE.md`** (`~/.claude/CLAUDE.md`) — Loaded for every session regardless of which repo you are in.
2. **Project root `CLAUDE.md`** (`./CLAUDE.md`) — Loaded when `claude` is run in that specific directory.
3. **Subdirectory `CLAUDE.md`** (e.g., `./packagename/CLAUDE.md`) — Loaded when Claude navigates into or operates within a subfolder.

All levels are additive — global + project + subfolder instructions all stack into Claude's context window.

| Level | Path | What belongs here |
|---|---|---|
| **Global** | `~/.claude/CLAUDE.md` | TipTip-wide engineering standards that apply universally to every repo. |
| **Project** | `<repo-root>/CLAUDE.md` | Repo-specific context: the specific tech stack, architecture patterns, and known issues. |
| **Subfolder** | `<repo-root>/packages/pkg/CLAUDE.md` | Extremely specific rules for an isolated package (e.g., strict security constraints for a `/payments` module). |

---

## 4. TipTip's Recommended Approach: Global + Per-Repo

We evaluated three approaches (Global only, Per-repo only, and Global + Per-repo) and determined that **Global + Per-Repo** is the optimal strategy for TipTip. 

The global file handles "how we work at TipTip" (universal across all engineers and repos), while the per-repo file handles "how this specific codebase works" (precise and relevant per session). This prevents context window bloat (you won't load Go conventions into a Flutter session like you would with a massive single global file) and prevents convention drift across projects (which happens with per-repo only files). This structure scales cleanly as TipTip adds more repos, services, or platforms.

### What goes in the Global CLAUDE.md

The global file covers standards that apply regardless of which repo is open:
- Company name and engineering team identity.
- Universal coding principles (e.g., write tests, no magic numbers, no hardcoded credentials).
- Git conventions: branch naming format, commit message format, PR size guidelines.
- Code review standards and reviewer expectations.
- Security rules: never log PII, never commit credentials, encryption at rest expectations.
- Incident and escalation channels.
- Language policy: English for all code, comments, and documentation (Bahasa Indonesia is acceptable in internal Slack and PR descriptions).
- A reference instructing Claude to check the project-level `CLAUDE.md` for stack-specific context.

*Note: The global `CLAUDE.md` is intentionally stack-agnostic. Stack-specific globals (Go, React/Next.js, Flutter) are maintained as separate stack-level files.*

### What goes in a Per-Repo CLAUDE.md

The per-repo file covers what is specific to that repository:
- Service or product name and its domain responsibility within TipTip.
- Tech stack and core dependencies.
- Folder structure overview.
- Patterns and conventions specific to this repo.
- Known technical debt or fragile areas Claude should be careful with.
- Instructions on how to run the project locally, run tests, and build.
- Environment variable structure (names only, **never** actual secret values).
- Anything Claude consistently gets wrong in this specific repo based on past experience.

---

## 5. The Four Global Template Files

TipTip maintains four global `CLAUDE.md` files to cover our primary stacks. Engineers should select and install the relevant one(s) for their machine based on the repositories they work on. If you work across multiple stacks, you can use the `@` import functionality in your primary `~/.claude/CLAUDE.md` to reference the specific stack files dynamically.

Below are the templates. **Copy and paste the ones relevant to your work:**

---

### Template 1: Global — TipTip Engineering (stack-agnostic)
**File:** `~/.claude/CLAUDE.md`

```markdown
# TipTip Engineering Global Conventions

You are assisting an engineer at PT TipTip Network Indonesia (which also operates the SatuSatu platform).

## Universal Principles
- Write clean, maintainable, and testable code. No magic numbers. 
- Never hardcode credentials, secrets, or API keys under any circumstances.
- Keep functions small and single-purpose.

## Git & PR Conventions
- Branch naming: `feature/<ticket-id>-<short-description>`, `fix/<ticket-id>-<short-description>`, `chore/<short-description>`
- Commit messages: Use imperative mood (e.g., "Add user authentication", not "Added user authentication"). Include ticket ID if applicable.
- PRs should be small and focused on a single logical change.

## Security & Compliance
- NEVER log Personally Identifiable Information (PII) like emails, phone numbers, or passwords.
- Ensure all sensitive data rests encrypted.
- If you suspect a security vulnerability in the code, highlight it immediately with a ⚠️ warning.

## Language Policy
- All code code (variables, functions, classes), comments, and documentation MUST be written in English.
- (Bahasa Indonesia is permitted for internal Slack communications and PR descriptions, but Claude should default to English).

## Team Communication
- General engineering discussion: `#engineering` Slack channel.
- Outages or critical production bugs: Escalated via PagerDuty and the `#incidents` Slack channel.

**IMPORTANT:** Always refer to the project-level `./CLAUDE.md` for stack-specific configurations and conventions relative to the specific repository you are currently operating in.
```

---

### Template 2: Global — Go Stack
**File:** `~/.claude/stacks/golang.md`
*(Import this into your `~/.claude/CLAUDE.md` via `@~/.claude/stacks/golang.md` if you write Go)*

```markdown
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
```

---

### Template 3: Global — React / Next.js Stack
**File:** `~/.claude/stacks/nextjs.md`
*(Import this into your `~/.claude/CLAUDE.md` via `@~/.claude/stacks/nextjs.md` if you write Frontend code)*

```markdown
# TipTip React / Next.js Stack Conventions

## Base Assumptions
- Node.js LTS and Next.js 14+.
- Default to **App Router** (`app/` directory) unless the repo specifically indicates it is a legacy Pages Router project.
- Strict TypeScript. Ensure `tsconfig.json` strict mode is respected. No `any` types.

## Components & State
- File naming: PascalCase for components (`UserProfile.tsx`), camelCase for utilities (`formatDate.ts`).
- Co-locate tests and styles with the component (e.g., `Button.tsx`, `Button.test.tsx`).
- State Management: Prefer Zustand for global client state and React Query for server state/data fetching.

## API & Integration
- Frontend should call TipTip backend APIs via typed fetch wrappers or React Query hooks.
- Handle loading, error, and success states explicitly.

## Error Handling & UX
- Use React Error Boundaries for catching render errors.
- Display user-friendly toast notifications for operational errors or successful mutations.

## Styling & Performance
- Use Tailwind CSS for all styling.
- Utilize `next/image` for image optimization.
- Implement lazy loading for heavy components not visible on the initial viewport.
- Be conscious of bundle size; import libraries selectively.

## Anti-Patterns to Avoid
- Do not mix Server Components and Client Components incorrectly. Use `"use client"` only at the boundary leaf nodes where interactivity/React hooks are actually needed.
- Avoid legacy `getServerSideProps` or `getStaticProps` in App Router components.
- Do not leak secret environment variables to the client. Only prefix with `NEXT_PUBLIC_` if it is explicitly meant to be visible in the browser.
```

---

### Template 4: Global — Flutter Stack
**File:** `~/.claude/stacks/flutter.md`
*(Import this into your `~/.claude/CLAUDE.md` via `@~/.claude/stacks/flutter.md` if you write Mobile code)*

```markdown
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
```

---

### Template 5: Per-Repo Sample — Go Service (Creator Service)
**File:** `<repo-root>/CLAUDE.md`

```markdown
# Creator Service

This is the TipTip Creator Service. It handles creator monetization, earnings calculations, wallet management, and TipTip's payment gateway integrations.

## Stack
- Go 1.22
- PostgreSQL 15 (using `pgx` native, DO NOT use `sqlx`)
- `gin-gonic/gin` for HTTP routing
- `uber-go/zap` for structured logging

## Directory Structure
```
.
├── cmd/
│   └── api/             # Main application entrypoint
├── internal/
│   ├── handler/         # HTTP routes and controllers
│   ├── service/         # Core business logic
│   ├── repository/      # Database interaction layer (pgx)
│   └── util/            # Shared utilities
└── migrations/          # SQL migrate files
```

## Domain Patterns
- **Wallets:** All financial calculations MUST use `int64` representing the lowest denomination (Rupiah). Never use floating-point types (`float64`, `float32`) for currency.
- **Transactions:** Financial updates spanning multiple tables must occur inside a `pgx.Tx` transaction.

## External Integrations
- Integrates with Midtrans and Xendit payment gateways. 
- Mocks for these gateways are located in `internal/service/mock_gateway/`.

## Development Commands
- Run locally: `go run cmd/api/main.go`
- Run all tests: `go test -v ./...`
- Run database migrations: `make migrate-up`

## Environment Variables Needed (Local)
(Never commit the actual values, just the structure)
- `DB_DSN`
- `PORT`
- `MIDTRANS_SERVER_KEY`
- `XENDIT_SECRET_KEY`

## Known Technical Debt (Careful here)
- The legacy `CalculatePayout_V1` function in `internal/service/payout.go` is notoriously fragile and lacks test coverage. If modifying it, proceed extremely slowly and verify steps.

## Claude Tips for this Repo
- Claude frequently tries to import `database/sql` or `github.com/jmoiron/sqlx`. Do not do this. Use `github.com/jackc/pgx/v5` constructs.
```

---

## 6. What to Expect from Engineers

For `CLAUDE.md` to be effective, it must be treated as living documentation, owned and maintained by the engineering team.

### Engineering Lead Responsibilities
Engineering leads are responsible for:
- **Owning the global stack CLAUDE.md** for their domain (e.g., the Go lead owns `golang.md`, Frontend lead owns `nextjs.md`, Mobile lead owns `flutter.md`).
- Reviewing and approving changes to global `CLAUDE.md` files via PR. Because these files affect every engineer on the team, changes should be deliberate.
- **Ensuring every active repository under their domain has a repo-level `CLAUDE.md`** before the team begins using Claude Code on that repo.
- Bootstrapping the initial per-repo `CLAUDE.md` for new repositories. Do not delegate the first version to junior engineers, as it requires deep knowledge of the repo's architectural patterns and intent.
- Using the per-repo `CLAUDE.md` as part of the onboarding process. If a new engineer reads the `CLAUDE.md` and it does not accurately describe the repo, that is a strong signal it needs updating.
- Scheduling a quarterly review of global `CLAUDE.md` files to ensure they reflect current TipTip standards, not legacy ones.

### Individual Engineer Responsibilities
Individual engineers are responsible for:
- Reading the repo's `CLAUDE.md` before their first Claude Code session on a new repo.
- Treating `CLAUDE.md` as living documentation. Never delete content from `CLAUDE.md` without a team discussion — flag anomalies rather than removing them unilaterally.
- Executing the **refinement loop**:
  1. Use Claude Code on a task.
  2. Claude produces output that misses a TipTip convention or pattern.
  3. Identify what context was missing.
  4. Update `CLAUDE.md` with that context.
  5. Verify with `/memory` that Claude is reading the update.
  6. Next session: Claude gets it right.
  *(This loop is how the file matures. It is expected and normal).*
- Treating `CLAUDE.md` updates as meaningful PRs. Include a brief description of why the change was made (e.g., "Added note about `pgx` because Claude kept suggesting `sqlx`").

### Quality Bar
- **Accuracy over completeness:** Stale context is worse than no context. If `CLAUDE.md` says a repo uses `sqlx` but it migrated to `pgx` 6 months ago, Claude will confidently generate broken code.
- **Avoid vagueness:** "Write clean code" tells Claude nothing. Give concrete examples.
- **Respect the context window:** A `CLAUDE.md` that is too long wastes tokens and degrades LLM performance. Aim for under 300 lines per file.
- **The 10-minute rule:** Read the `CLAUDE.md` aloud. If it sounds like generic advice applicable to any company, it needs more TipTip-specific detail. If it takes 10 minutes to read, it needs to be trimmed or split using `@` file imports.

---

## 7. Quick Reference

| Task / Item | Command / Location |
|---|---|
| View what Claude is reading | `/memory` (run inside Claude Code session) |
| Global `CLAUDE.md` location | `~/.claude/CLAUDE.md` |
| Go stack global | `~/.claude/stacks/golang.md` |
| React/Next.js stack global | `~/.claude/stacks/nextjs.md` |
| Flutter stack global | `~/.claude/stacks/flutter.md` |
| Project (Repo) `CLAUDE.md` location | `<repo-root>/CLAUDE.md` |
| Official memory documentation | [Docs: How Claude remembers](https://docs.anthropic.com/en/docs/claude-code/memory) |
| Official `CLAUDE.md` file reference | [Docs: CLAUDE.md Files](https://code.claude.com/docs/en/memory#claude-md-files) |
| Practical writing guide | [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) |
