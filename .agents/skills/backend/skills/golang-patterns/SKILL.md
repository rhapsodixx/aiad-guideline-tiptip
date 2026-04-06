---
name: golang-patterns
description: Use when writing, reviewing, or refactoring Go code to apply idiomatic patterns, error handling conventions, concurrency patterns, interface design, and package organization
---

# Go Development Patterns

Idiomatic Go patterns and best practices for building robust, efficient, and maintainable applications.

## When to Use

- Writing new Go code
- Reviewing Go code
- Refactoring existing Go code
- Designing Go packages/modules

## Core Principles

### 1. Simplicity and Clarity

```go
// Good: Clear and direct
func GetUser(id string) (*User, error) {
    user, err := db.FindUser(id)
    if err != nil {
        return nil, fmt.Errorf("get user %s: %w", id, err)
    }
    return user, nil
}
```

### 2. Make the Zero Value Useful

```go
// Good: Zero value is useful
type Counter struct {
    mu    sync.Mutex
    count int // zero value is 0, ready to use
}
```

### 3. Accept Interfaces, Return Structs

```go
// Good: Accepts interface, returns concrete type
func ProcessData(r io.Reader) (*Result, error) {
    data, err := io.ReadAll(r)
    if err != nil {
        return nil, err
    }
    return &Result{Data: data}, nil
}
```

## Error Handling Patterns

### Error Wrapping with Context

```go
func LoadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("load config %s: %w", path, err)
    }

    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("parse config %s: %w", path, err)
    }

    return &cfg, nil
}
```

### Custom Error Types and Sentinels

```go
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation failed on %s: %s", e.Field, e.Message)
}

var (
    ErrNotFound     = errors.New("resource not found")
    ErrUnauthorized = errors.New("unauthorized")
)

// Check with errors.Is / errors.As
if errors.Is(err, sql.ErrNoRows) { ... }

var validationErr *ValidationError
if errors.As(err, &validationErr) { ... }
```

### Never Ignore Errors

```go
// Bad
result, _ := doSomething()

// Good
result, err := doSomething()
if err != nil {
    return err
}
```

## Concurrency Patterns

### Worker Pool

```go
func WorkerPool(jobs <-chan Job, results chan<- Result, numWorkers int) {
    var wg sync.WaitGroup

    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for job := range jobs {
                results <- process(job)
            }
        }()
    }

    wg.Wait()
    close(results)
}
```

### Context for Cancellation and Timeouts

```go
func FetchWithTimeout(ctx context.Context, url string) ([]byte, error) {
    ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
    defer cancel()

    req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
    if err != nil {
        return nil, fmt.Errorf("create request: %w", err)
    }

    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return nil, fmt.Errorf("fetch %s: %w", url, err)
    }
    defer resp.Body.Close()

    return io.ReadAll(resp.Body)
}
```

### Graceful Shutdown

```go
func GracefulShutdown(server *http.Server) {
    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
    <-quit

    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    if err := server.Shutdown(ctx); err != nil {
        log.Fatalf("Server forced to shutdown: %v", err)
    }
}
```

### errgroup for Coordinated Goroutines

```go
func FetchAll(ctx context.Context, urls []string) ([][]byte, error) {
    g, ctx := errgroup.WithContext(ctx)
    results := make([][]byte, len(urls))

    for i, url := range urls {
        i, url := i, url // Capture loop variables
        g.Go(func() error {
            data, err := FetchWithTimeout(ctx, url)
            if err != nil {
                return err
            }
            results[i] = data
            return nil
        })
    }

    return results, g.Wait()
}
```

### Avoiding Goroutine Leaks

```go
// Good: Buffered channel + context cancellation
func safeFetch(ctx context.Context, url string) <-chan []byte {
    ch := make(chan []byte, 1)
    go func() {
        data, err := fetch(url)
        if err != nil {
            return
        }
        select {
        case ch <- data:
        case <-ctx.Done():
        }
    }()
    return ch
}
```

## Interface Design

### Small, Focused Interfaces

```go
// Good: Single-method interfaces, compose as needed
type Reader interface { Read(p []byte) (n int, err error) }
type Writer interface { Write(p []byte) (n int, err error) }
type ReadWriter interface { Reader; Writer }
```

### Define Interfaces Where They're Used

```go
// In the consumer package, not the provider
package service

type UserStore interface {
    GetUser(id string) (*User, error)
    SaveUser(user *User) error
}
```

## Package Organization

### Standard Project Layout

```text
myproject/
├── cmd/myapp/main.go
├── internal/
│   ├── handler/     # HTTP handlers
│   ├── service/     # Business logic
│   ├── repository/  # Data access
│   └── config/
├── pkg/client/      # Public API client
├── api/v1/          # Proto/OpenAPI definitions
├── testdata/
├── go.mod
└── Makefile
```

### Package Naming

```go
// Good: short, lowercase, no underscores
package user

// Bad: verbose, mixed case, redundant
package userService
package json_parser
```

### Avoid Package-Level State

```go
// Bad: Global mutable state
var db *sql.DB

// Good: Dependency injection
type Server struct { db *sql.DB }
func NewServer(db *sql.DB) *Server { return &Server{db: db} }
```

## Struct Design

### Functional Options Pattern

```go
type Option func(*Server)

func WithTimeout(d time.Duration) Option {
    return func(s *Server) { s.timeout = d }
}

func NewServer(addr string, opts ...Option) *Server {
    s := &Server{addr: addr, timeout: 30 * time.Second}
    for _, opt := range opts {
        opt(s)
    }
    return s
}
```

## Memory and Performance

### Preallocate Slices When Size is Known

```go
// Good: Single allocation
results := make([]Result, 0, len(items))
for _, item := range items {
    results = append(results, process(item))
}
```

### Use sync.Pool for Frequent Allocations

```go
var bufferPool = sync.Pool{
    New: func() interface{} { return new(bytes.Buffer) },
}

func ProcessRequest(data []byte) []byte {
    buf := bufferPool.Get().(*bytes.Buffer)
    defer func() { buf.Reset(); bufferPool.Put(buf) }()
    buf.Write(data)
    return buf.Bytes()
}
```

## Quick Reference: Go Idioms

| Idiom | Description |
|-------|-------------|
| Accept interfaces, return structs | Functions accept interface params, return concrete types |
| Errors are values | Treat errors as first-class values, not exceptions |
| Don't communicate by sharing memory | Use channels for coordination between goroutines |
| Make the zero value useful | Types should work without explicit initialization |
| Clear is better than clever | Prioritize readability over cleverness |
| Return early | Handle errors first, keep happy path unindented |
| gofmt is everyone's friend | Always format with gofmt/goimports |

## Anti-Patterns to Avoid

```go
// Bad: Naked returns in long functions
func process() (result int, err error) {
    // ... 50 lines ...
    return // What is being returned?
}

// Bad: Using panic for control flow
func GetUser(id string) *User {
    user, err := db.Find(id)
    if err != nil {
        panic(err) // Don't do this
    }
    return user
}

// Bad: Context in struct
type Request struct {
    ctx context.Context // Context should be first param
    ID  string
}

// Good: Context as first parameter
func ProcessRequest(ctx context.Context, id string) error { ... }

// Bad: Mixing value and pointer receivers — pick one
func (c Counter) Value() int { return c.n }
func (c *Counter) Increment() { c.n++ }
```

## Essential Tooling

```bash
go build ./...
go test -race ./...
go vet ./...
staticcheck ./...
golangci-lint run
go mod tidy
gofmt -w .
goimports -w .
```
