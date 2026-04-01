---
name: commit-staged
description: Create a commit from the currently staged Git changes only. Use when the user wants Codex to inspect the staged diff, write a concise plain-English commit subject without conventional-commit prefixes, refuse unrelated staged groups, avoid staging additional files, and print the exact commit message used after committing.
---

# Commit Staged

Inspect only the staged diff and turn it into one commit when the staged set represents a single coherent change.

## Workflow

1. Run `git diff --staged --stat`.
2. Run `git diff --staged`.
3. Base every decision only on those staged results.
4. Do not stage, unstage, or modify files as part of this skill.

## Decide Whether To Commit

- If there are no staged changes, do not commit. Output exactly: `Nothing is staged.`
- If the staged diff contains unrelated changes, do not commit.
- When refusing because the staged set is mixed, explain briefly that the staged changes should be split first and propose one commit message per logical group.
- Identify the single main purpose of the staged diff before writing any commit message.

## Commit Message Rules

- Write a concise, specific subject line in plain English.
- Do not use commit type prefixes such as `feat:`, `fix:`, or similar variants.
- Prefer the highest-level meaningful outcome over a list of file edits.
- Keep the subject focused on what changed for the project, not on mechanics like renaming, formatting, or moving files unless that is the real outcome.

## Commit Step

If the staged diff is coherent, run:

```bash
git commit -m "<generated message>"
```

## Output Rules

After a successful commit, output only:

```text
Committed: <generated message>
```

Do not add extra commentary after a successful commit.
