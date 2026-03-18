# Guide 7 of 7: Team Usage & Best Practices

> 📋 This guide is the final guide in TipTip's Claude Code series.
> It is written primarily for engineering leads.
> Individual engineers should read Sections 4 (Onboarding Sequence)
> and 6 (What Not to Use Claude Code For) in full.
> All other sections are lead-facing but worth understanding for
> senior engineers who want visibility into how adoption is tracked.
> 
> *Note on Section Numbering:* The introductory summary refers to Section 7 for "When Not to Use", but it corresponds to Section 6 below based on the guide structure. Lead expectations are covered in Section 7.

---

## 1. Purpose of This Guide

Guides 1–6 covered setup and usage for individual engineers. This guide covers how TipTip sustains and scales Claude Code adoption as a team-level capability — not just a personal tool.

Adoption without measurement produces inconsistency. Some engineers become power users while others barely use it, and the team does not converge on shared practices. This guide gives engineering leads the tools to measure adoption, maintain quality, onboard new engineers systematically, and make data-driven decisions about when to migrate to an official Claude Code subscription.

Individual engineers benefit from understanding what is being measured and why — it sets expectations and helps them know what good usage looks like.

---

## 2. Adoption Metrics

Without tracking, it is impossible to know whether Claude Code is being adopted, whether it is being used well, or whether the cost is justified. 

Metrics are grouped into two categories:
- **Activity metrics:** Are engineers using Claude Code at all?
- **Quality metrics:** Are engineers using it well?

### Activity Metrics

#### Metric 1: Weekly PR Volume with Claude Code Attribution
**What it is:** The number of PRs per week that were assisted by Claude Code (i.e., the engineer used Claude Code during development of that branch).

**Why it matters:** The most direct signal of whether engineers are integrating Claude Code into their daily workflow versus treating it as an occasional experiment.

**Success threshold:**
- Week 1–2 of adoption: any usage is a success 
- Week 4–6: target 50% of PRs on active features have Claude Code involvement
- Week 8+: target 70%+ of feature PRs involve Claude Code for at least one workflow (test generation, PR description, code review)

**How to track:**
- Lightweight: ask engineers to add a `[claude-assisted]` label or tag to GitLab MRs where Claude Code was used. Track label frequency in GitLab's MR analytics.
- Automated: the Stop hook from Guide 5 appends a session log to `.claude-session-log.md`. Engineers commit this file to a private tracking branch or push session summaries to a shared sheet.
- Manual: weekly quick check in the #aiad-discussion Google Chat channel — leads ask engineers to share what they used Claude Code for that week. This also drives knowledge sharing (Section 5).

---

#### Metric 2: Skill Invocation Frequency
**What it is:** How often named skills (Guide 3) are being invoked across the team — which skills are used daily, which are rarely used, and which are never used.

**Why it matters:** If the must-have skills (`pr-description`, `code-review`, `write-test`) are not being invoked regularly, it indicates either that engineers are not using Claude Code for these tasks, or that the skills are not working well enough to be trusted.

**Success threshold:**
- `pr-description`: invoked for at least 60% of MRs within 8 weeks
- `code-review`: invoked at least once per engineer per sprint
- `write-test`: invoked at least once per engineer per week on active feature work

**How to track:**
- Add a logging line to each skill's markdown file that appends an entry to a local `.claude-skill-log.jsonl` file on invocation. Example log entry: `{"skill": "pr-description", "timestamp": "...", "repo": "...", "user": "..."}`
- Aggregate the `.claude-skill-log.jsonl` files from each engineer's machine weekly (engineers paste their log into a shared Google Sheet or the lead runs a script to collect from committed log files).
- Alternative: the Stop hook can capture which skills were invoked during the session and include them in the session summary.

---

#### Metric 3: MCP Usage Patterns
**What it is:** Which MCPs are being called in sessions, and with what frequency. Are the must-have MCPs (Jira, Context7, Serena) being invoked, or are engineers running sessions without MCP context?

