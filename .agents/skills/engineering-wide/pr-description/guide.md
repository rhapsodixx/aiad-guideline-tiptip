# PR Description Skill — Format & Usage Guide

## Overview

The **pr-description** skill generates merge request titles and descriptions that follow TipTip's standardized format. It combines [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) for the title with a structured description template inspired by [merge request best practices](https://chameleonmind.medium.com/how-to-write-a-great-merge-request-1f161b89f15f).

---

## 1. MR Title Format

### With Jira Ticket

```
[JIRA-KEY] type: description
```

**Example:** `[SATU-837] feat: korean and language selector menu`

### Without Jira Ticket

```
type: description
```

**Example:** `chore: update botpress client id`

### Title Rules

| Rule | Detail |
|---|---|
| Jira key | Square brackets, uppercase — e.g., `[SATU-837]`. Omit entirely if no ticket. |
| Type | Conventional Commits type — `feat`, `fix`, `refactor`, `perf`, `style`, `test`, `docs`, `build`, `ops`, `chore` |
| Description | Lowercase, imperative mood ("add" not "added"), no trailing period |
| Length | Under 72 characters (excluding the Jira prefix) |

---

## 2. MR Description Structure

| Section | Required | Purpose |
|---|---|---|
| **Reference** | ✅ | Link to Jira ticket, design doc, or related MRs |
| **What's New** | ✅ | 2-3 sentence executive summary |
| **Why** | ✅ | Problem being solved, motivation, previous behavior |
| **Changes** | ✅ | Bullet list of specific modifications, grouped by component |
| **Impact Areas** | ✅ | Checklist of affected system areas (API, DB, UI, config, CI/CD, docs) |
| **How to Review** | ✅ | Suggested review order and focus areas |
| **Screenshots** | ❌ | Before/after for UI changes. Remove section if not applicable |
| **Checklist** | ✅ | Pre-submission self-check |

### Why Each Section Matters

- **Reference** gives the reviewer instant context without digging through Jira.
- **What's New** is the elevator pitch — reviewers read this first to decide priority.
- **Why** prevents the reviewer from guessing at your intent. It answers "should this change exist at all?"
- **Changes** is not a restatement of the diff — it's a logical grouping that helps reviewers understand the structure.
- **Impact Areas** tells the reviewer the blast radius so they know what to regression-test.
- **How to Review** saves the reviewer time — instead of reading top-to-bottom, they follow your recommended path.
- **Checklist** catches common oversights before the reviewer has to point them out.

---

## 3. How to Use

### Invocation

After your changes are committed (or staged), invoke the skill:

```
/pr-description
```

### What Happens

1. The skill reads the diff between your branch and `main`
2. Detects a Jira ticket from the branch name (if present)
3. Determines the Conventional Commits type
4. Generates the full MR title + description
5. **Presents it for your review and approval**
6. Only pushes or creates an MR after your explicit consent

### Tips

- **Commit before invoking** — the skill reads committed changes via `git diff main...HEAD`. Uncommitted changes won't appear in the description.
- **Name your branch with the Jira key** — e.g., `feature/SATU-837-language-selector`. The skill auto-detects this pattern.
- **Provide context** — if the skill's auto-detected type or summary doesn't match your intent, correct it and it will regenerate.
- **Remove unused sections** — the skill automatically removes sections like Screenshots if they don't apply.

---

## 4. Checklist Reference

The default checklist covers TipTip's standard pre-submission checks:

```markdown
- [ ] Self-reviewed the diff before requesting review
- [ ] Tests added or updated for changed behavior
- [ ] No secrets, credentials, or PII in the diff
- [ ] Follows patterns established in CLAUDE.md
- [ ] Documentation updated (if applicable)
- [ ] Migration is backward-compatible (if applicable)
```

The skill will pre-check items it can verify from the diff (e.g., no secrets detected). Items requiring human judgment are left unchecked.

---

## 5. Safety

> ⚠️ **The skill will never auto-push, auto-commit, or auto-create a merge request.** It always presents the full output for your review first.

This ensures:
- You can edit the title and description before submission
- Sensitive information is not accidentally included
- The description accurately reflects your intent, not just the AI's interpretation

---

## References

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- [How to Write a Great Merge Request](https://chameleonmind.medium.com/how-to-write-a-great-merge-request-1f161b89f15f)
- TipTip Jira: `https://tiptiptv.atlassian.net`

> **Recommended Setting**: Run in Antigravity **Fast** mode using **Gemini 3 Flash**.
