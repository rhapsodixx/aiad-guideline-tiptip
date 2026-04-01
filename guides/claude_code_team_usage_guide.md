# Guide 7 of 7: Team Usage & Best Practices

> 📋 Final guide in TipTip's Claude Code series.
> Written primarily for engineering leads.
> Individual engineers: read Sections 4 (Onboarding) and 6 (What Not to Use Claude Code For) in full. Everything else is lead-facing but worth understanding.

---

## 1. Purpose

Guides 1–6 covered setup and usage for individual engineers. This guide covers how TipTip sustains and scales Claude Code as a **team-level capability** — not just a personal tool.

Without measurement, adoption fragments. Some engineers become power users, others barely touch it, and the team doesn't converge on shared practices. This guide gives leads the tools to track adoption, maintain quality, onboard engineers, and decide when to migrate to an official subscription.

Individual engineers benefit from understanding what is being measured and why — it sets expectations and helps them know what good usage looks like.

---

## 2. Adoption Metrics

Our adoption metrics are simplified to focus on a core set of reliable data points regarding AI tool usage and its impact on engineering outcomes. These are separated into Leading Indicators (early signals of change) and Lagging Indicators (long-term outcomes).

### Lagging Indicators

#### Engineering North Star Metrics

The ultimate measure of AI adoption success is whether it improves our system outcomes without degrading quality. We track:
- **Predictability**: Are we shipping on time and maintaining consistent sprint velocities as AI adoption increases?
- **Quality / Bug Leak**: The defect density in production. If coding speed increases but bug leaks also increase, AI might be introducing technical debt or reviewers are facing cognitive overload.
- **How to track:** Lead assessment during sprint retrospectives and existing DORA metrics dashboards.

---

### Leading Indicators

#### Number of PRs per Person per Month

The primary signal that Claude Code is becoming a core part of the daily workflow instead of an isolated experiment. 

- **Implementation details:** Evaluated at the whole PR level. Engineers should add an `AI-Assisted` (or `[claude-assisted]`) label to their GitLab MRs/PRs whenever AI was materially used to write or review the code.
- **Targets:**
  - Week 1: any usage = success
  - Week 2: 50% of PRs involve Claude
  - Week 3+: 70%+ of PRs involve Claude
- **How to track:** Compare the percentage of PRs carrying the AI label against total PR volume in GitLab analytics.

---

#### Session Length

Helps identify if engineers are getting into a flow state or if they are facing high cognitive load adjusting the AI's context.

- **Targets:** Average session under 30 minutes. Flag sessions 3× the baseline.
- **How to track:** Extending the Stop hook to log session duration, or via `/usage` in Claude Code.

---

#### Token Usage

The primary cost driver and a proxy for the depth of AI engagement. Unusually high token counts often point to unfocused sessions with context bloat.

- **Targets:** Aggregate costs remain within the baseline budget. Flag engineers consistently 2× team average cost.
- **How to track:** `/usage` command in Claude Code sessions. Collect aggregate (not individual) weekly summaries so everyone understands consumption levels. During GLM fallback periods, check the Z.ai dashboard.

---

### Metrics Summary

| Metric                               | Category           | Tracking                   |
| ------------------------------------ | ------------------ | -------------------------- |
| Engineering North Star (Quality)     | Lagging Indicator  | Sprint Retros / DORA       |
| AI-Assisted PR Volume                | Leading Indicator  | GitLab MR labels           |
| Session Length                       | Leading Indicator  | Stop hook + `/usage`       |
| Token Usage                          | Leading Indicator  | `/usage` + Z.ai (fallback) |

*These metrics do not need perfect precision—they provide a directional signal. A lead who checks MR labels, runs `/usage`, and asks the team weekly gets 80% of the signal with 20% of the effort.*

---

## 3. Subscription & Model Strategy

### Current Plan: Claude Code Team Standard ($25/month per user)

