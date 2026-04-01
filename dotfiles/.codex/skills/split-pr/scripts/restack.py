#!/usr/bin/env python3
from __future__ import annotations

import argparse

from common import branch_head, ensure_git_repo, list_conflicted_files, load_meta, run, save_meta


def main() -> int:
    parser = argparse.ArgumentParser(description='Replay descendants after a parent branch changes.')
    parser.add_argument('--from', dest='branch', required=True, help='Parent branch to restack from')
    args = parser.parse_args()

    ensure_git_repo()
    meta = load_meta()
    branches = meta.get('branches', {})
    if args.branch not in branches:
        raise RuntimeError(f'unknown managed branch: {args.branch}')

    parent = args.branch
    children = branches[parent].get('children', [])
    while children:
        child = children[0]
        old_parent = branches[child]['parent']
        old_head = branch_head(child)
        old_base = run(['git', 'merge-base', child, old_parent])
        run(['git', 'checkout', child], capture=False)
        proc_ok = True
        try:
            run(['git', 'rebase', '--onto', parent, old_parent, child], capture=False)
        except Exception:
            proc_ok = False
        if not proc_ok:
            conflicted = list_conflicted_files()
            raise RuntimeError(f'conflict while restacking {child}: ' + ', '.join(conflicted))
        branches[child]['parent'] = parent
        branches[child]['head'] = branch_head(child)
        parent = child
        children = branches[child].get('children', [])

    save_meta(meta)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
