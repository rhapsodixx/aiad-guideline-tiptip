# Guide 4 of 7: MCP Integrations

> ⚠️ Prerequisites: Complete Guide 1 (Setup), Guide 2 (CLAUDE.md & Project Memory),
> and Guide 3 (Skills) before proceeding with this guide.

---

## 1. What Is MCP?

MCP (Model Context Protocol) is an open standard developed by Anthropic that allows
Claude Code to connect to external tools, services, and data sources as structured
tool calls within a session.

Without MCP, Claude Code can only work with files and commands available in the
local filesystem. With MCP, it can query Jira, read Confluence pages, inspect
a Figma design, search the web, or navigate a codebase symbolically — all within
the same session.

MCP servers are local processes or remote services that expose a defined set of
tools. Claude Code calls these tools the same way it calls built-in tools like
file read or bash execution.

**The difference between Skills (Guide 3) and MCP:**
- **Skills** are static prompt templates — they define *HOW* Claude should approach a task.
- **MCP servers** provide live data and live actions — they give Claude access to
  real-time information from external systems.
- **Skills and MCP compose**: a skill can orchestrate multiple MCP tool calls as
  part of its workflow.

**A note on token cost:** Every MCP tool call returns data that enters the context window.
This is why Guide 3 (Skills) came first — engineers should already understand
context cost before adding MCP tool calls on top.

[Read the official Anthropic MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp).

---

## 2. How Claude Code Loads MCP Servers

MCP servers can be configured globally for your machine or locally for a specific project.

### Configuration Levels
- **Global MCP config** (`~/.claude.json`): Available in every Claude Code session.
- **Project-level MCP config** (`.mcp.json` in the repo root): Available only
  in that project, and should be version-controlled with the repository.

*Recommendation for TipTip:* Project-specific tools (like PostgreSQL or Figma) belong in the project-level `.mcp.json`. Universal tools (like Context7, Jira, or Confluence) belong in the global `~/.claude.json`.

### Installation Methods

**1. Via CLI (`claude mcp add`)**
The easiest way to install a server. Example using Sequential Thinking:
```bash
claude mcp add --transport stdio sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
```