**Why it matters:** Sessions without MCP context produce lower-quality output for tasks that require live data (Jira acceptance criteria, current library docs, schema-aware SQL). If MCPs are installed but not being invoked, something is wrong — either the MCPs are failing silently, or engineers are not using the right workflows.

**Success threshold:**
- Jira MCP: invoked in sessions where a Jira ticket is the source of the work (target: 80% of feature sessions within 8 weeks)
- Context7: invoked at least once per session where library APIs are used
- Serena: invoked in sessions involving navigation of large codebases or refactoring tasks

**How to track:**
- The Stop hook can log MCP tool call names from the session summary if Claude Code exposes this data in the stop event.
- Manual proxy: check Context7 and Jira usage from their dashboards (Context7 has an API key — check request volume; Jira has audit logs).
- Lead observation: review a sample of session logs monthly to check whether MCP tool calls appear in the output.

---

#### Metric 4: Session Length and Token Consumption
**What it is:** How long each Claude Code session runs (in minutes or tool calls) and how many tokens are consumed per session. This is the most important cost metric.

**Why it matters:** Session length and token consumption are the primary drivers of cost in the current GLM/Z.ai setup. Very long sessions with high token counts may indicate either complex, high-value work — or engineers running unfocused sessions without task files, leading to context bloat and wasted spend. 

**Success threshold:**
- Average session: under 30 minutes for a focused task (Guide 6 workflow)
- Token consumption per session: establish a baseline in weeks 1–2, then flag sessions that are 3x the baseline as outliers for review.
- Cost per engineer per week: establish a target based on Z.ai pricing for expected volume. Flag engineers who are consistently 2x the team average.

**How to track:**
- **Z.ai Dashboard:** *(Note: Detailed documentation for Z.ai usage drill-downs is currently unverified.)* If Z.ai exposes per-user or per-session Token breakdown in their billing dashboard, use it as the primary tracking mechanism. 
- **Stop hook:** The Stop hook from Guide 5 captures session end events. Extend it to log session duration (start time from first tool call, end time from stop event).
- **Claude Code Native Reporting:** Use built-in `/cost` tracking commands (if natively available) at the end of sessions and encourage engineers to log this data.
- **Weekly aggregate:** Collect Stop hook logs from all engineers, sum tokens per engineer per week, and share the aggregate (not individual) view with the team so everyone understands the consumption level.

---

### Quality Metrics

#### Metric 5: Hook Intervention Rate
**What it is:** How often hooks are blocking or correcting Claude's output — specifically, how often the Go lint hook, ESLint hook, secret guard, and SQL guard are firing with non-zero exit codes.

**Why it matters:** Hook interventions are signal. A high intervention rate means Claude is producing code that needs correction, which could indicate the `CLAUDE.md` conventions need to be more explicit, or the engineer is using Claude on tasks that need more constraint. A zero intervention rate may mean hooks are not actually running.

**Success threshold:**
- Secret guard and SQL guard: should fire rarely. More than 1 fire per engineer per week is a signal that task constraints need tightening.
- Lint and format hooks: some interventions are expected and healthy — they are doing their job. A complete absence suggests they are not running. Target: firing on at least 20% of file-write operations (indicating active enforcement), with Claude resolving the issue on the first correction in 90%+ of cases.

**How to track:**
- Extend hook scripts from Guide 5 to append to `.claude-hook-log.jsonl` on every intervention (blocked or corrected). Log: hook name, tool that triggered it, intervention type, timestamp.
- Aggregate weekly — similar pattern to skill logging.

---

#### Metric 6: CLAUDE.md Update Frequency
**What it is:** How often per-repo and global `CLAUDE.md` files are updated via MR, and what type of changes are made.

**Why it matters:** A `CLAUDE.md` that is never updated after initial creation is either perfect (unlikely) or stale (much more likely). Regular updates indicate the refinement loop from Guide 2 is working — engineers are identifying gaps in Claude's context and filling them. Zero updates after the first month is a red flag.

**Success threshold:**
- Per-repo `CLAUDE.md`: at least one update per active repo per month during the first 3 months, settling to at least one update per quarter once the file matures.
- Global stack `CLAUDE.md`: at least one lead-driven review and update per quarter.

