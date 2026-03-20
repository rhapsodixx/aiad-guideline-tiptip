# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run server (HTTP on :18081)
go run main.go serve

# Run background worker
go run main.go content:asynq-worker

# Build binaries into bin/
make build

# Test / vet / lint / format
make test
make vet
make lint
make fmt

# Run a single test
go test ./internal/product/service/... -run TestFunctionName -v

# Run tests in unittest/
cd unittest/ && go test -v

# Coverage report
/bin/bash ./scripts/cover-unittest.sh

# New DB migration (TipTip DB)
make migrate_new

# New DB migration (SatuSatu DB)
make migrate_new_satusatu

# Scaffold a new module
/bin/bash ./scripts/new-module.sh {PATH} {MODULE_NAME}

# Scaffold a new endpoint within a module
/bin/bash ./scripts/new-endpoint.sh {MODULE_NAME} {FUNC} {METHOD} {PATH}
```

Config is loaded from `./config/app.env` — copy from `app.env.example` to set up locally.

## Architecture

This is the **Content Service** — manages product catalogs, bookings, reviews, and related content across TipTip and SatuSatu databases.

### Entry points

- `main.go` → `cmd/cmd.go` (cobra CLI) → `cmd/server.go` (HTTP + gRPC) or `cmd/worker.go` (Asynq background jobs)
- HTTP routes mounted at `/content/*`, health check at `/content/health-check`
- `cmd/initiator/initiator.go` — single place where all modules are wired with DI

### Module layout

All modules follow: `repo/` (DB queries) → `service/` (business logic) → `endpoint/` (HTTP handler + decoder) → `transport/` (route registration).

| Directory | DB | Purpose |
|---|---|---|
| `internal/` | `infra.Pgsql` | TipTip DB: products, categories, creators, organizations, price tiers |
| `internal_satusatu/` | `infra.PgSqlSatuSatu` | SatuSatu DB: bookings, catalogs, reviews, banners, suppliers |
| `utility/` | — | Shared infra: config, DB connections, Redis, AWS, helpers |
| `common/` | — | Shared constants, request/response models |

Within each module, `model/` holds internal DB structs; `viewmodel/` holds API-facing request/response structs. Never use `model/` types in endpoint handlers — use `viewmodel/`.

### Key modules

- `internal/product/` — Largest TipTip module: product CRUD, booking download, search indexing
- `internal_satusatu/` — SatuSatu modules: `booking/` (booking flow, payment callbacks, eTicket PDF, session management), `catalog/` (listing with location caching), `review/`, `banner/`, `custom_section/`, `supplier/`, `common/`

### Request flow

```
HTTP Request → transport/ → endpoint/reqresp.go (decode) → endpoint/http.go → service/ → repo/ → DB
```

Service methods signature: `Handle{Feature}(ctx context.Context, param request.Payload) (interface{}, error)`

### Background jobs (Asynq + SQS)

- `ProductStatsConsumer` — SQS-driven product stats updates
- `IndexingSearch` — Search engine indexing consumer
- `AsynqWorker` — General async task processor (booking expiry, notifications, etc.)

### External dependencies

gRPC clients to: `message`, `order`, `payment`, `session`, `user`, `wallet`, `social`, `subscription`, `promoter`, `codec` services.
AWS: S3 (file storage), CloudFront (CDN), SQS (queues).
Redis: cluster mode via `utility/redis/`.

### Observability

- Prometheus metrics (counters/gauges/histograms per handler)
- Zipkin tracing (opt-in via config `ZIPKIN_ENABLE`); always `defer log.ZipkinSpan.Finish()` in service methods
- go-kit structured logging: `log := s.infra.LogKit.Start(ctx, eventName, true)`

### Migrations

- TipTip DB: `db/migrations/`
- SatuSatu DB: `db/migrations_satusatu/`

## Pagination

### Cursor-based (use for all new endpoints)

Cursors must be encoded with `helper.HashInterface` — never raw base64 or plain offsets.

```go
// In NewService — initialize once, no need to inject as param
s.hashCursor = helper.InitHash(kitConstant.HashCursorSalt, kitConstant.HashCursorLength)

// Encode (last item's ID becomes the cursor)
nextCursor := s.hashCursor.EncodePublicID(lastItem.ID)

// Decode
id, err := s.hashCursor.DecodePublicID(cursorStr)
```

Reference: `internal/product/service/logic.go:207`, `internal/organization/service/service.go:130`

Response shape (define in `viewmodel/`):

```go
type PaginationMeta struct {
    TotalCount int64  `json:"total_count"`
    PageSize   int    `json:"page_size"`
    HasMore    bool   `json:"has_more"`
    NextCursor string `json:"next_cursor,omitempty"`
    PrevCursor string `json:"prev_cursor,omitempty"`
}
```

### Offset-based (legacy only)

Use `model.PaginationOutput` only for backward-compatible existing endpoints.
