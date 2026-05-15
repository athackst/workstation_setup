# Repository expectations for stacked PR work

- Prefer small stacked PRs over large mixed PRs.
- Keep one review commit per stack branch.
- Use `python3 scripts/status.py` after rewriting a stack.
- Use `python3 scripts/evolve.py --base origin/main` before opening or refreshing a stack.
- Run the narrowest meaningful tests for each PR branch.
- Never push stack branches with plain `--force`; use `--force-with-lease`.
