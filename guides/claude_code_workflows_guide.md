# Guide 6 of 7: Workflows & Autonomous Tasks

> ⚠️ **Prerequisites:** Complete all prior guides (1–5) before this guide.
> This guide assumes CLAUDE.md is configured (Guide 2), skills are installed (Guide 3), MCPs are active (Guide 4), and hooks are enforcing quality gates (Guide 5). Without these foundations, autonomous workflows will produce lower-quality, unconstrained output.

---

## 1. From Assistant to Autonomous Agent

Guides 1–5 covered setup and configuration. This guide is the shift: using Claude Code as an autonomous engineering collaborator.

Two modes:
- **Interactive** — engineer and Claude work back-and-forth. Best for exploratory work, unfamiliar codebases, unclear requirements.
- **Autonomous** — engineer defines the task upfront, Claude executes independently. Best for well-defined, repeatable tasks where CLAUDE.md + skills + MCPs provide sufficient context.

Neither is superior — the skill is knowing which to use. The foundations from Guides 1–5 make autonomous mode reliable: CLAUDE.md constrains conventions, hooks enforce quality, skills provide workflows, MCPs provide live context.

---

## 2. The Task File Pattern

The task file (`task.md`) is how you structure autonomous work — the equivalent of a well-written Jira ticket handed to a junior developer: context, goals, acceptance criteria, constraints, boundaries.

Claude has no memory between sessions. The task file is the single source of truth for what a session should accomplish. Also serves as an audit trail — reviewers see what Claude was asked alongside what it produced. Task files are ephemeral: live in repo root during the session, add `task.md` to `.gitignore`.

### Task File Structure

Below is the complete task file template TipTip engineers should use as their starting point for any autonomous task:

```markdown
# Task: [Short descriptive title]

## Context
[What is the background? What service or module is this in? What problem does this solve? Reference the Jira ticket if applicable.]

## Goal
[One clear statement of what should be true when this task is complete. Not a list of steps — Claude figures out the steps. This is the outcome.]

## Acceptance Criteria
- [ ] [Specific, verifiable condition 1]
- [ ] [Specific, verifiable condition 2]
- [ ] [Specific, verifiable condition 3]

## Constraints
- [Things Claude must NOT do, even if they seem helpful]
- [Patterns or approaches to avoid]
- [Files or directories that are off-limits for this task]

## Out of Scope
- [Related things that might seem relevant but are not part of this task]

## References
- Jira: [TICKET-ID]
- Related files: [list key files Claude should read first]
- Related docs: [Confluence page, API spec, etc.]
```

**Section Breakdown:**
- **Context** — Gives Claude the "why" so it makes appropriate architectural decisions.
- **Goal** — A single outcome statement, not a to-do list. Claude should determine the implementation path; the task file defines the destination.
- **Acceptance Criteria** — Verifiable checkboxes Claude can test against when it thinks it is done. Should be concrete enough that Claude can evaluate them programmatically where possible.
- **Constraints** — The guardrails. What Claude should never do in this task, regardless of what seems efficient. This is where repo-specific rules go (e.g., "do not modify the legacy `CalculatePayout_V1` function").
- **Out of Scope** — Prevents scope creep. Claude is helpful by nature and will expand scope if not explicitly bounded.
- **References** — The starting points for Claude's context gathering.

### Using Task Templates from `aiad-claude`

All sample task templates — including the generic template above and the specific workflow templates — are strictly managed in the TipTip Claude Code repository: `https://gitlab.com/tiptiptv/common/aiad-claude` under the `tasks/` directory.

**How to Use Local Task Templates:**
1. Clone or pull the latest version of the `aiad-claude` repository to your local machine.
2. Browse the `tasks/` directory for the template that matches your workflow (e.g., `workflow_1_new_endpoint.md`, `workflow_2_refactor.md`).
3. Copy the relevant template into the root directory of your active working repository.
4. Rename the copied file to `task.md`.
5. Open `task.md` and modify the bracketed placeholders (`[TICKET-ID]`, `[service name]`, etc.) to fit your specific feature.
6. Make sure `task.md` is added to your local `.gitignore`.

### Connecting Task Files to Jira
With the Jira MCP active (Guide 4), engineers can ask Claude to pull a Jira ticket and draft the task file automatically. Try:

> "Pull TICKET-123 from Jira and create a task.md for implementing this feature in the payment-service repo."

