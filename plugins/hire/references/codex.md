# codex — delegation notes

Golden command:

```sh
codex exec -s workspace-write --json "<self-contained prompt>" < /dev/null
```

- `--json` emits JSONL: the first event `thread.started` carries the `thread_id` (the resume handle); the answer is the last `agent_message` item. Alternatives: `-o <file>` writes the final message to a file, `--output-schema <file>` enforces a JSON Schema on it.
- Resume: `codex exec resume <thread_id> "<next prompt>"` — `--json`/`-o`/`-m` still apply, but NOT `-C`/`-s`: cd to the original working dir first; the session remembers its sandbox tier.
- Model: `-m <model>`; default comes from `~/.codex/config.toml`.
- Read-only recon: `-s read-only`. `-s danger-full-access` only on explicit user request.
- Working dir: `-C <dir>`; extra writable dirs: `--add-dir <dir>`.

Pitfalls:

- With a non-tty stdin codex blocks waiting for input — always append `< /dev/null`. It still prints "Reading additional input from stdin..." to stderr; don't merge stderr into the JSONL you parse.
- Requires a git repo; outside one add `--skip-git-repo-check`.

Everything else: `codex -h`, `codex exec -h`.