**2. Via Manual JSON Config**
You can directly edit `.mcp.json` (project-level) or `~/.claude.json` (global). Example for a project-level server:
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ],
      "env": {}
    }
  }
}
```

**3. Via VS Code Settings (Claude Code Extension)**
If you use an MCP-enabled VS Code extension (like Claude desktop/extension or Copilot), you can configure MCP servers in your user settings. Open the Command Palette (`Cmd + Shift + P`) and select "MCP: Open User Configuration" to edit your global MCP settings.

### Verifying MCP is Loaded
- In a Claude Code session, run the `/mcp` command to see installed servers and their status.
- When an MCP server is configured, Claude will automatically detect its tools (e.g., `resolve-library-id` for Context7) and use them when needed.

---

## 3. MCP and Token Cost

Before adding MCP servers indiscriminately, understand their impact on TipTip's current cost-sensitive GLM setup.

- **Persistent Context**: Every MCP tool call result enters the context window and stays there. Ten Jira ticket lookups = ten chunks of data in context.
- **High-Frequency vs Low-Frequency**: Some MCPs (like Serena or Context7) are called frequently during a session. Ensure their value justifies the cost.
- **Serena's Efficiency Mechanism**: While it's a high-frequency MCP, Serena provides code-centric tools like `find_symbol` and `find_referencing_symbols`. According to its documentation, this means *"the agent no longer needs to read entire files, perform grep-like searches or basic string replacements to find the right parts of the code... these tools greatly enhance (token) efficiency."* By using targeted symbol lookups instead of broad file reads across our large Go backends, Serena can actually help control context growth during refactoring.
- **Practical guidance**: Close and restart sessions when context gets large. MCP data does not persist between sessions — it is fetched fresh each time.
- **Contrast with Skills**: Skills add tokens *once* at invocation. MCP adds tokens *every time* a tool is called. In a long session with many MCP calls, MCP is the dominant cost driver.

---

## 4. Engineering-Wide MCPs

These MCPs are relevant for all TipTip engineers regardless of stack. Configure these globally (`~/.claude.json`) unless noted otherwise.

### 4.1 Serena — Semantic Code Intelligence
**Classification:** Must-Have

TipTip has multiple large Go backend services and a Next.js frontend. Navigating large codebases with file-level reads is expensive and imprecise. Serena provides symbol-level navigation: find all usages of an interface, navigate to a function definition, understand a type's dependency graph — without Claude reading entire files to find what it needs.

Serena's documentation states that by providing IDE-like tools directly to the agent, *"the agent no longer needs to read entire files... these tools greatly enhance (token) efficiency."* Serena is especially valuable for TipTip's refactoring workflows given the multi-service Go backend where interface changes cascade across many files.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "serena": {
      "command": "uvx",
      "args": ["--from", "git+https://github.com/oraios/serena", "serena", "start-mcp-server"]
    }
  }
}
```
**Config level:** Project-level (recommended, run via `.mcp.json` in the repo root).
**Prerequisites:** You must have `uv` installed. May require an initial indexing step on large repos.
**Link:** [github.com/oraios/serena](https://github.com/oraios/serena)
**Limitations:** Initial setup requires `uv` package manager. 

---

### 4.2 Context7 — Live Library Documentation
**Classification:** Must-Have

Go, Next.js, and Flutter all evolve rapidly. Claude's training data has a knowledge cutoff. Context7 injects current, version-accurate library documentation directly into the session context when Claude needs to reference an external library, eliminating hallucinated APIs and outdated code logic.

This is particularly valuable for TipTip's SatuSatu platform given its reliance on travel API integrations and third-party SDKs that update frequently.

**Installation — Claude Code CLI / Command Line:**
```bash
npx ctx7 setup --claude
```
*(This sets up the MCP and fetches the required API keys automatically).*

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```
**Config level:** Global (`~/.claude.json`).
**Prerequisites:** Requires a Context7 API key for higher rate limits (authenticates via OAuth during setup).
**Link:** [context7.com](https://context7.com/)

---

### 4.3 Sequential Thinking — Structured Problem Decomposition
**Classification:** Must-Have

Complex engineering tasks — system design, incident debugging, architecture decisions, migration planning — benefit from structured step-by-step reasoning. Sequential Thinking forces Claude to break a problem into explicit reasoning steps, evaluate each step, and revise before committing to an approach.

This produces more reliable outputs for high-stakes decisions and is especially relevant for TipTip's backend engineers working on payment flows, wallet management, and data migration tasks.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```
**Config level:** Global (`~/.claude.json`).
**Prerequisites:** Node.js installed.
**Link:** [github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)
**Limitations:** Adds token overhead; use for complex tasks but avoid for trivial edits.

---

### 4.4 Jira MCP — Issue Context in Sessions
**Classification:** Must-Have

TipTip engineers work from Jira tickets. With Jira MCP, Claude can pull the ticket directly, read linked tickets, understand context, and write code aligned with the actual acceptance criteria. This eliminates copy-pasting and enables skills (from Guide 3) to automatically pull the Jira ticket for the current branch.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio jira -- npx -y @modelcontextprotocol/server-jira --url https://your-tiptip-domain.atlassian.net
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-jira"],
      "env": {
        "JIRA_URL": "https://your-tiptip-domain.atlassian.net",
        "JIRA_EMAIL": "your.name@tiptip.co",
        "JIRA_API_TOKEN": "YOUR_API_TOKEN"
      }
    }
  }
}
```
**Config level:** Global (`~/.claude.json`).
**Prerequisites:** Atlassian API Token. Remember to replace `your-tiptip-domain` with the real tip-tip Jira domain.

---

### 4.5 Confluence MCP — Internal Documentation Access
**Classification:** Must-Have

TipTip's architecture decisions, API contracts, and technical RFCs live in Confluence. With it, Claude can pull the relevant ADR (Architecture Decision Record), read the API contract for a service, or reference the on-call runbook mid-session. Useful for onboarding and multi-service tasks.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio confluence -- npx -y @modelcontextprotocol/server-confluence --url https://your-tiptip-domain.atlassian.net/wiki
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "confluence": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-confluence"],
      "env": {
        "CONFLUENCE_URL": "https://your-tiptip-domain.atlassian.net/wiki",
        "CONFLUENCE_EMAIL": "your.name@tiptip.co",
        "CONFLUENCE_API_TOKEN": "YOUR_API_TOKEN"
      }
    }
  }
}
```
**Config level:** Global (`~/.claude.json`).
**Prerequisites:** Atlassian API Token (shares authentication with Jira).

