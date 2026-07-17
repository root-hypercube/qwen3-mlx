#!/bin/sh
# Reassemble model.safetensors from the split parts and verify its checksum.
# Run this once after cloning, from the repo root.
set -e

if [ -f model.safetensors ]; then
  echo "model.safetensors already exists; nothing to do."
  exit 0
fi

echo "Concatenating $(ls model.safetensors.part-* | wc -l | tr -d ' ') parts..."
cat model.safetensors.part-* > model.safetensors

echo "Verifying SHA-256 checksum..."
shasum -a 256 -c model.safetensors.sha256

echo "Done. You can now load the model with mlx-lm, e.g.:"
echo "  mlx_lm.generate --model . --prompt 'hello'"
