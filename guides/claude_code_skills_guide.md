# Guide 3 of 7: Skills

> ⚠️ Prerequisites: Complete Guide 1 (Setup) and Guide 2 (CLAUDE.md & Project Memory) before proceeding.

---

## 1. What Are Skills?

Skills are reusable prompt templates stored as markdown files — saved workflows you invoke with a short command (e.g., `/explain-code`) instead of typing long instructions every session.

They're context-aware (reads your `CLAUDE.md` and working directory), version-controlled, and can call tools, run shell commands, and chain actions — mini-workflows, not just text templates.

Two levels:
- **Global** (`~/.claude/skills/`) — available in every project
- **Project-level** (`.agents/skills/<skill-name>/SKILL.md`) — repo-specific, in its own directory

*[Anthropic Skills Documentation](https://docs.anthropic.com/en/docs/claude-code/skills)*

---

## 2. Why Skills Before MCP?

Skills come first because:
- **Zero infrastructure** — markdown files, no API keys, no OAuth, no network deps
- **Zero complexity** — MCP adds auth, network deps, extra token overhead. Skills have none of that.
- **Mental model** — writing a skill forces you to articulate a workflow clearly. Same clarity makes MCP effective later.
- **High ROI** — 80% of the productivity gain at 0% of the setup complexity
- **Composability** — once MCP is live (Guide 4), skills orchestrate MCP tools as part of their workflow

---

## 3. TipTip's Skills Repository

Canonical source: [https://gitlab.com/tiptiptv/common/aiad-claude](https://gitlab.com/tiptiptv/common/aiad-claude)

- Pre-tailored for TipTip's stack and conventions
- Some third-party skills (superpowers) require manual setup — called out in Section 5
- **No private forks** — if a skill needs improvement, open an MR to `aiad-claude`

**Install:**
```bash
git clone git@gitlab.com:tiptiptv/common/aiad-claude.git /tmp/aiad-claude
mkdir -p .agents/skills
cp -R /tmp/aiad-claude/.agents/skills/* .agents/skills/
```

---

## 4. How Skills Are Invoked

Invoking a skill in a Claude Code session is straightforward:

- **Invocation syntax:** Use the slash command defined in the skill's frontmatter (e.g., `/tdd`).
- **Discovery:** AI assistants automatically discover skills in `.agents/skills/` (project-level). Claude Code also checks `~/.claude/skills/` for global skills. You can see available skills dynamically, or ask your assistant "What skills are available?"
- **Passing parameters:** You can pass arguments directly. For example: `/explain-code src/auth/login.ts` passes the file path as context.
- **Interaction with CLAUDE.md:** When the skill runs, Claude blends the skill’s instructions with the rules defined in your project's `CLAUDE.md`.
- **End-to-End Example:** 
  You finish making a change to a Go service. You type: `/pr-description`. Claude uses the `pr-description` skill to look at your `git diff`, reads TipTip's PR requirements from `CLAUDE.md`, and generates a formatted PR description ready to be pasted into GitLab.

---

## 5. Choosing the Right Skill

- **Prefer CLI-backed skills** — CLI returns structured output, fewer tokens, more reliable
- **Match scope** — don't invoke full code-review to check one function
- **Project-level overrides global** — check for repo-specific skills first
- **Repeated prompting = skill gap** — if you type the same instructions twice, create a skill
- **Don't stack heavy skills** in one session — context bloat degrades output. Split sessions.

---

## 6. Engineering-Wide Skills (All Engineers)

These skills apply regardless of our stack. Every TipTip engineer should have these installed and use them as their default workflows.

### Must-Have Skills (Engineering-Wide)

| Skill                  | Source                   | Description                                                                                                                                                              | When to use                                                              | Sample Invocation                       | VS Code Install & Repo                                                                                                                               |
| ---------------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------ | --------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `pr-description`       | `aiad-claude`            | Generates structured PR descriptions from diff + CLAUDE.md context, adhering to TipTip's PR format expectations.                                                         | Before pushing a branch to GitLab for review.                            | `/pr-description`                       | Copy from `aiad-claude` repo. [Link](https://gitlab.com/tiptiptv/common/aiad-claude)                                                                 |
| `code-review`          | `everything-claude-code` | Comprehensive code review for security, code quality, React/Next.js patterns, and Node.js/Go backend patterns. Flags issues by severity, suggests fixes.                 | After finishing a major feature, before requesting peer review.          | `/everything-claude-code:code-review`   | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `rfc-review`           | `aiad-claude`            | Reviews Engineering Spec / RFC documents using the Atlassian Confluence MCP. Flags architectural risks or convention violations.                                         | When drafting or reading an RFC in Confluence before finalizing it.      | `/rfc-review`                           | Copy from `aiad-claude` repo. (Requires MCP) [Link](https://gitlab.com/tiptiptv/common/aiad-claude)                                                  |
| `tdd`                  | `everything-claude-code` | Full TDD workflow (RED→GREEN→REFACTOR) for Go, TypeScript/JavaScript, and React/Next.js. Generates unit, integration, and component tests following project conventions. | When implementing new features or adding test coverage to existing code. | `/everything-claude-code:tdd`           | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `test-coverage`        | `everything-claude-code` | Multi-language coverage analysis and gap-filling (Go, Jest, Vitest, pytest). Identifies under-covered files and generates missing tests to reach 80%+.                   | When verifying or improving test coverage after feature work.            | `/everything-claude-code:test-coverage` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `build-fix`            | `everything-claude-code` | Multi-language build error diagnosis and fixing (Go, TypeScript/JavaScript, Python, Rust, Java). Incrementally fixes compilation errors with minimal, surgical changes.  | When encountering build failures, type errors, or compilation crashes.   | `/everything-claude-code:build-fix`     | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `git-commit`           | `aiad-claude`            | Generates Conventional Commits messages from staged diff. Analyzes changes, categorizes by type/scope, and produces spec-compliant commit messages.                      | When committing staged changes to Git.                                   | `/git-commit`                           | Copy from `aiad-claude` repo. [Link](https://gitlab.com/tiptiptv/common/aiad-claude)                                                                 |
| `systematic-debugging` | `superpowers`            | 4-phase root cause process including root-cause-tracing, defense-in-depth, condition-based-waiting techniques.                                                           | When deep-diving into complex, hard-to-reproduce bugs across services.   | `/systematic-debugging`                 | Run: `/plugin install superpowers@claude-plugins-official` in VS Code terminal. [Link](https://github.com/obra/superpowers)                          |

### Nice-to-Have Skills (Engineering-Wide)

| Skill                         | Source                   | Description                                                                | When to use                                         | Sample Invocation                     | VS Code Install & Repo                                                                                                                      |
| ----------------------------- | ------------------------ | -------------------------------------------------------------------------- | --------------------------------------------------- | ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `brainstorming`               | `superpowers`            | Socratic design refinement to talk through architectural options.          | When picking between implementations before coding. | `/brainstorming`                      | Run: `/plugin install superpowers@claude-plugins-official` in VS Code. [Link](https://github.com/obra/superpowers)                          |
| `writing-plans`               | `superpowers`            | Compiles detailed, step-by-step implementation plans.                      | Before starting a large, multi-day feature.         | `/writing-plans`                      | Run: `/plugin install superpowers@claude-plugins-official` in VS Code. [Link](https://github.com/obra/superpowers)                          |
| `subagent-driven-development` | `superpowers`            | Fast iteration with two-stage review (spec compliance, then code quality). | When attempting rapid complex refactors.            | `/subagent-driven-development`        | Run: `/plugin install superpowers@claude-plugins-official` in VS Code. [Link](https://github.com/obra/superpowers)                          |
| `plan`                        | `everything-claude-code` | Basic feature implementation planning and task breakdown.                  | Before starting moderate-sized tickets.             | `/everything-claude-code:plan`        | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |
| `update-docs`                 | `everything-claude-code` | Automatically updates documentation based on codebase changes.             | When finishing a feature that changes APIs.         | `/everything-claude-code:update-docs` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |

---

## 7. Backend Skills (Go Stack)

These skills are specifically for engineers working on TipTip's Go backend services.

### Must-Have Skills (Backend)

| Skill            | Source                   | Description                                                                                                                                                        | When to use                                                                          | Sample Invocation                               | VS Code Install & Repo                                                                                                                               |
| ---------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------ | ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `golang-pattern` | `everything-claude-code` | Provides deep knowledge of Go idioms, testing patterns, and best practices. Must-have to ensure all backend services maintain TipTip's consistent Go architecture. | When starting a new Go service or rewriting an unstructured module.                  | `/everything-claude-code:golang-pattern`        | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `go-build`       | `everything-claude-code` | Go build error resolution specialist. Fixes compilation errors, `go vet` issues, and linter warnings with minimal, surgical changes.                               | When `go build ./...` or `go vet ./...` fails.                                       | `/everything-claude-code:go-build`              | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `go-test`        | `everything-claude-code` | Go TDD workflow — table-driven tests, parallel tests, test helpers, benchmarks, and coverage targets.                                                              | When writing or improving Go test coverage.                                          | `/everything-claude-code:go-test`               | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `postgres`       | `planetscale`            | Actionable intelligence on PostgreSQL optimizations, indexing strategies, and schema design.                                                                       | When designing Postgres schemas, writing complex queries, or optimizing performance. | `/postgres "Review query: SELECT * FROM users"` | Run: `npx skills add planetscale/database-skills` in VS Code terminal. [Link](https://database-skills.preview.planetscale.com/)                      |
| `go-review`      | `everything-claude-code` | Automated code review and formatting enforcement for Go files.                                                                                                     | When finalizing Go code before committing.                                           | `/everything-claude-code:go-review src/main.go` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |

### Nice-to-Have Skills (Backend)

| Skill                 | Source                   | Description                                                                                | When to use                                                  | Sample Invocation                                                             | VS Code Install & Repo                                                                                                                      |
| --------------------- | ------------------------ | ------------------------------------------------------------------------------------------ | ------------------------------------------------------------ | ----------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `api-design`          | `everything-claude-code` | Assists with REST API design, pagination, and error responses according to best practices. | When drafting a new API route before writing implementation. | `/everything-claude-code:api-design "Create endpoint for user profile"`       | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |
| `deployment-patterns` | `everything-claude-code` | Helps with CI/CD, Docker, health checks, and rollbacks.                                    | When updating service deployment configurations.             | `/everything-claude-code:deployment-patterns "Add healthcheck to Dockerfile"` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |

---

## 8. Frontend Skills (React / Next.js Stack)

These skills are relevant for engineers working on TipTip's React, Next.js, and SatuSatu codebases.

### Must-Have Skills (Frontend)

| Skill                         | Source | Description                                                                                                                                    | When to use                                                                    | Sample Invocation              | VS Code Install & Repo                                                                                                    |
| ----------------------------- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| `next-best-practices`         | Vercel | Vercel's official Next.js best practices injected directly into Claude. Critically important for App Router transitions and optimized caching. | When building Next.js pages, layouts, and data fetching correctly.             | `/next-best-practices`         | Run: `npx skills add vercel-labs/next-skills` in VS Code terminal. [Link](https://vercel.com/docs/agent-resources/skills) |
| `vercel-react-best-practices` | Vercel | Official Vercel constraints for high-performance React composition.                                                                            | When lifting state, splitting client/server boundaries, or optimizing renders. | `/vercel-react-best-practices` | Run: `npx skills add vercel-labs/next-skills` in VS Code terminal. [Link](https://vercel.com/docs/agent-resources/skills) |

### Nice-to-Have Skills (Frontend)

| Skill                   | Source                   | Description                                                    | When to use                                                  | Sample Invocation                                | VS Code Install & Repo                                                                                                                      |
| ----------------------- | ------------------------ | -------------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `web-design-guidelines` | Vercel                   | Advice on building accessible, performant user interfaces.     | When setting up a new layout or responsive design structure. | `/web-design-guidelines`                         | Run: `npx skills add vercel-labs/next-skills` in VS Code. [Link](https://vercel.com/docs/agent-resources/skills)                            |
| `e2e`                   | `everything-claude-code` | Playwright E2E test generation and Page Object Model patterns. | When writing UI automation tests.                            | `/everything-claude-code:e2e "Write login test"` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |

---

## 9. Skills and LLM Cost

### How cost works

- Every skill invocation adds content to the context window (on top of conversation + `CLAUDE.md`)
- Large skills (500+ lines) compound cost — that content is re-sent with every subsequent message
- Skills triggering multiple tool calls (file reads, shell execs) multiply cost further
- Well-structured skills direct lightweight steps to `ANTHROPIC_SMALL_FAST_MODEL`

### Do this

- Keep skills focused — one thing done well costs less than three things attempted
- Use project-level skills for repo-specific tasks (they assume `CLAUDE.md` context, so they stay concise)
- Invoke skills at session start, not mid-session (clean context = cheaper + better output)
- Use CLI-backed skills where possible — structured output, fewer tokens
- Use GLM-4.7 Flash ($0.06/1M input) for background tasks: mass file reading, linting, repetitive generation

### Don't do this

- Don't invoke heavy skills for simple questions — just ask directly
- Don't chain `pr-description` → `code-review` → `tdd` in one session — context bloat. Separate sessions.
- Don't repeat `CLAUDE.md` content inside skills — reference it instead
- Don't use flagship models for boilerplate output — use the small fast model
- Don't let skills go stale — outdated skills produce wrong output confidently

---

## 10. What to Expect from Engineers

### Engineering Lead Responsibilities

- **Own the canonical skills repository** at `aiad-claude`. Leads are responsible for the quality and accuracy of skills in their domain (backend lead owns Go skills, frontend lead owns Next.js skills).
- **Ensure project-level skills hit the mark.** Active repositories must have project-level skills installed that are tailored to the repo's domain, not just copied verbatim from global.
- **Review skill changes via MR.** Changes to canonical skills affect every engineer using them. Leads should review skill MRs with the same scrutiny as code changes.
- **Schedule skill reviews.** Skills should be reviewed every quarter or after a major architectural change (e.g., migrating from REST to gRPC, adopting a new state management library). Stale skills produce stale output.
- **Encourage skill suggestions from the team.** Engineers doing repetitive prompting are identifying skill gaps. Leads should create a lightweight process for engineers to propose new skills (e.g., a `#claude-code` Slack channel or a GitLab issue template on `aiad-claude`).

### Individual Engineer Responsibilities

- **Use skills as the default workflow** for covered tasks. Do not manually re-prompt for `pr-description`, `code-review`, or `tdd` when the skill exists. Consistent use is what makes skills improve over time.
- **Report when a skill produces wrong or suboptimal output.** Do not just fix it locally and move on — open an issue or MR on `aiad-claude` so the fix reaches everyone.
- **Do not create private skills that duplicate canonical ones.** If a canonical skill does not fit your repo, the fix is to improve the canonical skill or add a project-level override, not to maintain a private fork.
- **Suggest new skills.** If you find yourself typing the same multi-step prompt more than twice, that is a skill candidate. Document the prompt and propose it via the agreed channel.
- **Understand what each skill does before invoking it.** Skills can run commands, edit files, and make multiple API calls. Know what a skill does before running it on production-adjacent code.
- **Update placeholders before executing:** When invoking a newly created scaffolded skill from the repository, ensure you have updated the `<!-- TODO: Implement TipTip specific instructions for this skill -->` placeholder with actual instructions before executing it.

### The Improvement Loop

Invoke skill → output misses a TipTip pattern → identify the gap → open MR on `aiad-claude` with the fix → lead merges → everyone benefits.

*This is how the skill set matures. Expected and normal.*

### Skills vs Commands
**Skills vs Commands** — Skills (`~/.claude/skills/`) are broader workflow definitions, while Commands (`~/.claude/commands/`) are quick executable prompts invoked via `/slash`. Skills and commands can be **chained together** in a single prompt for multi-step workflows (e.g., `/refactor-clean` followed by `/tdd`).

### Plugins
**Plugins** extend Claude Code with bundled tools, skills, and MCPs. **LSP Plugins** are particularly useful if you run Claude Code outside editors — they give Claude real-time type checking, go-to-definition, and intelligent completions without an IDE. Strongly suggested plugins to install/enable depending on your team:
>
> | Plugin | Description |
> |---|---|
> | `typescript-lsp@claude-plugins-official` | TypeScript intelligence |
> | `pyright-lsp@claude-plugins-official` | Python type checking |
> | `hookify@claude-plugins-official` | Create hooks conversationally |
> | `mgrep@Mixedbread-Grep` | Better search than ripgrep |

---

## 11. Quick Reference

| Task                                   | Skill                         | Scope            | Source                   |
| -------------------------------------- | ----------------------------- | ---------------- | ------------------------ |
| Write PR description                   | `pr-description`              | Engineering-wide | `aiad`                   |
| Review code for conventions            | `code-review`                 | Engineering-wide | `everything-claude-code` |
| Review Engineering Spec / RFC          | `rfc-review`                  | Engineering-wide | `aiad`                   |
| Generate tests (TDD workflow)          | `tdd`                         | Engineering-wide | `everything-claude-code` |
| Test coverage analysis & gap-filling   | `test-coverage`               | Engineering-wide | `everything-claude-code` |
| Build error diagnosis & fixing         | `build-fix`                   | Engineering-wide | `everything-claude-code` |
| Generate commit message                | `git-commit`                  | Engineering-wide | `aiad`                   |
| Systematic trace & root cause analysis | `systematic-debugging`        | Engineering-wide | `superpowers`            |
| Basic feature planning                 | `plan`                        | Engineering-wide | `everything-claude-code` |
| Update documentation                   | `update-docs`                 | Engineering-wide | `everything-claude-code` |
| Go idiomatic patterns                  | `golang-pattern`              | Backend          | `everything-claude-code` |
| Go build error fixing                  | `go-build`                    | Backend          | `everything-claude-code` |
| Go TDD & testing patterns              | `go-test`, `golang-testing`   | Backend          | `everything-claude-code` |
| Postgres optimizations & schema design | `postgres`                    | Backend          | `planetscale`            |
| Go automated code review               | `go-review`                   | Backend          | `everything-claude-code` |
| Next.js architecture best practices    | `next-best-practices`         | Frontend         | `Vercel`                 |
| React composition performance rules    | `vercel-react-best-practices` | Frontend         | `Vercel`                 |

**Reference Sources:**
- TipTip AIAD - CLAUDE.md/Skills Repository: [https://gitlab.com/tiptiptv/common/aiad-claude](https://gitlab.com/tiptiptv/common/aiad-claude)
- Superpowers source: [https://github.com/obra/superpowers](https://github.com/obra/superpowers)
- everything-claude-code source: [https://github.com/affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)
- PlanetScale Database Skills: [https://database-skills.preview.planetscale.com/](https://database-skills.preview.planetscale.com/)
- Vercel skills source: [https://vercel.com/docs/agent-resources/skills](https://vercel.com/docs/agent-resources/skills)
