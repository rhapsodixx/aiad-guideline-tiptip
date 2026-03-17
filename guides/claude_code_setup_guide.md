# Claude Code Setup Guide — TipTip Internal
### Series: Claude Code at TipTip | Guide 1 of 7: Setup

---

## 1. Why Claude Code?

Claude Code is a terminal-native agentic coding tool — not just an autocomplete tool. It understands your full project context by directly reading files, running commands, and navigating codebases within your terminal. This allows it to autonomously execute multi-step tasks such as large-scale refactoring, writing comprehensive tests, and debugging complex issues.

Compared to alternatives like Cursor, Copilot, Cline, or Windsurf, Claude Code's ecosystem offers stronger capabilities for our workflows:
- **Skills system:** Reusable, project-specific task templates to standardize workflows.
- **CLAUDE.md project memory:** Native, persistent memory for project guidelines and architectural decisions.
- **MCP integrations:** First-class support for Model Context Protocol to seamlessly integrate with Jira, Confluence, Slack, and browsers.
- **Subagents and parallel execution:** Ability to delegate and run sub-tasks concurrently for faster completion.
- **Hooks:** Pre- and post-tool execution hooks to enforce linting, testing, and formatting standards dynamically.

**TipTip's Plan:** We are currently setting up Claude Code using GLM models via Z.ai to reduce cost during the onboarding phase. We plan to eventually migrate to an official Claude Code subscription (Pro/Max/Team) once the team is proficient and the ROI is demonstrated. The current GLM setup gives us full access to Claude Code's powerful tooling ecosystem right now at a minimal cost.

---

## 2. Prerequisites