Claude will read the ticket, understand the acceptance criteria, inspect linked tickets, and produce a populated `task.md` for you to review before execution begins. **Engineers should always review the generated task.md before running the autonomous session** — it is the contract for the session.

### How to Execute a Task File in VS Code

Because TipTip's recommended IDE is VS Code, these execution steps are specifically tailored for the VS Code environment. 

1. **Open the Integrated Terminal:** In VS Code, open the integrated terminal (`Ctrl+` `\`` or `Cmd+` `\`` on Mac).
2. **Verify File Placement:** Ensure your finalized `task.md` document is saved in the root directory of your active repository and that it is ignored in `.gitignore`.
3. **Launch Claude Code:** In the terminal, type `claude` and press Enter to start the interactive CLI session.
4. **Trigger the Autonomous Execution:** Once the Claude prompt appears, type the following command to kick off the session:
   > "Please execute the implementation plan detailed in `task.md`."
5. **Monitor Progress:** Claude will begin reading the file, invoking tools, and spawning subagents if necessary. You can watch the execution log in the terminal. Let it run autonomously, but remain available in case it pauses to ask for clarification or approval on a destructive action.

---

## 3. Interactive vs Autonomous: When to Use Each

For quick selection between modes, refer to this decision table:

| Situation                           | Recommended Mode | Reason                                        |
| ----------------------------------- | ---------------- | --------------------------------------------- |
| Exploring an unfamiliar codebase    | Interactive      | Need to understand before acting              |
| Requirements are still unclear      | Interactive      | Premature automation of an unclear goal       |
| Writing a new feature end-to-end    | Autonomous       | Well-defined goal, Claude can execute         |
| Refactoring a module to new pattern | Autonomous       | Clear before/after, hooks catch regressions   |
| Debugging a specific error          | Interactive      | Hypothesis-test loop needs human judgment     |
| Generating tests for existing code  | Autonomous       | Mechanical task, well-defined output          |
| Reviewing an MR before submitting   | Autonomous       | Defined input (diff), defined output (review) |
| Architecture or design decisions    | Interactive      | Requires judgment, not execution              |
| Generating an MR description        | Autonomous       | Short, well-defined, use the skill            |
| Incident debugging under pressure   | Interactive      | Speed and judgment over structure             |

**Practical Signal:**
If you can write clear acceptance criteria before starting, use **autonomous** mode. If you are not sure what done looks like yet, use **interactive** mode first, then switch to autonomous once the approach is clear.

---

## 4. Multi-Session Work

Claude has no memory between sessions. Each session starts fresh from CLAUDE.md and whatever files exist in the repo. This is both a constraint and a feature — it forces engineers to commit real progress rather than relying on ephemeral in-memory context.

**The Golden Rule:** Commit at the end of every session that makes meaningful progress. Uncommitted changes across a large working tree make the next session harder and significantly riskier.

For large tasks spanning multiple sessions:
1. Maintain your `task.md`. Check off the acceptance criteria as Claude finishes them.
2. **Session 1:** Claude reads `task.md`, implements criteria 1–3, and you commit with a clear message on your feature branch.
3. You review the commit, update `task.md` to check off done items, and add any new constraints discovered during review.
4. **Session 2:** Claude reads the updated `task.md` and committed state to continue with criteria 4–6.
5. Repeat until the task is complete.

**Branch Discipline:** Always constrain Claude to work on a feature branch (e.g., `feature/TICKET-ID-short-name`), not directly on `main`. Include this as a constraint in every `task.md`.

---

## 5. Subagents and Parallel Execution

Claude can spawn parallel subagent instances to tackle independent workstreams simultaneously.

- **What subagents are:** Specialized sub-instances of Claude configurable via `~/.claude/agents/` with distinct scopes, prompts, or tool allowances (e.g., a "code-reviewer" or "debugger"). Subagents can be run in the foreground (blocking) or background (parallel).
- **When parallel execution helps:** Independent tasks that do not share files or state. At TipTip, a great use case is refactoring a Go interface across the `creator-service`. One subagent updates the interface definition and the service layer; another updates the repository layer and tests. 
- **When parallel execution hurts:** Tasks with shared state, inter-dependencies, or tasks modifying the exact same files simultaneously.

*Note:* Hooks execute on the subagents according to their configured capabilities and actions. Before launching background subagents, Claude prompts for necessary tool permissions.

