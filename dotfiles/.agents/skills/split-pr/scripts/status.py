#!/usr/bin/env python3
from __future__ import annotations

from common import ensure_git_repo, load_meta, topological_chain, run


def main() -> int:
    ensure_git_repo()
    meta = load_meta()
    chain = topological_chain(meta) if meta.get('branches') else []
    if not chain:
        print('No managed PR stack found.')
        return 0

    current = run(['git', 'branch', '--show-current'])
    print(meta.get('base', 'origin/main'))
    for branch in chain:
        data = meta['branches'][branch]
        marker = '*' if branch == current else ' '
        dirty = run(['git', 'status', '--short'], check=False)
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