Before starting the setup, ensure you have the following ready:
- **Node.js v18+**: Required to run Claude Code. [Download and install Node.js here](https://nodejs.org/en/download/).
- **Z.ai Account & API Key**: Required for our GLM configuration. Ask Panji Gautama for the API key.
- **Git**: Assumed to be already installed and configured on your machine.

*Note: You do NOT need an Anthropic account for this setup.*

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

## 4. Configuration — Z.ai DevPack (Manual Setup)

We will configure Claude Code to route requests to Z.ai's GLM models instead of Anthropic's servers.

### macOS / Linux

Add the following export commands to your shell profile (e.g., `~/.zshrc` or `~/.bashrc`):

```bash
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_API_KEY="your_zai_api_key_here"
export ANTHROPIC_MODEL="glm-4.7"
export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7-flash"
```

After saving the file, apply the changes:
```bash
source ~/.zshrc # or source ~/.bashrc
```

### Windows (PowerShell)

For current session testing, you can use the `$env:` syntax. For persistence across sessions, use `[System.Environment]::SetEnvironmentVariable`. Run the following in PowerShell:

```powershell
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "https://api.z.ai/api/anthropic", "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "your_zai_api_key_here", "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_MODEL", "glm-4.7", "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", "glm-4.7-flash", "User")
```

Restart your PowerShell terminal to ensure the variables are loaded.

Once your environment variables are set, simply run Claude Code in your project directory:
```bash
claude
```

---

## 5. Verify the Setup

To confirm that Claude Code is correctly routing to Z.ai, launch the tool and check its status.

Run the tool:
```bash
claude
```

Then, inside the Claude Code prompt, type:
```
/status
```

**Expected output:** The environment variables section should show the Base URL pointing to `https://api.z.ai/api/anthropic` (Z.ai), rather than the default Anthropic endpoint.
*Optional:* You can also ask Claude Code directly, *"what model are you using?"* to confirm it is successfully routing to the GLM model you configured.

---

## 6. Shifting from OpenRouter to GLM Subscription

Previously, TipTip utilized OpenRouter to access a wide variety of models. We have now transitioned to a direct GLM subscription through Z.ai for our Claude Code workflows.

**Why is the GLM Subscription better?**
1. **Lower Latency & Higher Reliability:** By connecting directly to the Z.ai API rather than routing through an aggregator, we eliminate middleman latency and drastically reduce the risk of third-party rate limiting or outages.
2. **Data Privacy & Security:** Bypassing third-party aggregators ensures that TipTip's proprietary codebase does not pass through extra servers or translation layers. This fulfills our enterprise data residency and confidentiality requirements.
3. **Agentic Stability:** Claude Code heavily relies on precise tool-calling and strict JSON output. Direct API connections prevent unpredictable syntax regressions or dropped parameters sometimes caused by formatting translation layers in aggregator APIs.
4. **Cost Efficiency:** A direct subscription provides better cost predictability and economies of scale for our specific workloads compared to OpenRouter's proxy pricing.

---

## 7. Suggested Models

These are the models available via Z.ai that can be used with Claude Code. Depending on the task complexity, you can adjust your configured model.

| Model                 | OpenRouter ID         | Input ($/1M tokens) | Output ($/1M tokens) | Context Window | Tier       | Tool Use support | Best Use Case                                         | Notes                                                 |
| :-------------------- | :-------------------- | :------------------ | :------------------- | :------------- | :--------- | :--------------- | :---------------------------------------------------- | :---------------------------------------------------- |
| Claude 3.5 Sonnet     | anthropic/claude-3.5-sonnet | $3.00               | $15.00               | 200K           | Flagship   | Yes              | Complex architecture, deep debugging, massive refactors | Top-tier intelligence for difficult agentic tasks     |
| Claude 3.5 Haiku      | anthropic/claude-3.5-haiku | $0.80               | $4.00                | 200K           | Small-Fast | Yes              | High-speed iterations, simple scripts, log analysis   | Extremely fast and capable for its size               |
| GLM-5                 | glm-5                 | $0.72               | $2.30                | 203K           | Flagship   | Yes              | Heavy agentic workflows, large context tasks          | Next-generation flagship                              |
| GLM-4.7               | glm-4.7               | $0.38               | $1.98                | 203K           | Mid-range  | Yes              | Standard daily development, comprehensive code generation | Excellent for complex tasks, strong coding capability |
| GLM-4.6               | glm-4.6               | $0.39               | $1.90                | 205K           | Mid-range  | Yes              | Tasks requiring structured outputs                    | Expanded context, structured function calling         |
| GLM-4.5               | glm-4.5               | $0.60               | $1.80                | 128K           | Mid-range  | Yes              | Legacy code exploration, general reasoning            | Unifies reasoning and coding abilities                |
| GLM-4.5 Air           | glm-4.5-air           | $0.13               | $0.85                | 131K           | Small-Fast | Yes              | Fast, lightweight queries and reviews                 | Fast response time for general queries                |
| GLM-4.7 Flash         | glm-4.7-flash         | $0.06               | $0.40                | 203K           | Small-Fast | Yes              | Background agents, mass file reading, linting         | Highly cost-effective                                 |
| GLM-4.5 Air (free)    | glm-4.5-air-free      | $0.00               | $0.00                | 131K           | Free       | Yes              | Experimentation, onboarding without budget            | Rate-limited free tier option                         |
| DeepSeek V3.2         | deepseek-v3.2         | $0.26               | $0.38                | 164K           | Mid-range  | Yes              | Cost-sensitive high-quality agent runs                | Low output cost, Chinese server residency             |
| DeepSeek V3 0324      | deepseek-v3-0324      | $0.20               | $0.77                | 164K           | Mid-range  | Yes              | Legacy compatibility, reliable general coding         | Previous V3 version                                   |
| Gemini 2.5 Flash      | gemini-2.5-flash      | $0.30               | $2.50                | 1M             | Mid-range  | Yes              | Extremely large codebase analysis, immense context fetching | Massive context window                                |
| Gemini 2.5 Flash Lite | gemini-2.5-flash-lite | $0.10               | $0.40                | 1M             | Small-Fast | Yes              | Fast context scanning over medium-large repositories    | Fast, 1M context at low cost                          |

---

## 8. Recommended IDE

Claude Code operates primarily as a Command Line Interface (CLI) and can run in any terminal. However, the choice of IDE heavily impacts your workflow because of dedicated extensions that provide a Graphical User Interface (GUI) over the CLI.

| IDE | Compatibility | Plugin/Extension | Best Use Case | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Visual Studio Code** | Excellent | Yes (Official Anthropic Extension) | **Recommended** for the best Claude Code GUI experience | Provides a native graphical interface for Claude Code, including inline graphical diffs, plan reviews, `@-mentions`, and conversation history. |
| **GoLand** (JetBrains) | Very Good | Yes (JetBrains Plugin) | Native Go development with Claude | Integrates the CLI into the IDE terminal and provides shortcuts for interactive diff viewing and real-time diagnostic sharing. |
| **Antigravity** | Excellent | Works via terminal (VS Code fork) | Advanced native multi-agent orchestration | Google's agent-first IDE. While it supports Claude Code perfectly via its terminal (being a VS Code fork), Antigravity is designed around its own native agent orchestrations. |
| **KiloCode** | Good | Works via terminal / Custom Agents | Highly customizable, multi-model workflows | Open-source platform that excels in extreme customization (models, modes, permissions). TipTip previously explored this. |
| **Cursor** | Good | Works via terminal | Interactive pair-programming | Very popular AI IDE. While its Agent Mode is strong, it is fundamentally an interactive Editor interface rather than a CLI-first autonomous agent. |

### Why Visual Studio Code?
We highly recommend using **Visual Studio Code** when working with Claude Code. Anthropic has released an official VS Code extension that transforms the terminal-based CLI tool into a rich graphical experience. The native UI for viewing inline code diffs, reviewing plans before execution, and managing conversation history makes it vastly superior and more intuitive than using a standalone terminal or other IDEs.

### Why not KiloCode or Cursor natively? (The shift to pure Claude Code)

Previously, TipTip leaned toward **KiloCode** because of its incredible flexibility: it allows for deep customization of agents, permissions, modes, and supports 500+ models. It is a fantastic open-source ecosystem. 

However, we are moving towards using **Claude Code directly** (via VS Code or CLI) for the following reasons:
1. **Agent-First Autonomy:** Tools like Cursor are built as "Assistants" embedded in an editor. Claude Code is built from the ground up to be an autonomous orchestrator. You give it a high-level `task.md`, and it will map the codebase, edit multiple files, run terminal commands, debug, and self-correct with minimal hand-holding.
2. **First-class CLAUDE.md integration:** Claude Code relies natively on a hierarchical `CLAUDE.md` memory system to maintain architectural context and rules across sessions, making team alignment much easier.
3. **Seamless Git & Tooling integration:** Claude Code natively handles creating branches, committing code, and opening pull requests as part of its autonomous loop, turning it into a true junior developer rather than just a smart autocomplete engine. 
4. **Standardization:** By standardizing on the official Claude Code CLI/Extension powered by GLM models, we guarantee a uniform, highly capable agentic experience for all engineers, rather than maintaining complex custom agency configurations in KiloCode.

---

## 9. Model Recommendation

For optimal performance in Claude Code workflows, we recommend setting **GLM-4.7** as your standard `ANTHROPIC_MODEL` and **GLM-4.7 Flash** as your `ANTHROPIC_SMALL_FAST_MODEL`.

**Why GLM-4.7 and GLM-4.7 Flash?**
1. **Agentic Workflow Tuning:** GLM-4.7 is explicitly tuned to support comprehensive "task completion" and "interleaved thinking" modes ideal for agentic tools like Claude Code, Cline, and Roo Code.
2. **Idiomatic Go Code Generation:** Based on technical benchmarks, GLM-4.7 excels at generating idiomatic Go code. It successfully implements proper Go error handling patterns, well-structured interface design, and correct goroutine usage, which are highly relevant and essential for TipTip's backend microservices.
3. **TypeScript Type Inference:** GLM-4.7 provides robust multilingual coding support with a strong grasp of TypeScript types and generics, heavily benefiting our React/Next.js stacks.
4. **Frontend Code Quality:** It incorporates "Vibe Coding" capabilities, outputting cleaner, highly polished, and modern React frontend interfaces that resemble high-quality, human-designed output.
5. **Context Window:** The 203K token context easily handles searching and analyzing TipTip's large proprietary codebase.
6. **Cost-Effectiveness:** GLM-4.7 Flash, priced at just $0.06 per 1M input tokens, is exceptionally cheap for background tasks and minor file searches, making it the most cost-effective tool-capable small model currently available.

*Note regarding DeepSeek:* While DeepSeek V3.2 is cheaper on output tokens, its privacy policies mandate that data is stored natively on servers in mainland China, raising data residency and sovereignty concerns. For TipTip's proprietary codebase, GLM is preferred because Z.ai offers region-aware routing and distinct international endpoints, alongside stronger commitments tailored for enterprise data security and compliance.

**Final Configuration Block:**

For **macOS / Linux**:
```bash
export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
export ANTHROPIC_API_KEY="your_zai_api_key_here"
export ANTHROPIC_MODEL="glm-4.7"
export ANTHROPIC_SMALL_FAST_MODEL="glm-4.7-flash"
```

For **Windows (PowerShell)**:
```powershell
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_BASE_URL", "https://api.z.ai/api/anthropic", "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_API_KEY", "your_zai_api_key_here", "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_MODEL", "glm-4.7", "User")
[System.Environment]::SetEnvironmentVariable("ANTHROPIC_SMALL_FAST_MODEL", "glm-4.7-flash", "User")
```
