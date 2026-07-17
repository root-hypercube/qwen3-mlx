#!/bin/sh
# One-time setup for opencode + local MLX model on this machine.
# Run from anywhere: sh tools/setup-opencode.sh
set -e

TOOLS_DIR=$(cd "$(dirname "$0")" && pwd)
REPO_DIR=$(dirname "$TOOLS_DIR")
MODEL_ID=$(basename "$REPO_DIR")

echo "==> Verifying opencode zip checksum..."
cd "$TOOLS_DIR"
shasum -a 256 -c opencode-darwin-arm64.zip.sha256

echo "==> Installing opencode binary to ~/.local/bin..."
mkdir -p "$HOME/.local/bin"
unzip -o -q opencode-darwin-arm64.zip -d "$HOME/.local/bin"
chmod +x "$HOME/.local/bin/opencode"
"$HOME/.local/bin/opencode" --version

echo "==> Seeding models.dev cache (needed for offline startup)..."
mkdir -p "$HOME/.cache/opencode"
cp models.json "$HOME/.cache/opencode/models.json"

echo "==> Writing opencode config..."
mkdir -p "$HOME/.config/opencode"
if [ -f "$HOME/.config/opencode/opencode.json" ]; then
  echo "    ~/.config/opencode/opencode.json already exists — NOT overwriting."
  echo "    Compare it manually against tools/opencode.json.example if needed."
else
  cat > "$HOME/.config/opencode/opencode.json" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "autoupdate": false,
  "share": "disabled",
  "provider": {
    "mlx": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local MLX (Qwen3)",
      "options": {
        "baseURL": "http://127.0.0.1:8080/v1",
        "apiKey": "local"
      },
      "models": {
        "$MODEL_ID": {
          "name": "Qwen3 1.7B (local MLX)",
          "limit": { "context": 32768, "output": 4096 },
          "tool_call": true
        }
      }
    }
  },
  "model": "mlx/$MODEL_ID"
}
EOF
  echo "    Wrote ~/.config/opencode/opencode.json (model id: $MODEL_ID)"
fi

echo ""
echo "Setup complete. To work with the agent:"
echo "  sh $TOOLS_DIR/run-agent.sh          # TUI in current directory"
echo "  sh $TOOLS_DIR/run-agent.sh run 'your prompt'   # one-shot"
echo ""
echo "(run-agent.sh auto-starts mlx_lm.server if it is not already running;"
echo " make sure your conda env with mlx-lm is activated first.)"
