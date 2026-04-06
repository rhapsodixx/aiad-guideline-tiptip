---
name: stack-mrs
description: Use when implementing a JIRA ticket that touches 2 or more of: db migrations, endpoint/transport, service, or repo layers — to split into stacked MRs reviewable in under 15 minutes each
---

# stack-mrs

**Trigger:** Use when implementing a JIRA ticket that touches 2 or more of: db migrations, endpoint/transport, service, or repo layers.

Split the implementation into stacked MRs — one per architectural layer, further subdivided to keep each MR reviewable in < 15 minutes. Every branch must build cleanly using stubs for not-yet-implemented downstream layers.

---

## When to apply this skill

Apply automatically when:
- A JIRA ticket plan involves changes across multiple architectural layers
- The user starts implementing a feature (not a hotfix or single-file change)

Do NOT apply for:
- Single-layer changes (e.g. only a repo query fix)
- Hotfixes
- Config-only changes

---

## Step 1 — Gather scope before touching git

Ask the user:

> "Which layers does this ticket touch? Choose from: `db`, `endpoint`, `service`, `repo`.
> Also briefly describe what each layer needs to do (e.g. '1 migration, 2 endpoints: list + detail, 2 service methods, 2 repo queries'). I'll use this to plan the MR stack."

Wait for response.

## Step 2 — Plan the stack

**Assess size per layer using the 15-minute rule:**
- ≤ 2–3 meaningfully new functions, OR ≤ ~150 lines of real logic → single MR for that layer
- More than that → split into sub-MRs with descriptive suffixes

Build `STACK` — an ordered list of branch names in fixed layer order (db → endpoint → service → repo), with sub-splits where needed.

Present the planned stack for confirmation:

> "Planned MR stack for [TICKET]:
> 1. `TICKET/db` → main
> 2. `TICKET/endpoint-list` → `TICKET/db`
> 3. `TICKET/endpoint-detail` → `TICKET/endpoint-list`
> 4. `TICKET/service` → `TICKET/endpoint-detail`
> 5. `TICKET/repo` → `TICKET/service`
> Does this look right?"

Adjust based on feedback before touching git.

## Step 3 — Establish the base branch

```bash
git branch --show-current
```

- If not `main`: ask "Stack on top of `<branch>` instead of main? (yes/no)"
  - Yes → `BASE = <current branch>`, skip checkout
  - No → `git checkout main && git pull`
- Set `BASE = main` if checking out main.

If `git checkout main` or `git pull` fails, stop and report.

## Step 4 — For each slice: branch → implement → build → commit

Track `PREV_BRANCH = BASE`. For each branch in `STACK`:

### 4a. Branch

```bash
git checkout -b TICKET/SLICE PREV_BRANCH
```

### 4b. Implement this slice only

Layer boundaries:

| Slice prefix | Files in scope |
|---|---|
| `db` | `db/migrations/` only |
| `endpoint*` | `transport/`, `endpoint/`, `viewmodel/` only |
| `service*` | `service/` only |
| `repo*` | `repo/` only |

For any dependency that belongs to a later slice → write a **stub** (see below). No real logic for later layers.

### 4c. Build gate

```bash
go build ./...
```

Fix only compilation errors (types, imports, stub signatures). Never implement real logic. Re-run until green.

### 4d. Commit

```bash
git add <slice-specific files>
git commit -m "[TICKET] slice-name: concise description"
```

Examples:
- `[SATU-999] db: add review_count to catalog_products`
- `[SATU-999] endpoint-list: GET /catalog/:id/reviews (service stub)`
- `[SATU-999] service: aggregate review counts (repo stub)`
- `[SATU-999] repo: GetReviewCountByCatalogID`

### 4e. Advance

`PREV_BRANCH = TICKET/SLICE`. Continue to next slice.

## Step 5 — Print the stack summary

```
Stacked MR plan for [TICKET]:

  MR 1: TICKET/db              → main                     [create first]
  MR 2: TICKET/endpoint-list   → TICKET/db                [after MR 1 merges]
  MR 3: TICKET/endpoint-detail → TICKET/endpoint-list     [after MR 2 merges]
  MR 4: TICKET/service         → TICKET/endpoint-detail   [after MR 3 merges]
  MR 5: TICKET/repo            → TICKET/service           [after MR 4 merges]

Merge order: sequential. main stays stable throughout.
```

For each MR provide:
```
## What
<one sentence>

## Part
Slice N of M for [TICKET]. Stacks on: `PREV_BRANCH`.
Next: `TICKET/NEXT_SLICE` (if any).

## Review focus
<what the reviewer should focus on>

## Verification
`go build ./...` passes on this branch.
```

---

## Stub Conventions

Stubs keep the build green on layers that depend on not-yet-implemented downstream code.

### Service stub
```go
func (s *service) HandleFeature(ctx context.Context, param request.Payload) (output interface{}, err error) {
    return output, fmt.Errorf("not implemented") // TODO [TICKET]: implement HandleFeature
}
```

### Repo stub
```go
func (r *repository) GetSomething(ctx context.Context, id int64) (model.Something, error) {
    return model.Something{}, fmt.Errorf("not implemented") // TODO [TICKET]: implement GetSomething
}
```

### Rules
- Return the correct number and types of values
- Use `fmt.Errorf("not implemented")` — NOT `kitConstant.ErrInternal`
- Never `panic("not implemented")`
- Every stub: `// TODO [TICKET]: implement <what>`
- When implementing the real slice in a later MR, delete all stubs from upstream MRs

---

## Edge Cases

**Single layer** — one branch, one MR targeting BASE.

**No db layer** — first MR is the earliest needed layer, targeting BASE.

**Already on a non-main branch** — stack on top if user confirms. First MR targets that branch.

**Build fails** — fix types/imports only. Never implement logic to unblock a build on the wrong layer.

**User adjusts stack mid-plan** — update `STACK` before touching git. Never reorder after git operations start.