TipTip has adopted the **Claude Code Team Standard Plan** as our primary AI-assisted development engine. This gives every engineer direct access to native Anthropic models (Haiku, Sonnet, Opus) — ensuring code generation accuracy is not compromised by third-party model approximations.

**Why the Team Standard Plan?**
- **Model accuracy matters:** Our AI adoption metrics must reflect genuine Anthropic model quality. Third-party proxies (GLM, DeepSeek) introduce variable accuracy that makes it impossible to objectively measure AI-assisted development ROI.
- **Cost-effective:** At $25/month per user, the Team Standard Plan is more predictable and sustainable than pay-per-token billing at scale.
- **Native features:** Direct access to Anthropic's latest model releases, Projects for shared memory, and priority access without proxy middlemen.

### GLM Fallback

When the Team Plan's rolling 5-hour quota is temporarily exhausted, engineers switch to the **Z.ai GLM proxy** to continue working. See Guide 1, [Section 9 — GLM Fallback](claude_code_setup_guide.md#9-glm-fallback--when-team-plan-quota-is-exhausted) for exact setup instructions.

> ⚠️ **Do not self-upgrade** to individual Claude Pro/Max subscriptions without team coordination — this fragments the team's tooling and makes quality comparison impossible. All subscription changes go through **Dominikus**.

---

## 4. Onboarding Sequence

Key principle: **don't give engineers all seven guides at once.** Overloading leads to incomplete setup and surface-level usage. Build proficiency through use at each stage before the next.

### Full Proficiency: 3 Weeks

#### Phase 1 — Week 1: Setup & Core Habit Building (Guides 1-3)

