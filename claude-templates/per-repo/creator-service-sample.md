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
