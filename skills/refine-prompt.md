---
name: refine-prompt
description: Refines an initial prompt applying Anthropic's official Claude prompting best practices, outputs a ready-to-copy refined prompt, and explains the improvements.
---

## Instructions

Your task is to review the user's initial prompt and refine it based on Anthropic's official Claude prompting best practices found at: https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices.

Please apply techniques such as:
- Using XML tags to structure the prompt
- Providing examples where appropriate
- Assigning Claude a role
- Breaking down complex requests into clear steps
- Removing unnecessary verbosity while keeping necessary context

Your output MUST contain exactly two sections formatted exactly as follows:

### The Refined Prompt

```text
[Provide the fully refined, ready-to-copy prompt here, replacing this placeholder. Ensure it is wrapped in exactly one markdown code block.]
```

### Why this is better

[Provide a brief, educational explanation detailing the specific best practices applied (e.g., "Added XML tags for structure", "Provided examples", "Gave Claude a role") and explain why those changes make the prompt more effective for Claude.]
