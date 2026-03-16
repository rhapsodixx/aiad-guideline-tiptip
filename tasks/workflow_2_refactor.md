# Task: Refactor payment-service payout processor to repository pattern

## Context
We are migrating internal/service/payout.go from direct pgx DB queries to the repository pattern. 
The new pattern is defined in internal/repository/user_repo.go.

## Goal
All code in internal/service/payout.go uses the new repository interface injection.
No usages of direct SQL queries remain in the specified scope.

## Acceptance Criteria
- [ ] All direct DB usages replaced with interface method calls
- [ ] No references to pgx.Conn within internal/service/payout.go
- [ ] All existing tests still pass (go test ./... passes)
- [ ] New pattern is used consistently — no mixed old/new
- [ ] golangci-lint passes

## Constraints
- Do not change any public API or interface signatures
- Do not change downstream behavior — only the implementation pattern
- Scope is strictly: internal/service/payout.go and its corresponding tests
- Do not touch: internal/handler/*
- If a usage is unclear, stop and ask rather than guess

## Out of Scope
- Any files outside the listed scope
- Performance optimizations beyond what the pattern change requires
- Adding new feature functionality

## References
- New pattern reference: internal/repository/user_repo.go
- Old pattern example: internal/service/payout.go (current state)
