#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path

from common import current_branch, ensure_git_repo, run


def main() -> int:
    parser = argparse.ArgumentParser(description='Collect a compact summary of changes against a base ref.')
    parser.add_argument('--base', default='origin/main')
    args = parser.parse_args()

    ensure_git_repo()
    tracked = run(['git', 'diff', '--name-status', '--find-renames', f'{args.base}...HEAD'])
    working = run(['git', 'diff', '--name-status', '--find-renames', args.base], check=False)
    status = run(['git', 'status', '--short'])
    log = run(['git', 'log', '--oneline', '--decorate', '--graph', f'{args.base}..HEAD'], check=False)

    payload = {
        'base': args.base,
        'current_branch': current_branch(),
        'changed_files_against_head': [line for line in tracked.splitlines() if line.strip()],
        'changed_files_against_worktree': [line for line in working.splitlines() if line.strip()],
        'status': [line for line in status.splitlines() if line.strip()],
        'commits_since_base': [line for line in log.splitlines() if line.strip()],
    }
    print(json.dumps(payload, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
