# Repository expectations for stacked PR work

- Prefer small stacked PRs over large mixed PRs.
- Keep one review commit per stack branch.
- Use `python3 scripts/status.py` after rewriting a stack.
- Use `gh stack sync` before opening or refreshing an existing stack.
- Run the narrowest meaningful tests for each PR branch.
- Never push stack branches with plain `--force`; use `--force-with-lease`.
