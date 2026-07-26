# Global Agent Preferences

- Do not create Git commits unless the user explicitly requests a commit. Keep
  requested changes in the working tree until then.
- When a repository contains a `.devcontainer` directory, prefer running build, test, lint, and other project commands with `devcontainer exec` before falling back to host execution.

## Embedded documentation

- Source files may contain Markdown documentation inside comment blocks marked
  with `md` and `/md`, commonly `# md` and `# /md`.
- These blocks are extracted for the repository's documentation website. The
  generated page is named after the source file's basename, with any extension
  replaced by `.md` (`install.sh` produces `install.md`; `ci-bot` produces
  `ci-bot.md`).
- Keep embedded documentation close to and consistent with the implementation.
  When changing documented behavior, update the embedded block in the same
  change.
- Treat the source block as canonical. Do not create or edit the generated
  Markdown page unless a repository explicitly stores generated output.
- A Markdown link is not necessarily broken merely because its `.md` target is
  absent from the repository. Before changing or removing such a link, check
  whether the target is generated from an embedded documentation block.
