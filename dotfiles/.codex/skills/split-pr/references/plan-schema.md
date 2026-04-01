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
- `include` is primarily file-based. For mixed-file cases, add hunk notes in the branch description and stage manually before materialization.
- `exclude` is optional and can be used to protect broad formatting or generated files from accidental inclusion.
- `validation` should contain targeted commands for that branch.
