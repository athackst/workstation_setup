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

`bin/ci-bot` is a Python + argparse CLI for managing CI template setup and token refreshes.

- Registry file: `~/.config/ci_bot/repos.json`
- Default token file: `~/.config/tokens/ci_bot.token`
- Main commands:
  - `ci-bot setup`
  - `ci-bot update`
  - `ci-bot token add`
  - `ci-bot token list`
  - `ci-bot token refresh`
  - `ci-bot repo list|add|remove|token`

## Git Account Switching

`git-use` rewrites a repo remote to use one of your GitHub SSH host aliases during account migration.

Example:

```bash
git-use athackst
git-use althack
```
