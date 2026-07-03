---
name: hire
description: Delegate coding tasks to external coding agent CLIs — codex or cursor-agent. Use when offloading implementation work to save Claude subscription quota, when work should be verified or reviewed by an independent agent, when continuing a previous codex/cursor session, or before wiring an external agent into a Workflow.
argument-hint: "<codex|cursor> <task>"
---

# Hiring external coding agents

Two reasons to delegate: spend another subscription instead of Claude's, and get verification from a genuinely independent agent.

This skill is the delegation procedure itself — whoever loads it runs the CLI. Invoked as `/hire`, the first token of the arguments is the target CLI, the rest is the task.

## Procedure

1. Read the CLI's notes: `references/codex.md` or `references/cursor-agent.md`.
2. Resume or fresh? If the request continues an earlier delegation whose session id you have (or names one), resume that session — the user never needs to say "resume"; judge it from conversation continuity.
3. Pack a self-contained prompt — the caller's job, done from conversation context. The external agent sees nothing of this conversation — include the goal, constraints, acceptance criteria, relevant file paths, and the working directory. (In the contractor agent the prompt arrives pre-packed; forward it as-is per that agent's contract.)
4. Run at the CLI's default permission tier — the golden command in its notes, launched per the execution protocol below. Escalating beyond the default tier needs an explicit user request.
5. Capture the session id and the final message.
6. If files changed: capture `git status` and `git diff --stat` for the report. How deeply to review beyond that is the caller's verification policy, not this skill's.
7. Report the outcome, always with the session id — follow-ups depend on it.

Which CLI and which model are the caller's call, not this skill's: pass the model explicitly or let each CLI's own config decide. User-level routing policy (which model for which kind of work) lives in CLAUDE.md.

## Execution protocol

- Tasks expected to finish within a few minutes: run the golden command in the foreground with an explicit timeout.
- Anything longer or uncertain: launch through the watchdog wrapper with `Bash run_in_background`:

  ```sh
  ${CLAUDE_PLUGIN_ROOT}/scripts/hire-run.sh <logfile> <golden command...>
  ```

  The harness re-invokes you when it exits — do NOT poll, and do NOT spawn a subagent to wait for it. Parallel delegations are parallel background shells.
- The wrapper redirects the CLI's stdout to `<logfile>` (stderr to `<logfile>.err`) and guarantees exit: it kills the run when the log is silent AND the process tree burns no CPU for `HIRE_STALL_SECS` (default 600), or at the `HIRE_MAX_SECS` wall-clock cap (default 2700) — raise the cap for legitimately long tasks.
- Background cursor runs must use `--output-format stream-json`; plain `json` emits nothing until the end, so the watchdog has no liveness signal.
- On wake, the last log line is the verdict: `HIRE:EXIT:<code>` → parse the final message as usual; `HIRE:STALLED` / `HIRE:TIMEOUT` → report failure WITH the session id from the log head — resume is usually possible.

## In workflows

The `hire:contractor` agent is a thin pipe around this skill, for the one place a subagent is structurally required: Workflow stages — `agent(task, {agentType: 'hire:contractor', schema})` — and equivalent `Agent(subagent_type: 'hire:contractor')` calls. For interactive delegation the main agent runs the CLI itself per the execution protocol; a babysitter subagent adds cost and an extra hop for nothing.