**How to track:**
- GitLab MR history: filter MRs that touch `CLAUDE.md` files. This is the simplest and most accurate tracking method — no additional tooling required.
- Track via GitLab's contribution graphs on the `aiad-claude` repository for global files.

---

#### Metric 7: Rework Rate on Claude-Assisted Code
**What it is:** The proportion of code written with Claude Code assistance that requires significant rework in peer review — comments requesting substantial changes, reviewer rejection, or post-merge fixes.

**Why it matters:** This is the ultimate quality signal. If Claude-assisted code requires the same amount of rework as non-Claude code, Claude Code is not improving output quality. If it requires significantly more rework, engineers are not reviewing Claude's output carefully enough.

**Success threshold:**
- Target: Claude-assisted code should require equal or fewer significant review comments than non-Claude code by week 8 of adoption.
- Zero significant security or data handling review comments on Claude-assisted code at any time.

**How to track:**
- Imprecise but practical: leads make a qualitative assessment during monthly code review retrospectives. This does not need to be automated — a lead who reviews PRs regularly will develop intuition for whether Claude-assisted code is improving or degrading review quality.
- GitLab review comment tracking: count review comment threads per MR on Claude-labeled MRs vs non-labeled. Compare monthly.

---

### Metrics Summary Table

| Metric | Category | Success Threshold (Week 8) | Tracking Method |
|---|---|---|---|
| PR volume with Claude | Activity | 70%+ feature PRs | GitLab MR labels |
| Skill invocation | Activity | 3 must-have skills used weekly | Skill log file |
| MCP usage | Activity | Jira + Context7 in 80% of feature sessions | Stop hook + dashboard |
| Session length & tokens | Activity | Avg <30 min, cost within team baseline | Z.ai dashboard + Stop hook |
| Hook intervention rate | Quality | Lint fires on 20%+ writes, Claude resolves 90%+ | Hook log file |
| `CLAUDE.md` update freq | Quality | 1+ update per active repo per month | GitLab MR history |
| Rework rate | Quality | Equal or fewer review comments vs non-Claude code | Lead assessment |

*Note: Metrics do not need to be tracked with perfect precision. The goal is directional signal — are engineers using Claude Code, and is the output getting better? A lead who checks GitLab labels, glances at the Z.ai dashboard, and asks the team weekly will get 80% of the signal with 20% of the effort.*

---

## 3. The Migration to Claude Code Subscription

This section provides the decision framework for when TipTip migrates from the current GLM/Z.ai setup to an official Claude Code subscription.

### Why Claude Max, Not Claude Pro

- **Claude Pro** provides standard limits suited for individual ideation but places firm message caps on users during high-throughput coding tasks. Autonomous engineering tools easily hit these session rate limits.
- **Claude Max** is the target tier because it officially supports removing these exact limits: offering **5x or 20x more usage** than Pro, alongside higher output limits for complex tasks, and priority network access. 
- However, Claude Max is a per-user, per-month subscription at a fixed cost. For TipTip's current team size and usage patterns, this may cost more than the pay-per-token GLM setup — especially if a significant portion of the team's tasks are handled well by GLM-4.7 at $0.38/$1.98 per million tokens.
- The migration decision is not "GLM is worse, Claude is better" — it is "has our usage volume and complexity reached the point where a per-seat subscription is more cost-effective than per-token billing, AND do we need native Claude capabilities that GLM cannot provide?"

### Migration Decision Criteria

TipTip should consider migrating when the majority of these are true:

**Cost threshold:**
- [ ] The team's aggregate monthly Z.ai token cost exceeds `[Claude Max monthly price] × [Number of active engineers]`. When per-token cost exceeds flat subscription cost, the subscription wins on economics.

**Capability gaps:**
- [ ] Engineers are regularly encountering tasks where GLM-4.7 produces materially worse output than Claude models, requiring significant manual correction (track via the rework rate metric).
- [ ] The team needs the Claude Code Projects feature for shared team memory that persists across machines (not possible with per-machine `CLAUDE.md` alone).
- [ ] Extended thinking or reasoning capabilities available in Claude Max are needed for complex architecture or debugging tasks where GLM reasoning is insufficient.

