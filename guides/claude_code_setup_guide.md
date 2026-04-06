# Guide 1 of 7: Setup

---

## 1. Why Claude Code?

Claude Code is a terminal-native agentic coding tool — not autocomplete. It reads files, runs commands, and navigates codebases directly from your terminal to autonomously execute multi-step tasks.

Why Claude Code over Cursor, Copilot, Cline, or Windsurf:
- **Skills** — reusable, project-specific task templates
- **CLAUDE.md** — native, persistent project memory
- **MCP** — first-class Model Context Protocol integrations (Atlassian, browsers)
- **Subagents** — parallel sub-task delegation
- **Hooks** — pre/post tool execution enforcement for linting, testing, formatting

**TipTip's Plan:** We have adopted the **Claude Code Team Standard Plan** ($25/month per user) as our primary AI-assisted development engine. Using native Anthropic models (Haiku, Sonnet, Opus) ensures our AI adoption metrics reflect genuine model accuracy rather than being distorted by third-party model inconsistencies. When the Team Plan quota is exhausted, engineers fall back to GLM models via Z.ai (see [Section 9](#9-glm-fallback--when-team-plan-quota-is-exhausted)).

---

## 2. Prerequisites

Before starting:
- **Node.js v18+**: Required to run Claude Code. [Download and install Node.js here](https://nodejs.org/en/download/).
- **Claude Code Team Invitation**: You must accept the Team Plan invite from **Dominikus**. Check your email for the Anthropic team invitation.
- **Git**: Assumed to be already installed and configured on your machine.

*Note: You do NOT need a separate Anthropic API key. The Team Plan subscription handles authentication directly via `claude login`.*

---

## 3. Installation

### Install Claude Code
Install the Claude Code CLI globally using npm:

```bash
npm install -g @anthropic-ai/claude-code
```

Verify the installation by checking the version:

```bash
claude --version
```

---

## 4. Configuration — Claude Code Team Plan

TipTip uses the **Claude Code Team Standard Plan** as the primary AI-assisted development engine. This connects directly to Anthropic's native models — no proxy, no third-party translation layer.

### Step 1: Accept the Team Invitation

1. Check your email for the Anthropic Team invitation sent by **Dominikus**.
2. Click the invitation link and create your Anthropic account (or sign in if you already have one).
3. Confirm you are added to the TipTip team workspace.

### Step 2: Authenticate Claude Code

In your terminal, run:

```bash
claude login
```

Follow the interactive prompts to authenticate with your Anthropic account. Claude Code will open a browser window for OAuth authentication. Once complete, your CLI session is authenticated against the Team Plan.

### Step 3: Verify Authentication

```bash
claude
```

Then, inside the Claude Code prompt, type:
```
/status
```

**Expected output:** You should see your account linked to the TipTip team workspace, with the default model set to **Sonnet**.

> 💡 **No environment variables needed.** Unlike the GLM fallback setup, the Team Plan uses OAuth-based authentication via `claude login`. You do not need to set `ANTHROPIC_BASE_URL` or `ANTHROPIC_API_KEY` for normal operation.

> ⚠️ **If you previously had Z.ai environment variables set** (e.g., `ANTHROPIC_BASE_URL` pointing to `https://api.z.ai/api/anthropic`), you must **remove or comment them out** from your shell profile (`~/.zshrc`, `~/.bashrc`) and from `~/.claude/settings.json` before using the Team Plan. These overrides will redirect traffic away from Anthropic's servers.

---

## 5. Verify the Setup

To confirm that Claude Code is correctly using the Team Plan, launch the tool and check its status.

Run the tool:
```bash
claude
```

Then, inside the Claude Code prompt, type:
```
/status
```

**Expected output:** The status should show your Anthropic account, team workspace name (TipTip), and the default model (Sonnet). There should be **no** custom `ANTHROPIC_BASE_URL` override.

*Optional:* You can also type `/usage` to check your current subscription usage and remaining quota for the billing period.

---

## 6. Optimizing Your Subscription — Model & Mode Guide

The Team Standard Plan gives every engineer access to three model tiers: **Haiku**, **Sonnet**, and **Opus**. Using the right model for the right task is critical to maximizing quota efficiency while maintaining high code accuracy.

### 6a. When to Use Which Model

| Model      | Best For                                                                                                | Recommended TipTip Skills                                                                                                        | Quota Impact | How to Switch                  |
| :--------- | :------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------- | :----------: | :----------------------------- |
| **Haiku**  | Fast bash commands, boilerplate generation, simple diffs, codebase exploration, lightweight doc updates | `pr-description`, `git-commit`, `update-docs`, `shift-left-manual-test`, `golang-pattern`                                        |    🟢 Low     | `/model` → select haiku        |
| **Sonnet** | Heavy agentic coding, refactoring, code reviews, test generation, automation scripting                  | `code-review-golang`, `code-review-nextjs`, `code-review-flutter`, `tdd`, `automation-script-generation`, `build-fix`, `go-test` |   🟡 Medium   | **Default** — no switch needed |
| **Opus**   | Deep architectural reasoning, root cause analysis, complex multi-service planning, RFC reviews          | `systematic-debugging`, `rfc-review`, `system-design`, `writing-plans`, `subagent-driven-development`                            |    🔴 High    | `/model` → select opus         |

> 💡 **Switching models mid-session:** Type `/model` in the Claude Code prompt to open the model selector. Use arrow keys or type the model name (e.g., `haiku`) and press Enter. The switch takes effect immediately for all subsequent messages in the session.

> ⚠️ **Opus quota warning:** Opus consumes quota significantly faster than Sonnet. Reserve it for tasks where deep reasoning is genuinely required (e.g., debugging a production incident across 3 services, or reviewing an RFC with complex trade-offs). For standard code reviews and feature work, Sonnet is more than sufficient.

**Practical heuristics:**
- **Starting a new feature?** Begin with **Sonnet** (default). If Claude struggles with architectural decisions, switch to **Opus** for the planning phase, then switch back to **Sonnet** for implementation.
- **Generating PR descriptions or commit messages?** Switch to **Haiku** — these are template-fill tasks that don't need flagship reasoning.
- **Debugging a complex, hard-to-reproduce bug?** Start with **Opus** + the `systematic-debugging` skill for the root cause analysis, then switch to **Sonnet** for the fix.

### 6b. When to Use Accept Edits vs. Plan Mode

Claude Code operates in two primary execution modes. Choosing the right one prevents wasted quota and accidental code breakage.

| Mode                      | How to Activate                                   | What It Does                                                                                                                                                 | When to Use                                                                                                                 | When to Avoid                                                           |
| :------------------------ | :------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------- | :---------------------------------------------------------------------- |
| **Auto-Accept (Default)** | Just type your prompt                             | Claude reads, edits, and runs commands autonomously toward the goal.                                                                                         | Well-defined tasks: boilerplate, test generation, single-file fixes, skills with clear output.                              | Unfamiliar codebases, risky multi-file refactors, unclear requirements. |
| **Plan Mode**             | Type `/plan` or press `Shift+Tab` (cycle to Plan) | Claude analyzes the codebase and generates a detailed implementation plan **without executing any changes**. You review and approve before execution begins. | Architecture decisions, multi-file refactors, unfamiliar repos, tasks where you want to see the approach before committing. | Simple one-liners, quick fixes, tasks you've run many times before.     |

**Key shortcuts for execution control:**

| Action                | Shortcut    | Description                                                    |
| :-------------------- | :---------- | :------------------------------------------------------------- |
| Cycle execution modes | `Shift+Tab` | Toggles between Auto-Accept, Plan Mode, and other modes        |
| Interrupt execution   | `Ctrl+C`    | Stops Claude mid-action                                        |
| Undo / Rewind         | `Esc Esc`   | Reverts the last action or restores code to its pre-edit state |
| Check quota usage     | `/usage`    | Shows remaining subscription usage for the billing period      |
| Check context size    | `/context`  | Shows current token usage in the context window                |
| Switch model          | `/model`    | Opens the model selector to switch between Haiku, Sonnet, Opus |
| Clear session         | `/clear`    | Starts a fresh session, clearing the context window            |
| Open in text editor   | `Ctrl+G`    | Opens the current plan/output in your configured text editor   |

> 💡 **Rule of thumb:** If you can write clear acceptance criteria before starting, use **Auto-Accept**. If you're not sure what "done" looks like yet, use **Plan Mode** first to see Claude's approach, then approve or redirect.

### 6c. Quota Management Tips

Your Team Standard Plan quota is managed via a **rolling 5-hour window** per member. Here's how to stay efficient:

1. **Check your quota regularly:** Type `/usage` in any Claude Code session to see remaining capacity.
2. **Use Haiku aggressively for lightweight tasks.** Switching to Haiku for `pr-description`, `git-commit`, and exploration tasks can extend your effective quota by 3–5x compared to running everything on Sonnet.
3. **Avoid unnecessary Opus usage.** Reserve Opus for tasks listed in the table above. A single Opus session can consume as much quota as 5+ Sonnet sessions.
4. **Use `/clear` between unrelated tasks.** A bloated context window from a previous task wastes tokens on every subsequent message. Start fresh.
5. **When quota is exhausted,** fall back to the GLM proxy (see [Section 9](#9-glm-fallback--when-team-plan-quota-is-exhausted)). Do not stop working — switch and continue.

---

## 7. Recommended IDE

Claude Code operates primarily as a Command Line Interface (CLI) and can run in any terminal. However, the choice of IDE heavily impacts your workflow because of dedicated extensions that provide a Graphical User Interface (GUI) over the CLI.

| IDE                    | Compatibility | Plugin/Extension                   | Best Use Case                                              | Notes                                                                                                                                                                          |
| :--------------------- | :------------ | :--------------------------------- | :--------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Visual Studio Code** | Excellent     | Yes (Official Anthropic Extension) | **Recommended** for the best Claude Code GUI experience    | Provides a native graphical interface for Claude Code, including inline graphical diffs, plan reviews, `@-mentions`, and conversation history.                                 |
| **Zed**                | Excellent     | Native terminal + Agent panel      | Fast prototyping, POCs, and exploratory coding with Claude | Rust-based, extremely fast startup. Native AI assistant panel. Ideal for lightweight, high-velocity sessions.                                                                  |
| **GoLand** (JetBrains) | Very Good     | Yes (JetBrains Plugin)             | Native Go development with Claude                          | Integrates the CLI into the IDE terminal and provides shortcuts for interactive diff viewing and real-time diagnostic sharing.                                                 |
| **Antigravity**        | Excellent     | Works via terminal (VS Code fork)  | Advanced native multi-agent orchestration                  | Google's agent-first IDE. While it supports Claude Code perfectly via its terminal (being a VS Code fork), Antigravity is designed around its own native agent orchestrations. |
| **KiloCode**           | Good          | Works via terminal / Custom Agents | Highly customizable, multi-model workflows                 | Open-source platform that excels in extreme customization (models, modes, permissions). TipTip previously explored this.                                                       |
| **Cursor**             | Good          | Works via terminal                 | Interactive pair-programming                               | Very popular AI IDE. While its Agent Mode is strong, it is fundamentally an interactive Editor interface rather than a CLI-first autonomous agent.                             |

### Why Visual Studio Code?
We highly recommend using **Visual Studio Code** when working with Claude Code. Anthropic has released an official VS Code extension that transforms the terminal-based CLI tool into a rich graphical experience. The native UI for viewing inline code diffs, reviewing plans before execution, and managing conversation history makes it vastly superior and more intuitive than using a standalone terminal or other IDEs.

### Why Zed as a Secondary Option?

[Zed](https://zed.dev/) is recommended as a **secondary alternative** for **fast prototyping, testing, and proof-of-concept work** — not as a replacement for VS Code. Built in **Rust**, Zed is dramatically faster than VS Code (which runs on **Electron**) in startup time, file navigation, and rendering. Its native AI assistant panel pairs well with Claude Code for quick exploratory sessions where speed and minimal friction matter.

> ⚠️ **macOS only:** Zed is currently recommended only for engineers running **macOS**. Windows support is still in early stages and not yet reliable for daily use.

VS Code remains the **primary recommendation** because its Electron-based ecosystem, while heavier, is far more mature — its extension marketplace is richer, debugging tools are more robust, and team-wide extension consistency is easier to maintain. For iterative product development in a startup context, stability and tooling depth matter more than raw speed.

**Rule of thumb:** For daily product development (features, bug fixes, code reviews) → use **VS Code**. For quick POCs, spike explorations, or testing new ideas on macOS → **Zed** is a strong secondary choice.

### Why not KiloCode or Cursor natively? (The shift to pure Claude Code)

Previously, TipTip leaned toward **KiloCode** because of its incredible flexibility: it allows for deep customization of agents, permissions, modes, and supports 500+ models. It is a fantastic open-source ecosystem. 

However, we are moving towards using **Claude Code directly** (via VS Code or CLI) for the following reasons:
1. **Agent-First Autonomy:** Tools like Cursor are built as "Assistants" embedded in an editor. Claude Code is built from the ground up to be an autonomous orchestrator. You give it a high-level `task.md`, and it will map the codebase, edit multiple files, run terminal commands, debug, and self-correct with minimal hand-holding.
2. **First-class CLAUDE.md integration:** Claude Code relies natively on a hierarchical `CLAUDE.md` memory system to maintain architectural context and rules across sessions, making team alignment much easier.
3. **Seamless Git & Tooling integration:** Claude Code natively handles creating branches, committing code, and opening pull requests as part of its autonomous loop, turning it into a true junior developer rather than just a smart autocomplete engine. 
4. **Standardization:** By standardizing on the official Claude Code Team Plan, we guarantee a uniform, highly capable agentic experience for all engineers with native Anthropic models, rather than maintaining complex custom agency configurations in KiloCode.

> 💡 *Tip from [The Shorthand Guide to Everything Claude Code](https://x.com/affaanmustafa/status/2012378465664745795):* **Keyboard shortcuts** — `Ctrl+U` deletes an entire input line (faster than backspace), `!` prefixes a quick bash command, `@` searches for files, `/` initiates slash commands (for the difference between a command and a skill, see [Skills vs Commands](claude_code_skills_guide.md#2-skills-vs-commands)), `Shift+Enter` enables multi-line input, `Tab` toggles thinking display, and `Esc Esc` interrupts Claude or restores code.

---

## 8. Historical Context: OpenRouter → GLM → Team Plan

TipTip's AI-assisted development infrastructure has evolved through three phases:

1. **OpenRouter (Phase 1):** Initially used as a multi-model aggregator to experiment with different LLMs. Retired due to middleman latency, aggregator-introduced syntax regressions, and data privacy concerns.
2. **GLM via Z.ai (Phase 2):** Transitioned to a direct [GLM subscription](https://z.ai/subscribe) (no seat commitment) for lower latency, better agentic stability, and predictable cost efficiency. This phase proved AI-assisted development ROI and built team proficiency.
3. **Claude Code Team Plan (Phase 3 — Current):** Now standardized on Anthropic's native models via the Team Standard Plan. This ensures code generation accuracy is not compromised by third-party model approximations, which is critical for validating our AI adoption metrics.

The GLM/Z.ai infrastructure is retained as a **fallback** (see Section 9 below) for quota exhaustion scenarios.

---

## 9. GLM Fallback — When Team Plan Quota Is Exhausted

When your Team Plan quota is exhausted (you'll see rate-limit messages in Claude Code), switch to the Z.ai GLM proxy to continue working without interruption.

### How to Activate the GLM Fallback

#### Option A: Shell Environment Variables

**macOS / Linux** — Add to your shell profile (`~/.zshrc` or `~/.bashrc`):

```bash
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_API_KEY="your_zai_api_key_here"
```

After saving, apply:
```bash
source ~/.zshrc # or source ~/.bashrc
```

**Windows (PowerShell)**:

```powershell
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "https://api.z.ai/api/anthropic", "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "your_zai_api_key_here", "User")
```

Restart your PowerShell terminal to ensure the variables are loaded.

#### Option B: Claude Code Settings File (Cross-Platform)

Edit or create `~/.claude/settings.json` and add the `env` block:

```json
{
  "env": {
    "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
    "ANTHROPIC_API_KEY": "your_zai_api_key_here"
  }
}
```

> 💡 **Which method to choose?** The `settings.json` approach is recommended for the fallback because it keeps the override scoped to Claude Code — your shell stays clean and the config is portable. Use the shell environment variable approach only if you need other tools (beyond Claude Code) to read the same API key.

> ⚠️ If you already have a `~/.claude/settings.json` with other settings, merge the `env` block into the existing file rather than overwriting it.

### How to Switch Back to the Team Plan

When your Team Plan quota resets (rolling 5-hour window), **remove or comment out** the Z.ai environment variables:

1. **Shell profile:** Delete the `export ANTHROPIC_BASE_URL=...` block from `~/.zshrc` / `~/.bashrc` and run `source ~/.zshrc`.
2. **Settings file:** Remove the `env` block from `~/.claude/settings.json`.
3. Run `claude login` if needed to re-authenticate with the Team Plan.

> ⚠️ **Do not leave the GLM override active permanently.** The Team Plan uses native Anthropic models which provide higher accuracy and reasoning quality. The GLM fallback is for **temporary quota exhaustion only** — always switch back when quota resets.

### GLM Fallback API Key

Contact **Dominikus** for the Z.ai API key if you don't already have one.

### Available GLM Fallback Models

These are the models available via Z.ai when operating in fallback mode. The Z.ai proxy automatically routes requests to GLM models based on the `ANTHROPIC_BASE_URL` configuration.

| Model                 | OpenRouter ID               | Input ($/1M tokens) | Output ($/1M tokens) | Context Window | Tier       | Tool Use support | Best Use Case                                               | Notes                                                 |
| :-------------------- | :-------------------------- | :------------------ | :------------------- | :------------- | :--------- | :--------------- | :---------------------------------------------------------- | :---------------------------------------------------- |
| Claude 3.5 Sonnet     | anthropic/claude-3.5-sonnet | $3.00               | $15.00               | 200K           | Flagship   | Yes              | Complex architecture, deep debugging, massive refactors     | Top-tier intelligence for difficult agentic tasks     |
| Claude 3.5 Haiku      | anthropic/claude-3.5-haiku  | $0.80               | $4.00                | 200K           | Small-Fast | Yes              | High-speed iterations, simple scripts, log analysis         | Extremely fast and capable for its size               |
| GLM-5                 | glm-5                       | Included            | Included             | 203K           | Flagship   | Yes              | Heavy agentic workflows, large context tasks                | Next-generation flagship                              |
| GLM-4.7               | glm-4.7                     | Included            | Included             | 203K           | Mid-range  | Yes              | Standard daily development, comprehensive code generation   | Excellent for complex tasks, strong coding capability |
| GLM-4.6               | glm-4.6                     | Included            | Included             | 205K           | Mid-range  | Yes              | Tasks requiring structured outputs                          | Expanded context, structured function calling         |
| GLM-4.5               | glm-4.5                     | Included            | Included             | 128K           | Mid-range  | Yes              | Legacy code exploration, general reasoning                  | Unifies reasoning and coding abilities                |
| GLM-4.5 Air           | glm-4.5-air                 | Included            | Included             | 131K           | Small-Fast | Yes              | Fast, lightweight queries and reviews                       | Fast response time for general queries                |
| GLM-4.7 Flash         | glm-4.7-flash               | Included            | Included             | 203K           | Small-Fast | Yes              | Background agents, mass file reading, linting               | Highly cost-effective                                 |
| GLM-4.5 Air (free)    | glm-4.5-air-free            | $0.00               | $0.00                | 131K           | Free       | Yes              | Experimentation, onboarding without budget                  | Rate-limited free tier option                         |
| DeepSeek V3.2         | deepseek-v3.2               | $0.26               | $0.38                | 164K           | Mid-range  | Yes              | Cost-sensitive high-quality agent runs                      | Low output cost, Chinese server residency             |
| DeepSeek V3 0324      | deepseek-v3-0324            | $0.20               | $0.77                | 164K           | Mid-range  | Yes              | Legacy compatibility, reliable general coding               | Previous V3 version                                   |
| Gemini 2.5 Flash      | gemini-2.5-flash            | $0.30               | $2.50                | 1M             | Mid-range  | Yes              | Extremely large codebase analysis, immense context fetching | Massive context window                                |
| Gemini 2.5 Flash Lite | gemini-2.5-flash-lite       | $0.10               | $0.40                | 1M             | Small-Fast | Yes              | Fast context scanning over medium-large repositories        | Fast, 1M context at low cost                          |

**Why GLM-4.7 as the default fallback?**
1. **Agentic Workflow Tuning:** GLM-4.7 is explicitly tuned to support comprehensive "task completion" and "interleaved thinking" modes ideal for agentic tools like Claude Code.
2. **Idiomatic Go Code Generation:** Excels at generating idiomatic Go code with proper error handling patterns, well-structured interface design, and correct goroutine usage — essential for TipTip's backend microservices.
3. **TypeScript Type Inference:** Robust multilingual coding support with a strong grasp of TypeScript types and generics, benefiting our React/Next.js stacks.
4. **Cost-Effectiveness:** We utilize the [GLM Subscription plan via Z.ai](https://z.ai/subscribe) which provides a quarterly API bundle with **no seat commitment**, making it highly cost-effective and predictable for our fallback usage.

*Note regarding DeepSeek:* While DeepSeek V3.2 is cheaper on output tokens, its privacy policies mandate that data is stored on servers in mainland China, raising data residency concerns. For TipTip's proprietary codebase, GLM is preferred because Z.ai offers region-aware routing and distinct international endpoints with stronger enterprise data security commitments.
