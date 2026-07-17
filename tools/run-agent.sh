#!/bin/sh
# Start the local MLX model server (if needed) and launch opencode.
# Usage:
#   sh tools/run-agent.sh                 -> opencode TUI in the current directory
#   sh tools/run-agent.sh run "prompt"    -> one-shot non-interactive run
set -e

TOOLS_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_DIR=$(dirname "$TOOLS_DIR")
PARENT_DIR=$(dirname "$REPO_DIR")
PORT=8080

if [ ! -f "$REPO_DIR/model.safetensors" ]; then
  echo "model.safetensors not found in $REPO_DIR — run 'sh assemble.sh' there first." >&2
  exit 1
fi

if ! curl -s -o /dev/null "http://127.0.0.1:$PORT/v1/models"; then
  command -v mlx_lm.server >/dev/null 2>&1 || {
    echo "mlx_lm.server not found in PATH. Activate your conda env with mlx-lm first." >&2
    exit 1
  }
  echo "Starting mlx_lm.server on port $PORT (log: ~/.mlx_server.log)..."
  # cwd must be the model repo's PARENT so the model id resolves as a relative path
  (cd "$PARENT_DIR" && nohup mlx_lm.server --host 127.0.0.1 --port "$PORT" > "$HOME/.mlx_server.log" 2>&1 &)
  i=0
  until curl -s -o /dev/null "http://127.0.0.1:$PORT/v1/models"; do
    i=$((i+1))
    [ "$i" -gt 60 ] && { echo "Server did not come up after 60s; see ~/.mlx_server.log" >&2; exit 1; }
    sleep 1
  done
  echo "Server ready."
fi

exec "$HOME/.local/bin/opencode" "$@"
