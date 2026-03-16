# Task: Add creator earnings endpoint to creator-service

## Context
Jira: [TICKET-ID] — [ticket summary from Jira pull]
Service: creator-service handles creator payouts and transaction tracking.

## Goal
Implement a new GET /v1/creator/earnings endpoint that returns aggregated historical earnings.

## Acceptance Criteria
- [ ] Route registered in cmd/api/main.go or routes file
- [ ] Handler implemented in internal/handler/
- [ ] Service method implemented in internal/service/
- [ ] Repository method implemented in internal/repository/ using pgx
- [ ] Table-driven unit tests for service layer
- [ ] Integration test for the handler
- [ ] No regression in existing tests (go test ./... passes)
- [ ] golangci-lint passes (hook will enforce)

## Constraints
- Use pgx directly — do not use sqlx or database/sql
- Use int64 for all currency/Rupiah values — no float64
- Follow existing error wrapping pattern in this repo
- Do not modify any existing handler, service, or repository method signatures — only add new ones
- Branch: feature/[TICKET-ID]-[short-name]

## Out of Scope
- Database migrations (handle separately if schema changes needed)
- API documentation updates (handle in a follow-up)

## References
- Jira: [TICKET-ID]
- Existing similar endpoint for pattern reference: internal/handler/payouts.go
