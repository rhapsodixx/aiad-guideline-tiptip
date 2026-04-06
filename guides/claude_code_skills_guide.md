# Guide 3 of 7: Skills

> ⚠️ Prerequisites: Complete Guide 1 (Setup) and Guide 2 (CLAUDE.md & Project Memory) before proceeding.

---

## 1. What Are Skills?

Skills are reusable prompt templates stored as markdown files — saved workflows you invoke with a short command (e.g., `/explain-code`) instead of typing long instructions every session.

They're context-aware (reads your `CLAUDE.md` and working directory), version-controlled, and can call tools, run shell commands, and chain actions — mini-workflows, not just text templates.

Two levels:
- **Global** (`~/.claude/skills/`) — available in every project (personal skills only)asda
- **Project-level** (`.agents/skills/<team>/<skill-name>/SKILL.md`) — repo-specific, organized by team, in its own directory

*For more details, see the [Anthropic Skills Documentation](https://docs.anthropic.com/en/docs/claude-code/skills).*

---

## 2. Skills vs Commands

While both Skills and Commands are invoked via the `/slash` syntax, they serve fundamentally different purposes in the AI-Assisted Development workflow:

| Feature | Skills | Commands |
| :--- | :--- | :--- |
| **Definition** | Version-controlled workflow definitions (markdown files). | Quick, single-action CLI execution shortcuts. |
| **Location** | `.agents/skills/` (Project) or `~/.claude/skills/` (Global) | Hardcoded or defined via `~/.claude/commands/`. |
| **Complexity** | High. Defines deep agent context, rules, and multi-step logic. | Low. Usually maps to a single executing shell command. |
| **Persistence** | Persistent, tailored, and robust to TipTip conventions. | Ad-hoc or brief directives. |
| **Best Used For** | Code reviews, PR descriptions, test generation, complex architectural changes. | One-off bash commands, clearing terminal, simple status checks. |

**Heuristic for Teams:** Use **Skills** for recurring development tasks where the AI needs to follow specific rules (e.g., "Code Review"). Use **Commands** when you need a quick shell shortcut to compile, run tests, or manage files directly without agentic thinking.

**Pro Tip:** Skills and commands can be **chained together** in a single prompt for multi-step workflows (e.g., `/refactor-clean` followed by `/tdd`).

---

## 3. Why Skills Before MCP?

Skills come first because:
- **Zero infrastructure** — markdown files, no API keys, no OAuth, no network deps
- **Zero complexity** — MCP adds auth, network deps, extra token overhead. Skills have none of that.
- **Mental model** — writing a skill forces you to articulate a workflow clearly. Same clarity makes MCP effective later.
- **High ROI** — 80% of the productivity gain at 0% of the setup complexity
- **Composability** — once MCP is live (Guide 4), skills orchestrate MCP tools as part of their workflow

---

## 4. TipTip's Skills Repository

All TipTip-authored skills are available at our central repository:
[https://gitlab.com/tiptiptv/common/aiad-claude](https://gitlab.com/tiptiptv/common/aiad-claude)

- **The Canonical Set:** Engineers should clone or pull this repository to get the canonical TipTip skill set.
- **Tailored for TipTip:** Skills from this repository are pre-tailored for TipTip's stack and conventions — they reference TipTip's `CLAUDE.md` conventions and produce TipTip-flavored output.
- **Two sources of skills:** TipTip-authored skills live in `aiad-claude`. Third-party plugins (superpowers, everything-claude-code, Vercel, PlanetScale) are installed separately — see [`PLUGINS.md`](../PLUGINS.md) for the full manifest and install commands.
- **No private forks:** Engineers should **NOT** create private local copies of skills that diverge from the canonical repository. If a skill needs improvement, open a merge request to `aiad-claude` so the whole team benefits.

### Directory Structure

Skills in `aiad-claude` are organized by team/stack:

```
.agents/skills/
├── engineering-wide/        ← Every engineer, every stack
│   ├── git-commit/
│   ├── pr-description/
│   ├── prd-review/
│   ├── rfc-review/
│   ├── refine-prompt/
│   ├── refine-prompt-gravity/
│   └── system-design/
│
├── backend/                 ← Go stack engineers
│   └── code-review-golang/
│
├── frontend-web/            ← Next.js / React engineers
│   └── code-review-nextjs/
│
├── frontend-mobile/         ← Flutter engineers
│   └── code-review-flutter/
│
└── qa-automation/           ← QA Automation engineers (Playwright/Cucumber)
    ├── shift-left-manual-test/
    ├── automation-script-generation/
    └── automation-script-validation/
```

**Why organize by team?** Engineers think "I'm a backend dev" not "I need an aiad-claude skill." Grouping by team makes discoverability instant and ownership clear (backend lead owns `backend/`, frontend lead owns `frontend-web/` and `frontend-mobile/`, QA lead owns `qa-automation/`).

### Installation

To install project-level skills from the repository, clone it and copy the skills for your stack:

```bash
git clone git@gitlab.com:tiptiptv/common/aiad-claude.git /tmp/aiad-claude

# Copy all skills (recommended — full set)
mkdir -p .agents/skills
cp -R /tmp/aiad-claude/.agents/skills/* .agents/skills/

# Or copy only your team's skills + engineering-wide
cp -R /tmp/aiad-claude/.agents/skills/engineering-wide .agents/skills/
cp -R /tmp/aiad-claude/.agents/skills/backend .agents/skills/       # for Go repos
# OR
cp -R /tmp/aiad-claude/.agents/skills/frontend-web .agents/skills/  # for Next.js repos
# OR
cp -R /tmp/aiad-claude/.agents/skills/frontend-mobile .agents/skills/ # for Flutter repos
```

> **Global `~/.claude/skills/` usage:** Reserve this for personal skills that are not shared with the team. All team-shared skills belong in `aiad-claude` and are installed at the project level. Do not duplicate aiad-claude skills into your global directory — this causes drift.

---

## 5. How Skills Are Invoked

Invoking a skill in a Claude Code session is straightforward:

- **Invocation syntax:** Use the slash command defined in the skill's frontmatter (e.g., `/tdd`).
- **Discovery:** AI assistants automatically discover skills in `.agents/skills/` and its subdirectories (project-level). The team directory structure (`engineering-wide/`, `backend/`, etc.) is transparent to Claude — skills are discovered regardless of nesting depth. Claude Code also checks `~/.claude/skills/` for global skills. You can see available skills dynamically, or ask your assistant "What skills are available?"
- **Passing parameters:** You can pass arguments directly. For example: `/explain-code src/auth/login.ts` passes the file path as context.
- **Interaction with CLAUDE.md:** When the skill runs, Claude blends the skill’s instructions with the rules defined in your project's `CLAUDE.md`.
- **End-to-End Example:** 
  You finish making a change to a Go service. You type: `/pr-description`. Claude uses the `pr-description` skill to look at your `git diff`, reads TipTip's PR requirements from `CLAUDE.md`, and generates a formatted PR description ready to be pasted into GitLab.

---

## 6. How to Choose the Right Skill

Choose the right skill with this decision framework:

- **Prefer CLI-backed skills** — CLI returns structured output, fewer tokens, more reliable
- **Match scope** — don't invoke a full review skill to check one function
- **Project-level overrides global** — check for repo-specific skills first
- **Repeated prompting = skill gap** — if you type the same instructions twice, create a skill
- **Don't stack heavy skills** in one session — context bloat degrades output. Split sessions.

---

## 7. Disabling Skills at Workspace Level

There are scenarios where a skill installed globally or at the project level should not be active in a specific workspace. Claude Code provides two mechanisms to suppress skill discovery.

### Mechanism 1: `.claudeignore`

Add the skill's path to a `.claudeignore` file in the repository root. Claude Code respects `.claudeignore` the same way Git respects `.gitignore` — files matching these patterns are excluded from Claude's context and discovery.

**Example `.claudeignore` entries:**
```
# Suppress a specific skill in this repo
.agents/skills/engineering-wide/rfc-review/

# Suppress an entire team's skills in a repo where they don't apply
.agents/skills/backend/

# Suppress a global personal skill from activating here
# (global skills are not in .agents/, but you can exclude files Claude reads)
```

### Mechanism 2: Selective Installation

The most reliable approach for team-shared skills is to only install what the repo needs. Rather than copying the full `aiad-claude` skill set, copy only the relevant subdirectories during setup (see Section 3 — Installation). A skill that was never installed cannot be accidentally invoked.

### When to Use These Tips

| Scenario | Recommended Action |
|---|---|
| A global personal skill (`~/.claude/skills/`) conflicts with a workspace skill of the same name | Use `.claudeignore` to suppress the personal skill's effect, or rename to avoid the collision |
| A repo has both backend and frontend code, but a specific branch workspace is frontend-only | Add backend skill paths to `.claudeignore` in that branch's worktree |
| A heavy skill (e.g., `rfc-review`) should not auto-suggest in a fast-turnaround hotfix repo | Add it to `.claudeignore` for that repo |
| Running Claude Code in CI/CD automation where interactive skills are not appropriate | Add `.agents/skills/` wholesale to `.claudeignore` in the CI config |
| An outdated skill is in the repo but a fix is pending MR approval | Temporarily suppress it via `.claudeignore` rather than deleting the file |

> 💡 **Note:** Disabling via `.claudeignore` is non-destructive — the skill file remains in the repository for other engineers or branches. Deleting the file removes it for everyone immediately.

---

## 8. Best Practice: User-Level vs. Workspace-Level Skill Setup

Understanding where to install a skill is as important as knowing which skill to use.

### The Two Levels

| Level | Location | Visibility | Version Control |
|---|---|---|---|
| **User-level** | `~/.claude/skills/` | Your machine only, all projects | No — lives outside any repo |
| **Workspace-level** | `.agents/skills/` in repo root | Everyone who clones the repo | Yes — committed to Git |

### Decision Rule

> **If a team member would benefit from this skill, it belongs at workspace level. If it only serves you personally, it belongs at user level.**

**Use user-level (`~/.claude/skills/`) when:**
- The skill encodes a personal workflow preference not applicable to teammates (e.g., your own note-taking or scaffolding style)
- The skill contains personal credentials or machine-specific paths
- You are prototyping a skill before proposing it to the team via `aiad-claude`
- The skill is a personal override of a team skill during a transition period (keep this temporary)

**Use workspace-level (`.agents/skills/`) when:**
- The skill codifies a team convention, code review standard, or TipTip workflow
- The skill must be consistent across all engineers to avoid output divergence (e.g., `pr-description`, `git-commit`)
- The skill references repo-specific tooling, file paths, or test patterns
- The skill should be reviewed and improved as a team (via MR to `aiad-claude`)

### The Drift Risk

Installing a team skill at user-level creates a **private fork** — your version drifts as the canonical skill in `aiad-claude` is updated by the team. You silently use a stale version. **Do not duplicate workspace skills into `~/.claude/skills/`.**

### Decision Flowchart

```
Is this skill useful to my teammates?
├── Yes → Does it belong to an existing team category (engineering-wide / backend / frontend-mobile)?
│         ├── Yes → Install at workspace level via aiad-claude. Open MR if it's new.
│         └── No  → Propose new category or extend existing one via MR to aiad-claude.
└── No  → Is it a temporary prototype?
          ├── Yes → Install at user-level. Set a reminder to propose or discard after the sprint.
          └── No  → Install at user-level permanently. Document it in your personal README.
```

> ⚠️ **Reminder:** Skills installed at workspace level are committed to the repository and affect every engineer who pulls the branch. Review them with the same care as code changes.

---

## 9. Engineering-Wide Skills (All Engineers)

These skills apply regardless of our stack. Every TipTip engineer should have these installed and use them as their default workflows.

### Must-Have Skills (Engineering-Wide)

> ⚠️ **On Effort Levels:** Claude Code defaults to `medium` effort. Higher effort levels consume more thinking tokens, which directly increases session usage and cost. Only adjust when needed:
> - **Switch to `high` / `max`:** When Claude is making assumptions, skipping detailed tool results, or failing to solve complex architectural problems.
> - **Switch to `low`:** When you are doing simple tasks (e.g., "add a comment", "rename this variable") and want to save tokens and speed up the response.
>
> The recommendations below are starting points — not mandates. Use your judgment.

| Skill | Source | Description | Recommended Claude Code Effort | When to use | Sample Invocation | VS Code Install & Repo |
|---|---|---|---|---|---|---|
| `pr-description` | `aiad-claude` | Generates structured PR descriptions from diff + CLAUDE.md context, adhering to TipTip's PR format expectations. | `low` — template-fill from diff output | Before pushing a branch to GitLab for review. | `/pr-description` | Copy from `aiad-claude` repo. [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |
| `rfc-review` | `aiad-claude` | Reviews Engineering Spec / RFC documents using the Atlassian MCP. Flags architectural risks or convention violations. | `max` — deep architectural cross-referencing via MCP | When drafting or reading an RFC in Confluence before finalizing it. | `/rfc-review` | Copy from `aiad-claude` repo. (Requires MCP) [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |
| `tdd` | `everything-claude-code` | Full TDD workflow (RED→GREEN→REFACTOR) for Go, TypeScript/JavaScript, and React/Next.js. Generates unit, integration, and component tests following project conventions. | `high` — multi-phase workflow across source + test files | When implementing new features or adding test coverage to existing code. | `/everything-claude-code:tdd` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `test-coverage` | `everything-claude-code` | Multi-language coverage analysis and gap-filling (Go, Jest, Vitest, pytest). Identifies under-covered files and generates missing tests to reach 80%+. | `high` — scans many files, reasons about gaps, generates tests | When verifying or improving test coverage after feature work. | `/everything-claude-code:test-coverage` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `build-fix` | `everything-claude-code` | Multi-language build error diagnosis and fixing (Go, TypeScript/JavaScript, Python, Rust, Java). Incrementally fixes compilation errors with minimal, surgical changes. | `medium` — diagnoses specific errors, applies surgical fixes | When encountering build failures, type errors, or compilation crashes. | `/everything-claude-code:build-fix` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `git-commit` | `aiad-claude` | Generates Conventional Commits messages from staged diff. Analyzes changes, categorizes by type/scope, and produces spec-compliant commit messages. | `low` — single-shot message from staged diff | When committing staged changes to Git. | `/git-commit` | Copy from `aiad-claude` repo. [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |
| `systematic-debugging` | `superpowers` | 4-phase root cause process including root-cause-tracing, defense-in-depth, condition-based-waiting techniques. | `max` — iterative hypothesis-verify loop across services | When deep-diving into complex, hard-to-reproduce bugs across services. | `/systematic-debugging` | Run: `/plugin install superpowers@claude-plugins-official` in VS Code terminal. [Link](https://github.com/obra/superpowers) |
| `code-review-golang` | `aiad-claude` | Orchestrates Go backend code reviews through two specialist sub-agents — a Senior Go Engineer and a Security Engineer — producing a unified, severity-graded review report. | `max` — multi-agent orchestration, security + quality scoring | When reviewing Go code before submitting an MR or during peer review. | `/code-review-golang review internal/handler/user.go` | Copy from `aiad-claude` repo (`backend/`). [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |
| `code-review-nextjs` | `aiad-claude` | Orchestrates Next.js/React/TypeScript code reviews through two specialist sub-agents — a Senior Frontend Engineer and a Security Engineer — producing a unified, severity-graded review report. | `max` — multi-agent orchestration, security + quality scoring | When reviewing Next.js/React/TypeScript code before submitting an MR or during peer review. | `/code-review-nextjs review src/app/dashboard/page.tsx` | Copy from `aiad-claude` repo (`frontend-web/`). [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |
| `code-review-flutter` | `aiad-claude` | Orchestrates Flutter/Dart code reviews through two specialist sub-agents — a Senior Flutter Engineer and a Security Engineer — producing a unified, severity-graded review report with mobile-specific security focus. | `max` — multi-agent orchestration, mobile security + quality scoring | When reviewing Flutter/Dart code before submitting an MR or during peer review. | `/code-review-flutter review lib/features/auth/presentation/login_page.dart` | Copy from `aiad-claude` repo (`frontend-mobile/`). [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |

> 💡 **On `code-review-golang` / `code-review-nextjs` / `code-review-flutter` and existing review skills:** These three skills establish TipTip's **standardized review baseline** — ensuring all engineers apply the same checklist and severity grading. They are **complementary** to specialized tools like `go-review` (everything-claude-code) or Vercel's best-practice skills, not replacements. If your team or engineering lead decides to consolidate on a single code review skill, that's fine — formalize the decision via a pull request to `aiad-claude`.

### Nice-to-Have Skills (Engineering-Wide)

| Skill | Source | Description | Recommended Claude Code Effort | When to use | Sample Invocation | VS Code Install & Repo |
|---|---|---|---|---|---|---|
| `brainstorming` | `superpowers` | Socratic design refinement to talk through architectural options. | `high` — iterative exploration of design trade-offs | When picking between implementations before coding. | `/brainstorming` | Run: `/plugin install superpowers@claude-plugins-official` in VS Code. [Link](https://github.com/obra/superpowers) |
| `writing-plans` | `superpowers` | Compiles detailed, step-by-step implementation plans. | `high` — broad codebase analysis for step-by-step plans | Before starting a large, multi-day feature. | `/writing-plans` | Run: `/plugin install superpowers@claude-plugins-official` in VS Code. [Link](https://github.com/obra/superpowers) |
| `subagent-driven-development` | `superpowers` | Fast iteration with two-stage review (spec compliance, then code quality). | `max` — two-stage multi-agent coordination | When attempting rapid complex refactors. | `/subagent-driven-development` | Run: `/plugin install superpowers@claude-plugins-official` in VS Code. [Link](https://github.com/obra/superpowers) |
| `plan` | `everything-claude-code` | Basic feature implementation planning and task breakdown. | `medium` — scoped feature breakdown, moderate reasoning | Before starting moderate-sized tickets. | `/everything-claude-code:plan` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |
| `update-docs` | `everything-claude-code` | Automatically updates documentation based on codebase changes. | `low` — additive doc updates, single-pass | When finishing a feature that changes APIs. | `/everything-claude-code:update-docs` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |
| `system-design` | `aiad-claude` | Diagnose design problems and guide architecture decisions. State-based diagnostic from requirements clarity to walking skeleton. | `high` — iterative diagnostic with artifacts (ADRs, component maps) | When starting system design after requirements are validated, or when architecture feels uncertain. | `/system-design` | Copy from `aiad-claude` repo (`engineering-wide/`). [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |

> 💡 **Third-party plugins:** The engineering-wide skills above include both aiad-claude skills and third-party plugin skills. For full plugin install commands, see [`PLUGINS.md`](../PLUGINS.md).

---

## 10. Backend Skills (Go Stack)

These skills are specifically for engineers working on TipTip's Go backend services.

### Must-Have Skills (Backend)

| Skill | Source | Description | Recommended Claude Code Effort | When to use | Sample Invocation | VS Code Install & Repo |
|---|---|---|---|---|---|---|
| `golang-pattern` | `everything-claude-code` | Provides deep knowledge of Go idioms, testing patterns, and best practices. Must-have to ensure all backend services maintain TipTip's consistent Go architecture. | `high` — architectural reasoning across service/module | When starting a new Go service or rewriting an unstructured module. | `/everything-claude-code:golang-pattern` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `go-build` | `everything-claude-code` | Go build error resolution specialist. Fixes compilation errors, `go vet` issues, and linter warnings with minimal, surgical changes. | `medium` — surgical fix of specific build errors | When `go build ./...` or `go vet ./...` fails. | `/everything-claude-code:go-build` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `go-test` | `everything-claude-code` | Go TDD workflow — table-driven tests, parallel tests, test helpers, benchmarks, and coverage targets. | `high` — TDD workflow with multi-file test output | When writing or improving Go test coverage. | `/everything-claude-code:go-test` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |
| `postgres` | `planetscale` | Actionable intelligence on PostgreSQL optimizations, indexing strategies, and schema design. | `medium` — scoped query/schema advice, focused analysis | When designing Postgres schemas, writing complex queries, or optimizing performance. | `/postgres "Review query: SELECT * FROM users"` | Run: `npx skills add planetscale/database-skills` in VS Code terminal. [Link](https://database-skills.preview.planetscale.com/) |
| `go-review` | `everything-claude-code` | Automated code review and formatting enforcement for Go files. | `medium` — lint-style review on targeted files | When finalizing Go code before committing. | `/everything-claude-code:go-review src/main.go` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code terminal. [Link](https://github.com/affaan-m/everything-claude-code) |

> 💡 **`code-review-golang` vs `go-review`:** `code-review-golang` (Section 6) provides TipTip's standardized multi-persona review with security scoring. `go-review` from `everything-claude-code` provides automated formatting and quick lint-style feedback. These are complementary — not replacements for each other. If your team decides to standardize on one code review skill, formalize that decision via a pull request to `aiad-claude`.

### Nice-to-Have Skills (Backend)

| Skill | Source | Description | Recommended Claude Code Effort | When to use | Sample Invocation | VS Code Install & Repo |
|---|---|---|---|---|---|---|
| `api-design` | `everything-claude-code` | Assists with REST API design, pagination, and error responses according to best practices. | `high` — architectural decisions on routes and contracts | When drafting a new API route before writing implementation. | `/everything-claude-code:api-design "Create endpoint for user profile"` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |
| `deployment-patterns` | `everything-claude-code` | Helps with CI/CD, Docker, health checks, and rollbacks. | `medium` — narrow, well-scoped config changes | When updating service deployment configurations. | `/everything-claude-code:deployment-patterns "Add healthcheck to Dockerfile"` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |

---

## 11. Frontend Skills (React / Next.js Stack)

These skills are relevant for engineers working on TipTip's React, Next.js, and SatuSatu codebases.

### Must-Have Skills (Frontend)

| Skill | Source | Description | Recommended Claude Code Effort | When to use | Sample Invocation | VS Code Install & Repo |
|---|---|---|---|---|---|---|
| `next-best-practices` | Vercel | Vercel's official Next.js best practices injected directly into Claude. Critically important for App Router transitions and optimized caching. | `high` — broad architectural impact (routing, caching, data fetching) | When building Next.js pages, layouts, and data fetching correctly. | `/next-best-practices` | Run: `npx skills add vercel-labs/next-skills` in VS Code terminal. [Link](https://vercel.com/docs/agent-resources/skills) |
| `vercel-react-best-practices` | Vercel | Official Vercel constraints for high-performance React composition. | `medium` — focused composition rules for targeted components | When lifting state, splitting client/server boundaries, or optimizing renders. | `/vercel-react-best-practices` | Run: `npx skills add vercel-labs/next-skills` in VS Code terminal. [Link](https://vercel.com/docs/agent-resources/skills) |

> 💡 **On `code-review-nextjs`:** `code-review-nextjs` (Section 6) provides TipTip's standardized multi-persona review with security scoring for Next.js/React/TypeScript code. Vercel's `next-best-practices` and `vercel-react-best-practices` cover framework patterns, not code review. These are complementary — use both. If your team decides to standardize on a specific code review workflow, formalize that decision via a pull request to `aiad-claude`.

### Nice-to-Have Skills (Frontend)

| Skill | Source | Description | Recommended Claude Code Effort | When to use | Sample Invocation | VS Code Install & Repo |
|---|---|---|---|---|---|---|
| `web-design-guidelines` | Vercel | Advice on building accessible, performant user interfaces. | `low` — reference-style advice, single-pass | When setting up a new layout or responsive design structure. | `/web-design-guidelines` | Run: `npx skills add vercel-labs/next-skills` in VS Code. [Link](https://vercel.com/docs/agent-resources/skills) |
| `e2e` | `everything-claude-code` | Playwright E2E test generation and Page Object Model patterns. | `high` — multi-file scaffold with POM patterns | When writing UI automation tests. | `/everything-claude-code:e2e "Write login test"` | Run: `/plugin install everything-claude-code@everything-claude-code` in VS Code. [Link](https://github.com/affaan-m/everything-claude-code) |

---

## 12. Mobile Skills (Flutter Stack)

These skills are relevant for engineers working on TipTip's Flutter mobile applications.

### Must-Have Skills (Mobile)

| Skill | Source | Description | Recommended Claude Code Effort | When to use | Sample Invocation | VS Code Install & Repo |
|---|---|---|---|---|---|---|
| `code-review-flutter` | `aiad-claude` | Orchestrates Flutter/Dart code reviews through two specialist sub-agents — a Senior Flutter Engineer and a Security Engineer — producing a unified, severity-graded review report with mobile-specific security focus (OWASP Mobile Top 10). | `max` — multi-agent orchestration, mobile security + quality scoring | When reviewing Flutter/Dart code before submitting an MR or during peer review. | `/code-review-flutter review lib/features/auth/presentation/login_page.dart` | Copy from `aiad-claude` repo (`frontend-mobile/`). [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |

> 💡 **`code-review-flutter` focus areas:** Beyond standard code quality, this skill's Security Engineer agent is specifically tuned for mobile attack vectors: insecure local storage (`SharedPreferences` vs `flutter_secure_storage`), API keys in Dart source (extractable from APK/IPA), missing certificate pinning, platform channel security, and release build obfuscation. These are distinct from web security concerns and reflect OWASP Mobile Top 10 priorities.

### Nice-to-Have Skills (Mobile)

No additional Flutter-specific skills from third-party plugins are mature enough to recommend at this time. As the Flutter Claude Code ecosystem develops, this section will be updated. Engineers who identify Flutter-specific skill gaps should open an issue on `aiad-claude`.

> 💡 **Third-party plugins for mobile:** See [`PLUGINS.md`](../PLUGINS.md) for the latest plugin inventory. If Flutter-specific plugins become available in `everything-claude-code` or other sources, they will be listed here.

---

## 13. QA Automation Skills (Playwright / Cucumber Stack)

These skills are for QA Engineers working on TipTip's Playwright/Cucumber test automation across all platforms (TWA, Content Hub, SatuSatu). They support a **shift-left** testing philosophy: generating manual test cases early from PRDs, then converting them into automated scripts, and continuously validating existing automation against TipTip standards.

> 💡 **QA Engineer Persona:** The QA Automation Engineer ensures quality through early test design (shift-left), Playwright/Cucumber automation, and continuous compliance auditing. This persona collaborates with Product (for PRDs), Frontend (for element IDs and locators), and Backend (for API test data setup). The QA lead owns `qa-automation/` skills.

### Must-Have Skills (QA Automation)

| Skill | Source | Description | Recommended Claude Code Effort | When to use | Sample Invocation | VS Code Install & Repo |
|---|---|---|---|---|---|---|
| `shift-left-manual-test` | `aiad-claude` | Generates structured manual test cases in Gherkin format (Given/When/Then) from PRDs, Jira tickets, or feature descriptions. Covers positive, negative, edge, and boundary scenarios with TipTip's tagging conventions. | `high` — multi-step requirement analysis, scenario classification | When a new PRD or Jira ticket is created and test coverage needs to be defined before development starts. | `/shift-left-manual-test generate` | Copy from `aiad-claude` repo (`qa-automation/`). [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |
| `automation-script-generation` | `aiad-claude` | Generates production-ready Playwright Page Object Model classes, Cucumber step definitions, and `.feature` files following TipTip's exact repository structure (`tests/pages/`, `tests/stepDefinitions/web/`, `tests/features/`). | `high` — multi-file scaffold with POM patterns, index.js updates | When manual test cases are finalized and need to be converted into automated Playwright/Cucumber scripts. | `/automation-script-generation generate` | Copy from `aiad-claude` repo (`qa-automation/`). [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |
| `automation-script-validation` | `aiad-claude` | Audits existing Playwright/Cucumber scripts against TipTip's coding standards. Validates POM structure, step definition patterns, feature file conventions, locator robustness, and index.js exports. Produces a severity-graded report. | `max` — deep static analysis across multiple file types with cross-referencing | When reviewing QA automation code before merging, or during quarterly automation quality audits. | `/automation-script-validation validate tests/pages/twa/` | Copy from `aiad-claude` repo (`qa-automation/`). [Link](https://gitlab.com/tiptiptv/common/aiad-claude) |

> 💡 **Shift-left workflow:** The three QA skills form a pipeline: `shift-left-manual-test` → `automation-script-generation` → `automation-script-validation`. Start by generating test cases from a PRD, then generate automation scripts from those test cases, then validate the generated (or existing) scripts for compliance. Each skill can also be used independently.

> ⚠️ **QA Repository:** All automation scripts target the [web-automation-playwright](https://gitlab.com/tiptiptv/qa/web-automation-playwright) repository. Skills reference its exact directory structure, patterns, and conventions as documented in the [QE Confluence space](https://tiptiptv.atlassian.net/wiki/spaces/QE/pages/251461963).

---

## 14. Skills and LLM Cost

This section outlines how skills affect token consumption and API cost, and gives practical guidance on efficient use.

### How Skills Affect Cost

- **Context Window Padding:** Every skill invocation adds the skill's content to the context window on top of the existing conversation and `CLAUDE.md` content.
- **Cost Compounding:** A large skill (500+ lines) invoked at the start of a long session will compound cost because that skill content is re-sent with every subsequent message in the conversation.
- **Tool Triggers Multiplier:** Skills that trigger multiple tool calls (file reads, shell executions) multiply the token cost further — each tool result is added to context.
- **Model Distribution:** Background model calls (Haiku) are used for lightweight skill steps; main model calls (Sonnet/Opus) are used for reasoning-heavy steps. Well-structured skills can direct lighter work to Haiku. See Guide 1, Section 6 for model optimization guidance.

### Best Practices (Do This)

- **Keep skills focused and narrow.** A skill that does one thing well costs less than a skill that tries to do three things. Split broad skills into composable smaller ones.
- **Use project-level skills for repo-specific tasks.** They tend to be more concise because they can assume repo context from `CLAUDE.md` rather than re-explaining it in the skill body.
- **Invoke skills at the start of a session, not mid-session.** Starting fresh with a skill gives Claude a clean context. Mid-session skill invocation stacks on top of an already-large context, increasing cost and potentially degrading output quality.
- **Use CLI-backed skills where possible.** CLI output is structured and concise. Asking Claude to reason through unstructured data is more expensive.
- **Use Haiku for skill-driven background tasks.** For skills that do mass file reading, linting passes, or repetitive generation tasks, switch to Haiku (`/model` → haiku) to conserve your Team Plan quota. When using the GLM fallback, GLM-4.5 Air serves the same purpose at $0.13/1M input.

### What to Avoid (Do Not Do This)

- **Do not invoke a heavy skill just to ask a simple question.** If you only need to understand one function, ask directly — do not trigger a full review skill.
- **Do not chain multiple heavy skills in one session.** Running `pr-description`, then `tdd` in a single session will balloon the context window. Use separate sessions for separate tasks.
- **Do not write skills with redundant context.** If your `CLAUDE.md` already defines TipTip's error handling pattern, do not repeat it verbatim inside the skill. Reference it instead (e.g., "following error handling patterns in CLAUDE.md").
- **Do not use Opus for skills that only need lightweight output.** For skills that generate boilerplate, summaries, or simple diffs, switch to Haiku (`/model` → haiku). Reserve Sonnet and Opus for reasoning-heavy skills like `systematic-debugging`, `rfc-review`, and `code-review-*`.
- **Do not let skills go stale.** An outdated skill that reflects old conventions will produce wrong output confidently. Stale skills waste tokens and engineer time.

---

## 15. What to Expect from Engineers

### Engineering Lead Responsibilities

- **Own the canonical skills repository** at `aiad-claude`. Leads are responsible for the quality and accuracy of skills in their domain (backend lead owns Go skills, frontend lead owns Next.js skills).
- **Ensure project-level skills hit the mark.** Active repositories must have project-level skills installed that are tailored to the repo's domain, not just copied verbatim from global.
- **Review skill changes via MR.** Changes to canonical skills affect every engineer using them. Leads should review skill MRs with the same scrutiny as code changes.
- **Schedule skill reviews.** Skills should be reviewed every quarter or after a major architectural change (e.g., migrating from REST to gRPC, adopting a new state management library). Stale skills produce stale output.
- **Encourage skill suggestions from the team.** Engineers doing repetitive prompting are identifying skill gaps. Leads should create a lightweight process for engineers to propose new skills (e.g., a `#claude-code` Slack channel or a GitLab issue template on `aiad-claude`).

### Individual Engineer Responsibilities

- **Use skills as the default workflow** for covered tasks. Do not manually re-prompt for `pr-description` or `tdd` when the skill exists. Consistent use is what makes skills improve over time.
- **Report when a skill produces wrong or suboptimal output.** Do not just fix it locally and move on — open an issue or MR on `aiad-claude` so the fix reaches everyone.
- **Do not create private skills that duplicate canonical ones.** If a canonical skill does not fit your repo, the fix is to improve the canonical skill or add a project-level override, not to maintain a private fork.
- **Suggest new skills.** If you find yourself typing the same multi-step prompt more than twice, that is a skill candidate. Document the prompt and propose it via the agreed channel.
- **Understand what each skill does before invoking it.** Skills can run commands, edit files, and make multiple API calls. Know what a skill does before running it on production-adjacent code.
- **Update placeholders before executing:** When invoking a newly created scaffolded skill from the repository, ensure you have updated the `<!-- TODO: Implement TipTip specific instructions for this skill -->` placeholder with actual instructions before executing it.

### The Improvement Loop

The expected behavior for skill improvement follows this loop:
1. Engineer invokes a skill.
2. Output misses a TipTip pattern or produces a suboptimal result.
3. Engineer identifies what the skill is missing.
4. Engineer opens an MR on `aiad-claude` with the fix and a brief description of what was wrong and what was improved.
5. Lead reviews and merges.
6. All engineers pull the update and benefit.

*This is how the skill set matures. Expected and normal.*



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

## 16. Quick Reference

For the full, up-to-date skills reference — including recommended model tiers (Haiku / Sonnet / Opus) for each skill — see:

→ [**Skills List Reference**](./claude_code_skills_list.md)
