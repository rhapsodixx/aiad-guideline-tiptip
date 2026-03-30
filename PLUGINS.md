# Required Plugins & External Skills

This file lists the third-party plugins and external skills that complement TipTip's canonical skills in `aiad-claude`. These are maintained by external authors — do not copy them into this repository. Install them per-engineer following the commands below.

> **Why not bundle these?** Third-party plugins receive upstream updates (bug fixes, new features) that we'd lose if we vendored them. This manifest pins what to install; the authors maintain the code.

---

## Engineering-Wide Plugins

Every TipTip engineer should install these regardless of stack.

### superpowers (claude-plugins-official)

Process-oriented skills for planning, debugging, and development workflow discipline.

```bash
/plugin install superpowers@claude-plugins-official
```

**Skills provided:**

| Skill | Classification | Description |
|-------|---------------|-------------|
| `systematic-debugging` | Must-Have | 4-phase root cause analysis with hypothesis-verify loops |
| `test-driven-development` | Must-Have | RED→GREEN→REFACTOR TDD workflow |
| `brainstorming` | Nice-to-Have | Socratic design refinement before coding |
| `writing-plans` | Nice-to-Have | Step-by-step implementation plans for multi-day features |
| `executing-plans` | Nice-to-Have | Execute plans with review checkpoints |
| `subagent-driven-development` | Nice-to-Have | Two-stage review (spec compliance + code quality) |
| `dispatching-parallel-agents` | Nice-to-Have | Parallelize independent tasks |
| `using-git-worktrees` | Nice-to-Have | Isolated feature work in worktrees |
| `finishing-a-development-branch` | Nice-to-Have | Merge/PR/cleanup decision guidance |
| `requesting-code-review` | Nice-to-Have | Request review before merge |
| `receiving-code-review` | Nice-to-Have | Process review feedback rigorously |
| `verification-before-completion` | Nice-to-Have | Verify before claiming work is done |
| `writing-skills` | Nice-to-Have | Create and edit skills |

---

### commit-commands (claude-plugins-official)

Git workflow shortcuts for commit, push, and PR creation.

```bash
/plugin install commit-commands@claude-plugins-official
```

**Commands provided:**

| Command | Description |
|---------|-------------|
| `commit` | Create a git commit |
| `commit-push-pr` | Commit, push, and open a PR |
| `clean_gone` | Clean up local branches deleted on remote |

---

### everything-claude-code

Multi-language development skills covering TDD, build fixes, test coverage, and language-specific patterns.

```bash
/plugin install everything-claude-code@everything-claude-code
```

**Skills used by TipTip (engineering-wide):**

| Skill | Classification | Description |
|-------|---------------|-------------|
| `tdd` | Must-Have | Full TDD workflow for Go, TypeScript, React |
| `test-coverage` | Must-Have | Coverage analysis and gap-filling |
| `build-fix` | Must-Have | Multi-language build error diagnosis |
| `plan` | Nice-to-Have | Feature implementation planning |
| `update-docs` | Nice-to-Have | Auto-update documentation from code changes |

---

## Backend Plugins (Go Stack)

Install these if you work on TipTip's Go backend services.

### everything-claude-code (backend skills)

Already installed above. These are the backend-specific skills from the same plugin:

| Skill | Classification | Description |
|-------|---------------|-------------|
| `golang-pattern` | Must-Have | Go idioms, testing patterns, architecture best practices |
| `go-build` | Must-Have | Go build error resolution |
| `go-test` | Must-Have | Go TDD — table-driven, parallel, benchmarks |
| `go-review` | Nice-to-Have | Automated lint-style code review for Go |
| `api-design` | Nice-to-Have | REST API design, pagination, error responses |
| `deployment-patterns` | Nice-to-Have | CI/CD, Docker, health checks |

### PlanetScale Database Skills

PostgreSQL query optimization, indexing strategies, and schema design.

```bash
npx skills add planetscale/database-skills
```

| Skill | Classification | Description |
|-------|---------------|-------------|
| `postgres` | Must-Have | PostgreSQL optimization and schema review |

---

## Frontend Web Plugins (Next.js / React Stack)

Install these if you work on TipTip's React/Next.js codebases.

### Vercel Next.js Skills

Official Vercel best practices for Next.js and React.

```bash
npx skills add vercel-labs/next-skills
```

| Skill | Classification | Description |
|-------|---------------|-------------|
| `next-best-practices` | Must-Have | App Router, caching, data fetching patterns |
| `vercel-react-best-practices` | Must-Have | High-performance React composition rules |
| `web-design-guidelines` | Nice-to-Have | Accessible, performant UI advice |

### frontend-design (claude-plugins-official)

Production-grade UI code generation with high design quality.

```bash
/plugin install frontend-design@claude-plugins-official
```

| Skill | Classification | Description |
|-------|---------------|-------------|
| `frontend-design` | Nice-to-Have | Distinctive, polished frontend interface code |

### ui-ux-pro-max

UI/UX design intelligence with styles, palettes, font pairings, and UX guidelines.

```bash
/plugin install ui-ux-pro-max@ui-ux-pro-max-skill
```

| Skill | Classification | Description |
|-------|---------------|-------------|
| `ui-ux-pro-max` | Nice-to-Have | 50+ styles, 161 palettes, 57 font pairings, UX guidelines |

### everything-claude-code (frontend skills)

Already installed above. Frontend-specific skill:

| Skill | Classification | Description |
|-------|---------------|-------------|
| `e2e` | Nice-to-Have | Playwright E2E test generation with Page Object Model |

---

## Frontend Mobile Plugins (Flutter Stack)

Install these if you work on TipTip's Flutter mobile applications.

> **Note:** The Flutter ecosystem has fewer Claude Code plugins than web/Go. The primary review skill (`code-review-flutter`) is maintained in aiad-claude's `.agents/skills/frontend-mobile/` directory. This section will be updated as Flutter-specific plugins mature.

### everything-claude-code (Flutter skills)

Already installed above. If Flutter-specific skills become available in this plugin, they will be listed here.

---

## LSP Plugins (Optional, Recommended)

These provide real-time type checking and intelligent completions when running Claude Code outside an IDE.

| Plugin | Install Command | Use Case |
|--------|----------------|----------|
| `typescript-lsp` | `/plugin install typescript-lsp@claude-plugins-official` | TypeScript intelligence for frontend work |
| `pyright-lsp` | `/plugin install pyright-lsp@claude-plugins-official` | Python type checking (if applicable) |
| `hookify` | `/plugin install hookify@claude-plugins-official` | Create hooks conversationally via `/hookify` |
| `mgrep` | `/plugin install mgrep@Mixedbread-Grep` | Better search than ripgrep |

---

## Quick Install by Role

### All Engineers (run once)
```bash
/plugin install superpowers@claude-plugins-official
/plugin install commit-commands@claude-plugins-official
/plugin install everything-claude-code@everything-claude-code
```

### Backend Engineers (additionally)
```bash
npx skills add planetscale/database-skills
```

### Frontend Web Engineers (additionally)
```bash
npx skills add vercel-labs/next-skills
/plugin install frontend-design@claude-plugins-official
```

### Frontend Mobile Engineers
No additional plugin installs required beyond the engineering-wide set. The `code-review-flutter` skill is provided by aiad-claude directly.

---

## Maintenance

- **Review quarterly** — check for new plugin versions and deprecated skills.
- **Do not vendor** — plugins stay external. Only aiad-claude skills are version-controlled here.
- **Report issues** — if a plugin breaks or produces wrong output, report in `#aiad-discussion` and open an issue on the plugin's upstream repository.
