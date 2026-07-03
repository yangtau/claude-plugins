# cursor-agent — delegation notes

Golden command:

```sh
cursor-agent -p --trust --output-format json "<self-contained prompt>"
```

- Output is a single JSON object: `.result` is the answer, `.session_id` is the resume handle.
- Resume: `cursor-agent -p --trust --resume <session_id> --output-format json "<next prompt>"`.
- Model: `--model <model>` (`--list-models` to see options).
- Read-only: `--mode plan` or `--mode ask` — but these hard-block ALL shell execution for the session's lifetime (resume can't lift it). For review-and-run tasks, stay in default mode and instruct "do not modify files" instead. Parallel-safe isolation: `-w` (native git worktree).
- `-p` already allows write and shell; add `-f/--force` only if a command gets blocked, `--yolo` only on explicit user request.

Pitfalls:

- Headless runs refuse to start without `--trust`.
- Background runs (watchdog wrapper) need `--output-format stream-json` — plain `json` prints nothing until the end, so there is no liveness signal. `.session_id` still appears in the stream's events.
- Working dir is the cwd (or `--workspace <path>`) — cd to the target repo before invoking.

Everything else: `cursor-agent -h`.
