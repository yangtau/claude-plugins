# claude-agents-plugins

A [Claude Code](https://claude.com/claude-code) plugin marketplace for delegating work from Claude Code to other coding agents.

## Installation

```
/plugin marketplace add yangtau/claude-agents-plugins
/plugin install hire@claude-agents-plugins
```

## Plugins

| Plugin | Description |
| --- | --- |
| [hire](plugins/hire) | Delegate coding tasks to external coding agent CLIs (codex, cursor-agent) through one protocol: self-contained prompts, permission tiers, session resume, result verification. |

### hire

Spend another subscription's tokens instead of Claude's, and get verification from genuinely independent models:

```
/hire codex fix the race in foo.py
/hire cursor add unit tests for src/parser.ts
```

Requires the target CLI ([codex](https://github.com/openai/codex) or [cursor-agent](https://cursor.com/cli)) to be installed and logged in. See the [plugin README](plugins/hire/README.md) for details.

#### Pairing with CLAUDE.md

The skill is the delegation *procedure*; the *routing policy* — when to delegate at all, and which model for which kind of work — must be evaluated before the skill triggers, so it belongs in your always-loaded `CLAUDE.md`, not in the plugin. A starting point to adapt:

```markdown
# Orchestration

- Delegate to /hire: clear-spec implementation, bulk mechanical edits,
  independent review, parallelizable work.
- Keep on the main agent: emerging specs, tight iteration with the user,
  quality-critical work.
- Context travels via files: write spec, constraints, and session ids into
  a file and pass the path.
- Session reuse: one executor session per workstream; independent reviews
  always get a fresh session.

Task → model (adjust to your own subscriptions and their costs):
- bulk/mechanical work → codex
- fast turnaround over depth → cursor-agent
- plan/implementation reviews → either, as an independent perspective
```

## Layout

```
.claude-plugin/marketplace.json   # marketplace manifest
plugins/<name>/                   # one directory per plugin
```
