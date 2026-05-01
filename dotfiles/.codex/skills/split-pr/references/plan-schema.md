# PR stack plan schema

A stack plan is a JSON document that describes a dependency-ordered branch chain. It can use old file-level entries, new hunk-level patch entries, or both in the same branch.

```json
{
  "version": 2,
  "base": "origin/main",
  "branches": [
    {
      "name": "stack/001-parser",
      "title": "Extract parser helpers",
      "description": "Mechanical refactor with no behavior change.",
      "parents": ["origin/main"],
      "include": [
        "src/parser.py",
        "src/parser_helpers.py"
      ],
      "patches": [
        {
          "path": "src/parser.py",
          "label": "parser helper call-site hunk",
          "patch": "diff --git a/src/parser.py b/src/parser.py\n--- a/src/parser.py\n+++ b/src/parser.py\n@@ -10,7 +10,7 @@ def parse(value):\n-    return old_parse(value)\n+    return parse_with_helper(value)\n"
        }
      ],
      "exclude": [],
      "validation": [
        "pytest tests/test_parser.py"
      ]
    }
  ]
}
```

## Top-level fields

- `version` is optional. Use `2` for plans that may contain `patches`.
- `base` defaults to `origin/main`.
- `branches` must be ordered from root to leaf. `materialize_stack.py` creates one commit per branch in this order.

## Branch fields

- `name` is the branch to create or update, for example `stack/001-parser`.
- `title` becomes the commit subject and PR title.
- `description` becomes the commit body and PR body seed.
- `parents` is retained for readability. The script uses branch order to materialize a linear stack; the root is based on `base`.
- `include` is a list of whole-file paths to apply from the source diff with `git diff <base>...<source> -- <files>`.
- `patches` is a list of explicit patch entries. Each patch entry is applied with `git apply --index --3way`.
- `exclude` is optional plan documentation for files intentionally left out. The materializer does not need it to apply the plan.
- `validation` should contain targeted commands for that branch.

Each branch must contain at least one `include` path or one `patches` entry. Old plans that only use `include` remain valid.

Use `include` for files that belong wholly to one branch. Use `patches` for files that are split across branches. Avoid listing the same path in both fields for one branch unless the patch is intentionally meant to apply after the full-file diff.

## Patch entries

Patch entries contain complete unified diff text selected by the planning layer. The scripts do not infer semantic boundaries or reconstruct hunks from indexes. `extract_hunks.py` prints the file diff; select or trim the exact hunks before adding them to a plan.

```json
{
  "path": "src/parser.py",
  "label": "parse_with_helper call-site",
  "patch": "diff --git a/src/parser.py b/src/parser.py\n--- a/src/parser.py\n+++ b/src/parser.py\n@@ -10,7 +10,7 @@ def parse(value):\n-    return old_parse(value)\n+    return parse_with_helper(value)\n"
}
```

- `patch` is preferred. `diff` is accepted as a compatibility alias.
- `path` is optional but recommended for clear errors and review.
- `label` is optional but recommended when a branch has multiple entries for the same file.
- Patch text should be valid unified diff. Include `diff --git`, `---`, `+++`, and `@@` hunk headers when possible.

## Same-file hunk split example

This example splits two independent hunks from `docs/example.txt` into separate PRs.

```json
{
  "version": 2,
  "base": "main",
  "branches": [
    {
      "name": "stack/001-first-hunk",
      "title": "Update first example line",
      "description": "Applies only the first hunk in docs/example.txt.",
      "parents": ["main"],
      "include": [],
      "patches": [
        {
          "path": "docs/example.txt",
          "label": "first line hunk",
          "patch": "diff --git a/docs/example.txt b/docs/example.txt\n--- a/docs/example.txt\n+++ b/docs/example.txt\n@@ -1,5 +1,5 @@\n alpha\n-one\n+ONE\n two\n three\n four\n"
        }
      ],
      "validation": ["git diff --check HEAD~1 HEAD"]
    },
    {
      "name": "stack/002-second-hunk",
      "title": "Update second example line",
      "description": "Applies only the second hunk in docs/example.txt.",
      "parents": ["stack/001-first-hunk"],
      "include": [],
      "patches": [
        {
          "path": "docs/example.txt",
          "label": "second line hunk",
          "patch": "diff --git a/docs/example.txt b/docs/example.txt\n--- a/docs/example.txt\n+++ b/docs/example.txt\n@@ -3,5 +3,5 @@\n two\n three\n four\n-five\n+FIVE\n omega\n"
        }
      ],
      "validation": ["git diff --check HEAD~1 HEAD"]
    }
  ]
}
```
