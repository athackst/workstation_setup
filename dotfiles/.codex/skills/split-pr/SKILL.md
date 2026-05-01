---
name: split-pr
description: Plan and manage dependency-ordered stacked PR branches from a branch delta against a base ref, then materialize, restack, or evolve one-review-commit-per-branch chains. Use when the user asks to split a large change into stacked PRs that are easy to review and coherent, restack descendants after editing a parent, or replay a stack onto the latest base with local validation per branch.
---

# Split PR

## Goal

Given committed work relative to `origin/main` (or another explicit base), do two jobs:

1. **Plan** a stack of small, reviewable PRs.
2. **Materialize** that stack as one review commit per branch.

The stack should prefer semantic boundaries over file boundaries. When semantic boundaries cut across a single file, plan for hunk/line-level splits and call them out explicitly.

## Hard invariants

- One managed branch corresponds to one review commit.
- Child branches are based on the tip of their parent branch.
- PR bases must match the stack parent (`origin/main` for the root branch).
- Use `--force-with-lease`, never plain `--force`.
- Do not create merge commits in the stack.
- When changing a parent branch, restack descendants in dependency order.
- Every planned branch has at least one targeted local validation command.

## Inputs to gather first

Before proposing a plan, inspect the following. Replace `origin/main` with the explicit base when the user provides one:

- `git status --short`
- `git branch --show-current`
- `git fetch origin main`
- `git diff --name-status --find-renames origin/main...HEAD`
- `git diff --name-status --find-renames origin/main`
- `git log --oneline --decorate --graph origin/main..HEAD`
- repo-specific build/test commands from repo `AGENTS.md` if present

If helper scripts are available, prefer them, again replacing `origin/main` with the explicit base when needed:

- `python3 <skill_dir>/scripts/collect_diff.py --base origin/main`
- `python3 <skill_dir>/scripts/status.py`
- `python3 <skill_dir>/scripts/extract_hunks.py --path <file> --base origin/main --source HEAD`

Resolve `<skill_dir>` against this skill folder first.

If the working tree is dirty before history-rewrite operations (`materialize`, `restack`, `evolve`), pause and ask the user whether to commit or stash first. The materializer uses `HEAD` as the source ref, so uncommitted changes are not included in generated stack branches.

## Planning rubric

Split changes into the smallest coherent dependency-ordered sequence you can justify.

Prefer this order when applicable:

1. mechanical refactor or extraction that enables later changes
2. schema/interface/API introduction
3. core implementation
4. call-site migration / UI integration
5. tests and cleanup that only make sense after earlier steps

### Keep together

- tests that directly validate a behavior change
- interface changes with the first implementation that requires them
- migrations before code that relies on them
- generated files only when they are necessary for correctness or buildability
- tightly coupled code and logging that is required for the behavior to function

### Split apart

- pure refactors from behavior changes
- broad renames from feature logic
- cleanup that obscures the core change
- unrelated package changes even if edited in the same session
- cross-cutting debug/telemetry/logging from the functional changes they instrument (when the behavior works without them)

## Plan format

When proposing or validating a stack plan JSON, read and follow [`references/plan-schema.md`](references/plan-schema.md).

## Workflow

### 1) Build a plan

- Identify changed files and likely dependency edges.
- Group changes into candidate PRs.
- Minimize backwards dependencies.
- Prefer more, smaller PRs when uncertain.
- Present the plan clearly before rewriting history.
- For files with changes that belong in multiple PRs, emit per-branch `patches` entries containing the exact unified diffs for the selected hunks.

When a file contains changes for multiple PRs, call that out explicitly and describe the hunks (line ranges or functions) to separate. It is acceptable to split a single file across PRs; prefer semantic grouping over keeping files intact. If you need line-level splits, add `patches` entries to the plan JSON and materialize them. `extract_hunks.py` prints the file diff; select or trim the exact hunks yourself before adding them to a plan.

### 2) Materialize the stack

Use `scripts/materialize_stack.py` with a saved plan JSON when possible.

Recommended flow:

1. Save the plan to `.git/pr-stack-plan.json`.
2. Run:
   - `python3 <skill_dir>/scripts/materialize_stack.py --plan .git/pr-stack-plan.json --base origin/main`
3. Inspect the resulting stack:
   - `python3 <skill_dir>/scripts/status.py`
4. Run each branch's local validation commands before declaring the split ready for review.

Plans can mix whole-file `include` entries and explicit hunk-level `patches` entries in the same branch. Use `include` for files that belong wholly to that branch, and use `patches` for files that are split across branches. Do not list the same path in both `include` and `patches` for one branch unless the patch is intentionally meant to apply after the full-file diff. `materialize_stack.py` applies whole-file entries first, then applies each patch entry with `git apply --index --3way`, and creates exactly one commit for the branch.

If a patch cannot be applied, stop and report the branch and patch label or file set that failed.

## Restacking and evolving

### Restack descendants after changing a parent

- `python3 <skill_dir>/scripts/restack.py --from <branch>`

This should replay descendants in order and preserve one review commit per branch.

### Evolve the whole chain onto latest main

- `python3 <skill_dir>/scripts/evolve.py --base origin/main`

This should fetch the latest base and replay the stack root-first.

## Conflict handling

On conflict:

- say exactly which branch is being replayed
- show the conflicted files
- stop without destroying metadata
- tell the user whether the conflict happened during materialize, restack, or evolve

After manual resolution during `restack` or `evolve`, continue or abort the active rebase with Git before rerunning the helper. For `materialize`, resolve by refining the plan or patch entry, then rerun the materializer.

## Commit and PR conventions

- Commit subject becomes PR title.
- Commit body seeds the PR body.
- Branch names should be zero-padded and ordered, like `stack/001-parser`, `stack/002-api`.
- Prefer targeted validation per branch over running the entire suite every time.

## Metadata

Store stack metadata in `.git/pr-stack/stack.json`.

Use the provided scripts to read and update it rather than editing manually.

## Output expectations

Every run should leave the user with:

- a clear stack plan
- the created or updated branch chain
- the exact validation commands that were run, with pass/fail status (or an explicit user-approved skip)
- any manual follow-up required for mixed hunks or conflicts