**Team maturity threshold:**
- [ ] At least 70% of active engineers have completed all 7 guides and are actively using skills and MCP integrations in their daily workflow.
- [ ] The team has stable, maintained `CLAUDE.md` files for all active repos.
- [ ] The `aiad-claude` repository has a mature skill set that would benefit from native Claude model quality improvements.

**Operational threshold:**
- [ ] TipTip has a dedicated budget line for AI tooling that can absorb the per-seat subscription cost predictably (vs the variable per-token GLM cost).

### What Changes When TipTip Migrates

When migration happens, engineers need to understand what changes:
- Guide 1 environment variable configuration changes significantly: `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY`, `ANTHROPIC_MODEL`, and `ANTHROPIC_SMALL_FAST_MODEL` all change. A migration checklist will be published as a Guide 1 amendment when migration is confirmed.
- `CLAUDE.md` files are fully compatible — no changes needed.
- Skills are fully compatible — no changes needed.
- MCP configurations are fully compatible — no changes needed.
- Hook scripts are fully compatible — no changes needed.
- The model selection guidance in Guide 1 changes: `ANTHROPIC_MODEL` becomes a native Claude model, `ANTHROPIC_SMALL_FAST_MODEL` becomes Claude Haiku 3 or 3.5. The pricing and tier analysis in Guide 1 is replaced with subscription billing instructions.

### Interim Position

TipTip's current view:
- GLM-4.7 via Z.ai provides a strong value proposition for the onboarding phase: pay-per-token, no seat commitment, access to all Claude Code tooling (skills, MCPs, hooks, workflows).
- The migration to Claude Max is a future decision, not an immediate goal.
- Engineers should **not** self-upgrade to individual Claude subscriptions without team coordination — it fragments the team onto different model setups and makes quality comparison and tooling consistency difficult.

---

## 4. Onboarding Sequence

This section defines the expected ramp for new TipTip engineers joining the Claude Code program — both engineers who are new to TipTip and existing engineers who are onboarding to Claude Code for the first time.

The key principle: **do not give engineers all seven guides at once.** Overloading engineers at the start leads to incomplete setup and surface-level usage. The sequence below is designed to build genuine proficiency through use at each stage before moving to the next.

### Expected Full Proficiency Timeline: 6 Weeks

#### Phase 1 — Week 1: Core Setup and Habits (Guides 1, 2, 3)

**What to complete:**
- Guide 1: Setup — install Claude Code, configure Z.ai/GLM, verify the connection, understand the model tiers.
- Guide 2: `CLAUDE.md` — install the global stack `CLAUDE.md` for your primary stack, confirm the per-repo `CLAUDE.md` exists for your first active repo (lead provides this if it does not exist).
- Guide 3: Skills — install the TipTip skill set from `aiad-claude`, practice invoking the 5 must-have engineering-wide skills at least once each on a real task.

**Expected behavior by end of Week 1:**
- Engineer runs Claude Code daily for at least one task.
- At minimum: `pr-description` and `git-commit` skills are used for every applicable MR and commit.
- Engineer has identified at least one thing the `CLAUDE.md` for their repo got wrong or was missing, and has opened an MR to fix it.

**Lead action during Week 1:**
- Pair with the new engineer for their first Claude Code session on a real task — not a tutorial task, a real piece of work.
- Confirm the per-repo `CLAUDE.md` is accurate for the repos the engineer will work on.
- Point the engineer to `#aiad-discussion` on Google Chat.

---

#### Phase 2 — Weeks 2–3: Active Skills Usage

**What to complete:**
- No new guides — this phase is about developing habits with Guides 1–3.
- Engineer uses Claude Code for at least 3 different task types during this period: writing code, generating tests, and reviewing their own code before MR submission.
- Engineer uses the `debug-trace` or `systematic-debugging` skill on at least one real bug or error during this period.

**Expected behavior by end of Week 3:**
- Engineer reaches for Claude Code automatically for covered task types without being reminded.
- Engineer has invoked at least 4 distinct skills from the must-have list.
- Engineer has shared at least one observation or workflow tip in `#aiad-discussion`.

