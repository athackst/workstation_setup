#!/usr/bin/env python3
from __future__ import annotations

import json
import os
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path('.git/pr-stack')
META = ROOT / 'stack.json'


class GitError(RuntimeError):
    pass


def run(cmd: list[str], check: bool = True, capture: bool = True, cwd: str | None = None) -> str:
    proc = subprocess.run(
        cmd,
        cwd=cwd,
        text=True,
        capture_output=capture,
    )
    if check and proc.returncode != 0:
        err = (proc.stderr or '').strip()
        raise GitError(f"command failed ({proc.returncode}): {' '.join(cmd)}\n{err}")
    return proc.stdout.strip() if capture else ''


def ensure_git_repo() -> None:
    run(['git', 'rev-parse', '--git-dir'])


def ensure_clean_worktree(operation: str) -> None:
    status = run(['git', 'status', '--short'], check=False)
    if status.strip():
        raise RuntimeError(
            f'working tree must be clean before {operation}; commit or stash these changes first:\n{status}'
        )


def current_branch() -> str:
    return run(['git', 'branch', '--show-current'])


def ensure_meta_dir() -> None:
    ROOT.mkdir(parents=True, exist_ok=True)


def load_meta() -> dict[str, Any]:
    ensure_meta_dir()
    if not META.exists():
        return {"base": "origin/main", "branches": {}}
    return json.loads(META.read_text())


def save_meta(data: dict[str, Any]) -> None:
    ensure_meta_dir()
    META.write_text(json.dumps(data, indent=2) + '\n')


def branch_head(branch: str) -> str:
    return run(['git', 'rev-parse', branch])


def merge_base(a: str, b: str) -> str:
    return run(['git', 'merge-base', a, b])


def list_conflicted_files() -> list[str]:
    out = run(['git', 'diff', '--name-only', '--diff-filter=U'], check=False)
    return [line for line in out.splitlines() if line.strip()]


def fetch_base(base: str) -> None:
    remote, _, branch = base.partition('/')
    if remote and branch:
        run(['git', 'fetch', remote, branch], capture=False)


def topological_chain(meta: dict[str, Any], start: str | None = None) -> list[str]:
    branches = meta.get('branches', {})
    if not branches:
        return []

    if start is None:
        roots = [name for name, data in branches.items() if data.get('parent') == meta.get('base', 'origin/main')]
        if len(roots) != 1:
            roots = sorted(roots)
        start = roots[0]

    ordered: list[str] = []
    cur = start
    seen: set[str] = set()
    while cur:
        if cur in seen:
            raise RuntimeError(f'cycle detected at {cur}')
        seen.add(cur)
        ordered.append(cur)
        children = branches.get(cur, {}).get('children', [])
        cur = children[0] if children else None
    return ordered
