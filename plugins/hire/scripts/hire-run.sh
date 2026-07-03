#!/bin/bash
# hire-run.sh — run an external coding CLI under a hang watchdog.
#
# Usage:  hire-run.sh <logfile> <cli> [args...]
# Env:    HIRE_STALL_SECS  kill if log is silent AND process group burns no CPU (default 600)
#         HIRE_MAX_SECS    hard wall-clock cap (default 2700)
#         HIRE_CHECK_SECS  watchdog poll interval (default 30)
#
# Child stdout -> <logfile>, stderr -> <logfile>.err, stdin -> /dev/null.
# Always appends a final status line to the log and prints it to stdout:
#   HIRE:EXIT:<code> | HIRE:STALLED | HIRE:TIMEOUT
# Exit code: child's, or 124 (timeout) / 125 (stalled).

set -um
LOG=$1; shift
STALL=${HIRE_STALL_SECS:-600}
MAX=${HIRE_MAX_SECS:-2700}
CHECK=${HIRE_CHECK_SECS:-30}

: > "$LOG"
"$@" < /dev/null > "$LOG" 2> "$LOG.err" &
pid=$!
start=$(date +%s)

mtime() { stat -f %m "$LOG" 2>/dev/null || stat -c %Y "$LOG"; }

group_cpu() {
  local pids
  pids=$(pgrep -g "$pid" 2>/dev/null | tr '\n' ',' | sed 's/,$//')
  [ -z "$pids" ] && { echo 0; return; }
  ps -o cputime= -p "$pids" 2>/dev/null |
    awk '{ n=split($1,a,":"); s=a[n]+60*a[n-1]; if (n>2) s+=3600*a[n-2]; tot+=s } END { printf "%d\n", tot+0 }'
}

finish() { # <marker> <exit-code>
  echo "$1" >> "$LOG"
  echo "$1 (log: $LOG)"
  exit "$2"
}

last_cpu=-1
idle_checks=0
while kill -0 "$pid" 2>/dev/null; do
  sleep "$CHECK"
  now=$(date +%s)
  if [ $((now - start)) -ge "$MAX" ]; then
    kill -- -"$pid" 2>/dev/null; wait "$pid" 2>/dev/null
    finish "HIRE:TIMEOUT after ${MAX}s" 124
  fi
  if [ $((now - $(mtime))) -ge "$STALL" ]; then
    cpu=$(group_cpu)
    if [ "$last_cpu" -ge 0 ] && [ "$cpu" -le "$last_cpu" ]; then
      idle_checks=$((idle_checks + 1))
    else
      idle_checks=0
    fi
    last_cpu=$cpu
    if [ "$idle_checks" -ge 2 ]; then
      kill -- -"$pid" 2>/dev/null; wait "$pid" 2>/dev/null
      finish "HIRE:STALLED silent ${STALL}s with no CPU activity" 125
    fi
  else
    last_cpu=-1; idle_checks=0
  fi
done

wait "$pid"; code=$?
finish "HIRE:EXIT:$code" "$code"