---

### 4.6 Slack MCP — Thread and Decision Context
**Classification:** Nice-to-Have

Engineering decisions often happen in Slack threads before reaching Jira. With Slack MCP, Claude can pull a thread for context from `#incidents` or `#architecture` into a debugging session. Nice-to-Have because most decision context should eventually live in Jira or Confluence.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio slack -- npx -y @modelcontextprotocol/server-slack
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-YOUR-TOKEN"
      }
    }
  }
}
```
**Config level:** Global (`~/.claude.json`).
**Prerequisites:** Slack API token.

---

### 4.7 Brave Search / Web Search MCP — Research While Coding
**Classification:** Nice-to-Have

Enables Claude to search for solutions, error messages, and library documentation without leaving the session. Complements Context7 by covering general web research. Nice-to-Have because Context7 covers most library-specific needs, and general web search can bloat context.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio brave-search -- npx -y @modelcontextprotocol/server-brave-search
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```
**Config level:** Global (`~/.claude.json`).
**Prerequisites:** Brave Search API key.

---

## 5. Backend MCPs (Go Stack)

These MCPs are relevant for engineers working on TipTip's Go backend services. Configure at project-level (`.mcp.json` in the root) in backend repositories.

### 5.1 PostgreSQL MCP — Direct Database Inspection
**Classification:** Must-Have (Backend)

TipTip's Go services are data-layer heavy: payment records, creator profiles, wallet transactions, event tickets. Inspecting the schema and exploring table relationships without leaving Claude Code dramatically accelerates backend development. Claude can write migration scripts with full awareness of the real database and columns.

> 🚨 **SECURITY WARNING:** The PostgreSQL MCP should **ONLY** be configured against local development or staging databases. **NEVER** connect it to the production database via MCP in a local dev environment.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio postgres --env POSTGRES_URL=postgresql://localhost:5432/tiptip_local -- npx -y @modelcontextprotocol/server-postgres
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_URL": "postgresql://user:password@localhost:5432/dbname"
      }
    }
  }
}
```
**Config level:** Project-level (`.mcp.json`).
**Prerequisites:** Database connection string. Use environment variables instead of hard-coding credentials! (e.g., `"POSTGRES_URL": "${LOCAL_DB_URL}"`). Read-only capabilities are recommended for safety.

---

### 5.2 GitLab MCP — Repository and MR Context
**Classification:** Must-Have (Backend, but note it is also useful for Frontend)

Enables Claude to fetch MR descriptions, pipeline status, review comments, and repository metadata directly in a session. Particularly useful for the code-review skill (Guide 3): the skill can pull the MR diff from GitLab directly rather than relying on locally staged changes.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio gitlab -- npx -y @modelcontextprotocol/server-gitlab
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "gitlab": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gitlab"],
      "env": {
        "GITLAB_API_URL": "https://gitlab.com/api/v4",
        "GITLAB_PERSONAL_ACCESS_TOKEN": "glpat-YOURTOKEN"
      }
    }
  }
}
```
**Config level:** Global or Project-level.
**Prerequisites:** GitLab personal access token. Set `GITLAB_API_URL` to TipTip's instance URL if self-hosted or standard `gitlab.com`.

