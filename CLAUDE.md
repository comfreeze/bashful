# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Additional Context

Also read `AGENTS.md` for project objectives and development guidelines. It is the canonical source for design philosophy and contribution standards.

## Project Overview

Bashful is a modular Bash 4.0+ scripting framework providing RequireJS-style module loading for shell scripts. It operates at micro (single utility), medium (composed modules), and framework (full bootstrapped script) levels. All modules are `.sh` files in the root directory — there is no build step, compilation, or package manager. The framework is sourced directly into consuming scripts and automatically avoids duplicate imports.

## No Build/Test System

There is no formal build, lint, or test runner. The `test.sh` file is a stub. To verify changes, source modules manually in a Bash 4+ shell:

```bash
source require.sh
```

## Architecture

### Module Loader (`require.sh`)

The central entry point. `require <module>` sources `<module>.sh` from two locations in order:
1. Library directory (`_LIB_DIR`) — the bashful repo root
2. Script directory (`_SCRIPT_PATH`) — allows local overrides

Core modules loaded automatically by `require.sh`: `verbosity`, `output`, `utils`, `filesystem`, `config`.

### Convention-Based Function Discovery

The framework discovers functionality through naming conventions. Scripts define groups of functions sharing a suffix:

- `param_<name>()` — parameter handler (flag logic)
- `action_<name>()` — action handler (subcommand logic, only one runs per invocation)
- `usage_<name>()` — returns usage string (e.g., `-a|--anonymous`)
- `describe_<name>()` — one-line description
- `help_<name>()` — detailed help text

Minimum required: `param_*`/`action_*` + `usage_*`. The others are optional.

### Execution Flow

`run $*` triggers: help generation → `eval_request` (parse args) → match params → match single action → execute action and terminate.

### Module Layers

- **Core:** `require.sh`, `utils.sh`, `config.sh`, `params.sh`, `actions.sh`, `help.sh`
- **Data Parsing:** `json.sh`, `yaml.sh`, `ini.sh`, `base64.sh`
- **String/Array:** `string.sh`, `array.sh`, `lines.sh`
- **Display:** `colors.sh` (tput-based), `display.sh`, `cursor.sh`, `boxes.sh`
- **I/O & Integration:** `filesystem.sh`, `input.sh`, `docker.sh`, `aws.sh`

### Configuration System (`config.sh`)

Supports multiple formats via `load_config <format> <source>`: `bash`, `yaml`, `yaml64` (base64-encoded YAML), `ini`, `file`. Config state stored in arrays: `_CP` (params), `_CV` (values), `_CT` (types), `_CD` (descriptions).

### Verbosity (`verbosity.sh`)

Six levels via `-v` through `-vvvvvv`. Key functions:
- `verbose <level> <msg>` — conditional stderr output
- `verb <level> <cmd>` — conditional command execution
- `dump <varname>` / `dump_array` / `dump_method` — variable/call inspection
- Level 5+ enables `set -ex` shell debugging

### Key Global Variables

- `_V` — current verbosity level (integer)
- `_FAKE` — dry-run flag
- `_BV` — Bash major version
- `_LIB_DIR` / `_SCRIPT_PATH` — module search paths
- `_PREFIX_PARAM` / `_PREFIX_ACTION` / `_PREFIX_DESCRIPTION` — function prefix constants
- `USAGE_TITLE` — header title for generated help output

## Code Style

- Prioritize readability without eclipsing performance or security
- The framework is an extensible base layer — design modules so consuming projects can build on top of them
- Prefer pure Bash and standard Unix utilities; no external package dependencies

## Version Control Conventions

- Semantic release compatible commit messages with consistent scopes
- Small, atomic commits with explanatory (not just descriptive) messages
- Use worktrees for branch work; pull requests for merges
- Branches: `master` (main), `develop`
