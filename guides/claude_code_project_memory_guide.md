# Guide 2 of 7: CLAUDE.md & Project Memory

> ⚠️ **Prerequisites:** Complete Guide 1 (Setup) before proceeding with this guide.

---

## 1. What is CLAUDE.md?

`CLAUDE.md` is a markdown file Claude Code reads at the start of every session — it's persistent project memory. Claude doesn't retain context between sessions, so without this file, every session starts cold with zero knowledge of TipTip's stack, patterns, or conventions.

With it, Claude immediately writes idiomatic code and avoids common mistakes.

It lives at different levels:
- **Global** (`~/.claude/CLAUDE.md`) — cross-repo defaults
- **Project root** (`./CLAUDE.md`) — repo-specific context
- **Subdirectories** (e.g., `.claude/rules/` or sub-package folders) — package-specific rules

> **Note on `/memory`:** Run `/memory` during any session to check exactly what Claude is reading.

**References:**
- [How Claude remembers your project (Official)](https://docs.anthropic.com/en/docs/claude-code/memory)
- [CLAUDE.md file reference (Official)](https://code.claude.com/docs/en/memory#claude-md-files)
- [Writing a good CLAUDE.md (HumanLayer)](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — practical guide on progressive disclosure and why less is more

---

## 2. Why CLAUDE.md — Not agents.md

TipTip previously considered `agents.md` (the cross-tool community standard). We're not using it. Here's why:

- `agents.md` targets cross-tool compatibility (Claude Code, Cursor, Cline, Copilot all reading one file). That's its strength — but it caps you at the **lowest common denominator** across all tools.
- TipTip is Claude Code-first. We have no cross-tool requirement right now.
- Claude Code's native `CLAUDE.md` is richer — supports `@file` references, slash command definitions, tool permissions, and memory behaviors that `agents.md` doesn't account for.
- Maintaining `agents.md` adds an abstraction layer with zero practical benefit for a Claude Code-first team.
- If we ever adopt a second tool, we can adapt the files then. Optimizing for multi-tool now is premature.

**Verdict:** TipTip context files exclusively follow Anthropic's native `CLAUDE.md` format.

---

## 3. How Claude Code Reads CLAUDE.md

Claude loads instructions in a specific, additive order at session start:

1. **Global** (`~/.claude/CLAUDE.md`) — loaded for every session, every repo
2. **Project root** (`./CLAUDE.md`) — loaded when `claude` runs in that directory
3. **Subdirectory** (e.g., `./packagename/CLAUDE.md`) — loaded when Claude navigates into a subfolder

All levels stack — global + project + subfolder instructions all enter the context window.

| Level | Path | What belongs here |
|---|---|---|
| **Global** | `~/.claude/CLAUDE.md` | TipTip-wide standards that apply universally to every repo |
| **Project** | `<repo-root>/CLAUDE.md` | Repo-specific context: tech stack, architecture patterns, known issues |
| **Subfolder** | `<repo-root>/packages/pkg/CLAUDE.md` | Extremely specific rules for an isolated package (e.g., strict security constraints for `/payments`) |

---

## 4. TipTip's Approach: Global + Per-Repo

We evaluated three approaches and picked **Global + Per-Repo**:

- **Global file** = "how we work at TipTip" (universal across engineers and repos)
- **Per-repo file** = "how this specific codebase works" (precise, relevant per session)

This prevents context window bloat (no Go conventions loading in a Flutter session) and prevents convention drift across projects (which happens with per-repo-only files). Scales cleanly as we add repos.

### What goes in the Global CLAUDE.md

Standards that apply regardless of which repo is open:
- Company name and engineering team identity
- Universal coding principles (write tests, no magic numbers, no hardcoded credentials)
- Git conventions: branch naming, commit format, PR size
- Code review standards
- Security: never log PII, never commit credentials, encryption at rest
- Incident and escalation channels
- Language policy: English for code/comments/docs (Bahasa Indonesia fine in Slack and PR descriptions)
- Reference to check the project-level `CLAUDE.md` for stack-specific context

*The global file is intentionally stack-agnostic. Stack-specific globals (Go, React/Next.js, Flutter) are separate files.*

### What goes in a Per-Repo CLAUDE.md

What's specific to that repository:
- Service/product name and its domain responsibility
- Tech stack and core dependencies
- Folder structure overview
- Repo-specific patterns and conventions
- Known tech debt or fragile areas Claude should be careful with
- How to run locally, run tests, and build
- Environment variable names (**never** actual secret values)
- What Claude consistently gets wrong in this repo

---

## 5. The Four Global Template Files

TipTip maintains four global `CLAUDE.md` files for our primary stacks. Install the ones relevant to your work. If you work across stacks, use `@` imports in your primary `~/.claude/CLAUDE.md` to reference specific stack files.

---

### Template 1: Global — TipTip Engineering (stack-agnostic)
Universal principles, Git conventions, security rules, language policy.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/global/tiptip-engineering.md)

---

### Template 2: Global — Go Stack
Go-specific guidelines: error handling, architecture, anti-patterns for Go 1.22+. Prevents Claude from hallucinating non-standard packages.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/stacks/golang.md)

---

### Template 3: Global — React / Next.js Stack
App Router defaults, state management, styling constraints for Next.js.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/stacks/nextjs.md)

