# Guide 4 of 7: MCP Integrations

> ⚠️ Prerequisites: Complete Guides 1–3 before proceeding.

---

## 1. What Is MCP?

MCP (Model Context Protocol) is an open standard that lets Claude Code connect to external tools and data sources — Jira, Confluence, Figma, databases, web search — as structured tool calls within a session.

Without MCP, Claude only sees your local filesystem. With MCP, it queries live systems mid-session.

**Skills vs MCP:**
- **Skills** = static prompt templates defining *how* Claude approaches a task
- **MCP** = live data and live actions from external systems
- Skills orchestrate MCP — they compose, not compete

**Token cost note:** Every MCP tool call returns data into the context window. This is why Skills (Guide 3) came first — understand context cost before adding MCP calls on top.

[Official MCP docs](https://docs.anthropic.com/en/docs/claude-code/mcp).

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

- **Persistent context** — every MCP tool call result enters the context window and stays there. Ten Jira lookups = ten data chunks in context.
- **Serena's efficiency trade-off** — high-frequency MCP, but provides targeted symbol lookups instead of broad file reads. For large Go backends, this *reduces* token usage during refactoring.
- **Skills add tokens once; MCP adds tokens per call** — in long sessions with many MCP calls, MCP is the dominant cost driver
- **Restart when bloated** — MCP data doesn't persist between sessions. Fresh session = clean context.

---

## 4. Engineering-Wide MCPs

These MCPs are relevant for all TipTip engineers regardless of stack. Configure these globally (`~/.claude.json`) unless noted otherwise.

### 4.1 Serena — Semantic Code Intelligence
**Classification:** Must-Have

TipTip has multiple large Go backends and a Next.js frontend. Navigating these with file-level reads is expensive and imprecise. Serena provides symbol-level navigation: find all usages of an interface, navigate to a function definition, understand a type's dependency graph — without reading entire files. Especially valuable for refactoring workflows where interface changes cascade across services.

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

Go, Next.js, and Flutter evolve fast. Claude's training data has a knowledge cutoff. Context7 injects current, version-accurate library docs directly into the session — eliminates hallucinated APIs and outdated patterns.

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

Forces Claude to reason step-by-step for complex tasks — system design, incident debugging, migration planning. Produces more reliable outputs for high-stakes decisions. Token overhead, so use for complex tasks, not trivial edits.

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

Claude pulls the Jira ticket directly — linked tickets, acceptance criteria, all in session context. No more copy-pasting ticket descriptions.

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

Claude can pull ADRs, API contracts, and tech RFCs from Confluence mid-session. Useful for onboarding and multi-service tasks.

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

### 4.6 Brave Search / Web Search MCP — Research While Coding
**Classification:** Nice-to-Have

General web search without leaving the session. Complements Context7 for non-library queries. Can bloat context — use sparingly.

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

TipTip's Go services are data-layer heavy — payment records, wallet transactions, event tickets. Claude can inspect the real schema and write migration scripts with full column awareness.

> 🚨 **SECURITY WARNING:** Only connect to **local dev or staging** databases. **Never** production via MCP.

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

Claude opens a browser, navigates to your local dev server, inspects rendered UI. Useful for visual regressions where file-level inspection isn't enough.

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
| Web Search          | ✅                | -            | -                  | Nice-to-Have   | Global       |
| PostgreSQL          | -                | ✅            | -                  | Must-Have      | Project      |
| Figma               | -                | -            | ✅                  | Must-Have      | Project      |
| Browser/Playwright  | -                | -            | ✅                  | Nice-to-Have   | Project      |

- **Must-Have** MCPs should be installed before the engineer's first Claude Code session on a production repository.
- **Project-level** MCPs (in `.mcp.json`) should be committed to the repository so the whole team shares the same configuration automatically.
- **Global** MCPs (`~/.claude.json`) are machine-local and each engineer installs them once.

---

## 8. MCP and Skills: How They Work Together

Skills define the workflow. MCPs supply the live data.

**Example — TipTip code review workflow:**
1. **GitLab MCP** pulls the MR diff and reviewer comments
2. **Jira MCP** pulls the linked ticket to verify acceptance criteria
3. **PostgreSQL MCP** validates new SQL migrations against the local schema
4. **Context7** checks newly added Go modules against latest library docs

The skill orchestrates; MCPs supply data. Watch for **context window compounding** — multiple MCP calls in one skill grow context fast. Restart sessions when bloated.

---

## 9. What to Expect from Engineers

### Engineering Leads
- **Own the project-level `.mcp.json`** for active repos — committed to the repository so every engineer gets the same config
- **Provide a global config template** — standard `~/.claude.json` covering Jira, Confluence, GitLab, Context7, Sequential Thinking
- **Coordinate credentials** — API tokens via secrets manager, **never hardcoded in `.mcp.json`**
- **Review `.mcp.json` changes via MR** — adding MCPs is a team decision
- **Monitor token cost** — check Z.ai dashboard after MCP rollout. If costs spike, identify high-frequency MCPs

### Individual Engineers
- Install global MCPs before first production session (use the team template)
- Know what each MCP accesses — databases, Jira tickets, Confluence pages. Understand what you're giving Claude.
- Don't add MCPs to project `.mcp.json` without team discussion
- Report MCP failures immediately in `#aiad-discussion` — silent failures degrade output
- Keep tokens current — if Jira/Confluence lookups start failing, check token expiry first

> 💡 *Tip:* Keep under 10 MCPs enabled and under 80 tools active per session. Your 200K context window before compacting might only be ~70K with too many tools. Disable unused MCPs per project via `disabledMcpServers` in `.mcp.json`.

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
| PostgreSQL          | @modelcontextprotocol/server-postgres   | `claude mcp add postgres ...`             | Project      | DB connection string |
| Figma               | figma.com/MCP                           | `claude mcp add --transport sse figma...` | Project      | Figma PAT            |
| Browser             | @modelcontextprotocol/server-puppeteer  | `claude mcp add puppeteer ...`            | Project      | None                 |

- **Official MCP Docs:** [https://docs.anthropic.com/en/docs/claude-code/mcp](https://docs.anthropic.com/en/docs/claude-code/mcp)
- **TipTip Claude Code Repository:** [https://gitlab.com/tiptiptv/common/aiad-claude](https://gitlab.com/tiptiptv/common/aiad-claude) (project-level mcp.json templates are maintained here).
