# Git Commit Skill — Convention & Usage Guide

## Overview

The **git-commit** skill generates commit messages that follow the [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification — a lightweight convention that makes commit history machine-parseable and human-readable.

This guide covers:
1. The Conventional Commits format
2. How to use the skill
3. A Git Hook script to enforce the convention locally

---

## 1. What is Conventional Commits?

Conventional Commits is a specification for structuring commit messages in a standardized way. It dovetails with [Semantic Versioning (SemVer)](https://semver.org), allowing automated tools to determine version bumps, generate changelogs, and understand the nature of changes.

### The Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

| Part | Required | Rules |
|---|---|---|
| **type** | ✅ | One of the defined types (see table below) |
| **scope** | ❌ | Noun in parentheses describing the affected area, e.g., `(auth)` |
| **`!`** | ❌ | Placed before `:` to indicate a breaking change |
| **description** | ✅ | Imperative mood, lowercase, no trailing period, max 72 chars |
| **body** | ❌ | Motivation and context. Separated from header by a blank line |
| **footer** | ❌ | Issue references and `BREAKING CHANGE:` notes. Separated by a blank line |

### Types Reference

| Type | When to Use | SemVer |
|---|---|---|
| `feat` | Add, adjust, or remove a feature | MINOR |
| `fix` | Fix a bug | PATCH |
| `refactor` | Restructure code without changing behavior | PATCH |
| `perf` | Improve performance (special refactor) | PATCH |
| `style` | Code formatting, whitespace — no behavior change | PATCH |
| `test` | Add or correct tests | PATCH |
| `docs` | Documentation only | PATCH |
| `build` | Build tools, dependencies, project version | PATCH |
| `ops` | Infrastructure, CI/CD, deployment, monitoring | PATCH |
| `chore` | Miscellaneous (`.gitignore`, initial commit, etc.) | PATCH |

### Breaking Changes

Indicated by **one or both** of:
- `!` before the colon: `feat(api)!: remove status endpoint`
- `BREAKING CHANGE:` in the footer

Breaking changes trigger a **MAJOR** version bump.

### Description Rules

- Use **imperative, present tense**: "add" not "added" nor "adds"
- Think: *"This commit will..."*
- **Do not capitalize** the first letter
- **Do not end** with a period (`.`)

---

## 2. How to Use the Skill

### Invocation

After staging your changes with `git add`, invoke the skill:

```
/git-commit
```

### What Happens

1. The skill reads your staged diff (`git diff --cached`)
2. Analyzes the changes to determine type, scope, and description
3. Generates a Conventional Commits message
4. Presents it for your approval
5. Executes `git commit` only after you confirm

### Tips

- **Stage related changes together** — the skill works best when the staged diff represents one logical change.
- **Split unrelated changes** — if the skill detects multiple unrelated changes, it will suggest splitting into separate commits.
- **Provide context** — if the skill's auto-detected type or scope doesn't match your intent, tell it what the change is for and it will adjust.

---

## 3. Examples

### Simple feature
```
feat: add email notifications on new direct messages
```

### Feature with scope
```
feat(shopping-cart): add the amazing button
```

### Bug fix with body
```
fix: add missing parameter to service call

The error occurred because the `userId` parameter was not being passed
to the downstream authentication service, causing a 401 on all requests
from the mobile app.
```

### Breaking change with footer
```
feat!: remove ticket list endpoint

refers to JIRA-1337

BREAKING CHANGE: ticket endpoints no longer support list all entities.
```

### Build with scope
```
build(release): bump version to 1.0.0
```

### Performance improvement
```
perf: decrease memory footprint for unique visitors using HyperLogLog
```

---

## 4. Git Hook Script — `commit-msg` Validation

To enforce the Conventional Commits header format **before** a commit is recorded, install a `commit-msg` git hook. This catches malformed commit messages at the git level — independently of whether the AI skill was used.

### Installation

Create the file `.git/hooks/commit-msg` in your repository:

```bash
#!/usr/bin/env bash
# .git/hooks/commit-msg
# Validates that the commit message header follows Conventional Commits 1.0.0

# --- Configuration ---
# Allowed types (extend as needed)
TYPES="feat|fix|refactor|perf|style|test|docs|build|ops|chore"

# Regex for the header line:
#   type(optional-scope)!: description
#
# Breakdown:
#   ^              — start of line
#   (TYPES)        — one of the allowed types
#   (\(.+\))?      — optional scope in parentheses
#   !?             — optional breaking change indicator
#   :              — required colon
#   [ ]            — required space after colon
#   .{1,}          — description (at least 1 char)
#   $              — end of line
HEADER_REGEX="^($TYPES)(\(.+\))?!?: .{1,}$"

# --- Validation ---
# Read only the first line (header) of the commit message
HEADER=$(head -1 "$1")

# Skip merge commits and revert commits (they follow git's default format)
if echo "$HEADER" | grep -qE "^Merge branch |^Revert \""; then
    exit 0
fi

# Validate against the regex
if ! echo "$HEADER" | grep -qE "$HEADER_REGEX"; then
    echo ""
    echo "ERROR: Commit message header does not follow Conventional Commits format."
    echo ""
    echo "  Your header:  $HEADER"
    echo ""
    echo "  Expected format: <type>[(scope)][!]: <description>"
    echo "  Allowed types:   ${TYPES//|/, }"
    echo ""
    echo "  Examples:"
    echo "    feat: add user profile page"
    echo "    fix(auth): resolve token refresh loop"
    echo "    refactor!: restructure database layer"
    echo ""
    echo "  Reference: https://www.conventionalcommits.org/en/v1.0.0/"
    echo ""
    exit 1
fi

# Validate description does not start with uppercase
DESCRIPTION=$(echo "$HEADER" | sed -E 's/^[^:]+: //')
if echo "$DESCRIPTION" | grep -qE "^[A-Z]"; then
    echo ""
    echo "WARNING: Description should start with a lowercase letter."
    echo "  Your description: $DESCRIPTION"
    echo ""
    # Warning only — do not block
fi

# Validate no trailing period
if echo "$DESCRIPTION" | grep -qE '\.$'; then
    echo ""
    echo "WARNING: Description should not end with a period."
    echo "  Your description: $DESCRIPTION"
    echo ""
    # Warning only — do not block
fi

exit 0
```

### Make it executable

```bash
chmod +x .git/hooks/commit-msg
```

### Team-wide installation

Since `.git/hooks/` is not tracked by git, use one of these strategies to share the hook across the team:

**Option A: Shared hooks directory (recommended)**

Store hooks in a tracked directory and configure git to use it:

```bash
# Store the hook in a tracked directory
mkdir -p .githooks
cp .git/hooks/commit-msg .githooks/commit-msg
chmod +x .githooks/commit-msg

# Configure git to use the shared hooks directory
git config core.hooksPath .githooks
```

Add to your project's onboarding documentation:
```bash
git config core.hooksPath .githooks
```

**Option B: Install script**

Add a setup script that copies hooks into `.git/hooks/`:

```bash
#!/usr/bin/env bash
# scripts/install-git-hooks.sh
cp .githooks/commit-msg .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
echo "✓ commit-msg hook installed"
```

---

## References

- [Conventional Commits 1.0.0 Specification](https://www.conventionalcommits.org/en/v1.0.0/)
- [Conventional Commits Cheatsheet (qoomon)](https://gist.github.com/qoomon/5dfcdf8eec66a051ecd85625518cfd13)
- [Semantic Versioning 2.0.0](https://semver.org)
- [Angular Commit Message Guidelines](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines)

> **Recommended Setting**: Run in Antigravity **Fast** mode using **Gemini 3 Flash**.
