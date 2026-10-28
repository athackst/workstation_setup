#!/usr/bin/env python3
from __future__ import annotations

from common import ensure_git_repo, load_meta, topological_chains, run


def main() -> int:
    ensure_git_repo()
    meta = load_meta()
    chains = topological_chains(meta) if meta.get('branches') else []
    if not chains:
        print('No managed PR branches found.')
        return 0

    current = run(['git', 'branch', '--show-current'])
    print(meta.get('base', 'origin/main'))
    dirty = run(['git', 'status', '--short'], check=False)
    for chain in chains:
        stack_key = meta['branches'][chain[0]].get('stack_key')
        print(f"{meta.get('base', 'origin/main')} [{stack_key or 'standalone'}]")
        for branch in chain:
            data = meta['branches'][branch]
            marker = '*' if branch == current else ' '
            flags = []
            if branch == current:
                flags.append('current')
            if branch == current and dirty.strip():
                flags.append('dirty')
            title = data.get('title', '')
            print(f"{marker} └─ {branch} [{', '.join(flags) if flags else 'clean'}] {title}")
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
