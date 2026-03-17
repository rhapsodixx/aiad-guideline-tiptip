# Hooks — TipTip Internal
### Series: Claude Code at TipTip | Guide 5 of N: Hooks

> [!WARNING]
> **Prerequisites:** Complete Guides 1–4 before proceeding with this guide.
> Hooks build on the CLAUDE.md conventions (Guide 2), skills (Guide 3),
> and MCP setup (Guide 4). Having those in place first ensures hooks
> enforce the right standards.

---

## 1. What Are Hooks?

Hooks are scripts that Claude Code runs automatically at specific points in its tool execution lifecycle — before a tool runs (`PreToolUse`), after a tool runs (`PostToolUse`), when Claude sends a notification (`Notification`), and when Claude stops a task (`Stop`).

They are not git hooks. They fire inside Claude's own action loop, wrapping every tool call Claude makes during a session.

The key distinction from Skills and MCP:
- **Skills** define HOW Claude approaches a task (prompt templates).
- **MCP** provides live data from external systems.
- **Hooks** enforce quality gates and safety constraints on Claude's actions regardless of what skill or task is running — they cannot be skipped by Claude the way a prompt instruction can be overridden mid-session.

Hooks run on the engineer's local machine (or CI runner), not inside the LLM — they are deterministic shell scripts with real system access.

A hook can: inspect what Claude is about to do, block it, modify the context, run a linter, execute a test, post a notification, or log output.

This makes hooks TipTip's enforcement layer: they ensure Claude's output always meets TipTip's quality bar before the engineer reviews it.

*Official Reference: [Anthropic Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)*

---

## 2. The Four Hook Types

| Hook Type | Fires When | Primary Use at TipTip |
|---|---|---|
| PreToolUse | Before Claude executes any tool call | Safety gates — block dangerous commands |
| PostToolUse | After Claude executes a tool call | Quality gates — lint, format, test after edits |
| Notification | When Claude sends a status notification | Awareness — alert engineer on long tasks |
| Stop | When Claude finishes or stops a task | Reporting — summarize what changed |

### PreToolUse
- **Fires:** Before the tool executes. Claude has decided to run a tool, and the hook can inspect the parameters (`tool_name`, `tool_input`) and block it before it happens.
- **Primary Use:** Most valuable as a safety gate for dangerous operations (e.g., blocking `rm -rf` or destructive SQL queries).
- **Input:** JSON via `stdin` containing `hook_event_name`, `tool_name`, and `tool_input`. 
- **Behavior:** To allow the action silently, exit with code `0`. To block the action, exit with code `2`. To provide detailed feedback back to Claude, the script can output specific JSON containing `hookSpecificOutput.permissionDecision`.

### PostToolUse
- **Fires:** After the tool executes. Claude has already run the tool, and the hook can inspect the result and react.
- **Primary Use:** Most valuable for quality enforcement: run linters and formatters after every file write so Claude's output is always clean.
- **Input:** JSON via `stdin` containing `tool_name`, `tool_input`, and `tool_response`.
- **Behavior:** Hook can test for errors (e.g., via `eslint` or `go vet`) and output JSON with `decision: "block"` or `additionalContext` back to Claude if it detects a problem, so Claude can self-correct rather than the engineer having to flag it.

### Notification
- **Fires:** When Claude sends a status update during a long task (e.g., waiting for permissions, idle prompts).
- **Primary Use:** Useful for surfacing progress to the engineer during autonomous runs where Claude is working in the background.
- **Input:** JSON via `stdin` containing `message`, `title`, and `notification_type`.

### Stop
- **Fires:** When Claude finishes a task, completes a session, or hits a stop condition.
- **Primary Use:** Useful for cleanup, summary generation, or CI reporting.
- **Input:** JSON via `stdin` containing fields like `stop_hook_active` and `last_assistant_message`.

---

## 3. Hook Configuration

### Where Hooks Live
- **Global hooks:** Configured in `~/.claude/settings.json`. Scripts typically live in `~/.claude/hooks/`.
- **Project-level hooks:** Configured in `.claude/settings.json` in the root of your repository. Scripts typically live in `.claude/hooks/`.
- **Loading behavior:** Project-level settings override or merge with User (global) settings. Global hooks act as baselines, and project hooks define repo-specific behaviors.