**Complete:** Install Claude Code, authenticate via `claude login` with Team Plan invite, install global `CLAUDE.md` + verify per-repo file, install TipTip skill set from `aiad-claude` (engineering-wide + your stack's directory) and required plugins from `PLUGINS.md`, practice 5 must-have skills on real tasks. Engineer uses Claude for at least 3 different task types: writing code, generating tests, and reviewing their own code before MR submission.

**By end of week 1:** Engineer runs Claude daily. `pr-description` and `git-commit` used for every applicable MR. 4+ distinct skills invoked. Shared at least one tip in `#aiad-discussion`.

**Lead action:**
- Pair with the engineer on their first real task (not a tutorial). Confirm per-repo `CLAUDE.md` is accurate.
- Investigate whether there is a setup issue or habit gap if usage is low.

---

#### Phase 2 — Week 2: MCP Integrations & Hooks (Guides 4-5)

**Complete:** Install global MCPs (Context7, Sequential Thinking, Jira, Confluence, GitLab) + project MCPs. Install hook scripts from `aiad-claude`.

**By end of week 2:** No more manually copying Jira ticket descriptions into sessions. Engineer notices deprecated APIs via Context7. Lint runs automatically after Claude edits. Engineer has seen the secret guard fire at least once and understands what it does.

**Lead action:**
- Verify `.mcp.json` is committed. Confirm PostgreSQL MCP points to local/staging — **not production**.
- Confirm hooks are committed to repo (not just local install) and validate secret guard functions.

---

#### Phase 3 — Week 3: Advanced Workflows & Proficiency (Guide 6 and 70% Target)

**Complete:** Read Guide 6. Run at least 2 cookbook workflows on real tasks.

**By end of week 3:** Writing `task.md` for sessions touching 2+ files. Has run at least one autonomous session end-to-end without unnecessary interruption. Using Claude on 70%+ of PRs.

**Lead action:** Review the engineer's first autonomous session output together — `task.md`, diff, what worked, what to improve. This is formal onboarding completion.

---

#### Summary

| Phase            | Weeks | Guides           | Key Milestone                                     |
| ---------------- | ----- | ---------------- | ------------------------------------------------- |
| Setup & Habits   | 1     | 1, 2, 3          | Skills daily; 4 skills used; `CLAUDE.md` refined  |
| MCPs & Hooks     | 2     | 4, 5             | Jira MCP active; Lint hook firing                 |
| Workflows        | 3     | 6                | Two cookbook workflows completed; 70%+ adoption   |
| Full proficiency | 3+    | 7 *(this guide)* | Lead assessment: autonomous + skills + MCPs daily |

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
- Questions about which workflow to use for a new type of task

**What doesn't:** Full session logs (use GitLab snippets or Confluence — share the link), credentials/PII, non-Claude-specific coding questions.

### Monthly Demo (30 min)

One engineer shows a workflow that saved time or produced great output. 15-minute walkthrough + 15-minute discussion. Format:
1. The task/problem
2. The Claude approach (`task.md`, skills, MCPs)
3. The output
4. Time with vs without Claude

Not a formal presentation — the purpose is to make good workflows visible so they spread naturally. If nobody volunteers, the lead presents.

### Formal Path: aiad-claude MRs

Anything from `#aiad-discussion` that represents a systematic improvement (not a one-off) → MR to `https://gitlab.com/tiptiptv/common/aiad-claude`. The person who raises the issue in `#aiad-discussion` should (but is not required to) open the MR. If they don't, lead tags someone to pick it up.

### Quarterly Review

Leads cover: metrics trends, `CLAUDE.md` accuracy, skill utilization, MCP health, onboarding assessment, Future Work status (Guide 6 Section 8). Output: Confluence page summarizing findings + list of `aiad-claude` MRs to open + any updates to this guide series.

---

## 6. What Not to Use Claude Code For

> 🚨 **Required reading for all engineers.** These are boundaries, not suggestions. They protect TipTip's systems and data.

### ❌ Never: Production Database Mutations

No INSERT, UPDATE, DELETE, or schema-altering commands against production via Claude Code — regardless of hooks, review, or session type.

The SQL guard hook is a dev-time safety net, not production authorization. Claude Code lacks audit trail integration with TipTip's production database access controls. Any production change must go through the standard change management process: migration file reviewed in MR, applied by a human via the approved deployment pipeline.

**Instead:** Use Claude to write and review migration files. PostgreSQL MCP only against local dev or staging.

---

### ❌ Never: Infrastructure Changes Without Human Review

No autonomous Terraform, Kubernetes, CI/CD, or cloud config modifications affecting production/staging without human review first.

Infrastructure blast radius extends beyond the file being edited. A K8s resource limit, security group change, or CI job tweak can down services or expose vulnerabilities. Claude can generate and review these changes, but cannot understand the full blast radius the way a senior engineer can.

**Instead:** Use Claude interactively to draft infra changes. Treat output as a draft requiring senior review. Never `terraform apply` or `kubectl apply` in autonomous sessions.

---

### ❌ Never: Security Config Without Review

No autonomous generation, modification, or rotation of: API keys, OAuth configs, JWT secrets, encryption keys, CORS rules, CSP policies, or any security configuration.

Security misconfigurations are silent until exploited. Claude can reason about security but lacks full context of TipTip's threat model, existing attack surface, and compliance requirements. These changes require human security judgment, not LLM pattern matching.

**Instead:** Use Claude interactively to discuss security changes (good thinking partner). Actual changes must be human-written, second-reviewed, and manually applied. Never give Claude write access to `.env.production`, secrets managers, or vault configs.

---

### ❌ Never: PII Operations Outside CLAUDE.md Rules

No autonomous reading, processing, or reasoning about PII (email, phone, payment data, national IDs, UU PDP-covered data) beyond what `CLAUDE.md` security rules explicitly govern.

PII handling requires explicit consent, purpose limitation, and audit trail under Indonesia's Personal Data Protection Law (UU PDP). Claude sessions have no audit trail for data access — even well-intentioned debugging with real user PII may violate TipTip's data handling obligations.

**Instead:** Anonymize or mock PII before sessions. If real data is genuinely needed, follow TipTip's data access process — Claude Code is not part of that process. When in doubt, ask the engineering lead before the session, not after.

---

### ⚠️ Caution: Auth Logic

Not prohibited, but requires thorough human review — more than standard review. Auth bugs are among the most consequential. Claude can produce plausible auth code with subtle logical errors.

**Guidance:** Write auth with Claude, invoke `code-review-golang` or `code-review-nextjs` (as applicable) focused on security, require a second reviewer who knows TipTip's auth architecture.

---

### ⚠️ Caution: Payment & Financial Logic

Not prohibited, but high-stakes. Must follow creator-service `CLAUDE.md` constraints: int64 for currency, no floating point, pgx transactions for multi-table updates.

**Guidance:** All payment code needs explicit unit tests on boundary conditions + review by someone who understands the financial domain, not just the code.

---

### ⚠️ Caution: QA Test Automation

Not prohibited, but requires careful review of generated locators and test data. AI-generated Playwright scripts may reference stale element IDs or incorrect XPaths. Always verify generated locators against the running application before merging.

**Guidance:** Use `automation-script-generation` to scaffold scripts, then run `automation-script-validation` to audit compliance. QA tests targeting production (`@prod` tag) must be strictly read-only — no state mutations, no data creation, no purchases.

---

### Usage Summary

| Task              | Usage         | Requirement                 |
| ----------------- | ------------- | --------------------------- |
| Feature code      | Autonomous ✅  | Standard MR review          |
| Tests             | Autonomous ✅  | Verify edge case coverage   |
| PR description    | Autonomous ✅  | Read before submitting      |
| Code review       | Autonomous ✅  | Validate assessment         |
| QA test generation| Autonomous ✅  | Review generated scripts    |
| QA test validation| Autonomous ✅  | Review report findings      |
| SQL review        | Interactive ✅ | Never execute on production |
| Auth/authz        | Interactive ⚠️ | Mandatory second reviewer   |
| Payment logic     | Interactive ⚠️ | Domain expert review        |
| Infra changes     | Interactive ⚠️ | Senior review before apply  |
| QA prod tests     | Interactive ⚠️ | Read-only assertions only   |
| Production DB     | Prohibited ❌  | Deployment pipeline only    |
| Security config   | Prohibited ❌  | Human authorship required   |
| PII outside rules | Prohibited ❌  | Follow data access process  |

---

## 7. What to Expect from Engineering Leads

Leads are accountable for making these guidelines real:

1. **Metrics:** Run the 4 metrics monthly. Share directional findings — not precision reports.
2. **Subscription optimization:** Monitor Team Plan quota efficiency and fallback usage. If GLM fallback is used frequently, investigate whether quota-saving practices (model switching, session hygiene) are being followed.
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

| Metric                           | How                            | Time   |
| -------------------------------- | ------------------------------ | ------ |
| Engineering North Star (Quality) | Sprint Retros / DORA           | 10 min |
| AI-Assisted PR Volume            | GitLab MR label filter         | 5 min  |
| Session Length                   | Stop hook + `/usage`           | 10 min |
| Token Usage                      | `/usage` + Z.ai (fallback)     | 5 min  |

### Team Plan Health Check

| Criteria                                            | Check |
| --------------------------------------------------- | ----- |
| Team Plan quota sufficient for daily usage           | [ ]   |
| GLM fallback used < 20% of total sessions            | [ ]   |
| 70%+ engineers fully proficient (completed 7 guides) | [ ]   |
| Stable `CLAUDE.md` for all active repos              | [ ]   |
| Model optimization practiced (Haiku for light tasks) | [ ]   |

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
| Claude Team Plan info           | `https://www.anthropic.com/pricing`              |
| Z.ai (GLM fallback)             | `https://z.ai`                                   |
| `#aiad-discussion`              | Google Chat                                      |

---
**End of TipTip's Claude Code guide series.** Guides 1–7 establish the foundation. Standardizing and improving workflows lives in `#aiad-discussion` and `aiad-claude`.

**AI-assisted development is no longer optional.** We expect all TipTip engineers to use AI (via Claude Code) in their daily workflow — this competency is part of standard performance expectations.