**Lead action during Weeks 2–3:**
- Light check-in: ask the engineer what they have used Claude Code for this week in the next 1:1. If the answer is nothing or just one thing, it is a signal to investigate whether there is a setup issue or habit gap.

---

#### Phase 3 — Week 3–4: MCP Integrations (Guide 4)

**What to complete:**
- Guide 4: MCP Integrations — install global MCPs (Context7, Sequential Thinking, Jira, Confluence, GitLab) and project-level MCPs for the engineer's primary repo (Serena, PostgreSQL for backend engineers, Figma for frontend engineers).
- Run at least one session with Jira MCP pulling a real ticket.
- Run at least one session with Context7 active on a task involving a library the engineer recently looked up documentation for manually.

**Expected behavior by end of Week 4:**
- Engineer no longer manually copies Jira ticket descriptions into Claude Code sessions — the MCP handles it.
- Engineer notices when Claude suggests a deprecated API and uses Context7 to get the current version.

**Lead action during Week 4:**
- Verify the engineer's project-level `.mcp.json` is committed to their primary repo and the MCPs are loading correctly.
- If the engineer is a backend engineer, confirm the PostgreSQL MCP is pointed at a local or staging database — not production.

---

#### Phase 4 — Week 4–5: Hooks (Guide 5)

**What to complete:**
- Guide 5: Hooks — install the hook scripts from `aiad-claude` for the engineer's stack, commit the `.claude/settings.json` (or verify global `~/.claude/settings.json`) to their primary repo if it is not already there.
- Verify at least one hook fires correctly in a real session (lint hook for Go engineers, ESLint hook for frontend engineers).

**Expected behavior by end of Week 5:**
- Engineer is not manually running lint after Claude edits — the hook handles it automatically.
- Engineer has seen the secret guard hook fire at least once (in a test scenario if not organically) and understands what it does.

**Lead action during Week 5:**
- Confirm project hooks are committed to the repo and not just installed locally on the engineer's machine.
- Validate the secret guard and SQL guard hooks are functioning (run a test invocation from the terminal as shown in Guide 5).

---

#### Phase 5 — Week 5–6: Workflows (Guide 6)

**What to complete:**
- Guide 6: Workflows — read the full guide, run at least two workflows from the cookbook on real tasks:
  - Workflow 3 (MR review) before the next MR submission.
  - One workflow from Workflows 1, 2, 4, or 6 depending on what active work is available.

**Expected behavior by end of Week 6:**
- Engineer is writing `task.md` files for autonomous sessions touching more than 2 files.
- Engineer has run at least one autonomous session end-to-end without interrupting it unnecessarily.
- Engineer is comfortable judging when to use interactive vs autonomous mode.

**Lead action during Week 6:**
- Review the engineer's first autonomous session output together — look at the `task.md` they wrote, the diff Claude produced, and discuss what worked and what to improve.
- Consider this the formal completion of the onboarding sequence.

---

#### Onboarding Summary Table

| Phase | Weeks | Guides | Key Milestone |
|---|---|---|---|
| Core Setup | 1 | 1, 2, 3 | Using skills daily; `CLAUDE.md` refined once |
| Habits | 2–3 | *(practice)* | 4 skills used; sharing in `#aiad-discussion` |
| MCPs | 3–4 | 4 | Jira MCP used for ticket context; Context7 active |
| Hooks | 4–5 | 5 | Lint hook firing; hooks committed to repo |
| Workflows | 5–6 | 6 | Two cookbook workflows completed |
| Full proficiency | 6+ | 7 *(this guide)* | Lead assessment: autonomous + skills + MCPs daily |

*Note: Guide 7 (this guide) is not part of the onboarding sequence. Engineers read it as a reference once they are proficient. It is required reading for engineering leads from the start.*

---

## 5. Knowledge Sharing Norms

TipTip uses specific channels and practices to share Claude Code discoveries, improvements, and patterns across the engineering team.

### The #aiad-discussion Channel (Google Chat)

