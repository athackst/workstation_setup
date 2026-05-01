#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(mktemp -d "${TMPDIR:-/tmp}/pr-stack-hunk-demo.XXXXXX")"
meta_out="$repo/.git/pr-stack/materialize-meta.json"

cd "$repo"
git init -q
git config user.name "PR Stack Demo"
git config user.email "pr-stack-demo@example.com"

mkdir -p docs
cat > docs/example.txt <<'CONTENTS'
alpha
one
two
three
four
five
omega
CONTENTS
git add docs/example.txt
git commit -q -m "Create example file"
git branch -M main

git checkout -q -b source
cat > docs/example.txt <<'CONTENTS'
alpha
ONE
two
three
four
FIVE
omega
CONTENTS
git add docs/example.txt
git commit -q -m "Source change with two independent hunks"

first_patch="$repo/first-hunk.patch"
second_patch="$repo/second-hunk.patch"

git checkout -q -B patch-builder-first main
cat > docs/example.txt <<'CONTENTS'
alpha
ONE
two
three
four
five
omega
CONTENTS
git diff --binary main -- docs/example.txt > "$first_patch"
git reset -q --hard

git checkout -q -B patch-builder-second main
cat > docs/example.txt <<'CONTENTS'
alpha
one
two
three
four
FIVE
omega
CONTENTS
git diff --binary main -- docs/example.txt > "$second_patch"
git reset -q --hard

git checkout -q source
mkdir -p .git/pr-stack
python3 - "$first_patch" "$second_patch" <<'PY'
import json
import sys
from pathlib import Path

first = Path(sys.argv[1]).read_text()
second = Path(sys.argv[2]).read_text()
plan = {
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
                    "patch": first,
                }
            ],
            "validation": ["git diff --check HEAD~1 HEAD"],
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
                    "patch": second,
                }
            ],
            "validation": ["git diff --check HEAD~1 HEAD"],
        },
    ],
}
Path(".git/pr-stack/plan.json").write_text(json.dumps(plan, indent=2) + "\n")
PY

git stash push -q -u -m "demo generated hunk patches" -- first-hunk.patch second-hunk.patch
python3 "$script_dir/materialize_stack.py" --plan .git/pr-stack/plan.json --base main >"$meta_out"
git stash pop -q

test "$(git rev-list --count main..stack/001-first-hunk)" = "1"
test "$(git rev-list --count stack/001-first-hunk..stack/002-second-hunk)" = "1"
git diff --quiet source stack/002-second-hunk

echo "demo repo: $repo"
echo "plan: $repo/.git/pr-stack/plan.json"
echo "branches:"
git log --oneline --decorate --graph --all
echo "metadata:"
cat "$meta_out"
