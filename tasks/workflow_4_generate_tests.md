# Task: Add test coverage for internal/service/booking.go

## Context
internal/service/booking.go has insufficient test coverage. It is being modified for SatuSatu integrations.

## Goal
The booking service has meaningful test coverage for all non-trivial functions and methods. Tests follow TipTip's existing test patterns.

## Acceptance Criteria
- [ ] Table-driven tests for all exported functions in internal/service/booking.go
- [ ] Each test covers: happy path, error/edge cases, boundary conditions
- [ ] Tests use existing mock patterns in this repo (check internal/mock/)
- [ ] go test ./internal/service/... passes with new tests included
- [ ] No test uses time.Sleep or relies on real external services

## Constraints
- Do not modify the implementation code to make tests pass — only write tests. If the implementation must change for testability, stop and ask.
- Use table-driven test format: var tests = []struct{...}
- Mock external dependencies — do not make real API or Midtrans/Xendit DB calls in tests
- Follow existing test file naming: booking_test.go natively inside the same package

## Out of Scope
- Tests for unexported functions (unless they contain highly critical mathematical logic)
- Integration tests (handle separately)
- Benchmarks

## References
- Existing test example for pattern: internal/service/user_test.go