---

## 6. Frontend MCPs (React / Next.js Stack)

These MCPs are relevant for engineers working on TipTip's React/Next.js codebases. Configure at project-level (`.mcp.json`) in frontend repositories.

### 6.1 Figma MCP — Design-to-Code Context
**Classification:** Must-Have (Frontend)

Instead of manually inspecting Figma frames and translating design tokens, Claude can read the Figma design directly: component structure, spacing, typography, color tokens, and asset references are available in the session context. This is important for TipTip's SatuSatu platform where UI consistency and design fidelity are high priorities. 

The Figma MCP connects directly to Figma’s hosted endpoint at `https://mcp.figma.com/mcp` or runs locally through the Figma desktop app.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport sse figma https://mcp.figma.com/mcp --header "Authorization: Bearer YOUR_FIGMA_TOKEN"
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "figma": {
      "type": "sse",
      "url": "https://mcp.figma.com/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_FIGMA_TOKEN"
      }
    }
  }
}
```
**Config level:** Project-level (`.mcp.json`).
**Prerequisites:** Figma personal access token (`YOUR_FIGMA_TOKEN`). The MCP server strictly enforces standard Figma access permissions.
**Link:** [help.figma.com/hc/en-us/articles/32132100833559](https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server)

---

### 6.2 Browser/Playwright MCP — Live UI Testing and Inspection
**Classification:** Nice-to-Have (Frontend)

Enables Claude to open a browser, navigate to a running local dev server, inspect the rendered UI, and verify that generated components render correctly. Useful for debugging visual regressions where file-level inspection is insufficient.

**Installation — Claude Code CLI:**
```bash
claude mcp add --transport stdio puppeteer -- npx -y @modelcontextprotocol/server-puppeteer
```

**Installation — VS Code (Claude Code extension):**
```json
{
  "mcpServers": {
    "puppeteer": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-puppeteer"]
    }
  }
}
```
**Config level:** Project-level (`.mcp.json`).
**Prerequisites:** Requires a standard Node.js/NPX environment.

---

## 7. Recommended MCP Stack by Role

| MCP                 | Engineering-Wide | Backend (Go) | Frontend (Next.js) | Classification | Config Level |
| ------------------- | ---------------- | ------------ | ------------------ | -------------- | ------------ |
| Serena              | ✅                | ✅            | ✅                  | Must-Have      | Project      |
| Context7            | ✅                | ✅            | ✅                  | Must-Have      | Global       |
| Sequential Thinking | ✅                | ✅            | ✅                  | Must-Have      | Global       |
| Jira                | ✅                | ✅            | ✅                  | Must-Have      | Global       |
| Confluence          | ✅                | ✅            | ✅                  | Must-Have      | Global       |
| GitLab              | ✅                | ✅            | ✅                  | Must-Have      | Global       |
| Slack               | ✅                | -            | -                  | Nice-to-Have   | Global       |
| Web Search          | ✅                | -            | -                  | Nice-to-Have   | Global       |
| PostgreSQL          | -                | ✅            | -                  | Must-Have      | Project      |
| Figma               | -                | -            | ✅                  | Must-Have      | Project      |
| Browser/Playwright  | -                | -            | ✅                  | Nice-to-Have   | Project      |

- **Must-Have** MCPs should be installed before the engineer's first Claude Code session on a production repository.
- **Project-level** MCPs (in `.mcp.json`) should be committed to the repository so the whole team shares the same configuration automatically.
- **Global** MCPs (`~/.claude.json`) are machine-local and each engineer installs them once.

---

## 8. MCP and Skills: How They Work Together

**Skills** (Guide 3) define the workflow. **MCPs** provide the live data.

**Example: The TipTip Code Review Workflow**
The `code-review` skill orchestrates the activity, but it can be supercharged with MCPs:
1. **GitLab MCP** pulls the MR diff and reviewer comments directly from the repository.
2. **Jira MCP** pulls the linked ticket to check the original acceptance criteria.
3. **PostgreSQL MCP** validates if the new SQL migrations mapped in the MR correctly apply to the schema locally.
4. **Context7** checks the newly added Go module usage against the absolute latest library definitions.

The skill orchestrates; the MCPs supply the data. However, be cautious of **context window compounding**. When a skill triggers multiple MCP calls, the context grows quickly. Monitor session length and restart when context feels bloated!

---

## 9. What to Expect from Engineers

### Engineering Lead Responsibilities

- **Own the project-level `.mcp.json` for active repositories.** This file should be committed to the repository so every engineer who clones the repo gets the correct MCP configuration automatically.
- **Bootstrap global MCP config for the team.** Provide the team with a standard `~/.claude.json` template covering Jira, Confluence, GitLab, Context7, and Sequential Thinking. Engineers copy this as their baseline global config.
- **Manage MCP credentials distribution.** Jira, Confluence, and GitLab MCPs require API tokens. Coordinate with the team on how these are obtained and stored inside a secrets manager (**do not hardcode in `.mcp.json`**).
- **Review `.mcp.json` changes via MR.** Adding or modifying project-level MCPs is a team decision, not an individual one.
- **Monitor token cost impact.** After MCP rollout, review session costs in the Z.ai dashboard. If costs spike significantly, identify which MCPs are high-frequency and consider whether their usage can be made more targeted.

### Individual Engineer Responsibilities

- **Install global MCPs before first production session.** Use the team-provided global config template as the baseline.
- **Understand what each MCP does before relying on it.** MCPs can read sensitive data (database contents, Jira tickets, Confluence pages). Know what you are giving Claude access to in each session.
- **Do not add MCPs to project `.mcp.json` without team discussion.** Project-level MCPs affect everyone who works on that repo.
- **Report MCP failures promptly.** If an MCP server stops responding or returns wrong data, it degrades Claude's output silently. Report to the `#claude-code` Slack channel.
- **Keep MCP credentials current.** API tokens expire. If Claude starts failing on Jira or Confluence lookups, check token expiry first.

