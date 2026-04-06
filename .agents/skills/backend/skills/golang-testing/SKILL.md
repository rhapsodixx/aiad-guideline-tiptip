---
name: golang-testing
description: Use when writing Go tests, adding test coverage, creating benchmarks, implementing fuzz tests, or following TDD in Go projects
---

# Go Testing Patterns

Comprehensive Go testing patterns for writing reliable, maintainable tests following TDD methodology.

## When to Use

- Writing new Go functions or methods
- Adding test coverage to existing code
- Creating benchmarks for performance-critical code
- Implementing fuzz tests for input validation
- Following TDD workflow in Go projects

## TDD Workflow for Go

### The RED-GREEN-REFACTOR Cycle

```
RED     → Write a failing test first
GREEN   → Write minimal code to pass the test
REFACTOR → Improve code while keeping tests green
REPEAT  → Continue with next requirement
```

### Step-by-Step TDD in Go

```go
// Step 1: Define the interface/signature
// calculator.go
package calculator

func Add(a, b int) int {
    panic("not implemented") // Placeholder
}

// Step 2: Write failing test (RED)
// calculator_test.go
package calculator

import "testing"

func TestAdd(t *testing.T) {
    got := Add(2, 3)
    want := 5
    if got != want {
        t.Errorf("Add(2, 3) = %d; want %d", got, want)
    }
}

// Step 3: Run test - verify FAIL
// $ go test
// --- FAIL: TestAdd (0.00s)
// panic: not implemented

// Step 4: Implement minimal code (GREEN)
func Add(a, b int) int {
    return a + b
}

// Step 5: Run test - verify PASS
// $ go test
// PASS

// Step 6: Refactor if needed, verify tests still pass
```

## Table-Driven Tests

The standard pattern for Go tests. Enables comprehensive coverage with minimal code.

```go
func TestAdd(t *testing.T) {
    tests := []struct {
        name     string
        a, b     int
        expected int
    }{
        {"positive numbers", 2, 3, 5},
        {"negative numbers", -1, -2, -3},
        {"zero values", 0, 0, 0},
        {"mixed signs", -1, 1, 0},
        {"large numbers", 1000000, 2000000, 3000000},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got := Add(tt.a, tt.b)
            if got != tt.expected {
                t.Errorf("Add(%d, %d) = %d; want %d",
                    tt.a, tt.b, got, tt.expected)
            }
        })
    }
}
```

### Table-Driven Tests with Error Cases

```go
func TestParseConfig(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        want    *Config
        wantErr bool
    }{
        {
            name:  "valid config",
            input: `{"host": "localhost", "port": 8080}`,
            want:  &Config{Host: "localhost", Port: 8080},
        },
        {
            name:    "invalid JSON",
            input:   `{invalid}`,
            wantErr: true,
        },
        {
            name:    "empty input",
            input:   "",
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ParseConfig(tt.input)

            if tt.wantErr {
                if err == nil {
                    t.Error("expected error, got nil")
                }
                return
            }

            if err != nil {
                t.Fatalf("unexpected error: %v", err)
            }

            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("got %+v; want %+v", got, tt.want)
            }
        })
    }
}
```

## Subtests and Parallel Tests

```go
func TestUser(t *testing.T) {
    db := setupTestDB(t)

    t.Run("Create", func(t *testing.T) { /* ... */ })
    t.Run("Get", func(t *testing.T) { /* ... */ })
    t.Run("Update", func(t *testing.T) { /* ... */ })
    t.Run("Delete", func(t *testing.T) { /* ... */ })
}

// Parallel subtests - capture range variable
for _, tt := range tests {
    tt := tt
    t.Run(tt.name, func(t *testing.T) {
        t.Parallel()
        // ...
    })
}
```

## Test Helpers

