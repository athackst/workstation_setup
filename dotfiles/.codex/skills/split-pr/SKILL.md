---
name: split-pr
description: Plan and manage dependency-ordered stacked PR branches from a branch delta against a base ref, then materialize, restack, or evolve one-review-commit-per-branch chains. Use when the user asks to split a large change into stacked PRs that are easy to review and coherent, restack descendants after editing a parent, or replay a stack onto the latest base with local validation per branch.
---

# Split PR

## Goal

Given the current work relative to `origin/main` (or another explicit base), do two jobs:

1. **Plan** a stack of small, reviewable PRs.
2. **Materialize** that stack as one review commit per branch.

The stack should prefer semantic boundaries over file boundaries.

## Hard invariants

- One managed branch corresponds to one review commit.
- Child branches are based on the tip of their parent branch.
- PR bases must match the stack parent (`origin/main` for the root branch).
- Use `--force-with-lease`, never plain `--force`.
- Do not create merge commits in the stack.
- When changing a parent branch, restack descendants in dependency order.
- Every planned branch has at least one targeted local validation command.

## Inputs to gather first

Before proposing a plan, inspect:

- `git status --short`
- `git branch --show-current`
- `git fetch origin main`
- `git diff --name-status --find-renames origin/main...HEAD`
- `git diff --name-status --find-renames origin/main`
- `git log --oneline --decorate --graph origin/main..HEAD`
- repo-specific build/test commands from repo `AGENTS.md` if present

If helper scripts are available, prefer them:

- `python3 <skill_dir>/scripts/collect_diff.py --base origin/main`
- `python3 <skill_dir>/scripts/status.py`

Resolve `<skill_dir>` against this skill folder first.

If the working tree is dirty before history-rewrite operations (`materialize`, `restack`, `evolve`), pause and ask the user whether to commit or stash first.

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

### Split apart

- pure refactors from behavior changes
- broad renames from feature logic
- cleanup that obscures the core change
- unrelated package changes even if edited in the same session

## Plan format

When proposing or validating a stack plan JSON, read and follow [`references/plan-schema.md`](references/plan-schema.md).

## Workflow

### 1) Build a plan

- Identify changed files and likely dependency edges.
- Group changes into candidate PRs.
- Minimize backwards dependencies.
- Prefer more, smaller PRs when uncertain.
- Present the plan clearly before rewriting history.

When a file contains changes for multiple PRs, call that out explicitly and describe the hunks to separate.

### 2) Materialize the stack

Use `scripts/materialize_stack.py` with a saved plan JSON when possible.

Recommended flow:

1. Save the plan to `.git/pr-stack-plan.json`.
2. Run:
   - `python3 <skill_dir>/scripts/materialize_stack.py --plan .git/pr-stack-plan.json --base origin/main`
3. Inspect the resulting stack:
   - `python3 <skill_dir>/scripts/status.py`
4. Run each branch's local validation commands before declaring the split ready for review.

If the script cannot cleanly separate mixed-file hunks, stop and explain which files need manual staging.

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

After manual resolution, rerun the same command.

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