**Caution on Cost:** Subagents multiply token cost. Each parallel agent consumes its own context window. Run parallel processes only when the time saving is definitively worth the cost increase.

---

## 6. TipTip Workflow Cookbook

Below are 7 realistic TipTip scenarios structured as recipes.

### Workflow 1: Add a New API Endpoint to a Go Service

**When to use:** A Jira ticket requires a new HTTP endpoint (e.g., a new `/v1/creator/earnings` endpoint in `creator-service`).
**Recommended mode:** Autonomous
**MCPs:** Jira <!-- Reason: Pulls the exact acceptance criteria directly into the session without copy-pasting -->, Context7 <!-- Reason: Injects version-accurate Go library docs to prevent hallucinated APIs -->, PostgreSQL <!-- Reason: Allows Claude to inspect the schema locally for the repository layer -->, GitLab <!-- Reason: Fetches MR context and repository metadata -->
**Skills:** `golang-pattern`, `tdd`, `pr-description`

**Step-by-step instructions:**
1. Pull the Jira ticket via MCP to dynamically draft `task.md`.
2. Review and refine the generated `task.md` before starting.
3. Start Claude with the task file.
4. Once completed, review routes registration, error handling, test coverage, and pgx usage.

**The task file:**
Use the `workflow_1_new_endpoint.md` template from `aiad-claude/tasks/`. Copy it to your repo root, rename to `task.md`, and fill in the placeholders.

#### Sample on How to Execute (VS Code)

1. Open VS Code in the service repo: `code ~/repos/creator-service`
2. Open the integrated terminal (`Ctrl+\`` or `Cmd+\``).
3. Copy the task template: `cp ~/repos/aiad-claude/tasks/workflow_1_new_endpoint.md ./task.md`
4. Open `task.md` in the editor, fill in all `[PLACEHOLDER]` values, and save.
5. Launch Claude Code in the terminal: `claude`
6. Verify MCPs are loaded: type `/mcp` and confirm Jira, Context7, PostgreSQL, and GitLab are active.
7. Start execution: type `Please execute the implementation plan detailed in task.md.`
8. After completion, review: run `git diff`, check test output with `go test ./...`, and verify route registration in the router file.

**Common failure modes:** Claude drifts to sqlx (hook should catch via CLAUDE.md, but verify manually), missing context propagation on the HTTP request, or test tables not covering negative edge cases.

---

### Workflow 2: Refactor a Module to a New Pattern

**When to use:** The team is moving from direct DB calls to a repository pattern in a given module.
**Recommended mode:** Autonomous with subagents for large modules
**MCPs:** Serena <!-- Reason: The Serena MCP is strictly needed here to map symbol usages across modules prior to refactoring, avoiding expensive full-file reads -->, Context7 <!-- Reason: Validates library logic during the pattern refactor -->, PostgreSQL <!-- Reason: Verifies database schema implications -->
**Skills:** `golang-pattern`, `go-review`, `tdd`

**Step-by-step instructions:**
1. Define the before/after pattern explicitly in the `task.md`.
2. Ensure Serena is enabled; it is critical here to trace all usages without Claude blind-reading every file.
3. Feed the file to Claude. Review for consistency, unrefactored edge cases, and test passage.

**The task file:**
Use the `workflow_2_refactor.md` template from `aiad-claude/tasks/`. Copy it to your repo root, rename to `task.md`, and fill in the placeholders.

#### How to Execute (VS Code)

1. Open VS Code in the target repo: `code ~/repos/<service-name>`
2. Open the integrated terminal (`Ctrl+\`` or `Cmd+\``).
3. Copy the task template: `cp ~/repos/aiad-claude/tasks/workflow_2_refactor.md ./task.md`
4. Open `task.md`, define the before/after pattern with concrete code examples, and save.
5. Launch Claude Code: `claude`
6. Verify MCPs: type `/mcp` and confirm **Serena** (critical for this workflow), Context7, and PostgreSQL are active.
7. Start execution: type `Please execute the implementation plan detailed in task.md.`
8. After completion: run `git diff` to verify changes are scoped to the target module only, then run `go test ./...` to confirm all tests pass.

**Common failure modes:** Claude overzealously refactors files outside scope. Stricter constraints fix this. For overly convoluted spaghetti code, you may need to drop into interactive mode.

---

### Workflow 3: Review an Open GitLab MR Against Jira Acceptance Criteria

