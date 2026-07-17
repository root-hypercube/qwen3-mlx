#!/bin/sh
# Generic reassembler for a split MLX model directory.
# Usage: sh assemble-model.sh <model-dir>
#   e.g. sh assemble-model.sh Qwen3-14B-MLX-4bit
#
# Each model dir contains a PARTS.manifest listing, one per line:
#   <sha256>  <original-filename>
# and the split pieces named <original-filename>.part-*.
# This concatenates the parts back into each original file and verifies its
# checksum. Safe to re-run (skips files already assembled + verified).
set -e

DIR="${1:?usage: sh assemble-model.sh <model-dir>}"
cd "$DIR"

if [ ! -f PARTS.manifest ]; then
  echo "No PARTS.manifest in $DIR" >&2; exit 1
fi

# shasum on macOS, sha256sum on Linux
if command -v shasum >/dev/null 2>&1; then SHA="shasum -a 256"; else SHA="sha256sum"; fi

while read -r sum name; do
  [ -z "$name" ] && continue
  if [ -f "$name" ] && echo "$sum  $name" | $SHA -c - >/dev/null 2>&1; then
    echo "ok (already assembled): $name"
    continue
  fi
  nparts=$(ls "$name".part-* 2>/dev/null | wc -l | tr -d ' ')
  [ "$nparts" -eq 0 ] && { echo "missing parts for $name" >&2; exit 1; }
  echo "assembling $name from $nparts parts..."
  cat "$name".part-* > "$name"
  echo "$sum  $name" | $SHA -c -
done < PARTS.manifest

echo "Done. Model ready in: $DIR"
echo "Load with:  mlx_lm.generate --model $DIR --prompt 'hello'"
