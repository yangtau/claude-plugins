# hire

Delegate coding tasks from Claude Code to external coding agent CLIs — currently codex and cursor-agent — through one protocol: self-contained prompts, permission tiers, session resume, result verification.

Why: spend another subscription's tokens instead of Claude's, and get verification from genuinely independent models.

## Entry points

| Entry | What it is | Form |
| --- | --- | --- |
| `hire` skill | the delegation procedure itself — whoever loads it runs the CLI; long runs go through the watchdog wrapper in a background shell | `/hire codex fix the race in foo.py`, or Claude activates it autonomously |
| `hire:contractor` agent | a thin pipe that forwards a pre-packed prompt, for the one place a subagent is structurally required (Workflow stages) | `agent(task, {agentType: 'hire:contractor', schema})` / `Agent(subagent_type: 'hire:contractor')` |

Multi-turn: every delegation reports a session id; the caller judges continuity and resumes automatically — the user never types "resume".

## Layout

- `SKILL.md` — the delegation procedure (resume judgment, prompt packing, execution protocol, permission tiers, verification); doubles as the `/hire` entry
- `agents/contractor.md` — thin pipe for Workflow stages; forwards a pre-packed prompt, never composes one; the target CLI is part of its input
- `scripts/hire-run.sh` — watchdog wrapper for background runs: logs to a file, kills on silence-with-no-CPU or wall-clock cap, always appends a final `HIRE:EXIT/STALLED/TIMEOUT` status line
- `references/codex.md`, `references/cursor-agent.md` — per-CLI notes: one golden command, resume, pitfalls. Anything discoverable via `-h` stays out by design.

## Adding a CLI

Add `references/<name>.md` with the golden command, the resume mechanism, and the pitfalls `-h` won't tell you. Keep it under ~20 lines.
