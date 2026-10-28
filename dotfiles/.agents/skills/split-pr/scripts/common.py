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


def topological_chains(meta: dict[str, Any]) -> list[list[str]]:
    """Return every root-to-leaf chain in a managed PR forest."""
    branches = meta.get('branches', {})
    base = meta.get('base', 'origin/main')
    roots = sorted(name for name, data in branches.items() if data.get('parent') == base)
    chains: list[list[str]] = []

    def walk(name: str, path: list[str]) -> None:
        next_path = [*path, name]
        children = branches.get(name, {}).get('children', [])
        if not children:
            chains.append(next_path)
            return
        for child in children:
            walk(child, next_path)

    for root in roots:
        walk(root, [])
    return chains
