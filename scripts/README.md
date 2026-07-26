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

### Embedded documentation

Documentation for executable files can live alongside the implementation. Place
Markdown inside a comment block delimited by `md` and `/md`:

````bash
# md
# ## Example command
#
# Documentation written in Markdown.
# /md
````

The repository's documentation website extracts these blocks, removes the
source-language comment prefix, and publishes them as Markdown. The generated
filename is the source file's basename with its extension replaced by `.md`:

- `install.sh` → `install.md`
- `example.py` → `example.md`
- `ci-bot` → `ci-bot.md`

Treat the embedded block as the source of truth and keep it synchronized with
the implementation. Do not manually add or edit the generated Markdown file in
this repository.

Markdown files may link to these generated pages even when the corresponding
`.md` files do not exist in the repository checkout. Check whether a missing
link target is produced from an embedded documentation block before treating
the link as broken.

## CI Bot

`bin/ci-bot` is a Python + argparse CLI for managing CI template setup and token refreshes.

- Registry file: `~/.config/ci_bot/repos.json`
- Default token file: `~/.config/tokens/ci_bot.token`
- Main commands:
  - `ci-bot setup`
  - `ci-bot update`
  - `ci-bot token add`
  - `ci-bot token list`
  - `ci-bot token show`
  - `ci-bot token refresh`
  - `ci-bot repo list|add|remove|rename|token`
  - `ci-bot org token`

To update a registered repository after it moves to another owner, preserve its
local settings with:

```bash
ci-bot repo rename old-owner/repo new-owner/repo
ci-bot repo token --repo new-owner/repo --token-name ci_bot
```

`repo rename` updates the local registry only; it does not transfer the GitHub
repository or change its Actions secret.

## Git Account Switching

`git-use` rewrites the current repository's `origin` remote to use a GitHub SSH
host alias. It can also set the repository-local `user.email`.

Example:

```bash
git-use athackst
git-use althack
git-use athackst 12345678+athackst@users.noreply.github.com
```
