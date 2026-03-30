# Guide 7 of 7: Team Usage & Best Practices

> 📋 Final guide in TipTip's Claude Code series.
> Written primarily for engineering leads.
> Individual engineers: read Sections 4 (Onboarding) and 6 (What Not to Use Claude Code For) in full. Everything else is lead-facing but worth understanding.

---

## 1. Purpose

Guides 1–6 covered setup and usage for individual engineers. This guide covers how TipTip sustains and scales Claude Code as a **team-level capability** — not just a personal tool.

Without measurement, adoption fragments. Some engineers become power users, others barely touch it, and the team doesn't converge on shared practices. This guide gives leads the tools to track adoption, maintain quality, onboard engineers, and decide when to migrate to an official subscription.

---

## 2. Adoption Metrics

Two categories: **Activity** (are engineers using it?) and **Quality** (are they using it well?).

### Activity Metrics

#### Weekly PR Volume with Claude Code Attribution

Most direct signal of whether Claude Code is part of daily workflow or just an experiment.

**Targets:**
- Weeks 1–2: any usage = success
- Weeks 4–6: 50% of feature PRs involve Claude
- Week 8+: 70%+

**How to track:** Add a `[claude-assisted]` label to GitLab MRs. Alternatively, the Stop hook appends session logs — aggregate weekly. Simplest: ask in `#aiad-discussion` what people used it for that week.

---

#### Skill Invocation Frequency

Which skills are used daily, rarely, or never. If `pr-description`, `code-review-golang`/`code-review-nextjs`/`code-review-flutter` (as applicable per stack), and `tdd` aren't invoked regularly, either engineers aren't using Claude for those tasks or the skills aren't trusted.

**Targets (week 8):** `pr-description` on 60%+ of MRs, `code-review-golang` or `code-review-nextjs` (as applicable) once per engineer per sprint, `tdd` once per engineer per week on active feature work.

**How to track:** Add a logging line to each skill's markdown that appends to `.claude-skill-log.jsonl`. Aggregate weekly.

---

#### MCP Usage Patterns

Are sessions running with or without MCP context? Sessions without Jira/Context7/Serena produce lower-quality output for tasks that need live data.

**Targets (week 8):** Jira MCP in 80% of feature sessions, Context7 at least once per session using library APIs, Serena in refactoring tasks.

**How to track:** Stop hook logs, MCP dashboard request volume, or lead spot-checking session logs monthly.

---

#### Session Length and Token Consumption

Primary cost driver. Long sessions with high token counts = either complex high-value work or unfocused sessions without task files (context bloat, wasted spend).

**Targets:** Average session under 30 minutes. Flag sessions 3× the baseline. Flag engineers consistently 2× team average cost.

**How to track:** Z.ai billing dashboard, Stop hook for session duration, `/cost` command at session end.

---

### Quality Metrics

#### Hook Intervention Rate

How often hooks block or correct Claude's output. High intervention = `CLAUDE.md` needs more explicit conventions. Zero intervention = hooks probably aren't running.

**Targets:** Secret/SQL guard: rare (~1 fire per engineer per week max). Lint hooks: firing on ~20% of writes (healthy enforcement), Claude resolving on first try 90%+ of the time.

---

#### CLAUDE.md Update Frequency

A file never updated after creation is either perfect (unlikely) or stale (much more likely). Regular updates = the refinement loop from Guide 2 is working.

**Targets:** 1+ update per active repo per month (first 3 months), settling to 1+ per quarter. Global files: lead-driven review once per quarter.

**How to track:** GitLab MR history filtering on `CLAUDE.md` files. No tooling needed.

---

#### Rework Rate on Claude-Assisted Code

The ultimate quality signal. If Claude-assisted code requires more rework than non-Claude code, engineers aren't reviewing output carefully enough.

**Targets (week 8):** Equal or fewer significant review comments vs non-Claude code. Zero security/data handling review comments at any time.

**How to track:** Lead qualitative assessment during code review retros. Count GitLab review threads on Claude-labeled MRs vs non-labeled.

---

### Metrics Summary