**When to use:** Doing a thorough self-review or pre-review before submitting to peers.
**Recommended mode:** Autonomous (short session, clear output)
**MCPs:** GitLab <!-- Reason: Directly pulls the MR diff and review comments from the repository -->, Jira <!-- Reason: Pulls the linked ticket to check the original acceptance criteria -->, Context7 <!-- Reason: Checks newly added library usage against current API documentation -->, Serena <!-- Reason: Enables navigation to symbol definitions affected by the MR diff -->
**Skills:** `code-review`, `pr-description`

**Step-by-step instructions:**
1. Start a session in the repo with the feature branch checked out.
2. Submit the below prompt (no `task.md` needed).
3. Review Claude's analysis, any changes it automatically implemented, and the generated description.

**The prompt:**
```text
Review the current branch's changes against the Jira ticket linked in the MR. Use the GitLab MCP to pull the MR diff and any reviewer comments. Use the Jira MCP to pull [TICKET-ID] and its acceptance criteria. Then:

1. Verify each acceptance criterion is met by the implementation.
2. Mark each as PASS, FAIL, or PARTIAL with a brief explanation.
3. Check the implementation against TipTip's conventions in CLAUDE.md. Flag any violations.
4. Check for missing test coverage on changed code paths.
5. If any acceptance criteria are FAIL or PARTIAL, make the necessary changes to the implementation — do not just report them.
6. When all criteria pass, generate a PR description using the pr-description skill.
```

#### How to Execute (VS Code)

1. Open VS Code in the repo with the feature branch checked out: `code ~/repos/<service-name>`
2. Confirm you are on the correct branch: `git branch --show-current`
3. Open the integrated terminal and launch Claude Code: `claude`
4. Verify MCPs: type `/mcp` and confirm GitLab, Jira, Context7, and Serena are active.
5. Paste the prompt above into the Claude Code session, replacing `[TICKET-ID]` with the actual Jira ticket key.
6. Let Claude run autonomously. It will pull the MR diff, check acceptance criteria, implement fixes if needed, and generate a PR description.
7. After completion: review `git diff` for any auto-applied changes, verify the generated PR description, and check that all acceptance criteria are marked PASS.

**Common failure modes:** GitLab MCP token expiry (check your token), or Claude assessing a PASS on a criterion due to superficial reading. Validate the reasoning, not just the verdict.

---

### Workflow 4: Generate Tests for Existing Code

**When to use:** Legacy code modified for a new feature lacks sufficient test coverage.
**Recommended mode:** Autonomous
**MCPs:** Serena <!-- Reason: Quickly maps dependencies and usages of the functions needing test coverage -->, PostgreSQL <!-- Reason: Helps Claude understand schema types to build robust database layer mocks -->, Context7 <!-- Reason: Pulls up-to-date assertions and mock library patterns -->
**Skills:** `tdd`, `golang-pattern`

**Step-by-step instructions:**
1. Identify the un-covered file.
2. Use the `task.md` template below.
3. Review edge case coverage, mock robustness, and assure no tests rely on `time.Sleep`.

**The task file:**
Use the `workflow_4_generate_tests.md` template from `aiad-claude/tasks/`. Copy it to your repo root, rename to `task.md`, and fill in the placeholders.

#### How to Execute (VS Code)

1. Open VS Code in the target repo: `code ~/repos/<service-name>`
2. Open the integrated terminal (`Ctrl+\`` or `Cmd+\``).
3. Copy the task template: `cp ~/repos/aiad-claude/tasks/workflow_4_generate_tests.md ./task.md`
4. Open `task.md`, fill in the target file path and coverage expectations, and save.
5. Launch Claude Code: `claude`
6. Verify MCPs: type `/mcp` and confirm Serena, PostgreSQL, and Context7 are active.
7. Start execution: type `Please execute the implementation plan detailed in task.md.`
8. After completion: run `go test ./... -cover` to verify coverage, check that no tests use `time.Sleep`, and review mock implementations for correctness.

---

### Workflow 5: One-Off PostgreSQL Query Review

**When to use:** You have written a complex analytics query or migration and want a review against the actual schema before running it.
**Recommended mode:** Interactive
**MCPs:** PostgreSQL (development/staging databases ONLY) <!-- Reason: Allows Claude to review the SQL query strictly against the actual database schema rather than guessing types/indexes -->
**Skills:** `postgres` (PlanetScale database skill)

