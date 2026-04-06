# /checkout-commit

> **Scope:** Use for single-layer tickets, hotfixes, and config-only changes.
> For multi-layer tickets (2+ of: db, endpoint, service, repo) — use the `stack-mrs` skill instead.

Prepare a clean branch before executing a JIRA-ticket plan, then commit the result.

**Usage:** `/checkout-commit <TICKET-CODE> <short-branch-summary>`

**Example:** `/checkout-commit SATU-873 remove-catalog-image`

---

## Instructions

### Step 1 — Check current branch

Run `git branch --show-current` to get the current branch.

- If it is **not** `main`, check whether the plan depends on changes already on this branch.
  - If yes: skip Steps 2–3, notify the user ("Current branch is `<branch>` — staying here because the plan depends on in-progress changes."), then jump to Step 4.
  - If no: proceed to Step 2.

### Step 2 — Update main

```bash
git checkout main
git pull
```

If either command fails, stop and report the error to the user before proceeding.

### Step 3 — Create feature branch

Branch name format: `$TICKET_CODE/$SHORT_SUMMARY` (both from `$ARGUMENTS`, space-separated).

```bash
git checkout -b <TICKET-CODE>/<short-summary>
```

Confirm the new branch name to the user.

### Step 4 — Execute the plan

Carry out the implementation described in the current plan or the user's instructions.

### Step 5 — Commit

After implementation is complete and `go build ./...` passes:

```bash
git add <relevant files>
git commit -m "[TICKET-CODE] short but clear summary of what was done"
```

Commit message format: `[TICKET-CODE] <concise imperative description>` — e.g. `[SATU-873] remove catalog_image_url from catalog review list API response`.

Report the commit hash to the user when done.
