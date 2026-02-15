# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Additional Context

Also read `AGENTS.md` for project objectives and development guidelines. It is the canonical source for design philosophy and contribution standards.

## Project Overview

Bashful is a modular Bash 4.0+ scripting framework providing RequireJS-style module loading for shell scripts. It operates at micro (single utility), medium (composed modules), and framework (full bootstrapped script) levels. All modules are `.sh` files in the root directory — there is no build step, compilation, or package manager. The framework is sourced directly into consuming scripts and automatically avoids duplicate imports.

## Testing

Run the smoke test suite covering both entry points:

```bash
bash tests/smoke_test.sh
```

## Architecture

### Two Entry Points

| Entry Point | Dispatch | Status |
|---|---|---|
| `bashful.sh` | `run()` → `route()` → JSON router | **Primary** |
| `require.sh` | `run()` → `eval_request()` → convention-based `param_*/action_*` | **Legacy** |

### Primary Entry Point (`bashful.sh`)

Bootstraps the framework and loads the JSON router. `require <module>` searches the `_PATHS[]` array and stops at the first match, allowing local overrides.

Core modules loaded automatically: `verbosity`, `config`, `router`.

**Execution flow:** `run $*` → `require help` → `route $*` → match each arg against registered JSON routes → invoke callbacks.

### Router (`router.sh`)

Commands are defined as JSON route objects registered via `route_load`. Each route has: `namespace`, `pattern`, `use`, `description`, `callback`, `visible`, `priority`. Routes can be single objects or JSON arrays.

Key functions:
- `route_load <json>` — register one or more routes
- `route_match <arg>` — find a matching route by `use` (via `json_value_search`) then confirm via pattern split on `|`
- `route <args...>` — main dispatch loop: match, invoke callback, shift consumed args, repeat
- `route_list` — dump all registered routes

Built-in routes are registered by `bashful.sh` (verbosity flags, `--fake`) and `help.sh` (`-h|--help|help`, `--list-commands`, `--namespace-commands`). Modules like `docker.sh` register their own routes at load time.

### Help System (`help.sh`)

Loaded lazily via `require help` inside `run()`. Registers help routes and provides:
- `help_usage()` — callback for `-h|--help|help`: displays `USAGE_TITLE`, script name, and all routes grouped by namespace
- `usage_list()` — renders all routes grouped by namespace
- `usage_namespace_list <ns>` — renders routes for a single namespace

### JSON Utilities (`json.sh`)

jq-based helpers used throughout the router and help system. Requires `jq` in PATH. Key functions: `json_merge_objects`, `json_get_key`, `json_set_key`, `json_get_keys`, `json_append_object`, `json_array_length`, `json_get_array_item`, `json_value_search`, `json_group_objects`. Also includes a pure-bash JSON tokenizer/parser via `parse_json`.

### Legacy Entry Point (`require.sh`)

Still functional. Uses convention-based function discovery via `utils.sh`:
- `param_<name>()` + `usage_<name>()` — parameter handlers
- `action_<name>()` + `usage_<name>()` — action handlers (one per invocation)
- `describe_<name>()` / `help_<name>()` — optional documentation

`run $*` → `eval_request` → match args against `param_*`/`action_*` functions → execute.

### Module Layers

- **Core:** `bashful.sh`, `require.sh`, `router.sh`, `utils.sh`, `config.sh`, `help.sh`
- **Data Parsing:** `json.sh`, `yaml.sh`, `ini.sh`, `csv.sh`, `base64.sh`
- **String/Array:** `string.sh`, `array.sh`, `lines.sh`
- **Display:** `colors.sh` (tput + ascii), `display.sh`, `cursor.sh`, `boxes.sh`
- **Platform:** `platform.sh` (OS/arch detection), `net.sh` (download tool detection)
- **I/O & Integration:** `filesystem.sh`, `input.sh`, `output.sh`, `docker.sh`, `aws.sh`

### Configuration System (`config.sh`)

Supports multiple formats via `load_config <format> <source>`: `bash`, `yaml`, `yaml64` (base64-encoded YAML), `ini`, `file`. Config state stored in arrays: `_CP` (params), `_CV` (values), `_CT` (types), `_CD` (descriptions).

### Verbosity (`verbosity.sh`)

Named levels (`__ERROR=0`, `__WARN=1`, `__INFO=2`, `__DEBUG=3`, `__TRACE=4`) and numeric `-v` flags. Key functions:
- `verbose <level> <msg>` / `error` / `warn` / `info` / `debug` / `trace` — conditional stderr output
- `verb <level> <cmd>` — conditional command execution
- `dump <varname>` / `dump_array` / `dump_method` — variable/call inspection

### Key Global Variables

- `_V` — current verbosity level (integer)
- `__ACTIVE_ROUTES` — JSON string holding all registered routes
- `_FAKE` — dry-run flag
- `_BV` — Bash major version
- `_LIB_DIR` / `_SCRIPT_PATH` — module search paths
- `_PATHS[]` — extensible module search path array (`bashful.sh`)
- `USAGE_TITLE` — header title for generated help output

## Code Style

- Prioritize readability without eclipsing performance or security
- The framework is an extensible base layer — design modules so consuming projects can build on top of them
- Prefer pure Bash and standard Unix utilities; `jq` is the sole external dependency (bundled in `json/jq/`)

## Version Control Conventions

- Semantic release compatible commit messages with consistent scopes
- Small, atomic commits with explanatory (not just descriptive) messages
- Use worktrees for branch work; pull requests for merges
- Branches: `master` (main), `develop`
