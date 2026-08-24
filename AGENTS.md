# Agent Instructions

## Development Environment

This project uses a devcontainer with pixi for environment management.

### Available Tools

- **GitHub CLI (`gh`)**: Available via `pixi run gh` or directly if using a login shell. Authentication arrives as `GH_TOKEN`, which `dl` forwards into every workspace it starts, taking it from `GH_TOKEN`, `GITHUB_TOKEN` or `gh auth token` -- whichever answers first. The container used to mount the host's `~/.config/gh` instead, which never worked: `gh` keeps its token in the system keyring, so the mounted `hosts.yml` carried no `oauth_token`. If the container was opened by something other than `dl` -- a plain `devpod up`, or VS Code's Reopen in Container -- it has no `gh` login and you have to export `GH_TOKEN` yourself.

### Running Commands

When using pixi tasks, prefer `pixi run <task>`. See `pixi task list` for available tasks.

For tools installed as dependencies (like `gh`), you can run them via:
- `pixi run gh <args>` - works in any shell
- `gh <args>` - works in login shells (`bash -l -c '...'`)
