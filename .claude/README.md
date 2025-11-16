# Claude Code Configuration

This directory contains configuration for using this project with Claude Code, particularly in the online environment.

## Files

- `setup-common.sh` - Shared setup functions used by SessionStart, devcontainer, and other setup scripts
- `activate.sh` - Manual activation script to add pixi to PATH
- `hooks/SessionStart` - Automatic setup hook for Claude Code online sessions

## Setup Architecture

The setup is consolidated using shared functions in `setup-common.sh`:

- `install_pixi()` - Installs pixi package manager
- `install_dependencies()` - Installs project dependencies via pixi
- `setup_pre_commit()` - Configures pre-commit hooks
- `setup_git_merge_driver()` - Sets up git merge driver for lockfiles
- `setup_environment()` - Runs all setup steps

## SessionStart Hook

The `hooks/SessionStart` script automatically runs when a new Claude Code session begins. It sources `setup-common.sh` and executes the full environment setup:

1. **Installs pixi** (if not already installed) - The package and environment manager
2. **Installs project dependencies** - All Python packages and tools defined in `pyproject.toml`
3. **Sets up pre-commit hooks** - For automatic code quality checks
4. **Configures git** - Sets up merge drivers for lockfiles

## Usage with Claude Code Online

When you start a Claude Code online session, the SessionStart hook will automatically run and set up your environment. You'll see output indicating the setup progress.

### Available Commands

Once setup is complete, Claude can use these pixi tasks:

#### Testing & Quality
- `pixi run test` - Run pytest tests
- `pixi run coverage` - Run tests with coverage report
- `pixi run lint` - Run ruff and pylint linters
- `pixi run format` - Format code with ruff

#### CI Tasks
- `pixi run ci` - Run full CI pipeline (format, lint, test, coverage)
- `pixi run fix` - Auto-fix common issues (update lock, format, lint)

#### Pre-commit
- `pixi run pre-commit` - Run all pre-commit hooks
- `pixi run pre-commit-update` - Update pre-commit hook versions

### How It Works

1. **First session**: The hook installs pixi and all dependencies (may take a few minutes)
2. **Subsequent sessions**: The hook verifies the environment is ready (much faster)
3. **Environment activated**: All pixi commands are available to Claude

### Troubleshooting

If you encounter issues:

1. **Dependencies not found**: Run `pixi install` manually
2. **Lockfile conflicts**: Run `pixi run update-lock`
3. **Pre-commit issues**: Run `pixi run pre-commit-update`
4. **Full reset**: Delete `.pixi` directory and restart session

### Customization

You can modify `hooks/SessionStart` to:
- Install additional tools
- Run custom setup scripts
- Configure environment variables
- Set up external services

## Learn More

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Pixi Documentation](https://pixi.sh)
- [Project README](../README.md)