---

## 10. Quick Reference

| MCP                 | Source                                  | Install Command (CLI)                     | Config Level | Key Credential       |
| ------------------- | --------------------------------------- | ----------------------------------------- | ------------ | -------------------- |
| Serena              | github.com/oraios/serena                | `claude mcp add serena ...`               | Project      | None / uv config     |
| Context7            | context7.com                            | `npx ctx7 setup --claude`                 | Global       | Context7 API key     |
| Sequential Thinking | github.com/.../sequentialthinking       | `claude mcp add sequential-thinking ...`  | Global       | None                 |
| Jira                | @modelcontextprotocol/server-jira       | `claude mcp add jira ...`                 | Global       | Atlassian API token  |
| Confluence          | @modelcontextprotocol/server-confluence | `claude mcp add confluence ...`           | Global       | Atlassian API token  |
| GitLab              | @modelcontextprotocol/server-gitlab     | `claude mcp add gitlab ...`               | Global       | GitLab PAT           |
| Slack               | @modelcontextprotocol/server-slack      | `claude mcp add slack ...`                | Global       | Slack API token      |
| PostgreSQL          | @modelcontextprotocol/server-postgres   | `claude mcp add postgres ...`             | Project      | DB connection string |
| Figma               | figma.com/MCP                           | `claude mcp add --transport sse figma...` | Project      | Figma PAT            |
| Browser             | @modelcontextprotocol/server-puppeteer  | `claude mcp add puppeteer ...`            | Project      | None                 |

- **Official MCP Docs:** [https://docs.anthropic.com/en/docs/claude-code/mcp](https://docs.anthropic.com/en/docs/claude-code/mcp)
- **TipTip Claude Code Repository:** [https://gitlab.com/tiptiptv/common/aiad-claude](https://gitlab.com/tiptiptv/common/aiad-claude) (project-level mcp.json templates are maintained here).