| Metric                  | Category | Target (Week 8)                             | Tracking                   |
| ----------------------- | -------- | ------------------------------------------- | -------------------------- |
| PR volume with Claude   | Activity | 70%+ feature PRs                            | GitLab MR labels           |
| Skill invocation        | Activity | 3 must-have skills weekly                   | Skill log file             |
| MCP usage               | Activity | Jira + Context7 in 80% of feature sessions  | Stop hook + dashboard      |
| Session length & tokens | Activity | Avg <30 min, cost within baseline           | Z.ai dashboard + Stop hook |
| Hook intervention rate  | Quality  | Lint on 20%+ writes, 90%+ first-try resolve | Hook log file              |
| `CLAUDE.md` update freq | Quality  | 1+ per active repo per month                | GitLab MR history          |
| Rework rate             | Quality  | ≤ non-Claude code                           | Lead assessment            |

*These don't need perfect precision. Directional signal — are engineers using it, is the output improving? A lead who checks MR labels, glances at Z.ai, and asks the team weekly gets 80% of the signal with 20% of the effort.*

---

## 3. The Migration to Claude Code Subscription

### Why Claude Max, Not Claude Pro

- **Claude Pro** caps messages — autonomous engineering tools hit these limits easily
- **Claude Max** removes those limits: 5× or 20× more usage, higher output limits, priority access
- **But**: Claude Max is per-user/per-month fixed cost. For our current team size, the pay-per-token GLM setup may still be cheaper — especially if most tasks run fine on GLM-4.7 at $0.38/$1.98 per million tokens
- The decision is not "GLM worse, Claude better" — it's "has our volume reached the point where per-seat is more cost-effective than per-token, AND do we need native Claude capabilities GLM can't provide?"

### Migration Decision Criteria

Migrate when the majority of these are true:

**Cost:**
- [ ] Monthly Z.ai token cost > `[Claude Max price] × [active engineers]`

**Capability gaps:**
- [ ] GLM-4.7 regularly produces materially worse output than Claude models (track via rework rate)
- [ ] Team needs Claude Code Projects for shared memory across machines
- [ ] Extended thinking/reasoning needed for complex architecture or debugging beyond GLM

**Team maturity:**
- [ ] 70%+ engineers completed all 7 guides, actively using skills + MCPs daily
- [ ] Stable `CLAUDE.md` files for all active repos
- [ ] Mature skill set in `aiad-claude`

**Operational:**
- [ ] Dedicated AI tooling budget line established

### What Changes on Migration

- Guide 1 env vars change: `ANTHROPIC_BASE_URL`, `ANTHROPIC_API_KEY`, `ANTHROPIC_DEFAULT_OPUS_MODEL`, `ANTHROPIC_DEFAULT_SONNET_MODEL`, `ANTHROPIC_DEFAULT_HAIKU_MODEL` all update. Migration checklist published as a Guide 1 amendment
- Everything else is compatible: `CLAUDE.md`, skills, MCPs, hooks — no changes needed
- Model guidance changes: `ANTHROPIC_DEFAULT_OPUS_MODEL` → native Claude Opus, `ANTHROPIC_DEFAULT_SONNET_MODEL` → native Claude Sonnet, `ANTHROPIC_DEFAULT_HAIKU_MODEL` → native Claude Haiku

### Current Position

- GLM-4.7 via Z.ai is strong for onboarding: pay-per-token, no seat commitment, full access to Claude Code tooling
- Migration to Claude Max is a future decision, not immediate
- **Don't self-upgrade** to individual Claude subscriptions without team coordination — fragments the team and makes quality comparison impossible

---

## 4. Onboarding Sequence

Key principle: **don't give engineers all seven guides at once.** Overloading leads to incomplete setup and surface-level usage. Build proficiency through use at each stage before the next.

### Full Proficiency: ~6 Weeks

#### Phase 1 — Week 1: Core Setup (Guides 1, 2, 3)

