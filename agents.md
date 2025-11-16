# python_template Agent Documentation

## Project Overview
This project uses **pixi** for environment management. Configuration and tasks are defined in `pyproject.toml`.

## Development Workflow

**Making Changes:**
- Implement the requested modifications
- Run `pixi run style` to format and lint the code
- Run `pixi run test` to verify tests pass
- Execute `pixi run ci` and iterate until all checks pass
- Commit only when CI passes

## Available Pixi Tasks

### Formatting and Linting
- `pixi run format` - Format code using ruff
- `pixi run ruff-lint` - Lint and auto-fix code issues with ruff
- `pixi run pylint` - Run pylint checks on all Python files
- `pixi run lint` - Run both ruff-lint and pylint
- `pixi run style` - Format and lint code (runs format + lint)

### Testing
- `pixi run test` - Run pytest tests
- `pixi run coverage` - Run tests with coverage reporting
- `pixi run coverage-report` - Display coverage report

### CI Workflow
- `pixi run ci` - Run complete CI pipeline (style + coverage + coverage-report)

### Pre-commit Hooks
- `pixi run pre-commit` - Run all pre-commit hooks
- `pixi run pre-commit-update` - Update pre-commit hook versions

### Utility Tasks
- `pixi run update-lock` - Update pixi.lock file
- `pixi run clear-pixi` - Remove .pixi directory and pixi.lock
- `pixi run setup-git-merge-driver` - Configure git merge driver for lock files
- `pixi run update-from-template-repo` - Update from the template repository

## Python Environments

The project supports multiple Python versions:
- `default` - Default environment with latest supported Python
- `py310` - Python 3.10 environment
- `py311` - Python 3.11 environment
- `py312` - Python 3.12 environment
- `py313` - Python 3.13 environment

To use a specific environment, add `-e <env>` to pixi commands:
```bash
pixi run -e py310 test
```

## Best Practices

1. **Always run CI before committing**: Use `pixi run ci` to ensure all checks pass
2. **Keep dependencies updated**: Regularly run `pixi run update-lock`
3. **Use pre-commit hooks**: Set up pre-commit hooks to catch issues early
4. **Test across Python versions**: Verify compatibility by testing with different environments
5. **Format before linting**: The `style` task runs format first, then lint
