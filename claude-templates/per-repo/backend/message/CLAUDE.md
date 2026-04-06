# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is the **TipTip Messaging Service** — a Go-based notification delivery platform supporting multiple channels: Email (AWS SES), SMS, WhatsApp (Infobip), and Push Notifications (Firebase). It exposes both HTTP (Echo, port 18082) and gRPC (port 7002) interfaces and uses event-driven workers for async processing.

---

## Commands

**Run the HTTP server:**
```sh
go run main.go serve
```

**Run unit tests:**
```sh
CGO_ENABLED=0 go test ./...
# or a single package:
CGO_ENABLED=0 go test ./internal/notification/service/...
```

**Run a single test:**
```sh
go test -v ./internal/notification/service/... -run TestName
```

**Run tests with coverage:**
```sh
/bin/bash ./scripts/cover-unittest.sh
```

**Run workers/consumers:**
```sh
go run main.go message:asynq-worker
go run main.go message:notification-consumer
go run main.go satusatu:message:general-consumer
```

**Generate Swagger docs:**
```sh
swag init
```

**Generate a new module:**
```sh
/bin/bash ./scripts/new-module.sh {PATH} {MODULE_NAME}
```

**Generate a new endpoint:**
```sh
/bin/bash ./scripts/new-endpoint.sh {MODULE_NAME} {FUNC} {METHOD} {PATH}
```

**Build:**
```sh
make build   # Builds bin/api and bin/job
make vet
make fmt
make lint
```

---

## Architecture

**Request flow:**
```
HTTP Request → Transport → Endpoint → Service → Repository → Database
                   ↓          ↓         ↓          ↓
                Decoder   Validation  Logic   SQL Query
```

### Module structure

Each domain module follows this layout:
```
internal/{module}/
  model/        # internal data structures and DB DTOs (NOT for API-facing types)
  repo/         # DB/external queries
  service/      # business logic
  endpoint/     # go-kit endpoint + reqresp
  transport/    # HTTP and/or gRPC handlers
  grpc/protoc/  # generated protobuf files
```

**TipTip modules** live under `internal/`:
- `notification` — core notification logic, templates, logging (email, WA, SMS)
- `emailverifier` — email address verification

**SatuSatu modules** live under `internal_satusatu/`:
- Separate consumers, callbacks, and delivery logic for the SatuSatu product line

### Application entrypoint

`cmd/cmd.go` defines all CLI commands (Cobra). Key commands:
- `serve` — starts HTTP + gRPC server
- `message:asynq-worker` — async job queue worker (Redis/Asynq)
- `message:notification-consumer` — SQS notification consumer
- `message:notification-consumer-email-mq` / `-wa` / `-push-notif` — per-channel consumers
- `message:logging-email` — email logging consumer
- `satusatu:message:general-consumer` — SatuSatu general consumer
- `satusatu:message:email-status-callback` — email status callback consumer

### Infrastructure / connections

`utility/connection/connection.go` is the central DI struct passed to every module. It holds:
- PostgreSQL master/slave via `sqlx` — **two separate DB connections**:
  - `infra.Pgsql` — TipTip database (use for `internal/` modules)
  - `infra.PgSqlSatuSatu` — SatuSatu database (use for `internal_satusatu/` modules)
- Redis (`go-redis/redis/v8`) + distributed locks via Redsync
- AWS session (SES, SQS, S3)
- gRPC server + gRPC clients
- Asynq client (background task queue via Redis)
- Zipkin tracer

Config is loaded from `config/app.env` via Viper (`utility/config/config.go`).

### External integrations (`external/`)

| Directory | Purpose |
|-----------|---------|
| `email/` | AWS SES email sending |
| `infobip/` | SMS and WhatsApp via Infobip |
| `firebase/` | Push notifications |
| `fazpass/` | OTP (WA + SMS) via Fazpass |
| `whapi/` | WhatsApp API |
| `kickbox/` | Email address validation |
| `debounce/` | Email debounce checking |

### Observability

- **Metrics**: Prometheus (`/metrics` endpoint)
- **Tracing**: Zipkin (distributed trace context propagated via HTTP headers)
- **Logging**: Logrus structured logging

### Protocol Buffers

gRPC definitions are in `internal/notification/grpc/protoc/`. Re-generate with protoc after `.proto` changes.

---

## Key Conventions

### Endpoint pattern

```go
func Make{Feature}Endpoint(s svc.Service, zipkinTracer *stdZipkin.Tracer) endpoint.Endpoint {
    return func(ctx context.Context, req interface{}) (interface{}, error) {
        payload := req.(request.Payload)
        request := payload.Body.(viewmodel.{Feature}Request)
        emptyData := make([]viewmodel.{Feature}Response, 0)

        result, err := s.Handle{Feature}(ctx, payload)
        if err != nil {
            // Return proper error response
        }

        return response.CreateResponseWithStatusCode{
            ResponseJson: responseBody,
            StatusCode:   httpCode,
        }, nil
    }
}
```

### Service layer pattern