TipTip's primary knowledge sharing channel for Claude Code and AI-assisted development is **`#aiad-discussion`** on Google Chat.

**What goes in `#aiad-discussion`:**
- Workflow discoveries: *"I found that running the postgres skill before writing a migration saves me from schema mistakes — here's how"*
- Skill improvement proposals: *"The code-review skill misses our new error handling pattern — here's a proposed fix"*
- Unusual Claude behavior: *"Claude keeps suggesting sqlx despite the `CLAUDE.md` rule — anyone else seeing this?"*
- MCP issues: *"The Jira MCP token expires every 30 days — reminder to rotate before your next session"*
- Cost observations: *"My session cost spiked this week on the refactor — turned out I forgot to invoke Serena and Claude read 40 files manually"*
- Questions about which workflow to use for a new type of task

**What does NOT go in `#aiad-discussion`:**
- Full session logs or large code pastes (use GitLab snippets or Confluence and share the link)
- Sensitive code, credentials, or PII — even accidentally
- General coding questions that are not Claude Code specific

### Monthly Demo Session

Engineering leads should organize a brief monthly demo (30 minutes max) where one engineer shares a Claude Code workflow that saved time or produced notably good output that month. 

**Format:**
1. Show the task or problem
2. Show the Claude Code approach (`task.md`, skills invoked, MCPs active)
3. Show the output
4. What would have taken without Claude Code vs with

This is not a formal presentation — it is a 15-minute walkthrough followed by 15 minutes of team discussion. The purpose is to make good workflows visible so they spread naturally through the team.

### Formal Improvement Path: aiad-claude MRs

The formal channel for improving Claude Code tooling (skills, hooks, `CLAUDE.md` templates, `.mcp.json` templates) is merge requests to:
`https://gitlab.com/tiptiptv/common/aiad-claude`

Anything that comes up in `#aiad-discussion` that represents a systematic improvement — not just a one-off — should be formalized as an `aiad-claude` MR. The person who raises the issue in `#aiad-discussion` is expected (but not required) to open the MR. If they do not, the lead should tag someone to pick it up.

### Quarterly Review

Leads conduct a quarterly review covering:
- **Metrics check:** how are the 7 metrics from Section 2 trending?
- **`CLAUDE.md` review:** are global stack files still accurate?
- **Skill review:** which skills are underused and why?
- **MCP review:** are all MCPs still functioning? Any new MCPs worth adding?
- **Onboarding assessment:** how did engineers who joined this quarter ramp up?
- **Future work:** review Section 8 of Guide 6 — is any Future Work item now ready to implement?

The output of each quarterly review should be: a Confluence page summarizing findings, a list of `aiad-claude` MRs to open, and any updates to this guide series.

---

## 6. What Not to Use Claude Code For

> 🚨 **Mandatory Boundary Checks** 🚨
> This section is required reading for all engineers, not just leads. These are not suggestions. This boundary protects TipTip's systems and data.

### Never: Production Database Mutations

**Prohibited:** Running any INSERT, UPDATE, DELETE, or schema-altering command (ALTER TABLE, DROP TABLE, CREATE INDEX CONCURRENTLY) against a production database via Claude Code — even through a reviewed session, even with the SQL guard hook active.

**Why:** The SQL guard hook is a development-time safety net, not a production authorization mechanism. Claude Code does not have audit trail integration with TipTip's production database access controls. Any production database change must go through TipTip's standard change management process: migration file reviewed in MR, applied by a human via the approved deployment pipeline.

**What to do instead:** Use Claude Code to write and review migration files. Apply migrations through the deployment pipeline. Use Claude Code with the PostgreSQL MCP only against local development or staging databases.

---

### Never: Infrastructure Changes Without Human Review

**Prohibited:** Using Claude Code autonomously to modify Terraform, Kubernetes manifests, CI/CD pipeline configuration, cloud resource configurations, or any infrastructure-as-code that affects production or staging environments — without a human reviewing the output before it is applied.

**Why:** Infrastructure changes have blast radius that extends beyond the file being edited. A Kubernetes resource limit change, a security group rule, or a CI job modification can take down services or expose vulnerabilities. Claude Code can generate and review these changes, but it cannot understand the full blast radius of infrastructure decisions the way a senior engineer can.

