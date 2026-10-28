---
name: split-pr
description: Split a branch delta into coherent standalone or stacked pull requests, materialize one-review-commit branches, and manage dependent chains with GitHub's gh stack extension. Use for PR splitting, native GitHub stacks, restacking, or replaying PR chains onto a base.
---

# Split PR

## Goal

Given committed work relative to `origin/main` (or another explicit base), do two jobs:

1. **Plan** a forest of small, reviewable PRs: standalone roots and only the dependency chains that are genuine stacks.
2. **Materialize** one review commit per branch and register each multi-branch chain with `gh stack`.

The stack should prefer semantic boundaries over file boundaries. When semantic boundaries cut across a single file, plan for hunk/line-level splits and call them out explicitly.

## Hard invariants

- One managed branch corresponds to one review commit.
- Independent PRs are based directly on the base; child branches are based on their actual dependency.
- PR bases must match each branch's declared parent.
- Use `--force-with-lease`, never plain `--force`.
- Do not create merge commits in the stack.
- Use `gh stack` as the source of truth for local stack membership, ordering, synchronization, and remote stack identity.
- Do not create an artificial dependency chain merely because changes share a source worktree.
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

Split changes into the smallest coherent dependency graph you can justify. Put unrelated changes in standalone PRs or separate stacks.

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

When proposing or validating a PR forest plan JSON, read and follow [`references/plan-schema.md`](references/plan-schema.md).

## Workflow

### 1) Build a plan

- Identify changed files and likely dependency edges.
- Group changes into candidate PRs.
- Minimize backwards dependencies.
- Prefer more, smaller PRs when uncertain.
- Present the plan clearly before rewriting history.
- For files with changes that belong in multiple PRs, emit per-branch `patches` entries containing the exact unified diffs for the selected hunks.

When a file contains changes for multiple PRs, call that out explicitly and describe the hunks (line ranges or functions) to separate. It is acceptable to split a single file across PRs; prefer semantic grouping over keeping files intact. If you need line-level splits, add `patches` entries to the plan JSON and materialize them. `extract_hunks.py` prints the file diff; select or trim the exact hunks yourself before adding them to a plan.

### 2) Materialize the PR forest

Use `scripts/materialize_stack.py` with a saved plan JSON when possible.

Recommended flow:

1. Save the plan to `.git/pr-stack-plan.json`.
2. Run:
   - `python3 <skill_dir>/scripts/materialize_stack.py --plan .git/pr-stack-plan.json --base origin/main`
3. Inspect the resulting branches:
   - `python3 <skill_dir>/scripts/status.py`
4. For every group of two or more branches sharing a `stack_key`, adopt the chain in bottom-to-top order:
   - `gh stack init --base <trunk> <branch-1> <branch-2> ...`
5. Inspect native stacks with `gh stack view` and run every branch's local validation commands.

Plans can mix whole-file `include` entries and explicit hunk-level `patches` entries in the same branch. Use `include` for files that belong wholly to that branch, and use `patches` for files that are split across branches. Do not list the same path in both `include` and `patches` for one branch unless the patch is intentionally meant to apply after the full-file diff. `materialize_stack.py` applies whole-file entries first, then applies each patch entry with `git apply --index --3way`, and creates exactly one commit for the branch.

If a patch cannot be applied, stop and report the branch and patch label or file set that failed.

Standalone branches do not need `gh stack init`. A one-branch group is not a useful stack.

## Native GitHub stack operations

- Local cascading rebase: `gh stack rebase`
- Fetch, rebase, push, and reconcile: `gh stack sync`
- Push branches without creating PRs: `gh stack push`
- Create or update PRs and the GitHub stack: `gh stack submit`
- Restructure a chain: `gh stack modify`

Treat `submit`, `sync`, `push`, and `merge` as remote mutations and obtain authorization when it is not already implied. Before a remote mutation in a multi-account setup, resolve the repository owner from `origin`, select the matching stored account without globally switching it when possible, and verify the login. A scoped invocation may use `GH_TOKEN="$(gh auth token --hostname github.com --user <user>)" gh stack ...`; never print the token.

## Conflict handling

On conflict:

- say exactly which branch is being replayed
- show the conflicted files
- stop without destroying metadata
- tell the user whether the conflict happened during materialization or a named `gh stack` operation

After manual resolution during a native stack operation, follow `gh stack`'s continuation or abort guidance. For `materialize`, resolve by refining the plan or patch entry, then rerun the materializer.

## Commit and PR conventions

- Commit subject becomes PR title.
- Commit body seeds the PR body.
- Standalone branches use `<type>/<slug>`.
- Stacked branches use `<type>/<stack-key>/<slug>`; the stable stack key distinguishes concurrent stacks.
- Do not encode layer numbers in branch names. `gh stack` owns order, and layers may be inserted or reordered.
- Choose a label-compatible type such as `fix`, `feat`, `maint`, `dev`, `deps`, or `doc`, following repository conventions when present.
- Prefer targeted validation per branch over running the entire suite every time.

## Metadata

Store materialization metadata in `.git/pr-stack/stack.json`. Native stack identity and order belong to `gh stack`.

Use the provided scripts to read and update it rather than editing manually.

## Output expectations

Every run should leave the user with:

- a clear stack plan
- the created or updated standalone branches and stack chains
- the exact validation commands that were run, with pass/fail status (or an explicit user-approved skip)
- any manual follow-up required for mixed hunks or conflicts