**Step-by-step instructions:**
1. Secure the PostgreSQL MCP connection. Ensure it connects to your local dev DB, never production.
2. Paste the SQL query using the prompt below.
3. Review Claude's schema verification, performance analysis, and rewrites.

> ⚠️ **CRITICAL SAFETY NOTE**
> The PostgreSQL MCP in this workflow **must be pointed at a local development or staging database only.** Never connect Claude Code's PostgreSQL MCP to a production database. The "Do NOT execute" instruction in the prompt is a soft guard — the hard boundary is ensuring the MCP connection string never points to production.

**The prompt:**
```text
/postgres
Here is a query I'm about to run on the creator-service database:
[paste SQL query here]
Please review this query for:
1. Correctness against the actual schema (use the PostgreSQL MCP to verify table names, column names, and types)
2. Performance concerns — missing indexes, full table scans, N+1 patterns
3. Safety — could this lock tables? What is the blast radius if it runs incorrectly?

Suggest improvements or a safer alternative if relevant.
Do NOT execute this query. Review only.
```

#### How to Execute (VS Code)

1. Open VS Code in the service repo: `code ~/repos/<service-name>`
2. Ensure your local dev database is running and migrations are up to date: `make migrate-up` (or equivalent).
3. Open the integrated terminal and launch Claude Code: `claude`
4. Verify MCPs: type `/mcp` and confirm **PostgreSQL** is active and pointing to your **local dev DB** (never production).
5. Paste the prompt above into the session, replacing `[paste SQL query here]` with your actual query.
6. Review Claude's schema verification, performance analysis, and suggested rewrites. Apply improvements manually.

**Common failure modes:** Claude validates against a stale schema (make sure you ran migrations locally first). If Claude mistakenly tries to execute the query despite the instruction, immediately check your local DB state and report the session behavior.

---

### Workflow 6: Create a Feature Implementation Plan from a Jira Ticket

**When to use:** Deep feature work touching multiple services where upfront planning prevents wasted effort.
**Recommended mode:** Interactive
**MCPs:** Jira <!-- Reason: Pulls the foundational feature ticket and all linked requirements -->, Confluence <!-- Reason: Retrieves relevant ADRs and architectural contracts for planning -->, Serena <!-- Reason: Maps out affected codebase areas semantically without blind-reading files -->, Context7 <!-- Reason: Assesses third-party SDK viability directly from current docs -->, Sequential Thinking <!-- Reason: Forces Claude to explicitly structure and evaluate its plan step-by-step before finalizing -->
**Skills:** `plan`

**Step-by-step instructions:**
1. Start the session in the primary affected repo.
2. Prompt Claude to formulate a plan without writing code.
3. Push back on Claude interactively to refine scope, edge cases, and risks.
4. Once approved, generate sequential `task.md` files for the implementation steps.

**The prompt:**
```text
Pull Jira ticket [TICKET-ID] and all linked tickets.
Also pull the Confluence page [page-URL] which contains the relevant API contract / architecture context.
Using this context and the current codebase, create an engineering implementation plan that covers:

1. Scope: Which services, files, and APIs are affected?
2. Approach: What is the recommended implementation approach? What alternatives were considered and why were they rejected?
3. Implementation steps: Ordered list of concrete tasks. Each task should be small enough to be completed in one Claude Code session.
4. Database changes: Are schema migrations required? If so, what are they? Are they backward compatible?
5. Risks and unknowns: What could go wrong? What needs clarification before implementation begins?
6. Acceptance criteria: What does done look like? Phrase them as testable conditions.

Do not write any code yet. Output the plan as a markdown document I can review and refine before implementation begins.
```

#### How to Execute (VS Code)

1. Open VS Code in the primary affected repo: `code ~/repos/<service-name>`
2. Open the integrated terminal and launch Claude Code: `claude`
3. Verify MCPs: type `/mcp` and confirm Jira, Confluence, Serena, Context7, and Sequential Thinking are active.
4. Paste the prompt above, replacing `[TICKET-ID]` and `[page-URL]` with actual values.
5. **Stay interactive** — push back on Claude's plan if scope is too broad, edge cases are missing, or risks are underestimated.
6. Once the plan is satisfactory, ask Claude to generate sequential `task.md` files for each implementation step.
7. Review and save the generated plan and task files before starting implementation.

**Common failure modes:** Claude hallucinates a plan that looks plausible but misses a key upstream service dependency. Enforce Serena usage so Claude reads actual symbol usages, not just filenames.

