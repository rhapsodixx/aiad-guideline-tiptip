# CLAUDE.md — TipTip Backend (shared)

This file applies to **all** repos under `tiptiptv/backend/`. Each repo's own `CLAUDE.md` adds to (not overrides) these conventions.

---

## Git workflow (JIRA tickets)

**Multi-layer ticket** (touches 2+ of: db, endpoint, service, repo) → use `stack-mrs` skill.
It handles base branch setup and branching internally. Do NOT call `/checkout-commit` first.

**Single-layer ticket** (one layer only), hotfix, or config-only change → use `/checkout-commit`.
It checks out `main`, pulls latest, creates the feature branch, and commits at the end.

Branch format: `[TICKET-CODE]/[short-plan-summary]` — e.g. `SATU-873/remove-catalog-image`

Commit message format:
```
[TICKET-CODE] short but clear summary
```
e.g. `[SATU-873] remove catalog_image_url from API response`

---

## Database connection rule

All tiptiptv backend services share a split DB setup via `utility/connection/connection.go`:

- `infra.Pgsql` — TipTip database → use **only** in `internal/` modules
- `infra.PgSqlSatuSatu` — SatuSatu database → use **only** in `internal_satusatu/` modules

**CRITICAL:** Never use `infra.Pgsql` in `internal_satusatu/` repositories. Always use `infra.PgSqlSatuSatu`.

---

## Import standards

**CRITICAL:** Use the correct `request.Payload` type:

```go
import "gitlab.com/tiptiptv/backend/tip2kit.git/request"
```

This is the tip2kit `request.Payload` — it has an `ErrReq` field and is the standard across all services. Do **not** use any local `request.Payload` (legacy, no `ErrReq`, causes panics).

---

## Error logging and masking

Always log errors. Use log level based on severity:

| Situation | Log level | Error returned to caller |
|---|---|---|
| Unexpected / blocking error (DB down, nil pointer, etc.) | `log.Error` | `kitConstant.ErrInternal` |
| Non-blocking / degraded path (cache miss write, optional enrichment) | `log.Warn` | original error or `nil` |
| Expected invalid input (validation failure, bad request) | `log.Info` | `kitConstant.ErrBadRequest` |
| Expected not-found | `log.Info` or `log.Warn` | `kitConstant.ErrDataNotFound` |

When the caller is a public user or external client, **always mask the actual error** — never expose internal error messages. Use the appropriate `kitConstant` error:

```go
import kitConstant "gitlab.com/tiptiptv/backend/tip2kit.git/constant"
```

---

## DB model field conventions

- Tags: always set both `db:"<column_name>"` and `json:"<column_name>"` — both match the exact SQL column name (snake_case).
- **NOT NULL** → plain Go types (`int64`, `string`, `bool`, `uuid.UUID`)
- **Nullable** → `sql.Null*` variants (`sql.NullString`, `sql.NullInt64`, `sql.NullTime`, etc.)
- **UUID** → `uuid.UUID` (NOT NULL) or `uuid.NullUUID` (nullable) — import `github.com/google/uuid`
- **JSONB** → `[]byte`
- **Monetary NUMERIC** → `decimal.Decimal` (NOT NULL) or `decimal.NullDecimal` (nullable)
- **Nullable ENUM** → named `type Foo string`, use `*Foo` for nullable columns
- **DEFAULT values** → add a comment on the field (e.g. `// DEFAULT CURRENT_TIMESTAMP`); do NOT encode defaults in Go

---

## Core principles

- **Simplicity first** — make every change as simple as possible, impact minimal code
- **No laziness** — find root causes, no workarounds
- **No trailing summaries** — don't restate what you just did; the user can read the diff
- **Be concise** — short, direct responses; lead with the answer, not the reasoning
