#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
import tempfile
from pathlib import Path

from common import ensure_git_repo, load_meta, save_meta, run


def apply_file_subset(base_ref: str, source_ref: str, files: list[str]) -> None:
    if not files:
        return
    with tempfile.NamedTemporaryFile('w+', delete=False) as handle:
        tmp = handle.name
    try:
        with open(tmp, 'w', encoding='utf-8') as fh:
            subprocess.run(
                ['git', 'diff', '--binary', f'{base_ref}...{source_ref}', '--', *files],
                text=True,
                check=True,
                stdout=fh,
            )
        if os.path.getsize(tmp) == 0:
            return
        run(['git', 'apply', '--index', tmp], capture=False)
    finally:
        try:
            os.unlink(tmp)
        except OSError:
            pass


def commit_if_needed(title: str, description: str) -> None:
    diff_cached = run(['git', 'diff', '--cached', '--name-only'], check=False)
    if not diff_cached.strip():
        raise RuntimeError('no staged changes for this branch; refine the plan or stage hunks manually')
    message = title if not description else f'{title}\n\n{description}'
    run(['git', 'commit', '-m', message], capture=False)


def main() -> int:
    parser = argparse.ArgumentParser(description='Materialize a stacked PR plan into branches.')
    parser.add_argument('--plan', required=True, help='Path to plan JSON')
    parser.add_argument('--base', default=None, help='Override base ref from the plan')
    args = parser.parse_args()

    ensure_git_repo()
    plan = json.loads(Path(args.plan).read_text())
    base = args.base or plan.get('base', 'origin/main')
    branches = plan.get('branches', [])
    if not branches:
        raise RuntimeError('plan has no branches')

    meta = load_meta()
    meta['base'] = base
    meta['branches'] = {}

    source_ref = run(['git', 'rev-parse', 'HEAD'])
    parent_ref = base
    for idx, spec in enumerate(branches):
        name = spec['name']
        title = spec['title']
        description = spec.get('description', '')
        include = [item for item in spec.get('include', []) if '/' in item or '.' in item]
        validation = spec.get('validation', [])

        run(['git', 'checkout', '-B', name, parent_ref], capture=False)
        run(['git', 'reset', '--hard', parent_ref], capture=False)
        apply_file_subset(base, source_ref, include)
        commit_if_needed(title, description)

        head = run(['git', 'rev-parse', 'HEAD'])
        meta['branches'][name] = {
            'parent': parent_ref,
            'children': [branches[idx + 1]['name']] if idx + 1 < len(branches) else [],
            'title': title,
            'head': head,
            'validation': validation,
        }
        parent_ref = name

    save_meta(meta)
    print(json.dumps(meta, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
