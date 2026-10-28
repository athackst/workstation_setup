# PR forest plan schema

A version 3 plan describes standalone pull requests and one or more dependency
chains. Branches are listed in topological order: every branch appears after its
parent. The materializer creates one review commit per branch.

```json
{
  "version": 3,
  "base": "origin/main",
  "branches": [
    {
      "name": "maint/tooling",
      "title": "Update development tooling",
      "description": "Independent maintenance change.",
      "parent": "origin/main",
      "stack_key": null,
      "include": [".vscode/settings.json"],
      "patches": [],
      "validation": ["python -m json.tool .vscode/settings.json"]
    },
    {
      "name": "feat/auth/model",
      "title": "Add the user model",
      "description": "Foundation for the authentication stack.",
      "parent": "origin/main",
      "stack_key": "auth",
      "include": ["src/model.py"],
      "patches": [],
      "validation": ["pytest tests/test_model.py"]
    },
    {
      "name": "feat/auth/api",
      "title": "Add the authentication API",
      "description": "Builds on the user model.",
      "parent": "feat/auth/model",
      "stack_key": "auth",
      "include": ["src/api.py"],
      "patches": [],
      "validation": ["pytest tests/test_api.py"]
    }
  ]
}
```

## Top-level fields

- `version` must be `3`.
- `base` defaults to `origin/main`.
- `branches` is a topologically ordered list. Independent branches may share
  the base as their parent; dependent branches name an earlier planned branch.

## Branch fields

- `name` is `<type>/<slug>` for a standalone PR or
  `<type>/<stack-key>/<slug>` for a stacked PR.
- `title` becomes the commit subject and PR title.
- `description` becomes the commit body and PR body seed.
- `parent` is required. It must be the top-level `base` or an earlier branch.
- `stack_key` is `null` for a standalone PR and a stable string shared by every
  branch in one genuine dependency chain. A useful stack has at least two
  branches.
- `include` lists whole files to apply from the source delta.
- `patches` lists explicit unified diffs for files split across PRs.
- `exclude` optionally documents intentionally omitted files.
- `validation` contains at least one targeted local command.

Each branch must contain at least one `include` path or one `patches` entry. Do
not put the same path in both unless the patch intentionally follows the full
file diff.

## Patch entries

```json
{
  "path": "src/parser.py",
  "label": "parser helper call site",
  "patch": "diff --git a/src/parser.py b/src/parser.py\n--- a/src/parser.py\n+++ b/src/parser.py\n@@ -10,7 +10,7 @@ def parse(value):\n-    return old_parse(value)\n+    return parse_with_helper(value)\n"
}
```

- `patch` is required and must contain a non-empty unified diff.
- `path` and `label` are recommended for actionable errors.
- Include `diff --git`, `---`, `+++`, and `@@` headers when possible.

## Register native GitHub stacks

After materialization, group branches by non-null `stack_key` and preserve
bottom-to-top dependency order:

```bash
gh stack init --base main feat/auth/model feat/auth/api
```

Do not register standalone branches or unrelated branches as a stack.
