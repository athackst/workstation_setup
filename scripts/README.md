# Overview

This folder contains scripts and installable programs that I find useful.

## Layout

```bash
├─ bin/ # installed into ~/.local/bin by install.sh
└─ utils/ # not installed; run from repo only
```

## Authoring conventions

Shell scripts should follow these basics:

- Shebang and strict mode:

    ```bash
    #!/usr/bin/env bash
    set -euo pipefail
    ```

- Be executable: `chmod +x scripts/bin/<name>`
- Provide `-h|--help` usage.
- Avoid reading from TTY unless necessary
- Keep `bin/` flat (no subdirectories)

Python command-line scripts should use a shebang, expose `-h|--help` through
`argparse` or another CLI library when appropriate, and keep their usage text
in sync with the implementation.

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
- `example` → `example.md`

Treat the embedded block as the source of truth and keep it synchronized with
the implementation. Do not manually add or edit the generated Markdown file in
this repository.

Markdown files may link to these generated pages even when the corresponding
`.md` files do not exist in the repository checkout. Check whether a missing
link target is produced from an embedded documentation block before treating
the link as broken.

Individual commands document themselves in embedded Markdown beside their
implementation. Shell helpers and aliases are documented in
`dotfiles/README.md`.