**Complete:** Install Claude Code, configure Z.ai/GLM, install global `CLAUDE.md` + verify per-repo file, install TipTip skill set from `aiad-claude` (engineering-wide + your stack's directory) and required plugins from `PLUGINS.md`, practice 5 must-have skills on real tasks.

**By end of week:** Engineer runs Claude daily. `pr-description` and `git-commit` used for every applicable MR. At least one `CLAUDE.md` fix MR opened.

**Lead:** Pair with the engineer on their first real task (not a tutorial). Confirm per-repo `CLAUDE.md` is accurate. Point to `#aiad-discussion`.

---

#### Phase 2 — Weeks 2–3: Habits (Practice Guides 1–3)

No new guides — just habit building.

**By end of week 3:** Engineer reaches for Claude automatically for covered tasks. 4+ distinct skills invoked. Shared at least one tip in `#aiad-discussion`.

**Lead:** Light check-in at 1:1 — "what did you use Claude for this week?" If the answer is nothing, investigate.

---

#### Phase 3 — Weeks 3–4: MCPs (Guide 4)

**Complete:** Install global MCPs (Context7, Sequential Thinking, Jira, Confluence, GitLab) + project MCPs (Serena, PostgreSQL for BE / Figma for FE). Run at least one session with Jira MCP on a real ticket. One session with Context7 on a library lookup.

**By end of week 4:** No more manually copying Jira ticket descriptions into sessions. Engineer notices deprecated APIs via Context7.

**Lead:** Verify `.mcp.json` is committed. Confirm PostgreSQL MCP points to local/staging — **not production**.

---

#### Phase 4 — Weeks 4–5: Hooks (Guide 5)

**Complete:** Install hook scripts from `aiad-claude`. Verify at least one hook fires correctly in a real session.

**By end of week 5:** Lint runs automatically after Claude edits. Engineer has seen the secret guard fire at least once.

**Lead:** Confirm hooks are committed to repo (not just local). Test secret/SQL guards.

---

#### Phase 5 — Weeks 5–6: Workflows (Guide 6)

**Complete:** Read Guide 6. Run at least 2 cookbook workflows on real tasks (Workflow 3 + one from 1/2/4/6).

**By end of week 6:** Writing `task.md` for sessions touching 2+ files. Comfortable with interactive vs autonomous mode selection.

**Lead:** Review the engineer's first autonomous session output together — `task.md`, diff, what worked, what to improve. This is formal onboarding completion.

---

#### Summary

| Phase            | Weeks | Guides           | Key Milestone                                     |
| ---------------- | ----- | ---------------- | ------------------------------------------------- |
| Core Setup       | 1     | 1, 2, 3          | Skills daily; `CLAUDE.md` refined once            |
| Habits           | 2–3   | *(practice)*     | 4 skills used; sharing in `#aiad-discussion`      |
| MCPs             | 3–4   | 4                | Jira MCP for tickets; Context7 active             |
| Hooks            | 4–5   | 5                | Lint hook firing; hooks committed                 |
| Workflows        | 5–6   | 6                | Two cookbook workflows completed                  |
| Full proficiency | 6+    | 7 *(this guide)* | Lead assessment: autonomous + skills + MCPs daily |

*Guide 7 is not part of the onboarding sequence. Engineers read it as a reference once proficient. Required reading for leads from day one.*

---

## 5. Knowledge Sharing

### #aiad-discussion (Google Chat)

Primary channel for Claude Code knowledge sharing.

**What goes here:**
- Workflow discoveries: *"Running the postgres skill before writing a migration saves schema mistakes — here's how"*
- Skill improvement proposals: *"The code-review-golang skill misses our new error handling pattern"*
- Unusual Claude behavior: *"Claude keeps suggesting sqlx despite the CLAUDE.md rule"*
- MCP issues: *"Jira MCP token expires every 30 days — reminder to rotate"*
- Cost observations: *"Session cost spiked — forgot Serena, Claude read 40 files manually"*

**What doesn't:** Full session logs (use GitLab snippets), credentials/PII, non-Claude-specific coding questions.

### Monthly Demo (30 min)

One engineer shows a workflow that saved time or produced great output. 15-minute walkthrough + 15-minute discussion. Format:
1. The task/problem
2. The Claude approach (`task.md`, skills, MCPs)
3. The output
4. Time with vs without Claude

Not a formal presentation. If nobody volunteers, the lead presents.

### Formal Path: aiad-claude MRs

Anything from `#aiad-discussion` that represents a systematic improvement (not a one-off) → MR to `https://gitlab.com/tiptiptv/common/aiad-claude`. The person who raises the issue in `#aiad-discussion` should (but is not required to) open the MR. If they don't, lead tags someone.

### Quarterly Review

Leads cover: metrics trends, `CLAUDE.md` accuracy, skill utilization, MCP health, onboarding assessment, Future Work status (Guide 6 Section 8). Output: Confluence page + list of `aiad-claude` MRs.

---

## 6. What Not to Use Claude Code For

> 🚨 **Required reading for all engineers.** These are boundaries, not suggestions.

### ❌ Never: Production Database Mutations

No INSERT, UPDATE, DELETE, or schema-altering commands against production via Claude Code — regardless of hooks, review, or session type.

The SQL guard hook is a dev-time safety net, not production authorization. Claude lacks audit trail integration with TipTip's production DB access controls. Production changes go through migration files → MR review → deployment pipeline.

**Instead:** Use Claude to write and review migration files. PostgreSQL MCP only against local dev or staging.

---

### ❌ Never: Infrastructure Changes Without Human Review

No autonomous Terraform, Kubernetes, CI/CD, or cloud config modifications affecting production/staging without human review first.

Infrastructure blast radius extends beyond the file being edited. A K8s resource limit, security group change, or CI job tweak can down services or expose vulnerabilities.

**Instead:** Use Claude interactively to draft infra changes. Treat output as a draft requiring senior review. Never `terraform apply` or `kubectl apply` in autonomous sessions.

---

### ❌ Never: Security Config Without Review

No autonomous generation, modification, or rotation of: API keys, OAuth configs, JWT secrets, encryption keys, CORS rules, CSP policies, or any security configuration.

Security misconfigurations are silent until exploited. Claude can reason about security but lacks full context of TipTip's threat model and compliance requirements.

**Instead:** Use Claude interactively to discuss security changes (good thinking partner). Actual changes must be human-written, second-reviewed, and manually applied. Never give Claude write access to `.env.production`, secrets managers, or vault configs.

---

### ❌ Never: PII Operations Outside CLAUDE.md Rules

No autonomous reading, processing, or reasoning about PII (email, phone, payment data, national IDs, UU PDP-covered data) beyond what `CLAUDE.md` security rules explicitly govern.

Claude sessions have no audit trail for data access. Even well-intentioned debugging with real user PII may violate TipTip's data handling obligations.

**Instead:** Anonymize or mock PII before sessions. If real data is genuinely needed, follow TipTip's data access process — Claude Code is not part of that process.

---

### ⚠️ Caution: Auth Logic

Not prohibited, but requires thorough human review — more than standard review. Auth bugs are among the most consequential. Claude can produce plausible auth code with subtle logical errors.

**Guidance:** Write auth with Claude, invoke `code-review-golang` or `code-review-nextjs` (as applicable) focused on security, require a second reviewer who knows TipTip's auth architecture.

---

### ⚠️ Caution: Payment & Financial Logic

Not prohibited, but high-stakes. Must follow creator-service `CLAUDE.md` constraints: int64 for currency, no floating point, pgx transactions for multi-table updates.

**Guidance:** All payment code needs explicit unit tests on boundary conditions + review by someone who understands the financial domain, not just the code.

---

### Usage Summary

| Task              | Usage         | Requirement                 |
| ----------------- | ------------- | --------------------------- |
| Feature code      | Autonomous ✅  | Standard MR review          |
| Tests             | Autonomous ✅  | Verify edge case coverage   |
| PR description    | Autonomous ✅  | Read before submitting      |
| Code review       | Autonomous ✅  | Validate assessment         |
| SQL review        | Interactive ✅ | Never execute on production |
| Auth/authz        | Interactive ⚠️ | Mandatory second reviewer   |
| Payment logic     | Interactive ⚠️ | Domain expert review        |
| Infra changes     | Interactive ⚠️ | Senior review before apply  |
| Production DB     | Prohibited ❌  | Deployment pipeline only    |
| Security config   | Prohibited ❌  | Human authorship required   |
| PII outside rules | Prohibited ❌  | Follow data access process  |

---

## 7. What to Expect from Engineering Leads

Leads are accountable for making these guidelines real:

1. **Metrics:** Run the 7 metrics monthly. Share directional findings — not precision reports.
2. **Migration decision:** Own the framework for when to migrate to Claude Max. Present analysis when criteria approach.
3. **Onboarding:** Personally pair with each new engineer during Week 1. The sequence doesn't work on paper alone.
4. **`#aiad-discussion`:** Participate actively. If the channel goes quiet for a week, prompt the team with a question or observation.
5. **Monthly demo:** Schedule and facilitate. If no volunteer, present yourself.
6. **Quarterly review:** Conduct the review. Publish findings to Confluence.
7. **Boundary enforcement:** Ensure Section 6 is understood. If a prohibited use is observed, address directly and update `CLAUDE.md`/hooks.
8. **`aiad-claude` stewardship:** Own MR review for your domain. Don't let MRs sit unreviewed over a week.

> 💡 *Tip from [The Shorthand Guide to Everything Claude Code](https://x.com/affaanmustafa/status/2012378465664745795):* Treat Claude Code config like **fine-tuning, not architecture**. Context window is precious — disable unused MCPs. Use parallel execution (fork conversations, git worktrees). Automate the repetitive with hooks. Scope subagents with limited tools.

---

## 8. Quick Reference

### Monthly Metrics Checklist

| Metric                      | How                            | Time   |
| --------------------------- | ------------------------------ | ------ |
| PR volume with Claude label | GitLab MR filter               | 5 min  |
| Skill invocation            | Collect skill logs             | 10 min |
| MCP usage                   | Stop hook + Context7 dashboard | 10 min |
| Session tokens              | Z.ai dashboard                 | 5 min  |
| Hook interventions          | Hook log files                 | 5 min  |
| `CLAUDE.md` updates         | GitLab MR history              | 5 min  |
| Rework rate                 | Qualitative in retro           | 10 min |

### Migration Checklist

| Criteria                                           | Check |
| -------------------------------------------------- | ----- |
| Monthly Z.ai cost > (Claude Max price × team size) | [ ]   |
| GLM rework rate materially worse than Claude       | [ ]   |
| Team needs Projects for shared memory              | [ ]   |
| 70%+ engineers fully proficient                    | [ ]   |
| Stable `CLAUDE.md` for all active repos            | [ ]   |
| Dedicated AI tooling budget line                   | [ ]   |

### Knowledge Sharing

| Channel                          | Purpose                        | Cadence   |
| -------------------------------- | ------------------------------ | --------- |
| `#aiad-discussion` (Google Chat) | Daily Q&A, discoveries, issues | Ongoing   |
| Monthly demo                     | Workflow showcases             | Monthly   |
| `aiad-claude` MRs                | Formal tooling improvements    | As needed |
| Confluence quarterly review      | Metrics, findings, updates     | Quarterly |

### Key Links

| Resource                        | Link                                             |
| ------------------------------- | ------------------------------------------------ |
| TipTip `aiad-claude` repository | `https://gitlab.com/tiptiptv/common/aiad-claude` |
| Claude Code docs                | `https://docs.anthropic.com/en/docs/claude-code` |
| Z.ai pricing / dashboard        | `https://z.ai`                                   |
| Claude Max pricing              | `https://www.anthropic.com/pricing`              |
| `#aiad-discussion`              | Google Chat                                      |

---
**End of TipTip's Claude Code guide series.** Guides 1–7 establish the foundation. Standardizing and improving workflows lives in `#aiad-discussion` and `aiad-claude`.

**AI-assisted development is no longer optional.** We expect all TipTip engineers to use AI (via Claude Code) in their daily workflow — this competency is part of standard performance expectations.
