# Guide 3 of 7: Skills

> ⚠️ Prerequisites: Complete Guide 1 (Setup) and Guide 2 (CLAUDE.md & Project Memory) before proceeding with this guide.

---

## 1. What Are Skills?

Skills are reusable, invocable prompt templates stored as markdown files that Claude Code can execute on demand.

They are the equivalent of saved workflows — instead of typing the same long instructions every session, you define them once as a skill and invoke them with a short command (e.g., `/explain-code`).

**Key aspects of Skills:**
- **Context-aware:** They run with full awareness of the project's `CLAUDE.md`, the current working directory, and any files Claude has already read.
- **Structured and repeatable:** The difference between a skill and a regular prompt is that a skill is structured, repeatable, and version-controlled. A regular prompt is ad hoc and ephemeral.
- **Workflow orchestrators:** Skills can call other tools, run shell commands, read files, and chain actions — they are not just text templates, they are mini-workflows.

Skills live at two levels:
- **Global skills:** Located in `~/.claude/skills/` — available in every project.
- **Project-level skills:** Located in `.agents/skills/<skill-name>/SKILL.md` in the repo root — available only in that repository. Each skill lives in its own directory with a `SKILL.md` entry point.

*For more details, see the [Anthropic Skills Documentation](https://docs.anthropic.com/en/docs/claude-code/skills).*

---

## 2. Why Skills Before MCP?

This guide covers Skills before MCP Integrations (Guide 4) for several critical reasons:

- **Zero-cost infrastructure:** Skills are simple markdown files. There are no API keys, no OAuth setups, no external service dependencies, and no additional token overhead beyond what the skill itself uses.
- **Zero complexity:** MCP integrations add real complexity: network dependencies, authentication, extra context window consumption per tool call, and potential points of failure. Skills have none of these.
- **Mental models for MCP:** Skills teach engineers how Claude Code thinks about tasks. Writing a skill requires you to articulate a workflow clearly. That same clarity is what makes MCP configurations effective later.
- **High ROI:** For TipTip's current phase (onboarding, cost control, building habits), Skills deliver 80% of the productivity gain at 0% of the setup complexity of MCP.
- **Composability:** Once MCP is set up in Guide 4, skills can call MCP tools as part of their workflow. Skills are not replaced by MCP; they orchestrate it.

---

## 3. TipTip's Skills Repository

All skills needed for TipTip's Claude Code setup are available at our central repository:
[https://gitlab.com/tiptiptv/common/aiad-claude](https://gitlab.com/tiptiptv/common/aiad-claude)

- **The Canonical Set:** Engineers should clone or pull this repository to get the canonical TipTip skill set.
- **Tailored for TipTip:** Skills from this repository are pre-tailored for TipTip's stack and conventions — they reference TipTip's `CLAUDE.md` conventions and produce TipTip-flavored output.
- **Manual vs Simple Setup:** Some skills (particularly superpowers from third parties) require manual setup steps beyond just copying the file — these are called out explicitly in Section 5.
- **No private forks:** Engineers should **NOT** create private local copies of skills that diverge from the canonical repository. If a skill needs improvement, open a merge request to `aiad-claude` so the whole team benefits.

**Installation Command:**
To install project-level skills from the repository, clone it and copy the skills into your project:
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

## 5. How to Choose the Right Skill

Choose the right skill with this decision framework:

- **Prefer skills with CLI integration when available.** If a skill wraps a CLI tool (e.g., `gh` for GitLab/GitHub operations, `gcloud`, `docker`) rather than making API calls, it is generally more reliable, faster, and produces more predictable output. CLI-backed skills consume fewer tokens because the CLI returns structured output.
- **Match skill scope to task scope.** Use narrow skills for narrow tasks. Do not invoke a full code-review skill just to check a single function — that wastes context window and costs more tokens.
- **Project-level overrides global.** If a repo has a local skill tailored to its domain (`.agents/skills/<skill-name>/SKILL.md`), it takes precedence over the global one. Check for project-level skills before assuming only global ones are available.
- **Repeated manual prompting is a skill gap.** If no skill exists for a task you do repeatedly, that is a signal to create one.
- **Avoid stacking multiple heavy skills in a single session.** Each skill adds context. Running three large skills consecutively in one session can bloat the context window and degrade output quality. Split into separate sessions if needed.

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

This section outlines how skills affect token consumption and API cost, and gives practical guidance on efficient use.

### How Skills Affect Cost

- **Context Window Padding:** Every skill invocation adds the skill's content to the context window on top of the existing conversation and `CLAUDE.md` content.
- **Cost Compounding:** A large skill (500+ lines) invoked at the start of a long session will compound cost because that skill content is re-sent with every subsequent message in the conversation.
- **Tool Triggers Multiplier:** Skills that trigger multiple tool calls (file reads, shell executions) multiply the token cost further — each tool result is added to context.
- **Model Distribution:** Background model calls (`ANTHROPIC_SMALL_FAST_MODEL`) are used for lightweight skill steps; main model calls are used for reasoning-heavy steps. Well-structured skills can direct lighter work to the small model.

### Best Practices (Do This)

- **Keep skills focused and narrow.** A skill that does one thing well costs less than a skill that tries to do three things. Split broad skills into composable smaller ones.
- **Use project-level skills for repo-specific tasks.** They tend to be more concise because they can assume repo context from `CLAUDE.md` rather than re-explaining it in the skill body.
- **Invoke skills at the start of a session, not mid-session.** Starting fresh with a skill gives Claude a clean context. Mid-session skill invocation stacks on top of an already-large context, increasing cost and potentially degrading output quality.
- **Use CLI-backed skills where possible.** CLI output is structured and concise. Asking Claude to reason through unstructured data is more expensive.
- **Prefer GLM-4.7 Flash for skill-driven background tasks.** At $0.06/1M input, it is the right tool for skills that do mass file reading, linting passes, or repetitive generation tasks.

### What to Avoid (Do Not Do This)

- **Do not invoke a heavy skill just to ask a simple question.** If you only need to understand one function, ask directly — do not trigger a full code-review skill.
- **Do not chain multiple heavy skills in one session.** Running `pr-description`, then `code-review`, then `tdd` in a single session will balloon the context window. Use separate sessions for separate tasks.
- **Do not write skills with redundant context.** If your `CLAUDE.md` already defines TipTip's error handling pattern, do not repeat it verbatim inside the skill. Reference it instead (e.g., "following error handling patterns in CLAUDE.md").
- **Do not use flagship models (GLM-4.7) for skills that only need lightweight output.** For skills that generate boilerplate, summaries, or simple diffs, configure them to use the small fast model.
- **Do not let skills go stale.** An outdated skill that reflects old conventions will produce wrong output confidently. Stale skills waste tokens and engineer time.

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

The expected behavior for skill improvement follows this loop:
1. Engineer invokes a skill.
2. Output misses a TipTip pattern or produces a suboptimal result.
3. Engineer identifies what the skill is missing.
4. Engineer opens an MR on `aiad-claude` with the fix and a brief description of what was wrong and what was improved.
5. Lead reviews and merges.
6. All engineers pull the update and benefit.

*This loop is how the skill set matures. It is expected and normal.*

> 💡 *Tip from [The Shorthand Guide to Everything Claude Code](https://x.com/affaanmustafa/status/2012378465664745795):* **Skills vs Commands** — Skills (`~/.claude/skills/`) are broader workflow definitions, while Commands (`~/.claude/commands/`) are quick executable prompts invoked via `/slash`. Skills and commands can be **chained together** in a single prompt for multi-step workflows (e.g., `/refactor-clean` followed by `/tdd`).

> 💡 *Tip from [The Shorthand Guide to Everything Claude Code](https://x.com/affaanmustafa/status/2012378465664745795):* **Plugins** extend Claude Code with bundled tools, skills, and MCPs. **LSP Plugins** are particularly useful if you run Claude Code outside editors — they give Claude real-time type checking, go-to-definition, and intelligent completions without an IDE. Strongly suggested plugins to install/enable:
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
