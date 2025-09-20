# Overview

This folder contains scripts and installable programs that I find useful.

## Layout

```bash
├─ bin/ # installed into ~/.local/bin by install.sh
└─ utils/ # not installed; run from repo only
```

## Authoring conventions

All scripts should follow these basics:

- Shebang and strict mode:

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail
    ```

- Be executable: `chmod +x scripts/bin/<name>`
- Provide `-h|--help` usage.
- Avoid reading from TTY unless necessary
- Keep `bin/` flat (no subdirectories)
