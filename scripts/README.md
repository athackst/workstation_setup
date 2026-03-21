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

## CI Bot

`bin/ci_bot` is a Python + Click CLI for managing CI template setup and token refreshes.

- Registry file: `~/.config/ci_bot/repos.json`
- Default token file: `~/.config/tokens/ci_bot.token`
- Main commands:
  - `ci_bot setup`
  - `ci_bot update`
  - `ci_bot token set`
  - `ci_bot token list`
  - `ci_bot token refresh`
  - `ci_bot repo list|add|remove`
