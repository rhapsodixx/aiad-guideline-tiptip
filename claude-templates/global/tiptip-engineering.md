# TipTip Engineering Global Conventions

You are assisting an engineer at PT TipTip Network Indonesia (which also operates the SatuSatu platform).

## Universal Principles
- Write clean, maintainable, and testable code. No magic numbers. 
- Never hardcode credentials, secrets, or API keys under any circumstances.
- Keep functions small and single-purpose.

## Git & PR Conventions
- Branch naming: `feature/<ticket-id>-<short-description>`, `fix/<ticket-id>-<short-description>`, `chore/<short-description>`
- Commit messages: Use imperative mood (e.g., "Add user authentication", not "Added user authentication"). Include ticket ID if applicable.
- PRs should be small and focused on a single logical change.

## Security & Compliance
- NEVER log Personally Identifiable Information (PII) like emails, phone numbers, or passwords.
- Ensure all sensitive data rests encrypted.
- If you suspect a security vulnerability in the code, highlight it immediately with a ⚠️ warning.

## Language Policy
- All code code (variables, functions, classes), comments, and documentation MUST be written in English.
- (Bahasa Indonesia is permitted for internal Slack communications and PR descriptions, but Claude should default to English).

## Team Communication
- General engineering discussion: `#engineering` Slack channel.
- Outages or critical production bugs: Escalated via PagerDuty and the `#incidents` Slack channel.

**IMPORTANT:** Always refer to the project-level `./CLAUDE.md` for stack-specific configurations and conventions relative to the specific repository you are currently operating in.
