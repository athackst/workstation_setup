#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import subprocess
import tempfile
from pathlib import Path
from typing import Any

from common import ensure_clean_worktree, ensure_git_repo, load_meta, save_meta, run


class PlanError(RuntimeError):
    pass


class ApplyEntryError(RuntimeError):
    def __init__(self, branch: str, entry: str, cause: Exception):
        self.branch = branch
        self.entry = entry
        self.cause = cause
        super().__init__(f'failed to apply {entry} on {branch}: {cause}')


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
        run(['git', 'apply', '--index', tmp])
    finally:
        try:
            os.unlink(tmp)
        except OSError:
            pass


def patch_label(entry: dict[str, Any], idx: int) -> str:
    if entry.get('label'):
        return str(entry['label'])
    if entry.get('path'):
        return str(entry['path'])
    return f'patch[{idx}]'


def patch_text(entry: dict[str, Any], idx: int) -> str:
    text = entry.get('patch', entry.get('diff'))
    if not isinstance(text, str) or not text.strip():
        raise PlanError(f'patch[{idx}] must contain a non-empty "patch" or "diff" string')
    return text if text.endswith('\n') else text + '\n'


def apply_patch_entry(entry: dict[str, Any], idx: int) -> str:
    label = patch_label(entry, idx)
    text = patch_text(entry, idx)
    with tempfile.NamedTemporaryFile('w+', delete=False) as handle:
        tmp = handle.name
        handle.write(text)
    try:
        run(['git', 'apply', '--index', '--3way', tmp])
    finally:
        try:
            os.unlink(tmp)
        except OSError:
            pass
    return label


def normalize_include(spec: dict[str, Any]) -> list[str]:
    include = spec.get('include', [])
    if include is None:
        return []
    if not isinstance(include, list) or not all(isinstance(item, str) for item in include):
        raise PlanError(f'{spec.get("name", "<unnamed>")}: include must be a list of file paths')
    return [item.strip() for item in include if item.strip()]


def normalize_patches(spec: dict[str, Any]) -> list[dict[str, Any]]:
    patches = spec.get('patches', spec.get('hunks', spec.get('patch_entries', [])))
    if patches is None:
        return []
    if not isinstance(patches, list):
        raise PlanError(f'{spec.get("name", "<unnamed>")}: patches must be a list')
    normalized: list[dict[str, Any]] = []
    for idx, entry in enumerate(patches):
        if isinstance(entry, str):
            entry = {'patch': entry}
        elif not isinstance(entry, dict):
            raise PlanError(f'{spec.get("name", "<unnamed>")}: patch[{idx}] must be an object or string')
        patch_text(entry, idx)
        normalized.append(entry)
    return normalized


def validate_branch_spec(spec: dict[str, Any], idx: int) -> None:
    for key in ('name', 'title'):
        if not isinstance(spec.get(key), str) or not spec[key].strip():
            raise PlanError(f'branches[{idx}] must contain a non-empty "{key}"')
    include = normalize_include(spec)
    patches = normalize_patches(spec)
    if not include and not patches:
        raise PlanError(f'{spec["name"]}: include and patches are both empty')
    validation = spec.get('validation', [])
    if not isinstance(validation, list) or not any(isinstance(item, str) and item.strip() for item in validation):
        raise PlanError(f'{spec["name"]}: validation must contain at least one targeted command')


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
    ensure_clean_worktree('materialize')
    plan = json.loads(Path(args.plan).read_text())
    base = args.base or plan.get('base', 'origin/main')
    branches = plan.get('branches', [])
    if not branches:
        raise RuntimeError('plan has no branches')
    if not isinstance(branches, list):
        raise PlanError('plan "branches" must be a list')
    for idx, spec in enumerate(branches):
        if not isinstance(spec, dict):
            raise PlanError(f'branches[{idx}] must be an object')
        validate_branch_spec(spec, idx)

    meta = load_meta()
    meta['base'] = base
    meta['branches'] = {}
    meta['plan_version'] = max(int(meta.get('plan_version', 1)), 2)

    source_ref = run(['git', 'rev-parse', 'HEAD'])
    parent_ref = base
    for idx, spec in enumerate(branches):
        name = spec['name']
        title = spec['title']
        description = spec.get('description', '')
        include = normalize_include(spec)
        patches = normalize_patches(spec)
        validation = spec.get('validation', [])
        applied_entries: list[str] = []

        run(['git', 'checkout', '-B', name, parent_ref], capture=False)
        run(['git', 'reset', '--hard', parent_ref], capture=False)
        try:
            try:
                apply_file_subset(base, source_ref, include)
                applied_entries.extend(f'file:{path}' for path in include)
            except Exception as exc:
                raise ApplyEntryError(name, 'file-level include set', exc) from exc
            for patch_idx, patch in enumerate(patches):
                label = patch_label(patch, patch_idx)
                try:
                    apply_patch_entry(patch, patch_idx)
                    applied_entries.append(f'patch:{label}')
                except Exception as exc:
                    raise ApplyEntryError(name, f'patch {label}', exc) from exc
            commit_if_needed(title, description)
        except Exception as exc:
            failed = name
            if isinstance(exc, ApplyEntryError):
                failed = f'{exc.branch} {exc.entry}'
            print(f'materialize failed on {failed}', flush=True)
            if include:
                print(f'file-level entries: {", ".join(include)}', flush=True)
            if patches:
                print('patch entries: ' + ', '.join(patch_label(patch, i) for i, patch in enumerate(patches)), flush=True)
            raise

        head = run(['git', 'rev-parse', 'HEAD'])
        meta['branches'][name] = {
            'parent': parent_ref,
            'children': [branches[idx + 1]['name']] if idx + 1 < len(branches) else [],
            'title': title,
            'head': head,
            'validation': validation,
            'entries': applied_entries,
        }
        parent_ref = name

    save_meta(meta)
    print(json.dumps(meta, indent=2))
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