---

### Workflow 7: Debug a Production Incident from Sentry Error

**When to use:** A production Sentry error is reported, requiring root cause diagnosis and a fix.
**Recommended mode:** Interactive
**MCPs:** Serena <!-- Reason: Traces the exact execution path and symbol relationships upward from the erroring line -->, Context7 <!-- Reason: Assesses if the error stems from a known third-party library issue or version mismatch -->, PostgreSQL <!-- Reason: Inspects the data constraints if the panic involves the DB layer -->, Sequential Thinking <!-- Reason: Prevents Claude from prematurely jumping to conclusions by forcing a structured, multi-step diagnosis of the root cause -->
**Skills:** `build-fix`, `systematic-debugging`

**Step-by-step instructions:**
1. Copy the raw Sentry error and the full stack trace.
2. Prompt Claude to trace the logic up the chain.
3. Review the root cause hypothesis. If Claude's diagnosis is superficial, push back.
4. Pivot to autonomous mode only after agreeing on the root cause and fix approach to generate the regression test and patch.

**The prompt:**
```text
Here is a production error from Sentry:
[paste full error message and stack trace]

Environment: [production/staging]
First seen: [timestamp]
Frequency: [how often it is occurring]

Using the systematic-debugging skill, work through this systematically:
1. Locate the exact line in our codebase where this originates
2. Trace the call chain upward to understand how we got there
3. Form a hypothesis for the root cause
4. Identify what data state or condition triggers this error
5. Propose a fix with an explanation of why it addresses the root cause
6. Identify what test would have caught this

Do not apply any fix yet — present the diagnosis and proposed fix for my review first.
```

#### How to Execute (VS Code)

1. Open VS Code in the affected service repo: `code ~/repos/<service-name>`
2. Open the integrated terminal and launch Claude Code: `claude`
3. Verify MCPs: type `/mcp` and confirm Serena, Context7, PostgreSQL, and Sequential Thinking are active.
4. Paste the prompt above, replacing the Sentry error details with the actual error message, stack trace, environment, timestamp, and frequency.
5. **Stay interactive** — review Claude's root cause hypothesis before allowing any fix. Push back if the diagnosis seems superficial.
6. Once you agree on the root cause and fix approach, tell Claude to proceed with the patch and regression test.
7. After completion: run `go test ./...` to confirm the regression test fails without the patch (revert temporarily) and passes with it.

**Common failure modes:** Fixing the symptom instead of the root cause. Insist on a test that fails without the patch and passes with it.

---

## 7. The Autonomous Loop and When to Interrupt

During an autonomous session, Claude executes a continuous sequence of file reads, bash commands, and edits toward the task goal. It self-corrects when test hooks return errors and re-evaluates when it hits a task constraint. 

Engineers do not need to watch every keystroke — but they should not fully disconnect. Check in periodically.

