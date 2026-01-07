#!/usr/bin/env sh
set -e

WORKER_MB=${UNICORN_WORKER_MB:-300}
RESERVED_MB=${UNICORN_RESERVED_MB:-400}

# Detect cgroup version
if [ -f /sys/fs/cgroup/memory.max ]; then
  LIMIT_BYTES=$(cat /sys/fs/cgroup/memory.max)
elif [ -f /sys/fs/cgroup/memory/memory.limit_in_bytes ]; then
  LIMIT_BYTES=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)
else
  LIMIT_BYTES="max"
fi

# Set a default value if the memory is unlimited or not available
if [ "$LIMIT_BYTES" = "max" ] || [ "$LIMIT_BYTES" -gt 9000000000000000000 ]; then
  export UNICORN_WORKERS=${UNICORN_WORKERS:-2}
  return
fi

LIMIT_MB=$((LIMIT_BYTES / 1024 / 1024))
AVAILABLE_MB=$((LIMIT_MB - RESERVED_MB))

WORKERS=$((AVAILABLE_MB / WORKER_MB))
[ "$WORKERS" -lt 1 ] && WORKERS=1

export UNICORN_WORKERS=$WORKERS