**What to do instead:** Use Claude Code interactively to draft infrastructure changes — it can produce good Terraform or YAML. Treat the output as a draft that requires senior engineer review before any apply or commit to a deployment branch. Never run `terraform apply` or `kubectl apply` as part of a Claude Code autonomous session.

---

### Never: Security-Sensitive Configuration Without Review

**Prohibited:** Using Claude Code autonomously to generate, modify, or rotate: API keys and secrets, OAuth client configurations, JWT signing secrets, encryption key material, CORS configurations, Content Security Policy rules, or any security policy configuration.

**Why:** Security configuration mistakes are silent until they are exploited. Claude Code can reason about security configuration but does not have full context of TipTip's threat model, existing attack surface, or compliance requirements. These changes require human security judgment, not LLM pattern matching.

**What to do instead:** Use Claude Code in interactive mode to discuss and reason through a security configuration change — it can be a useful thinking partner. But the actual change must be written by a human engineer, reviewed by a second engineer, and applied manually. Never give Claude Code write access to `.env.production`, secrets managers, or vault configuration files.

---

### Never: Autonomous Operations Involving PII Outside CLAUDE.md Rules

**Prohibited:** Using Claude Code to autonomously read, process, transform, export, or reason about Personally Identifiable Information (PII) in ways not explicitly governed by the security rules in `CLAUDE.md` — specifically: user email addresses, phone numbers, payment card data, national ID numbers, or any data covered by Indonesia's Personal Data Protection Law (UU PDP).

**Why:** PII handling requires explicit consent, purpose limitation, and audit trail. Claude Code sessions do not provide an audit trail of what data was accessed or how it was used. Even in a well-intentioned debugging session, if Claude reads a database record containing user PII to debug a payment issue, that access may not be compliant with TipTip's data handling obligations.

**What to do instead:** Anonymize or mock PII before using it in Claude Code sessions. If a debugging task genuinely requires access to real user data, follow TipTip's data access request process — Claude Code is not part of that process. When in doubt, ask the engineering lead before the session, not after.

---

### Use With Caution: Authentication and Authorization Logic

**Not prohibited but requires careful review:** Claude Code can write authentication middleware, authorization checks, and permission logic. However, this code must receive thorough human review before merging — more thorough than average code review.

Authentication and authorization bugs are among the most consequential defects in TipTip's systems. Claude Code can produce plausible-looking auth code that has subtle logical errors (checking the wrong condition, using a comparison that works for most cases but fails on edge cases).

**Guidance:** Use Claude Code to write auth logic, but explicitly invoke the `code-review` skill focused on security, and require a second reviewer who is familiar with TipTip's auth architecture before any auth-related MR merges.

---

### Use With Caution: Payment and Financial Calculation Logic

**Not prohibited but requires careful review:** Given TipTip's creator payout and wallet management domain, payment calculation logic is high-stakes. Claude Code can write this logic, but must follow the constraints in the creator-service `CLAUDE.md` strictly: int64 for all currency, no floating point, pgx transactions for multi-table updates.

**Guidance:** All payment and financial calculation code produced by Claude Code must have explicit unit tests covering boundary conditions, and must be reviewed by an engineer who understands the financial domain — not just the code structure.

---

### Summary: Autonomous vs Review Required vs Prohibited

| Task Type | Claude Code Usage | Requirement |
|---|---|---|
| Writing feature code | Autonomous ✅ | Standard MR review |
| Generating tests | Autonomous ✅ | Verify edge case coverage |
| PR description | Autonomous ✅ | Engineer reads before submitting |
| Code review | Autonomous ✅ | Engineer validates assessment |
| SQL query review | Interactive ✅ | Never execute on production |
| Auth/authz logic | Interactive ⚠️ | Mandatory second reviewer |
| Payment logic | Interactive ⚠️ | Domain expert review required |
| Infrastructure changes | Interactive ⚠️ | Senior review before apply |
| Production DB mutations | Prohibited ❌ | Use deployment pipeline only |
| Security config changes | Prohibited ❌ | Human authorship required |
| PII operations outside `CLAUDE.md` | Prohibited ❌ | Follow data access process |

