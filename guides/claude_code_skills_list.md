# TipTip Skills — Quick Reference

All skills available across TipTip's Claude Code ecosystem, organized by scope. For context on effort levels, skill anatomy, cost, and installation details, see the full [Skills Guide](./claude_code_skills_guide.md).

**Recommended Model** reflects the minimum model tier that reliably produces quality output for each skill. Use a higher tier when Claude is making assumptions or skipping detail; switch to Haiku for token efficiency on simpler tasks.

---

| Task | Skill | Scope | Source | Path in aiad-claude | Recommended Claude Code Effort | Recommended Model | Rationale |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Write PR description | `pr-description` | Engineering-wide | `aiad-claude` | `engineering-wide/pr-description/` | `low` | Haiku | Template-fill from staged diff; output is structured and predictable |
| Review Engineering Spec / RFC | `rfc-review` | Engineering-wide | `aiad-claude` | `engineering-wide/rfc-review/` | `max` | Opus | Deep architectural cross-referencing via Confluence MCP; flags subtle convention violations |
| Review PRD | `prd-review` | Engineering-wide | `aiad-claude` | `engineering-wide/prd-review/` | `max` | Sonnet | Multi-perspective document analysis (PM, UX, SEO); requires coherent synthesis, not deep reasoning |
| Refine a prompt (Claude) | `refine-prompt` | Engineering-wide | `aiad-claude` | `engineering-wide/refine-prompt/` | `low` | Haiku | Template-based prompt restructuring; fast pattern application |
| Refine a prompt (Gemini) | `refine-prompt-gravity` | Engineering-wide | `aiad-claude` | `engineering-wide/refine-prompt-gravity/` | `low` | Haiku | Same as `refine-prompt`; Gemini-targeted variant |
| System design & architecture | `system-design` | Engineering-wide | `aiad-claude` | `engineering-wide/system-design/` | `high` | Opus | Iterative diagnostic with ADRs and component maps; ambiguous requirements require deep reasoning |
| Generate commit message | `git-commit` | Engineering-wide | `aiad-claude` | `engineering-wide/git-commit/` | `low` | Haiku | Single-shot message from diff; narrow, well-scoped output |
| Generate tests (TDD workflow) | `tdd` | Engineering-wide | `everything-claude-code` | *(plugin)* | `high` | Sonnet | Multi-phase RED→GREEN→REFACTOR across source and test files |
| Test coverage analysis & gap-filling | `test-coverage` | Engineering-wide | `everything-claude-code` | *(plugin)* | `high` | Sonnet | Scans many files, identifies gaps, generates missing tests |
| Build error diagnosis & fixing | `build-fix` | Engineering-wide | `everything-claude-code` | *(plugin)* | `medium` | Sonnet | Surgical multi-language fixes; errors are well-scoped |
| Systematic trace & root cause analysis | `systematic-debugging` | Engineering-wide | `superpowers` | *(plugin)* | `max` | Opus | 4-phase iterative hypothesis-verify loop across services; high ambiguity |
| Basic feature planning | `plan` | Engineering-wide | `everything-claude-code` | *(plugin)* | `medium` | Sonnet | Feature breakdown and task sequencing; moderate reasoning depth |
| Update documentation | `update-docs` | Engineering-wide | `everything-claude-code` | *(plugin)* | `low` | Haiku | Additive doc updates from known codebase changes; single-pass |
| Go code review (multi-persona) | `code-review-golang` | Backend | `aiad-claude` | `backend/code-review-golang/` | `max` | Opus | Multi-agent orchestration (Senior Go + Security Engineer); severity grading requires deep analysis |
| Go idiomatic patterns | `golang-pattern` | Backend | `everything-claude-code` | *(plugin)* | `high` | Sonnet | Architectural reasoning across service/module boundaries |
| Go build error fixing | `go-build` | Backend | `everything-claude-code` | *(plugin)* | `medium` | Sonnet | Surgical fix of specific `go build` / `go vet` errors |
| Go TDD & testing patterns | `go-test` | Backend | `everything-claude-code` | *(plugin)* | `high` | Sonnet | Table-driven tests, parallel tests, benchmarks — multi-file output |
| Postgres optimizations & schema design | `postgres` | Backend | `planetscale` | *(external skill)* | `medium` | Sonnet | Scoped query and schema advice; well-defined problem space |
| Go automated code review | `go-review` | Backend | `everything-claude-code` | *(plugin)* | `medium` | Sonnet | Lint-style review on targeted files; no deep cross-service reasoning needed |
| Next.js code review (multi-persona) | `code-review-nextjs` | Frontend Web | `aiad-claude` | `frontend-web/code-review-nextjs/` | `max` | Opus | Multi-agent orchestration (Senior Frontend + Security Engineer); severity grading requires deep analysis |
| Next.js architecture best practices | `next-best-practices` | Frontend Web | `Vercel` | *(external skill)* | `high` | Sonnet | Broad architectural impact across routing, caching, and data fetching |
| React composition performance rules | `vercel-react-best-practices` | Frontend Web | `Vercel` | *(external skill)* | `medium` | Sonnet | Focused composition rules applied to targeted components |
| Flutter code review (multi-persona) | `code-review-flutter` | Frontend Mobile | `aiad-claude` | `frontend-mobile/code-review-flutter/` | `max` | Opus | Multi-agent orchestration with OWASP Mobile Top 10 security focus |
| Generate manual test cases from PRDs | `shift-left-manual-test` | QA Automation | `aiad-claude` | `qa-automation/shift-left-manual-test/` | `high` | Sonnet | Multi-step requirement analysis and scenario classification |
| Generate Playwright/Cucumber scripts | `automation-script-generation` | QA Automation | `aiad-claude` | `qa-automation/automation-script-generation/` | `high` | Sonnet | Multi-file POM scaffold with index updates; structured but extensive |
| Validate automation scripts | `automation-script-validation` | QA Automation | `aiad-claude` | `qa-automation/automation-script-validation/` | `max` | Opus | Deep static analysis across POM, step definitions, and feature files with cross-referencing |

---

**Reference Sources:**

- TipTip AIAD Skills & Plugin Manifest: [`PLUGINS.md`](../PLUGINS.md)
- TipTip AIAD - CLAUDE.md/Skills Repository: [https://gitlab.com/tiptiptv/common/aiad-claude](https://gitlab.com/tiptiptv/common/aiad-claude)
- Superpowers source: [https://github.com/obra/superpowers](https://github.com/obra/superpowers)
- everything-claude-code source: [https://github.com/affaan-m/everything-claude-code](https://github.com/affaan-m/everything-claude-code)
- PlanetScale Database Skills: [https://database-skills.preview.planetscale.com/](https://database-skills.preview.planetscale.com/)
- Vercel skills source: [https://vercel.com/docs/agent-resources/skills](https://vercel.com/docs/agent-resources/skills)
