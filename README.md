# claude-plugins

A [Claude Code](https://claude.com/claude-code) plugin marketplace for delegating work from Claude Code to other coding agents.

## Installation

```
/plugin marketplace add yangtau/claude-plugins
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

## Layout

```
.claude-plugin/marketplace.json   # marketplace manifest
plugins/<name>/                   # one directory per plugin
```