---

## 7. What to Expect from Engineering Leads

Engineering leads are accountable for bringing these guidelines into reality. Below is the top-level accountability list for leads running Claude Code for their team:

1. **Metrics tracking:** Running the 7 adoption metrics monthly and sharing directional findings with the team. Not precision reporting — directional signal.
2. **Migration decision:** Owning the decision framework for when TipTip migrates to Claude Max, and presenting the analysis to the engineering leadership when the criteria are approaching.
3. **Onboarding quality:** Personally pairing with each new engineer during their Phase 1 (Week 1) Claude Code session. The onboarding sequence does not work on paper alone.
4. **`#aiad-discussion` facilitation:** Participating actively in the Google Chat channel. If the channel goes quiet for a week, the lead prompts the team with a question or observation from their own Claude Code usage that week.
5. **Monthly demo organization:** Scheduling and facilitating the monthly 30-minute demo session. If no engineer volunteers to present, the lead presents.
6. **Quarterly review:** Conducting the quarterly review of metrics, `CLAUDE.md` files, skills, and MCPs. Publishing the findings to Confluence.
7. **Boundary enforcement:** Ensuring the prohibited usage list in Section 6 is understood by every engineer on the team. If a prohibited use is observed, addressing it directly and updating `CLAUDE.md` or hook configuration to prevent recurrence.
8. **`aiad-claude` stewardship:** Owning the review and merge of MRs to `aiad-claude` for their domain (backend lead for Go files, frontend lead for Next.js files). MRs should not sit unreviewed for more than one week.

---

## 8. Quick Reference

### Metrics Tracking Checklist (Monthly)

| Metric | How to Check | Takes How Long |
|---|---|---|
| PR volume with Claude label | GitLab MR filter by label | 5 minutes |
| Skill invocation frequency | Collect skill log files | 10 minutes |
| MCP usage | Stop hook logs + Context7 dashboard | 10 minutes |
| Session length and tokens | Z.ai billing dashboard | 5 minutes |
| Hook intervention rate | Hook log files | 5 minutes |
| `CLAUDE.md` update frequency | GitLab MR history on `CLAUDE.md` files | 5 minutes |
| Rework rate | Qualitative assessment in team retro | 10 minutes |

### Migration Decision Checklist

| Criteria | Check |
|---|---|
| Monthly Z.ai cost > (Claude Max price × team size) | [ ] |
| GLM rework rate materially worse than Claude models | [ ] |
| Team needs Projects feature for shared memory | [ ] |
| 70%+ engineers fully proficient (all 7 guides) | [ ] |
| Stable `CLAUDE.md` for all active repos | [ ] |
| Dedicated AI tooling budget line established | [ ] |

### Knowledge Sharing Channels

| Channel | Purpose | Cadence |
|---|---|---|
| `#aiad-discussion` (Google Chat) | Daily Q&A, discoveries, issues | Ongoing |
| Monthly demo session | Workflow showcases | Monthly |
| `aiad-claude` MRs | Formal tooling improvements | As needed |
| Confluence quarterly review | Metrics, findings, updates | Quarterly |

### Key Links

| Resource | Link |
|---|---|
| TipTip `aiad-claude` repository | `https://gitlab.com/tiptiptv/common/aiad-claude` |
| Claude Code official docs | `https://docs.anthropic.com/en/docs/claude-code` |
| Z.ai pricing and dashboard | `https://z.ai` |
| Claude Max pricing | `https://www.anthropic.com/pricing` |
| `#aiad-discussion` | Google Chat |

---
**This marks the conclusion of TipTip's Claude Code internal guide series.** The documentation within Guides 1–7 establishes the foundation, but standardizing and continually improving workflows lives within `#aiad-discussion` and `aiad-claude`.

**Remember**: AI-assisted development is no longer an optional skill. We expect all TipTip engineers to comfortably use AI (via Claude Code) within their daily workflow—and this competency is now expected as part of standard performance expectations.
