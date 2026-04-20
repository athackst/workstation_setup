#!/usr/bin/env python3
from __future__ import annotations

import argparse
import subprocess

from common import ensure_git_repo


def run_diff(base: str, source: str, path: str, context: int) -> str:
    cmd = [
        'git',
        'diff',
        f'-U{context}',
        f'{base}...{source}',
        '--',
        path,
    ]
    proc = subprocess.run(cmd, text=True, capture_output=True)
    if proc.returncode not in (0, 1):
        raise RuntimeError(proc.stderr.strip() or 'git diff failed')
    return proc.stdout


def main() -> int:
    parser = argparse.ArgumentParser(description='Extract unified diff hunks for a file to use in stack plan hunks.')
    parser.add_argument('--path', required=True, help='File path to extract hunks from')
    parser.add_argument('--base', default='origin/main', help='Base ref (default: origin/main)')
    parser.add_argument('--source', default='HEAD', help='Source ref (default: HEAD)')
    parser.add_argument('--context', type=int, default=3, help='Context lines for the diff (default: 3)')
    args = parser.parse_args()

    ensure_git_repo()
    diff_text = run_diff(args.base, args.source, args.path, args.context)
    if not diff_text.strip():
        print('')
        return 0
    print(diff_text.rstrip())
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
