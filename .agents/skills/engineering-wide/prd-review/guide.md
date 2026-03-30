# PRD Review & Create Skill — Installation & Usage Guide

## Overview

The **prd-review** skill turns your AI coding assistant into a **Seasoned Product Manager** that reviews and creates Product Requirement Documents (PRDs) from three specialist perspectives:

| Persona | Focus Area |
| --- | --- |
| 🎯 **Product Manager** | Problem framing, business goals, scoping, acceptance criteria, estimation |
| 🎨 **UI/UX Designer** | User flows, interaction design, visual states, responsive behavior, accessibility |
| 🔍 **SEO Specialist** | Crawlability, structured data, Core Web Vitals, meta tags, i18n |

---

## Directory Structure

```
.agents/skills/prd-review/
├── SKILL.md                          # Main orchestrator (entry point)
├── guide.md                          # This guide
├── agents/
│   ├── product-manager.md            # PM persona sub-agent
│   ├── uiux-designer.md              # UX persona sub-agent
│   └── seo-specialist.md             # SEO persona sub-agent
└── templates/
    └── prd-template.md               # TipTip PRD template (Confluence format)
```

---

## Prerequisites

- **Atlassian MCP Server** — Required for fetching PRDs directly from Confluence. Ensure the `atlassian-mcp-server` is configured with access to your Confluence workspace.
- **AI Coding Assistant** — The skill is designed for AI coding assistants that support the skill/agent pattern (Claude Code, Antigravity, etc.).

---

## Installation

1. Copy the `.agents/skills/prd-review/` directory into your project's `.agents/skills/` folder.
2. Ensure your AI assistant is configured to read skill files from the `.agents/skills/` directory.
3. Verify the Atlassian MCP server is connected (for Confluence URL support).

No additional dependencies or packages are required.

---

## Commands

### 1. `review` — Review an Existing PRD

Analyzes a PRD from all three personas and produces a unified review report with critical issues, recommendations, and open questions.

**Input Options:**
- **Confluence URL**: Provide a direct link to the PRD page.
- **Pasted Markdown**: Paste the PRD content directly.

**Example Prompts:**

```
Review this PRD: https://tiptiptv.atlassian.net/wiki/spaces/SATU/pages/1389199373/PRD+Select+Package+by+Options
```

```
Review the following PRD:

## Problem
Users have difficulty comparing packages on the product detail page...

## Requirements
| No. | Feature | Actor | Requirement | Note |
| ... | ... | ... | ... | ... |
```

**Output:** A consolidated review report with:
- Executive summary with per-persona verdicts
- Individual reviews from PM, UX, and SEO perspectives
- De-duplicated action items (Must Fix / Should Fix)
- Open questions for stakeholders

---

### 2. `create` — Create a New PRD

Generates a complete PRD from a bullet list of requirements and objectives. The PM drafts the structure, UX enriches interaction specs, and SEO adds discoverability requirements.

**Input:** A bullet list containing your objectives and requirements.

**Example Prompt:**

```
Create a PRD from these requirements:

Objective: Improve checkout conversion for SatuSatu mobile users

Requirements:
- Add a progress indicator showing checkout steps (cart → details → payment → confirmation)
- Implement guest checkout option without requiring account creation
- Add a "Save for Later" button on the cart page
- Show estimated delivery date before payment
- Support GoPay and OVO as payment methods
- Add order summary sidebar on desktop

Constraints:
- Must work on both SatuSatu Web App (SWA) and Mobile App (SMA)
- Guest checkout must still collect email for order confirmation
- Payment gateway integration via Midtrans
```

**Output:** A complete PRD following TipTip's template, including:
- Problem statement with `[DATA NEEDED]` placeholders
- Business goals and success metrics
- Prioritized requirements table with user stories and acceptance criteria
- UX state specifications and `[FIGMA NEEDED]` callouts
- SEO requirements (structured data, meta tags, CWV criteria)
- Appendix listing all placeholders to resolve

---

## How the Sub-Agents Work Together

```
┌─────────────────────────────────────────────────────────┐
│                    SKILL.md (Orchestrator)               │
│                                                         │
│  User Input ──► Command Router ──► review │ create      │
│                                                         │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │  🎯 PM      │  │  🎨 UX       │  │  🔍 SEO       │  │
│  │  Agent      │  │  Agent       │  │  Agent        │  │
│  │             │  │              │  │               │  │
│  │ • Structure │  │ • States     │  │ • Schema.org  │  │
│  │ • Goals     │  │ • Flows      │  │ • Meta tags   │  │
│  │ • Criteria  │  │ • A11y       │  │ • CWV impact  │  │
│  └──────┬──────┘  └──────┬───────┘  └───────┬───────┘  │
│         │                │                   │          │
│         └────────────────┼───────────────────┘          │
│                          ▼                              │
│               Consolidated Output                       │
└─────────────────────────────────────────────────────────┘
```

**Review flow**: All three agents analyze the PRD independently → results are merged into one report.

**Create flow**: PM drafts → UX enriches → SEO enriches → final document assembled.

---

## Customization

### Adding a New Persona

1. Create a new file in `agents/` (e.g., `agents/data-analyst.md`).
2. Follow the existing format: YAML frontmatter + Identity + Review mode + Create mode.
3. Update `SKILL.md` to include the new agent in both the `review` and `create` pipelines.

### Modifying the PRD Template

Edit `templates/prd-template.md` to match your team's evolving conventions. All agents reference this template during `create` mode.

---

## Tips

- **Be specific in your bullet list**: The more detail you provide in `create` mode, the better the output. Include target users, platforms, known constraints, and any metrics you have.
- **Use Confluence URLs when possible**: The skill fetches the latest version directly, avoiding stale copy-paste.
- **Iterate**: Run `create` to draft, then `review` to self-check. Fix the gaps and repeat.

> **Recommended Setting**: Run in Antigravity **Planning** mode using **Gemini 3 Pro** for best results.