### Configuration Format
Hooks are registered under the `hooks` key in the settings file. You specify the event name, a `matcher` (to filter which tool calls trigger the hook), and a list of command definitions.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/post-tool-use-lint.sh"
          }
        ]
      }
    ]
  }
}
```
- **`matcher`**: A regex pattern matching the `tool_name` (e.g., `Bash`, `Edit|Write`, `mcp__*`). If you want it to trigger on all tool calls, use `*`.
- **`type`**: `command` is standard for shell scripts.
- **`command`**: The path to your executable script.

### The Exit Code Contract
Claude Code interprets exit codes from hook scripts mathematically:
- **`exit 0`**: Success/Allow. The tool call proceeds without interruption.
- **`exit 2`**: Block. This immediately stops the tool from running (critical for `PreToolUse` and `Stop` blocks).
- Scripts can also exit `0` but emit a standard JSON structure with `{"decision": "block", "reason": "..."}` or `{"hookSpecificOutput": ...}` to provide conversational feedback so Claude knows precisely *why* it was blocked.

### Hook Script Inputs
Data is passed to hooks via standard input (`stdin`) as a JSON string. Hook authors parse this using tools like `jq`.
```bash
#!/bin/bash
# Read stdin into a variable
PAYLOAD=$(cat)
# Extract the tool name
TOOL_NAME=$(echo "$PAYLOAD" | jq -r '.tool_name')
```

---

## 4. TipTip's Must-Have Hooks

All official TipTip hooks are maintained in the canonical repository at `https://gitlab.com/tiptiptv/common/aiad-claude` under the `hooks/` directory. 

Engineers should pull from the canonical repository rather than writing hooks from scratch. If a hook needs improvement, open a merge request on `aiad-claude` — **do not maintain private versions**.

### 4.1 Go Linter — PostToolUse (Backend)

**Purpose:** After Claude writes or edits any `.go` file, automatically run `go vet` and `golangci-lint`. If lint errors are found, feed them back to Claude as context so it can self-correct before the engineer reviews.

**Why this matters for TipTip:** Claude frequently produces Go code that compiles but has lint issues — unused error returns, shadowed variables, or import ordering problems. Without this hook, the engineer must manually run lint after every Claude edit. With it, Claude's output is always lint-clean before the engineer sees it.

**Prerequisites:** `golangci-lint` installed.

**settings.json entry:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
             "type": "command",
             "command": ".claude/hooks/post-tool-use-go-lint.sh"
          }
        ]
      }
    ]
  }
}
```

**Script (`.claude/hooks/post-tool-use-go-lint.sh`):**
```bash
#!/bin/bash
# hooks/post-tool-use-go-lint.sh
# PostToolUse hook: runs go vet and golangci-lint after any Go file write

# Read stdin JSON
PAYLOAD=$(cat)
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

# Check if it's a Go file
if [[ ! "$FILE_PATH" == *.go ]]; then
    exit 0
fi

DIR=$(dirname "$FILE_PATH")

# Run vetting tools and capture output
VET_OUT=$(go vet "./$DIR/..." 2>&1)
LINT_OUT=$(golangci-lint run "./$DIR/..." 2>&1)

if [ -n "$VET_OUT" ] || [ -n "$LINT_OUT" ]; then
    # Return errors to Claude to self-correct
    jq -n \
      --arg vet "$VET_OUT" \
      --arg lint "$LINT_OUT" \
      '{
         decision: "block",
         reason: "Linting failed. Please fix the following issues.",
         hookSpecificOutput: {
           hookEventName: "PostToolUse",
           additionalContext: ($vet + "\n" + $lint)
         }
       }'
    exit 0
fi

exit 0
```

---

### 4.2 TypeScript/ESLint — PostToolUse (Frontend)

**Purpose:** After Claude writes or edits any `.ts`, `.tsx`, `.js`, or `.jsx` file, automatically run `eslint --fix` on the file. Feed any unfixable errors back to Claude.

**Why this matters for TipTip:** Claude's React/Next.js output sometimes violates TipTip's ESLint rules (unused imports, missing hook dependencies, improper `any` usage). Auto-fixing what can be fixed and surfacing what cannot keeps the output clean.

**Prerequisites:** project-local `eslint`.

**settings.json entry:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
             "type": "command",
             "command": ".claude/hooks/post-tool-use-eslint.sh"
          }
        ]
      }
    ]
  }
}
```