---

### Template 4: Global — Flutter Stack
Architecture, Riverpod state management, UI testing standards for Dart/Flutter.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/stacks/flutter.md)

---

### Template 5: Per-Repo Sample — Go Service (Creator Service)
Example repo-level `CLAUDE.md` for an internal Go service. Shows how to document domain constraints (currency formats, transaction logic), external integrations, and tech debt warnings.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/per-repo/creator-service-sample.md)

---

### Automated Installation Script

Run the interactive wizard to install templates automatically:

```bash
bash install-claude-templates.sh
```

---

## 6. Tips & Tricks for Repository-Level CLAUDE.md

### Generating with `/init`
- Run `/init` inside a session — Claude scans your code and recent commits to draft a `CLAUDE.md`. [[Docs: /init Command]](https://docs.anthropic.com/en/docs/claude-code/overview#init)
- Run `/init` periodically as architecture evolves. Claude updates the file with new patterns while preserving your custom additions. [[Docs: Updating Memory]](https://docs.anthropic.com/en/docs/claude-code/memory#updating-project-memory)

### Content rules
- **Skip generic advice.** Omit "write clean code" — focus on TipTip-specific exceptions and non-obvious rules. [[Ref]](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- **Document frequent mistakes.** If you keep correcting Claude on the same thing, put it in the file. [[Ref]](https://docs.anthropic.com/en/docs/claude-code/memory#best-practices-for-claudemd)
- **Keep it under 300 lines.** Bloated context wastes tokens and dilutes instruction-following. [[Ref]](https://www.humanlayer.dev/blog/writing-a-good-claude-md)

---

## 7. What to Expect from Engineers

### Engineering Leads
- **Own the global stack CLAUDE.md** for your domain (Go lead → `golang.md`, Frontend lead → `nextjs.md`, Mobile lead → `flutter.md`)
- Review global `CLAUDE.md` changes via PR — these files affect every engineer
- **Ensure every active repo has a repo-level `CLAUDE.md`** before the team uses Claude Code on it
- Bootstrap the initial per-repo file yourself — don't delegate the first version to junior engineers (requires deep architectural knowledge)
- Use the per-repo `CLAUDE.md` as an onboarding test: if a new engineer reads it and it doesn't accurately describe the repo, it needs updating
- Schedule a quarterly review of global files

### Individual Engineers
- Read the repo's `CLAUDE.md` before your first session on a new repo
- Treat it as living documentation — never delete content without team discussion
- **Run the refinement loop:**
  1. Use Claude on a task → Claude misses a TipTip convention → identify the missing context → update `CLAUDE.md` → verify with `/memory` → next session it gets it right
  *(This loop is how the file matures. Expected and normal.)*
- Treat updates as meaningful PRs with a brief description (e.g., "Added note about `pgx` because Claude kept suggesting `sqlx`")
- **Update templates**: if global/stack templates are inaccurate, submit a PR to `/claude-templates/`

### Quality Bar
- **Accuracy > completeness** — stale context is worse than no context. If the file says `sqlx` but you migrated to `pgx` 6 months ago, Claude will confidently generate broken code.
- **Avoid vagueness** — "Write clean code" tells Claude nothing. Give concrete examples.
- **Respect the context window** — aim for under 300 lines per file.
- **The 10-minute rule** — read it aloud. If it sounds like generic advice for any company, add more TipTip detail. If it takes 10 minutes to read, trim it or split using `@` imports.

> 💡 *Tip from [The Shorthand Guide to Everything Claude Code](https://x.com/affaanmustafa/status/2012378465664745795):* As `CLAUDE.md` grows, consider breaking rules into a modular **`.rules` folder** (`~/.claude/rules/`) with separate `.md` files per concern (e.g., `security.md`, `coding-style.md`, `testing.md`). Keeps things composable.

---

## 8. Quick Reference

| Task / Item | Command / Location |
|---|---|
| View what Claude is reading | `/memory` (inside Claude Code session) |
| Global `CLAUDE.md` location | `~/.claude/CLAUDE.md` |
| Go stack global | `~/.claude/stacks/golang.md` |
| React/Next.js stack global | `~/.claude/stacks/nextjs.md` |
| Flutter stack global | `~/.claude/stacks/flutter.md` |
| Project (Repo) `CLAUDE.md` location | `<repo-root>/CLAUDE.md` |
| Official memory documentation | [Docs: How Claude remembers](https://docs.anthropic.com/en/docs/claude-code/memory) |
| Official `CLAUDE.md` file reference | [Docs: CLAUDE.md Files](https://code.claude.com/docs/en/memory#claude-md-files) |
| Practical writing guide | [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) |
