# Agent Build Instructions - python_template

## Project Setup
```bash
# This project uses Pixi for dependency management
# Pixi automatically handles environment setup

# Install dependencies (handled automatically by pixi)
pixi install
```

## Running Tests
```bash
# Quick test run
pixi run test

# Test with coverage
pixi run coverage

# View coverage report
pixi run coverage-report

# Run tests on specific Python version
pixi run -e py310 test
pixi run -e py311 test
pixi run -e py312 test
pixi run -e py313 test
```

## Code Quality
```bash
# Format code
pixi run format

# Lint code
pixi run ruff-lint

# Run PyLint
pixi run pylint

# Type checking
pixi run ty

# All linting checks
pixi run lint

# Format + Lint combined
pixi run style
```

## Build Commands
```bash
# Full CI pipeline (format, lint, test, coverage)
pixi run ci

# CI without coverage
pixi run ci-no-cover

# Auto-fix issues (update lockfile, format, lint, pre-commit)
pixi run fix

# Fix and commit
pixi run fix-commit-push
```

## Pre-commit Hooks
```bash
# Run pre-commit checks
pixi run pre-commit

# Update pre-commit configs
pixi run pre-commit-update
```

## Development Server
```bash
# Start DevPod SSH environment
pixi run dev

# Start with VSCode
pixi run dev-vs

# Restart DevPod
pixi run dev-restart
```

## Running Examples
```bash
# Run the example directly
python example/example.py
```

## Key Learnings
- Use `pixi run ci` as the primary validation command
- The project supports Python 3.10-3.13
- Ruff handles both formatting and linting
- Coverage reports exclude test files and `__init__.py`

## Project Structure
```
python_template/          # Main package
  __init__.py
  basic_class.py         # Example dataclass
test/                    # Pytest tests
  test_basic.py
example/                 # Usage examples
  example.py
docs/                    # Sphinx documentation
```

## Feature Development Quality Standards

### Testing Requirements
- Minimum 85% code coverage for new code
- 100% test pass rate required
- Use pytest for unit tests
- Use Hypothesis for property-based testing
- Run `pixi run coverage` to validate coverage

### Git Workflow
1. Work on feature branches (`feature/<name>`)
2. Use conventional commits (`feat:`, `fix:`, `docs:`, etc.)
3. Run `pixi run ci` before committing
4. Push changes and create PR

### Feature Completion Checklist
- [ ] All tests pass (`pixi run test`)
- [ ] Coverage meets threshold (`pixi run coverage`)
- [ ] Code formatted (`pixi run format`)
- [ ] Linting passes (`pixi run lint`)
- [ ] Changes committed with clear message
- [ ] @fix_plan.md updated
