---
name: commit-staged
description: Create a commit from the currently staged Git changes only. Use when the user wants Codex to inspect the staged diff, write a concise plain-English commit subject without conventional-commit prefixes, refuse unrelated staged groups, avoid staging or modifying files, and print the exact commit message used after committing.
---

# Commit Staged

Inspect only the staged diff and turn it into one commit when the staged set represents a single coherent change.

This skill is deliberately narrow: do not fix, format, stage, unstage, regenerate, or otherwise change the worktree while using it.

## Workflow

1. Run `git diff --staged --stat`.
2. Run `git diff --staged`.
3. Base every decision only on those staged results.
4. If the staged diff is too large to inspect safely in one output, use staged-only follow-up reads such as `git diff --staged -- <path>` for the files shown in the staged stat.
5. Do not run commands whose purpose is to inspect, include, or alter unstaged changes.

## Decide Whether To Commit

- If there are no staged changes, do not commit. Output exactly: `Nothing is staged.`
- If the staged diff contains unrelated changes, do not commit.
- When refusing because the staged set is mixed, explain briefly that the staged changes should be split first and propose one commit message per logical group.
- Identify the single main purpose of the staged diff before writing any commit message.
- Treat changes as coherent when they serve one reviewable outcome, even if they touch multiple files.
- Treat changes as mixed when independent behavior, documentation, config, dependency, or formatting changes could reasonably be committed separately.

## Commit Message Rules

- Write a concise, specific subject line in plain English.
- Do not use commit type prefixes such as `feat:`, `fix:`, or similar variants.
- Do not add a body or footer unless the user explicitly asks for one.
- Prefer the highest-level meaningful outcome over a list of file edits.
- Keep the subject focused on what changed for the project, not on mechanics like renaming, formatting, or moving files unless that is the real outcome.
- Use sentence case unless the project clearly uses another local convention.

## Commit Step

If the staged diff is coherent, run:

```bash
git commit -m "<generated message>"
```

If the commit command fails, report the failure briefly and do not try to repair the worktree or index under this skill.

## Output Rules

After a successful commit, the final response must be only:

```text
Committed: <generated message>
```

Do not add extra commentary after a successful commit.