**Script (`.claude/hooks/post-tool-use-eslint.sh`):**
```bash
#!/bin/bash
# hooks/post-tool-use-eslint.sh
# PostToolUse hook: runs eslint --fix after any TS/JS/TSX/JSX file write

PAYLOAD=$(cat)
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx)
        LINT_OUT=$(npx eslint --fix "$FILE_PATH" 2>&1)
        STATUS=$?
        
        if [ $STATUS -ne 0 ]; then
            jq -n \
              --arg lint "$LINT_OUT" \
              '{
                 decision: "block",
                 reason: "ESLint failed after auto-fix attempts.",
                 hookSpecificOutput: {
                   hookEventName: "PostToolUse",
                   additionalContext: $lint
                 }
               }'
            exit 0
        fi
        ;;
    *)
        exit 0
        ;;
esac

exit 0
```

---

### 4.3 Prettier — PostToolUse (Frontend)

**Purpose:** After Claude writes any frontend file, run `prettier --write` to enforce consistent formatting. This is a silent hook — it fixes and exits 0 with no feedback to Claude unless Prettier itself errors.

**Why this matters for TipTip:** Formatting debates are eliminated. Every file Claude touches is automatically formatted to TipTip's Prettier config before the engineer reviews it.

**Prerequisites:** project-local `prettier`.

**settings.json entry:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
             "type": "command",
             "command": ".claude/hooks/post-tool-use-prettier.sh"
          }
        ]
      }
    ]
  }
}
```

**Script (`.claude/hooks/post-tool-use-prettier.sh`):**
```bash
#!/bin/bash
# hooks/post-tool-use-prettier.sh
# PostToolUse hook: runs prettier --write after frontend file writes

PAYLOAD=$(cat)
FILE_PATH=$(echo "$PAYLOAD" | jq -r '.tool_input.file_path // empty')

case "$FILE_PATH" in
    *.ts|*.tsx|*.js|*.jsx|*.css|*.json|*.md)
        # Suppress stdout, only capture stderr
        ERR_OUT=$(npx prettier --write "$FILE_PATH" 2>&1 > /dev/null)
        STATUS=$?
        
        if [ $STATUS -ne 0 ]; then
            jq -n \
              --arg err "$ERR_OUT" \
              '{
                 decision: "block",
                 reason: "Prettier tool crashed or failed.",
                 hookSpecificOutput: {
                   hookEventName: "PostToolUse",
                   additionalContext: $err
                 }
               }'
            exit 0
        fi
        ;;
    *)
        exit 0
        ;;
esac

exit 0
```

---

### 4.4 Dangerous SQL Guard — PreToolUse (Backend)

> [!CAUTION]
> Safety-critical hook. Do not disable without explicit team consensus.

**Purpose:** Before Claude executes any bash command, scan for patterns that indicate destructive SQL operations without safety conditions. Block the command and explain why.

**Why this matters for TipTip:** With the PostgreSQL MCP, Claude has direct database access in backend sessions. This hook is a hard stop that forces explicit review before anything destructive runs.

**settings.json entry:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
             "type": "command",
             "command": ".claude/hooks/pre-tool-use-sql-guard.sh"
          }
        ]
      }
    ]
  }
}
```

**Script (`.claude/hooks/pre-tool-use-sql-guard.sh`):**
```bash
#!/bin/bash
# hooks/pre-tool-use-sql-guard.sh
# PreToolUse hook: blocks dangerous SQL patterns in bash commands

PAYLOAD=$(cat)
COMMAND=$(echo "$PAYLOAD" | jq -r '.tool_input.command // empty')

# Regex patterns for dangerous SQL statements
if echo "$COMMAND" | grep -E -i -q '(DROP TABLE|TRUNCATE TABLE)'; then
    echo "Blocked: Destructive DROP/TRUNCATE queries are strictly prohibited without human intervention." >&2
    exit 2
fi

if echo "$COMMAND" | grep -E -i -q '\bDELETE FROM\b' && ! echo "$COMMAND" | grep -E -i -q '\bWHERE\b'; then
    echo "Blocked: DELETE FROM statement without a WHERE clause." >&2
    exit 2
fi

if echo "$COMMAND" | grep -E -i -q '\bUPDATE\b' && ! echo "$COMMAND" | grep -E -i -q '\bWHERE\b'; then
    echo "Blocked: UPDATE statement without a WHERE clause." >&2
    exit 2
fi

exit 0
```