```go
func setupTestDB(t *testing.T) *sql.DB {
    t.Helper() // Marks this as a helper function

    db, err := sql.Open("sqlite3", ":memory:")
    if err != nil {
        t.Fatalf("failed to open database: %v", err)
    }

    t.Cleanup(func() { db.Close() })
    return db
}

func assertEqual[T comparable](t *testing.T, got, want T) {
    t.Helper()
    if got != want {
        t.Errorf("got %v; want %v", got, want)
    }
}
```

## Golden Files

```go
var update = flag.Bool("update", false, "update golden files")

func TestRender(t *testing.T) {
    // ...
    golden := filepath.Join("testdata", tt.name+".golden")
    if *update {
        os.WriteFile(golden, got, 0644)
    }
    want, _ := os.ReadFile(golden)
    if !bytes.Equal(got, want) {
        t.Errorf("output mismatch:\ngot:\n%s\nwant:\n%s", got, want)
    }
}
// Update: go test -update
```

## Mocking with Interfaces

```go
type MockUserRepository struct {
    GetUserFunc  func(id string) (*User, error)
    SaveUserFunc func(user *User) error
}

func (m *MockUserRepository) GetUser(id string) (*User, error) {
    return m.GetUserFunc(id)
}
```

## Benchmarks

```go
func BenchmarkProcess(b *testing.B) {
    data := generateTestData(1000)
    b.ResetTimer() // Don't count setup time

    for i := 0; i < b.N; i++ {
        Process(data)
    }
}
// Run: go test -bench=BenchmarkProcess -benchmem
```

## Fuzzing (Go 1.18+)

```go
func FuzzParseJSON(f *testing.F) {
    f.Add(`{"name": "test"}`)
    f.Add(`[]`)

    f.Fuzz(func(t *testing.T, input string) {
        var result map[string]interface{}
        if err := json.Unmarshal([]byte(input), &result); err != nil {
            return // Invalid JSON is expected
        }
        if _, err := json.Marshal(result); err != nil {
            t.Errorf("Marshal failed after successful Unmarshal: %v", err)
        }
    })
}
// Run: go test -fuzz=FuzzParseJSON -fuzztime=30s
```

## Test Coverage

```bash
go test -cover ./...
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out       # browser view
go tool cover -func=coverage.out       # by function
go test -race -coverprofile=coverage.out ./...
```

| Code Type | Target |
|-----------|--------|
| Critical business logic | 100% |
| Public APIs | 90%+ |
| General code | 80%+ |
| Generated code | Exclude |

## HTTP Handler Testing

```go
func TestHealthHandler(t *testing.T) {
    req := httptest.NewRequest(http.MethodGet, "/health", nil)
    w := httptest.NewRecorder()

    HealthHandler(w, req)

    resp := w.Result()
    defer resp.Body.Close()

    if resp.StatusCode != http.StatusOK {
        t.Errorf("got status %d; want %d", resp.StatusCode, http.StatusOK)
    }
}
```

## Testing Commands

```bash
go test ./...                                    # all tests
go test -v ./...                                 # verbose
go test -run TestAdd ./...                       # specific test
go test -run "TestUser/Create" ./...             # subtest
go test -race ./...                              # race detector
go test -cover -coverprofile=coverage.out ./...  # coverage
go test -bench=. -benchmem ./...                 # benchmarks
go test -fuzz=FuzzParse -fuzztime=30s ./...      # fuzzing
go test -count=10 ./...                          # flaky detection
```

## Best Practices

**DO:**
- Write tests FIRST (TDD)
- Use table-driven tests for comprehensive coverage
- Test behavior, not implementation
- Use `t.Helper()` in helper functions
- Use `t.Parallel()` for independent tests
- Clean up resources with `t.Cleanup()`

**DON'T:**
- Test private functions directly (test through public API)
- Use `time.Sleep()` in tests (use channels or conditions)
- Ignore flaky tests (fix or remove them)
- Mock everything (prefer integration tests when possible)
- Skip error path testing
