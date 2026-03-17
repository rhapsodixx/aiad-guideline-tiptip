# AI Assisted Development at TipTip

Welcome to the TipTip AI Assisted Development repository. The purpose of this repository is to provide guidance, resources, and standardized practices for leveraging AI tools effectively and securely within our engineering workflows.

## Installation & Automation

To standardize tip-to-tail setup across TipTip, this repository provides automated shell scripts in the root directory. **These scripts must be executed from the root of the cloned `aiad-claude` repository.**

- **`install-claude-templates.sh`**: Installs global `CLAUDE.md` context files for your specific engineering stack (Backend, Frontend, Mobile). See the [Project Memory Guide](guides/claude_code_project_memory_guide.md) for details.
- **`install-hooks.sh`**: Installs essential safety/quality hook gates (like SQL protection and ESLint enforcement) globally and per-project. See the [Hooks Guide](guides/claude_code_hooks_guide.md) for details.

To run either script, simply execute:
```bash
./install-claude-templates.sh
# or
./install-hooks.sh
```

## Guides

The `guides/` directory contains comprehensive documentation covering various aspects of AI Assisted Development. These guides provide high-level overviews and in-depth information on setup, integrations, project configurations, and best practices to ensure teams can adopt and benefit from AI assistance consistently.

- [**Guide 1 of 7: Setup**](guides/claude_code_setup_guide.md): Outlines the initial installation and configuration required to run Claude Code locally using TipTip's GLM model routing and recommended IDEs.
- [**Guide 2 of 7: Project Memory**](guides/claude_code_project_memory_guide.md): Explains the structure and purpose of `CLAUDE.md` files for injecting persistent, repo-specific architecture patterns and engineering rules into every session.
- [**Guide 3 of 7: Skills**](guides/claude_code_skills_guide.md): Details how to install and invoke reusable, version-controlled prompt templates that standardize repetitive tasks like code reviews and PR descriptions.
- [**Guide 4 of 7: MCP Integrations**](guides/claude_code_mcp_guide.md): Documents how to connect Claude to live external tools and contexts, such as Jira, Confluence, database schemas, and codebase symbols via Serena.
- [**Guide 5 of 7: Hooks**](guides/claude_code_hooks_guide.md): Covers the setup of automated safety and quality gates (linters, formatters, SQL guards) that trigger transparently during Claude's tool execution lifecycle.
- [**Guide 6 of 7: Workflows & Autonomous Tasks**](guides/claude_code_workflows_guide.md): Provides practical blueprints and `task.md` templates for running complex, autonomous engineering operations from end to end.
- [**Guide 7 of 7: Team Usage & Best Practices**](guides/claude_code_team_usage_guide.md): Covers how to sustain, measure, and scale Claude Code adoption across TipTip's engineering team, including metrics and migration criteria.

## Skills

Skills are reusable, specialized prompts and instructions that extend the capabilities of our AI tools for specific development and operational tasks. They help standardize outcomes, improve code quality, and save engineers time on repetitive tasks.

For full details on the available skills, their purpose, and how to use them, please refer to the [Skills Guide](guides/claude_code_skills_guide.md).

## Tasks & Workflows

Tasks and workflows are structured, repeatable sequences of actions that combine multiple tools, commands, or processes to accomplish larger engineering objectives efficiently. They outline the standardized approaches for complex or multi-step operations.

For further, detailed information on the available tasks and workflows, please review the [Workflows Guide](guides/claude_code_workflows_guide.md).