```go
func (s *service) Handle{Feature}(ctx context.Context, param request.Payload) (output interface{}, err error) {
    var (
        eventName = "{module}.logic.{feature}.handle-{feature}"
        logFields = map[string]interface{}{
            "event": eventName,
            "param": param,
        }
    )

    log := s.infra.LogKit.Start(ctx, eventName, true)
    defer log.ZipkinSpan.Finish()

    req := param.Body.(viewmodel.{Feature}Request)

    _, err = govalidator.ValidateStruct(req)
    if err != nil {
        log.Info(logFields, fmt.Sprintf("failed on validation request, err : %s", err.Error()))
        return output, kitConstant.ErrBadRequest
    }

    // Business logic here

    return output, nil
}
```

### Error logging — code examples

```go
import kitConstant "gitlab.com/tiptiptv/backend/tip2kit.git/constant"

// Unexpected error — mask with ErrInternal
if err != nil {
    log.Error(logFields, fmt.Sprintf("failed to query DB, err: %s", err.Error()))
    return output, kitConstant.ErrInternal
}

// Invalid request
_, err = govalidator.ValidateStruct(req)
if err != nil {
    log.Info(logFields, fmt.Sprintf("failed on validation request, err: %s", err.Error()))
    return output, kitConstant.ErrBadRequest
}

// Non-blocking — log warn, do not fail the request
if err != nil {
    log.Warn(logFields, fmt.Sprintf("failed to set cache, err: %s", err.Error()))
}
```

Include **relevant arguments** in `logFields` to aid troubleshooting:

```go
logFields = map[string]interface{}{
    "event":    eventName,
    "user_id":  userID,
    "channel":  req.Channel,
}
```

### Request validation

Validate every incoming request using `govalidator.ValidateStruct` immediately after the type assertion in the service layer:

```go
import (
    "github.com/asaskevich/govalidator"
    kitConstant "gitlab.com/tiptiptv/backend/tip2kit.git/constant"
)

_, err = govalidator.ValidateStruct(req)
if err != nil {
    log.Info(logFields, fmt.Sprintf("failed on validation request, err : %s", err.Error()))
    return output, kitConstant.ErrBadRequest
}
```

Validation rules are declared on the struct via the `valid` struct tag:

```go
type SendNotificationRequest struct {
    Channel   string   `json:"channel"  valid:"required,in(email|sms|wa|push)"`
    Recipient string   `json:"recipient" valid:"required"`
    TemplateID int64   `json:"template_id" valid:"required"`
    Limit     int      `json:"limit"`  // optional, no constraint
}
```

---

## DB model field conventions

Nullable column type mappings (extends parent conventions):

- `VARCHAR` / `TEXT` nullable → `sql.NullString`
- `INTEGER` nullable → `sql.NullInt32`
- `BIGINT` nullable → `sql.NullInt64`
- `TIMESTAMP` nullable → `sql.NullTime`
- `BOOLEAN` nullable → `sql.NullBool`
- `NUMERIC` nullable → `sql.NullFloat64` (non-monetary) or `decimal.NullDecimal` (monetary)

---

## Testing

Tests for `internal/` modules are co-located with their source (`service/` package). Mocks live in `test/mocks/`.

**Run all tests:**
```sh
CGO_ENABLED=0 go test ./...
```

**Run a single module:**
```sh
go test -v ./internal/notification/service/...
```

**Generate mocks** (after changing a repo interface):
```sh
mockgen -source=internal/{module}/repo/repository.go -destination=test/mocks/mock_{module}_repository.go
```

### Bug report workflow

When a bug is reported, **do not attempt to fix it immediately**. Follow this order:

1. **Write a failing test first** — reproduce the bug with a test that fails in the current state.
2. **Delegate the fix** — use a subagent to attempt the fix.
3. **Prove with a passing test** — the fix is only accepted when the previously failing test now passes.

### Testing checklist

- [ ] Build succeeds: `go build ./...`
- [ ] No type assertion panics
- [ ] Proper error responses (400, 500)
- [ ] Logging includes event names and relevant identifiers
- [ ] Zipkin spans are properly closed

---

## Config conventions

When adding or renaming a configurable value in `utility/config/config.go`:

1. **Always mirror it in `config/app.env.example`** — add the corresponding `mapstructure` key as an env var entry.
2. **Leave the value empty by default** in `app.env.example` (e.g. `SOME_KEY=`, not `SOME_KEY=somevalue`).
3. **SatuSatu configs must use the `SatuSatu` prefix** in the Go struct field name and `SATUSATU_` prefix in the env key.
4. Add the env key under the relevant comment section in `app.env.example`.

---

## Key Dependencies

- `github.com/labstack/echo/v4` — HTTP server
- `google.golang.org/grpc` — gRPC
- `github.com/go-kit/kit` — service/endpoint/middleware pattern
- `github.com/hibiken/asynq` — task queue
- `github.com/jmoiron/sqlx` + `lib/pq` — PostgreSQL
- `github.com/go-redis/redis/v8` — Redis
- `github.com/spf13/viper` + `cobra` — config + CLI
- `gitlab.com/tiptiptv/backend/tip2kit.git` — internal shared utilities