**Signals that warrant interruption:**
- Claude has made the same type of edit more than twice and it keeps failing (it is stuck in a correction loop — redirect it).
- Claude is asking to modify files completely outside the task scope (scope creep — halt and add the file to Constraints).
- Claude requests tool permissions that seem unrelated or dangerous.
- The session has run significantly longer than expected without reaching acceptance criteria.
- Hooks repeatedly block the same action (Claude fundamentally doesn't understand the restriction).

**How to interrupt cleanly:**
- Standard interrupt: `Ctrl+C` suspends the execution.
- Review what has been done via `git diff`.
- Commit what is good if it represents a coherent partial state.
- Adjust `task.md` with clarifications or new constraints.
- Resume with a fresh session referencing the updated `task.md`.

---

## 8. Future Work

This list bounds improvements planned for TipTip's Claude Code workflow. Engineers who implement these should submit an MR to `aiad-claude` describing their updates.

- **CI/CD Integration (Headless Mode):** Claude Code supports headless execution suitable for GitLab CI pipelines (e.g., auto-reviewing open MRs, or blocking commits on failure). Future considerations: managing CI credentials, controlling per-pipeline cost, and handling outputs robustly.
- **Per-Session Cost Management:** Currently, our GLM/Z.ai setup lacks hard per-session token budgets. Unmonitored complex autonomous sessions can rack up costs. We plan to evaluate ways to impose session-level token caps or a statusline spend UI.
- **Migration to Claude Code Subscription:** TipTip plans to migrate from GLM/Z.ai to an Anthropic Pro/Team subscription once ROI is fully proven. Native models provide higher reasoning quality without custom bridges.
- **Shared Team Context via Projects:** With an official Team subscription, "Projects" allow shared conversation history and memory mapped across the org, transcending localized per-machine CLAUDE.md files.
- **Workflow Metrics and Adoption Tracking:** Telemetry on which workflows yield the highest ROI via stop-hook logging aggregated into internal dashboards.

---

## 9. What to Expect from Engineers

### Engineering Lead Responsibilities
- **Set the standard:** Deliver guided walk-throughs of Workflow 1 and Workflow 3 to your team. Running an autonomous process incorrectly and cementing bad habits is worse than not running it at all.
- **Define mandatory operations:** Map which workflows are non-negotiable (e.g., Backend leads mandating Workflow 3 before any Go-service MR). Record these rules directly into the per-repo `CLAUDE.md`.
- **Review complex `task.md` payloads:** For massive multi-file overhauls or schema changes, Leads should peer-review the task file before the engineer hits enter.
- **Monitor scale and cost:** Keep an eye on Z.ai expenditure dashboards. Massive aberrations usually indicate an engineer whose sessions are deadlocking or over-scoping without interruption.
- **Standardize novel discoveries:** When an engineer crafts a highly effectively workflow sequence, merge it back to the cookbook in `aiad-claude`.

### Individual Engineer Responsibilities
- **Write `task.md` before starting:** For anything surpassing two files, documenting acceptance criteria is the highest-leverage habit you can build. Unscoped sessions drift.
- **Review output before committing:** Autonomous strictly doesn't mean "unreviewed". Claude can be wrong. The engineer is permanently responsible for the code merged, irrespective of who authored it.
- **Commit progress incrementally:** Break multi-session endeavors down. Do not stockpile uncommitted changes over 4 days.
- **Kill wandering sessions:** A session spinning for 10 minutes without hitting criteria should be killed via `Ctrl+C`. Do not squander tokens on an unguided trajectory.
- **Select modes intelligently:** Do not invoke interactive for pure boilerplate tests. Do not expect autonomous behaviors on abstract system-design choices without a plan.
- **Contribute IDE-Specific Workflows:** The execution instructions in this guide are written for VS Code, TipTip's recommended IDE. *However, if you use a different IDE (e.g., JetBrains GoLand, Neovim, IntelliJ), you are expected to contribute and maintain step-by-step execution documentation for your specific environment via Merge Requests to the `aiad-claude` repository.*

---

## 10. Quick Reference

### Workflow Decision

| Want to...                  | Workflow   | Mode        | Key MCPs                   |
| --------------------------- | ---------- | ----------- | -------------------------- |
| Add a Go API endpoint       | Workflow 1 | Autonomous  | Jira, Context7, PostgreSQL |
| Refactor a Go module        | Workflow 2 | Autonomous  | Serena, Context7           |
| Review MR before submission | Workflow 3 | Autonomous  | GitLab, Jira, Serena       |
| Add tests to existing code  | Workflow 4 | Autonomous  | Serena, PostgreSQL         |
| Review a SQL query          | Workflow 5 | Interactive | PostgreSQL                 |
| Plan a feature from Jira    | Workflow 6 | Interactive | Jira, Confluence, Serena   |
| Debug a Sentry error        | Workflow 7 | Interactive | Serena, Context7           |

### Task File Checklist

Before starting an autonomous session, confirm:
- [ ] `task.md` has a single clear Goal statement.
- [ ] Acceptance criteria are verifiable, not vague.
- [ ] Constraints explicitly specify your working branch name.
- [ ] Out of scope is explicitly listed.
- [ ] Relevant file references are appended.
- [ ] `task.md` is strictly added to your repository's `.gitignore`.

### Key Resources

| Resource                      | Link                                                            |
| ----------------------------- | --------------------------------------------------------------- |
| TipTip aiad-claude repository | https://gitlab.com/tiptiptv/common/aiad-claude                  |
| Claude Code common workflows  | https://docs.anthropic.com/en/docs/claude-code/common-workflows |
| PlanetScale database skills   | https://database-skills.preview.planetscale.com/                |
| Claude Code subagents         | https://docs.anthropic.com/en/docs/claude-code/sub-agents       |
| **Next in series**            | Guide 7 — Team Usage & Best Practices                           |
