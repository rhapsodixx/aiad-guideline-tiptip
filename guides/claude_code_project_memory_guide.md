# CLAUDE.md & Project Memory — TipTip Internal
### Series: Claude Code at TipTip | Guide 2 of 7: Project Memory

> ⚠️ **Prerequisites:** Complete Guide 1 (Setup) before proceeding with this guide.

---

## 1. What is CLAUDE.md?

`CLAUDE.md` is a markdown file that Claude Code automatically reads at the start of every session. It acts as persistent project memory. Because Claude does not retain context or remember conversations between sessions, `CLAUDE.md` is how you give Claude standing instructions, conventions, and codebase knowledge that should always be in context.

Without it, every Claude Code session starts cold — it has no initial knowledge of TipTip's stack, patterns, or team conventions. With it, Claude Code immediately understands the TipTip codebase, writes idiomatic code, and avoids common mistakes.

It can live at different levels:
- **Globally** (`~/.claude/CLAUDE.md`) for cross-repo defaults.
- At the **project root** for repo-specific context.
- In **subdirectories** (e.g., `.claude/rules/` or sub-package folders) for package-specific rules.

> **Note on `/memory`:** You can use the `/memory` command at any time during a Claude Code session to verify exactly what instructions and context Claude is currently reading.

**Supporting References:**
- [How Claude remembers your project (Official)](https://docs.anthropic.com/en/docs/claude-code/memory) — Anthropic's official guide on auto memory and `CLAUDE.md`.
- [CLAUDE.md file reference (Official)](https://code.claude.com/docs/en/memory#claude-md-files) — Documentation on how `CLAUDE.md` files are loaded and parsed.
- [Writing a good CLAUDE.md (HumanLayer)](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — A practical guide explaining why less is more, progressive disclosure, and why LLMs need explicit onboarding.

---

## 2. Why CLAUDE.md — Not agents.md

An earlier direction in TipTip's AI coding tool adoption pointed toward using the open standard `agents.md` (from agents.md) as the format for writing context files. This guide intentionally steps back from that approach.

- **Lowest Common Denominator:** `agents.md` is a community standard designed for cross-tool compatibility (Claude Code, Cursor, Cline, Copilot all reading the same file). While that is its strength, it also restrains the capabilities to the lowest common denominator across all tools.
- **Claude Code-First:** TipTip is standardizing on Claude Code as the primary AI coding tool. There is no cross-tool compatibility requirement right now.
- **Richer Capabilities:** Claude Code's native `CLAUDE.md` is richer and more capable. It supports `@file` references for progressive disclosure, slash command definitions, tool permissions, and specific memory behaviors that `agents.md` does not account for.
- **No Unnecessary Abstraction:** Maintaining the `agents.md` format introduces an abstraction layer with no practical benefit for a team that is Claude Code-first. Keeping it native means TipTip engineers learn one format deeply, not two formats shallowly.
- **Future-Proofing:** If TipTip ever adopts a second AI coding tool in the future, the `CLAUDE.md` files can be adapted or translated at that point. Optimizing for multi-tool compatibility now is premature.

**Conclusion:** TipTip's context files will exclusively follow Anthropic's native `CLAUDE.md` format and conventions.

---

## 3. How Claude Code Reads CLAUDE.md

When you start a session, Claude Code loads your instructions in a specific, additive order:

1. **Global `CLAUDE.md`** (`~/.claude/CLAUDE.md`) — Loaded for every session regardless of which repo you are in.
2. **Project root `CLAUDE.md`** (`./CLAUDE.md`) — Loaded when `claude` is run in that specific directory.
3. **Subdirectory `CLAUDE.md`** (e.g., `./packagename/CLAUDE.md`) — Loaded when Claude navigates into or operates within a subfolder.

All levels are additive — global + project + subfolder instructions all stack into Claude's context window.

| Level | Path | What belongs here |
|---|---|---|
| **Global** | `~/.claude/CLAUDE.md` | TipTip-wide engineering standards that apply universally to every repo. |
| **Project** | `<repo-root>/CLAUDE.md` | Repo-specific context: the specific tech stack, architecture patterns, and known issues. |
| **Subfolder** | `<repo-root>/packages/pkg/CLAUDE.md` | Extremely specific rules for an isolated package (e.g., strict security constraints for a `/payments` module). |

---

## 4. TipTip's Recommended Approach: Global + Per-Repo

We evaluated three approaches (Global only, Per-repo only, and Global + Per-repo) and determined that **Global + Per-Repo** is the optimal strategy for TipTip. 

The global file handles "how we work at TipTip" (universal across all engineers and repos), while the per-repo file handles "how this specific codebase works" (precise and relevant per session). This prevents context window bloat (you won't load Go conventions into a Flutter session like you would with a massive single global file) and prevents convention drift across projects (which happens with per-repo only files). This structure scales cleanly as TipTip adds more repos, services, or platforms.

### What goes in the Global CLAUDE.md

The global file covers standards that apply regardless of which repo is open:
- Company name and engineering team identity.
- Universal coding principles (e.g., write tests, no magic numbers, no hardcoded credentials).
- Git conventions: branch naming format, commit message format, PR size guidelines.
- Code review standards and reviewer expectations.
- Security rules: never log PII, never commit credentials, encryption at rest expectations.
- Incident and escalation channels.
- Language policy: English for all code, comments, and documentation (Bahasa Indonesia is acceptable in internal Slack and PR descriptions).
- A reference instructing Claude to check the project-level `CLAUDE.md` for stack-specific context.

*Note: The global `CLAUDE.md` is intentionally stack-agnostic. Stack-specific globals (Go, React/Next.js, Flutter) are maintained as separate stack-level files.*

### What goes in a Per-Repo CLAUDE.md

The per-repo file covers what is specific to that repository:
- Service or product name and its domain responsibility within TipTip.
- Tech stack and core dependencies.
- Folder structure overview.
- Patterns and conventions specific to this repo.
- Known technical debt or fragile areas Claude should be careful with.
- Instructions on how to run the project locally, run tests, and build.
- Environment variable structure (names only, **never** actual secret values).
- Anything Claude consistently gets wrong in this specific repo based on past experience.

---

## 5. The Four Global Template Files

TipTip maintains four global `CLAUDE.md` files to cover our primary stacks. Engineers should select and install the relevant one(s) for their machine based on the repositories they work on. If you work across multiple stacks, you can use the `@` import functionality in your primary `~/.claude/CLAUDE.md` to reference the specific stack files dynamically.

Below are the templates. **Copy and paste the ones relevant to your work:**

---

### Template 1: Global — TipTip Engineering (stack-agnostic)
Contains universal principles, Git conventions, security rules, and language policy applicable across all TipTip repositories. Essential for ensuring consistent code quality and security standards.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/global/tiptip-engineering.md)

---

### Template 2: Global — Go Stack
Provides specific Go-based guidelines covering error handling, design architecture, and anti-patterns for Go 1.22+. Prevents Claude from hallucinating non-standard packages or improper Go concurrency models.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/stacks/golang.md)

---

### Template 3: Global — React / Next.js Stack
Establishes App Router defaults, state management preferences, and styling constraints for Next.js applications. Ensures Claude generates modern React code adhering to TipTip's specific Next.js conventions.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/stacks/nextjs.md)

---

### Template 4: Global — Flutter Stack
Defines architecture, state management (Riverpod), and UI testing standards for TipTip Dart/Flutter applications. Prevents outdated patterns and ensures proper API data handling.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/stacks/flutter.md)

---

### Template 5: Per-Repo Sample — Go Service (Creator Service)
Demonstrates how to structure a repository-specific `CLAUDE.md` for a hypothetical internal Go service. Illustrates how to document domain constraints (currency formats, transaction logic), external integration pointers, and specific warnings for known tech debt.
[View Template](file:///Users/panji.gautama/Documents/Project/ai-guidance-tiptip/claude-templates/per-repo/creator-service-sample.md)

---

### Automated Installation Script

To easily install these global setup and stack templates onto your machine, use the interactive wizard script. It will automatically copy the relevant files and configure the imports.

Run the script from the root of the cloned `aiad-claude` repository and follow the prompts:

```bash
bash install-claude-templates.sh
```

---

## 6. Tips & Tricks for Repository-Level CLAUDE.md

### Generating and Refining with `/init`
- **Initial Generation**: Use the `/init` command within a Claude Code session. Claude will scan your project's code and recent commits to automatically draft a relevant `CLAUDE.md`. [[Docs: /init Command]](https://docs.anthropic.com/en/docs/claude-code/overview#init)
- **Iterative Refinement**: Run `/init` periodically as your architecture evolves. Claude updates the existing file with newly discovered patterns while preserving your custom additions. [[Docs: Updating Memory]](https://docs.anthropic.com/en/docs/claude-code/memory#updating-project-memory)

### Best Practices for Content
- **1. Omit Standard Boilerplate:** Exclude generic advice (e.g., "write clean code"). Focus exclusively on TipTip-specific exceptions, custom commands, and non-obvious rules. [[Ref: The "does this help" filter]](https://www.humanlayer.dev/blog/writing-a-good-claude-md)
- **2. Document Frequent Mistakes:** Explicitly document the specific, repetitive corrections you find yourself giving Claude for the repository. [[Ref: CLAUDE.md Best Practices]](https://docs.anthropic.com/en/docs/claude-code/memory#best-practices-for-claudemd)
- **3. Enforce Brevity:** Keep the file under 300 lines. A bloated context file wastes tokens and dilutes instruction-following capabilities. [[Ref: Keep CLAUDE.md succinct]](https://www.humanlayer.dev/blog/writing-a-good-claude-md)

---

## 7. What to Expect from Engineers

For `CLAUDE.md` to be effective, it must be treated as living documentation, owned and maintained by the engineering team.

### Engineering Lead Responsibilities
Engineering leads are responsible for:
- **Owning the global stack CLAUDE.md** for their domain (e.g., the Go lead owns `golang.md`, Frontend lead owns `nextjs.md`, Mobile lead owns `flutter.md`).
- Reviewing and approving changes to global `CLAUDE.md` files via PR. Because these files affect every engineer on the team, changes should be deliberate.
- **Ensuring every active repository under their domain has a repo-level `CLAUDE.md`** before the team begins using Claude Code on that repo.
- Bootstrapping the initial per-repo `CLAUDE.md` for new repositories. Do not delegate the first version to junior engineers, as it requires deep knowledge of the repo's architectural patterns and intent.
- Using the per-repo `CLAUDE.md` as part of the onboarding process. If a new engineer reads the `CLAUDE.md` and it does not accurately describe the repo, that is a strong signal it needs updating.
- Scheduling a quarterly review of global `CLAUDE.md` files to ensure they reflect current TipTip standards, not legacy ones.

### Individual Engineer Responsibilities
Individual engineers are responsible for:
- Reading the repo's `CLAUDE.md` before their first Claude Code session on a new repo.
- Treating `CLAUDE.md` as living documentation. Never delete content from `CLAUDE.md` without a team discussion — flag anomalies rather than removing them unilaterally.
- Executing the **refinement loop**:
  1. Use Claude Code on a task.
  2. Claude produces output that misses a TipTip convention or pattern.
  3. Identify what context was missing.
  4. Update `CLAUDE.md` with that context.
  5. Verify with `/memory` that Claude is reading the update.
  6. Next session: Claude gets it right.
  *(This loop is how the file matures. It is expected and normal).*
- Treating `CLAUDE.md` updates as meaningful PRs. Include a brief description of why the change was made (e.g., "Added note about `pgx` because Claude kept suggesting `sqlx`").
- **Updating Templates**: If you believe the global templates or stack templates are inaccurate or missing information, you are strictly encouraged to submit a Pull Request to update the source templates located in the `/claude-templates/` directory. This process is critical to maintaining consistent accuracy and upholding TipTip's quality bar across the organization.

### Quality Bar
- **Accuracy over completeness:** Stale context is worse than no context. If `CLAUDE.md` says a repo uses `sqlx` but it migrated to `pgx` 6 months ago, Claude will confidently generate broken code.
- **Avoid vagueness:** "Write clean code" tells Claude nothing. Give concrete examples.
- **Respect the context window:** A `CLAUDE.md` that is too long wastes tokens and degrades LLM performance. Aim for under 300 lines per file.
- **The 10-minute rule:** Read the `CLAUDE.md` aloud. If it sounds like generic advice applicable to any company, it needs more TipTip-specific detail. If it takes 10 minutes to read, it needs to be trimmed or split using `@` file imports.

---

## 8. Quick Reference

| Task / Item | Command / Location |
|---|---|
| View what Claude is reading | `/memory` (run inside Claude Code session) |
| Global `CLAUDE.md` location | `~/.claude/CLAUDE.md` |
| Go stack global | `~/.claude/stacks/golang.md` |
| React/Next.js stack global | `~/.claude/stacks/nextjs.md` |
| Flutter stack global | `~/.claude/stacks/flutter.md` |
| Project (Repo) `CLAUDE.md` location | `<repo-root>/CLAUDE.md` |
| Official memory documentation | [Docs: How Claude remembers](https://docs.anthropic.com/en/docs/claude-code/memory) |
| Official `CLAUDE.md` file reference | [Docs: CLAUDE.md Files](https://code.claude.com/docs/en/memory#claude-md-files) |
| Practical writing guide | [HumanLayer: Writing a good CLAUDE.md](https://www.humanlayer.dev/blog/writing-a-good-claude-md) |
