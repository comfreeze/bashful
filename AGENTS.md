# Bashful — Development Guidelines

## Design Objectives

- Modular Bash toolkit supporting micro, medium, and framework-level sourcing
- Automatic multi-import conflict avoidance via load tracking
- Small utility scripts compose into larger ones
- Extensible base layer: consuming projects build on top to expose complex yet intuitive tooling

## Code Style

- Readability matters but must not eclipse performance or security
- Pure Bash 4.0+ with standard Unix utilities; no external package dependencies
- Follow existing naming conventions (`param_*`, `action_*`, `usage_*`, `describe_*`, `help_*`)

## Version Control

- Use `git` for all changes
- Use worktrees for branch work; pull requests for merge approval
- Semantic release compatible commit messages with consistent scopes (document scopes in README.md)
- Small, atomic commits with explanatory messages — describe *why*, not just *what*