---

### 4.5 Secret Leak Guard — PreToolUse (Engineering-Wide)

> [!CAUTION]
> Safety-critical hook. Belongs in the *global* config to protect all projects.

**Purpose:** Before Claude writes any file, scan the content for patterns that look like secrets: AWS keys, private keys, connection strings.

**Why this matters for TipTip:** An enforcement layer that catches credential patterns before they are written to disk — before they can accidentally be committed to GitLab. *(Note: This is a heuristic guard and does not replace CI tools like `gitleaks`.)*

**settings.json (Global) entry:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
             "type": "command",
             "command": "~/.claude/hooks/pre-tool-use-secret-guard.sh"
          }
        ]
      }
    ]
  }
}
```

**Script (`~/.claude/hooks/pre-tool-use-secret-guard.sh`):**
```bash
#!/bin/bash
# hooks/pre-tool-use-secret-guard.sh
# PreToolUse hook: blocks file writes containing secret patterns

PAYLOAD=$(cat)
CONTENT=$(echo "$PAYLOAD" | jq -r '.tool_input.content // empty')

# AWS keys
if echo "$CONTENT" | grep -E -q 'AKIA[0-9A-Z]{16}'; then
    echo "Blocked: Detected potential AWS Access Key ID." >&2
    exit 2
fi

# Private keys
if echo "$CONTENT" | grep -E -q '-----BEGIN.*PRIVATE KEY-----'; then
    echo "Blocked: Detected Private Key block." >&2
    exit 2
fi

# Common DB credential leak inside URIs like postgres://user:password@
if echo "$CONTENT" | grep -E -q ':\/\/\w+:\w+@'; then
    echo "Blocked: Detected connection string with embedded password." >&2
    exit 2
fi

# Generic API keys
if echo "$CONTENT" | grep -E -i -q '(api_key|apikey|secret_key)\s*=\s*["'"'"'][^"'"'"']{16,}'; then
    echo "Blocked: Detected hardcoded API key or secret." >&2
    exit 2
fi

exit 0
```

---

### 4.6 Long Task Notification — Notification (Engineering-Wide)

**Purpose:** When Claude sends a progress notification, surface it visibly in the terminal.

**Why this matters for TipTip:** During autonomous workflow runs (covered in Guide 6), this hook provides visibility into what Claude is doing.

**settings.json (Global) entry:**
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
             "type": "command",
             "command": "~/.claude/hooks/notification-progress.sh"
          }
        ]
      }
    ]
  }
}
```

**Script (`~/.claude/hooks/notification-progress.sh`):**
```bash
#!/bin/bash
# hooks/notification-progress.sh
# Notification hook: surfaces Claude's progress notifications in terminal

PAYLOAD=$(cat)
MESSAGE=$(echo "$PAYLOAD" | jq -r '.message // "Update"')

TIMESTAMP=$(date +"%H:%M:%S")
echo "[$TIMESTAMP] Claude progress: $MESSAGE" >&2

exit 0
```

---

### 4.7 Task Summary on Stop — Stop (Engineering-Wide)

**Purpose:** When Claude finishes a task, generate a brief summary and append it to `.claude-session-log.md`. 
*(Be sure to add `.claude-session-log.md` to your repository's `.gitignore`)*

**Why this matters for TipTip:** Engineers reviewing what Claude did currently have to scroll through the entire session. This provides a succinct audit file.

**settings.json entry:**
```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
             "type": "command",
             "command": ".claude/hooks/stop-session-summary.sh"
          }
        ]
      }
    ]
  }
}
```

**Script (`.claude/hooks/stop-session-summary.sh`):**
```bash
#!/bin/bash
# hooks/stop-session-summary.sh
# Stop hook: appends a session summary to .claude-session-log.md

PAYLOAD=$(cat)
REASON=$(echo "$PAYLOAD" | jq -r '.last_assistant_message // "Session stopped."')
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

cat <<EOF >> .claude-session-log.md
## Session: $TIMESTAMP
**Summary:**
$REASON
---
EOF

exit 0
```

---

## 5. Project-Level settings.json — Complete Example

Below is the complete configuration. The global config isolates engineering-wide safeguards to your machine scale, while the project config isolates lintings for the repo.

**Global Settings (`~/.claude/settings.json`):**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "hooks": [
          {
             "type": "command",
             "command": "~/.claude/hooks/pre-tool-use-secret-guard.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "*",
        "hooks": [
          {
             "type": "command",
             "command": "~/.claude/hooks/notification-progress.sh"
          }
        ]
      }
    ]
  }
}
```

**Project Settings for a Full-Stack Node/Go repo (`.claude/settings.json`):**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
             "type": "command",
             "command": ".claude/hooks/pre-tool-use-sql-guard.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
             "type": "command",
             "command": ".claude/hooks/post-tool-use-go-lint.sh"
          },
          {
             "type": "command",
             "command": ".claude/hooks/post-tool-use-eslint.sh"
          },
          {
             "type": "command",
             "command": ".claude/hooks/post-tool-use-prettier.sh"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "*",
        "hooks": [
          {
             "type": "command",
             "command": ".claude/hooks/stop-session-summary.sh"
          }
        ]
      }
    ]
  }
}
```

