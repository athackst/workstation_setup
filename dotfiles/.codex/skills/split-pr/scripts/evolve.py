#!/usr/bin/env python3
from __future__ import annotations

import argparse

from common import ensure_git_repo, fetch_base, list_conflicted_files, load_meta, run, save_meta, topological_chain


def main() -> int:
    parser = argparse.ArgumentParser(description='Replay the managed stack onto the latest base.')
    parser.add_argument('--base', default=None)
    args = parser.parse_args()

    ensure_git_repo()
    meta = load_meta()
    base = args.base or meta.get('base', 'origin/main')
    fetch_base(base)
    meta['base'] = base

    chain = topological_chain(meta)
    if not chain:
        raise RuntimeError('no managed stack found')

    parent_ref = base
    for branch in chain:
        old_parent = meta['branches'][branch]['parent']
        run(['git', 'checkout', branch], capture=False)
        try:
            run(['git', 'rebase', '--onto', parent_ref, old_parent, branch], capture=False)
        except Exception:
            conflicted = list_conflicted_files()
            raise RuntimeError(f'conflict while evolving {branch}: ' + ', '.join(conflicted))
        meta['branches'][branch]['parent'] = parent_ref
        meta['branches'][branch]['head'] = run(['git', 'rev-parse', 'HEAD'])
        parent_ref = branch

    save_meta(meta)
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
