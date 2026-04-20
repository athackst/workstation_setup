# PR stack plan schema

A stack plan is a JSON document with this shape:

```json
{
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
      "hunks": [
        {
          "patch": "diff --git a/src/parser.py b/src/parser.py\nindex 1111111..2222222 100644\n--- a/src/parser.py\n+++ b/src/parser.py\n@@ -10,6 +10,7 @@ def parse_line(line):\n     result = helper(line)\n+    debug_log(result)\n     return result\n"
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

## Notes

- `base` defaults to `origin/main`.
- `branches` must be ordered from root to leaf.
- Each branch should contain one logical review commit.
- `parents` is usually a single-element array; the root branch should name `origin/main`.
- `include` is primarily file-based.
- `hunks` is optional and accepts one or more unified diff patches (string or `{ "patch": "..." }`) to apply line-level splits. If you use `hunks`, avoid listing those files in `include` or they will be pulled in whole.
- You can generate a patch for `hunks` with `python3 <skill_dir>/scripts/extract_hunks.py --path <file> --base origin/main --source HEAD`.
- `exclude` is optional and can be used to protect broad formatting or generated files from accidental inclusion.
- `validation` should contain targeted commands for that branch.