---

## 6. Installing Hooks from `aiad-claude`

Engineers should not write hooks from scratch — pull from `aiad-claude`.

### Option 1: Automated Installation (Recommended)

To streamline setup, we provide an interactive installation script that installs global hooks and interactively sets up project-level hooks for your specific stack.

**Prerequisite:** Ensure TipTip's Claude Code resource repository is cloned to `/tmp`:
```bash
git clone git@gitlab.com:tiptiptv/common/aiad-claude.git /tmp/aiad-claude
```

Run the following command from the root of your project repository:

```bash
bash scripts/install-hooks.sh
```

The script will:
1. Verify the `aiad-claude` repository exists in `/tmp/aiad-claude`.
2. Install the required global hooks (like secret guard and notifications) to `~/.claude/hooks/`.
3. Prompt you to select your stack (Backend/Go or Frontend/Next.js) and install the corresponding project-level hooks into `.claude/hooks/` for your current repository.
4. Automatically apply `chmod +x` to make all installed hooks executable.

Lastly, make sure to copy the relevant settings block from `/tmp/aiad-claude/settings/project-settings.json` to your local `.claude/settings.json`.

### Option 2: Manual Installation (Advanced/Fallback)

If you prefer to install hooks manually or are using an unsupported environment, follow these steps:

**Installation Commands:**
```bash
# Clone TipTip's Claude Code resource repository
git clone git@gitlab.com:tiptiptv/common/aiad-claude.git /tmp/aiad-claude

# Install global hooks (secret guard, notifications)
mkdir -p ~/.claude/hooks
cp /tmp/aiad-claude/hooks/global/* ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# Install project-level hooks (run inside your repo directory)
mkdir -p .claude/hooks
cp /tmp/aiad-claude/hooks/backend/* .claude/hooks/   # for Go repos
# OR
cp /tmp/aiad-claude/hooks/frontend/* .claude/hooks/  # for Next.js repos
chmod +x .claude/hooks/*.sh
```
Lastly, copy the relevant settings block from `/tmp/aiad-claude/settings/project-settings.json` to your local `.claude/settings.json`.

**The improvement expectation:** If a hook produces false positives, misses a case, or could enforce a better standard, open a merge request on `aiad-claude` rather than modifying your local copy. The improvement benefits every engineer on the team.

---

## 7. Verifying Hooks Are Working

To check which hooks are active, use the `/status` or `/hooks` commands directly in your Claude Code session. 

### Testing Scripts Isolated from Claude

Before integrating, you can pipe sample JSON into the shell script locally to verify exit codes and output correctly flow to stderr/stdout.

```bash
# Test the Go lint hook manually
echo '{"tool_name": "Write", "tool_input": {"file_path": "main.go"}}' \
  | .claude/hooks/post-tool-use-go-lint.sh

# Test the secret guard hook
echo '{"tool_name": "Write", "tool_input": {"content": "api_key=abc123secret"}}' \
  | ~/.claude/hooks/pre-tool-use-secret-guard.sh
```

### Common Failure Reasons
- **Script not executable:** Forgot `chmod +x my-hook.sh`. Claude will silently bypass or throw minor warnings.
- **Missing Tooling:** E.g., `golangci-lint` isn't installed. The script will error, potentially silently returning exit 0 depending on the setup. 
- **Wrong File Path:** The path in `settings.json` is incorrect.
- **Exit Code Mismatch:** Using `exit 1` instead of `exit 2` for a `PreToolUse` block condition.

