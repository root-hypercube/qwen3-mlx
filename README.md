---
library_name: mlx
license: apache-2.0
license_link: https://huggingface.co/Qwen/Qwen3-1.7B/blob/main/LICENSE
pipeline_tag: text-generation
base_model: Qwen/Qwen3-1.7B
tags:
- mlx
---
# qwen3-mlx (GitHub mirror of lmstudio-community/Qwen3-1.7B-MLX-bf16)

GitHub-friendly repackaging of the model below. Because GitHub rejects files
over 100 MB, `model.safetensors` (3.4 GB) is stored as regular git blobs split
into 90 MB parts (`model.safetensors.part-*`). No git-LFS is used anywhere, so
a plain `git clone` over HTTPS is all you need.

## Restoring the weights after cloning

```bash
git clone https://github.com/root-hypercube/qwen3-mlx.git
cd qwen3-mlx
sh assemble.sh   # concatenates the parts and verifies the SHA-256 checksum
```

`assemble.sh` recreates `model.safetensors` and checks it against
`model.safetensors.sha256`. After that, load the model from this directory:

```bash
pip install mlx-lm
mlx_lm.generate --model . --prompt "hello"
```

The split parts can be deleted after assembly if you need the disk space back
(`rm model.safetensors.part-*`), at the cost of re-cloning if you ever need to
reassemble.

---

# Original model card: lmstudio-community/Qwen3-1.7B-MLX-bf16

This model [lmstudio-community/Qwen3-1.7B-MLX-bf16](https://huggingface.co/lmstudio-community/Qwen3-1.7B-MLX-bf16) was
converted to MLX format from [Qwen/Qwen3-1.7B](https://huggingface.co/Qwen/Qwen3-1.7B)
using mlx-lm version **0.24.0**.

## Use with mlx

```bash
pip install mlx-lm
```

```python
from mlx_lm import load, generate

model, tokenizer = load("lmstudio-community/Qwen3-1.7B-MLX-bf16")

prompt = "hello"

if tokenizer.chat_template is not None:
    messages = [{"role": "user", "content": prompt}]
    prompt = tokenizer.apply_chat_template(
        messages, add_generation_prompt=True
    )

response = generate(model, tokenizer, prompt=prompt, verbose=True)
```
