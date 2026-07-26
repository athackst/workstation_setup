# Dotfiles

This directory contains user configuration files installed by `install.sh`.
The Bash configuration defines the helpers and aliases documented below.

## Bash helpers and aliases

`.bash_aliases` is sourced by Bash after installation. It defines shell
helpers, Docker/ROS/MkDocs workflows, and shortcuts for common commands. The
`~/.aliases/bazel_aliases.sh` and `~/.aliases/git_aliases.sh` files are sourced
separately when present.

### General helpers

- `title <text>`: set the terminal title.
- `zipall`: create one `<directory>.zip` archive for each directory in the
  current directory.
- `parse_git_branch`: return the current Git branch for prompt rendering.
- `__bash_prompt`: configure the prompt with the working directory, branch,
  and a dirty-worktree marker; it removes itself after initialization.

### GitHub authentication and workspace creation

The following helpers use the GitHub CLI:

- `get_gh_auth_status` returns raw authentication status, including the token.
  Treat its output as secret.
- `get_gh_username [auth_status]` extracts the active username.
- `create_ros2_ws <name>` creates and clones a private ROS 2 workspace from
  `athackst/vscode_ros2_workspace`.
- `create_website_ws <name>` creates and clones a private website workspace
  from `athackst/vscode_website_workspace`.

Both creation helpers require `gh auth status` to succeed and change into the
newly cloned repository.

### MkDocs helpers

- `mkdocs_docker_serve [port]` serves the current directory from the
  `althack/mkdocs-simple-plugin:latest` container. The default port is `8000`.
- `mkdocs_docker_build` builds the current directory with
  `mkdocs_simple_gen --build` as the current user.
- `mkdocs_docker` opens an interactive shell in the MkDocs container.
- `mkdocs_athackst` copies the current directory into a temporary clone of
  `athackst/athackst.mkdocs` and serves it.

### GitHub completion

When the GitHub CLI is installed, this configuration enables its Bash
completion definitions.

### ROS helper

- `noetic_gazebo` runs `althack/ros:noetic-gazebo` with the host display and
  X11 socket mounted, using the container's `ros` user.

### Docker helpers

- `docker-images-update` removes unused Docker resources and pulls the
  workstation's base images.
- `docker-services-start` starts the local registry, notes, and Watchtower
  containers.
- `docker-services-stop` disables automatic restarts for those containers; it
  does not stop them.
- `docker-services-update` runs a one-shot Watchtower update.
- `docker-prune` aggressively removes unused Docker resources, including
  volumes.

### HTML Proofer

- `htmlproofer_action <site-directory>` runs the
  `althack/htmlproofer:latest` container against a site directory relative to
  the current directory.

### Account-specific aliases

- `rm` moves removed files to Trash through `trash -v`.
- `ci-bot-athackst` runs `ci-bot setup` with
  `~/.config/tokens/athackst_ci_bot.token`.
- `ci-bot-althack` runs `ci-bot setup` with
  `~/.config/tokens/althack_ci_bot.token`.
- `git-use-athackst` and `git-use-althack` select the corresponding GitHub SSH
  account and set its repository-local email.

The `git-use-*` aliases must be run from inside a repository with an `origin`
remote. They use the SSH hosts configured in `.ssh/config`.

### `ci-bot` completion

When `ci-bot` is installed, the configuration loads the completion function
emitted by `_CI_BOT_COMPLETE=bash_source ci-bot`.

### Agent alias

- `commit-staged` asks Codex to create a commit from the currently staged
  changes using the `commit-staged` skill.

## Bazel aliases

The Bazel aliases are loaded only when Bash completion is available at
`/etc/bash-completion.d/bazel-complete.bash`. They use:

- `BAZEL_WS=~/bazel_ws` as the workspace containing Bazel projects.
- `BAZEL_BIN_CACHE=~/.bazel-binaries` as the cache of discovered binary and
  test targets.

Commands:

- `b`: refresh the binary/test target cache.
- `b <binary> [args...]`: find a cached Bazel binary by name, run it from
  `$BAZEL_WS/bazel-bin`, and forward the remaining arguments.
- `bb`: alias for `bazel build`, with Bazel target completion.
- `bt`: alias for `bazel test`.

The `b` command also provides completion for cached binary names.

## Git aliases

The Git aliases are loaded only when the system Git Bash completion or prompt
file is available. The short alias and branch commands are:

- `g`: alias for `git`.
- `g_status`: show short status for the current repository.
- `g_ls`: list local branches.
- `g_cd <branch>`: check out a branch, with branch completion.
- `g_mk <branch>`: stash uncommitted changes, fetch remotes, create a branch
  from the remote default branch, and restore the stash.
- `g_del <branch>`: delete a local branch and its `origin` branch.
- `g_up`: push the current branch with `--force-with-lease` and set its
  upstream.
- `g_sync`: prune remote references and rebase the current branch onto the
  remote default branch using `--autostash`.
- `g_syncup`: run `g_sync` followed by `g_up`.

Commit shortcuts:

- `g_amend`: amend the current commit without changing its message.
- `g_amend_all`: stage updated tracked files and amend without changing the
  commit message.
- `g_commit <message>`: run `git commit -am <message>`.

Repository-group helpers:

- `g_scan`: fetch and display ahead/behind, upstream, and working-tree status
  for every local branch.
- `g_prune`: delete local branches whose changes are already contained in the
  remote default branch or whose diff is empty.
- `g_scanall`: run `g_scan` for each repository below the current directory,
  excluding `archive` and `third_party` directories.
- `g_fetchall`: fetch every Git repository below the current directory.
- `g_statusall [-d]`: fetch every repository and print a short status for each;
  `-d` includes changed-file details.
- `g_setall <branch>`: attempt to switch every repository that has the
  requested branch and print the resulting branch status.

The internal helpers `maxlength`, `_g_base_branch`, `_g_current_branch`,
`_g_remote`, `try_stash`, and `pop_stash` support these commands and are not
intended as primary user commands.