---

## 8. What to Expect from Engineers

### Engineering Lead Responsibilities

- **Bootstrap project-level hooks for every active repository.** Before the team uses Claude Code autonomously on a production repo, the project-level `.claude/settings.json` with `PostToolUse` lint and format hooks must be committed to that repo. No engineer should be running autonomous Claude Code sessions on a production-adjacent repo without the quality gate hooks in place.
- **Own the hooks in `aiad-claude` for your domain.** The backend lead owns Go-related hooks. The frontend lead owns TypeScript/ESLint/Prettier hooks. When a hook produces a false positive or misses a case, leads are responsible for reviewing and merging the fix.
- **Commit `.claude/settings.json` with project hooks to the repo.** This file is not personal config — it is team infrastructure. It belongs in version control the same as a `Makefile` or `.eslintrc.json`. New engineers who clone the repo get the correct hooks automatically.
- **Never disable safety hooks without explicit team discussion.** The SQL guard and secret leak guard hooks exist for data protection. Disabling them on a production-adjacent repo requires team consensus and a documented reason. These are not matters of personal preference.
- **Review hook changes with the same scrutiny as code changes.** A poorly written hook can block legitimate work or silently fail to catch real issues. Hook MRs on `aiad-claude` should include a test case demonstrating the hook fires correctly on the target pattern and does not fire on a clean example.

### Individual Engineer Responsibilities

- **Do not modify hooks locally without a corresponding `aiad-claude` MR.** If a hook is causing problems — false positives, wrong exit codes, missing prerequisites — fix it in `aiad-claude` so everyone benefits. A local patch that is never merged means the next engineer encounters the same problem.
- **Treat a hook block as signal, not obstacle.** When the SQL guard or secret guard blocks Claude, the correct response is to review what Claude was trying to do — not to disable the hook. Hooks are catching things that would otherwise require a code review to find.
- **Ensure hook prerequisites are installed.** Hooks only work if their dependencies exist. Before starting a session on a Go repo, confirm `golangci-lint` is installed. Before a frontend session, confirm `eslint` and `prettier` are available. A hook that fails because its dependency is missing exits silently in most cases and provides no quality gate.
- **Report unexpected hook behavior to the `#claude-code` channel.** If a hook fires unexpectedly, blocks legitimate work, or appears to not be running when it should, report it. Silent hook failures degrade the quality gate without the engineer knowing.
- **Suggest new hooks via `aiad-claude` issues.** The current hook set covers the most common cases. Engineers who identify a recurring quality problem — Claude repeatedly producing code that violates a specific pattern — should open an issue on `aiad-claude` proposing a hook that catches it automatically.

### The Improvement Loop
1. Hook fires unexpectedly or misses a real problem.
2. Engineer identifies the specific case that is not handled correctly.
3. Engineer opens an MR on `aiad-claude` with tests enforcing correct behavior.
4. Lead reviews and merges.
5. Engineers pull the updated hook from `aiad-claude`.
6. Team pulls the updated `.claude/settings.json`.

---

## 9. Quick Reference

| Hook | Type | Stack | Config Level | Prerequisite |
|---|---|---|---|---|
| Go Lint (`go vet` + `golangci-lint`) | `PostToolUse` | Backend | Project | `golangci-lint` |
| ESLint Auto-fix | `PostToolUse` | Frontend | Project | `eslint` (project) |
| Prettier Auto-format | `PostToolUse` | Frontend | Project | `prettier` (project) |
| Dangerous SQL Guard | `PreToolUse` | Backend | Project | None |
| Secret Leak Guard | `PreToolUse` | Engineering-wide | Global | None |
| Long Task Notification | `Notification` | Engineering-wide | Global | None |
| Task Summary on Stop | `Stop` | Engineering-wide | Project | None |

- **Official hooks docs:** https://docs.anthropic.com/en/docs/claude-code/hooks
- **TipTip hooks repository:** https://gitlab.com/tiptiptv/common/aiad-claude (hooks are in the `hooks/` directory, settings templates in `settings/`)
- **Next in series:** Guide 6 — Workflows & Autonomous Tasks
