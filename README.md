# BASHFUL v0.1

## Synopsis

A collection of various scripting hacks used over time to consolidate and provide a simple framework for future scripting.

## Inspiration/Goals

* Provide modular collection, easily loaded from a single entry point
  * fashion loading after `requirejs` or similar
* Capture scripting used in the past into atomic functions
* Deliver a uniform bootstrapping syntax

## Implementation

The base directory contains elements that demonstrate existing integrations of the principles.  These are generally useful tools, but are primarily here to demonstrate integration.

The framework provides two entry points:

* **`bashful.sh`** - The primary entry point.  Uses a JSON-based router for command dispatch, with structured route definitions supporting namespaces, pattern matching, callbacks, and priorities.
* **`require.sh`** - The legacy entry point.  Uses convention-based function discovery (`param_*/action_*`) for command dispatch.  Still functional for scripts that rely on the original pattern.

### Entry Point: bashful.sh

Primary entry point:
```
source $( dirname -- "$0" )/bashful.sh $*
```
This code assumes the script called is in the parent directory to the bashful collection.  This can be changed, but is convenient for local relativity out-of-the-box.

NOTE: the `$*` ensures the current script passes all its parameters into the framework.  This allows the framework to work on parameters behind the scenes.

Loading libraries:
```
require array
require string
```
The above loads modules from the collection; `array` and `string`, each of which house utilities for interacting with their self-titled entities.

The `require` function searches an extensible `_PATHS` array and stops at the first match, allowing local overrides of shared library modules.

Execution:
```
run $*
```
Calling `run $*` should be the last call in your script.  It loads the help system and dispatches all arguments through the router.

### Route Definitions

Commands are defined as JSON route objects registered via `route_load`.  Each route specifies a namespace, usage pattern, description, callback function, and priority.

```
#
# ROUTES
###################
route_load "$(cat <<ROUTE
{
  "namespace": "myapp",
  "use": "-a|--add|add",
  "description": "Add a new record.",
  "callback": "action_add",
  "priority": 100
}
ROUTE
)"
```

Multiple routes can be registered at once using a JSON array:

```
route_load "$(cat <<ROUTE
[
  {
    "namespace": "myapp",
    "use": "-l|--list|list",
    "description": "List all records.",
    "callback": "action_list",
    "priority": 100
  },
  {
    "namespace": "myapp",
    "use": "-d|--delete|delete",
    "description": "Delete a record.",
    "callback": "action_delete",
    "priority": 100
  }
]
ROUTE
)"
```

Route fields:

| Field | Description |
|---|---|
| `namespace` | Grouping label for help display (e.g. `"myapp"`, `"verbosity"`) |
| `pattern` | Glob pattern for matching (defaults to `use` value if omitted) |
| `use` | Pipe-separated usage triggers shown in help (e.g. `"-l\|--list\|list"`) |
| `description` | One-line description shown in help output |
| `callback` | Function name to invoke when the route matches |
| `visible` | Whether to show in help listings (default `"true"`) |
| `priority` | Numeric priority for route ordering (lower = higher priority) |

Built-in routes are registered automatically for help (`-h|--help|help`, `--list-commands`, `--namespace-commands`), verbosity (`-v` flags, `--error`, `--warn`, `--info`, `--debug`, `--trace`), and command faking (`-f|--fake`).

Modules can register their own routes at load time.  For example, `docker.sh` registers `--use-docker`, `--docker`, and `--compose` routes when loaded.

## Bootstrapping

The framework provides several helpers to get a new script started fast.  Typically we define the configuration variables at the top level for quick reference:

```
#
# CONFIG
###################
USAGE_TITLE="SSH Toolkit"
```

`USAGE_TITLE` is a special value that defines the help header title.  Whatever text is provided in this variable will appear in all help output.

Include the entry point:

```
#
# USE BASHFUL
###################
source $( dirname -- "$0" )/bashful.sh $*
```

Load any additional libraries:

```
#
# LIBRARIES
###################
require array
require string
```

Define your commands as route callbacks and register them:

```
#
# COMMANDS
###################
action_add ()   { echo "Adding record: $1"; }
action_list ()  { echo "Listing records"; }

route_load "$(cat <<ROUTE
[
  {
    "namespace": "records",
    "use": "a|add",
    "description": "Add a new record.",
    "callback": "action_add",
    "priority": 100
  },
  {
    "namespace": "records",
    "use": "l|list",
    "description": "List all records.",
    "callback": "action_list",
    "priority": 100
  }
]
ROUTE
)"
```

Finally, execute the framework:

```
#
# EXECUTION
###################
run $*
```

Running this script with `--help` will display:

```
 SSH Toolkit

 myscript.sh [options] [command] [parameters]

 bashful:
 USE                                 | DESCRIPTION
================================================================================
 -f|--fake                           | Replace commands with echo equivalents to output what would be run.

 help:
 USE                                 | DESCRIPTION
================================================================================
 -h|--help|help                      | Display help
 --list-commands                     | Display all registered command usage.
 --namespace-commands (namespace)    | Display all registered command usage.

 records:
 USE                                 | DESCRIPTION
================================================================================
 a|add                               | Add a new record.
 l|list                              | List all records.

 verbosity:
 USE                                 | DESCRIPTION
================================================================================
 -v|-vv|-vvv|-vvvv                   | Support various verbosity level specification.
 --error                             | Set verbosity to error explicitly.
 ...
```

## Legacy Entry Point: require.sh

The original `require.sh` entry point is still available for scripts that use the convention-based `param_*/action_*` pattern:

```
source $( dirname -- "$0" )/require.sh $*
```

This path uses `eval_request` to discover commands by function naming convention.  Parameters are defined with a `param_` prefix and actions with an `action_` prefix, each paired with `usage_`, `describe_`, and `help_` functions sharing the same suffix:

```
param_anonymous ()      { apply_options COMMANDS "${ANON_HOST}"; }
usage_anonymous ()      { echo "-a|--anonymous"; }
describe_anonymous ()   { echo "Support anonymous hosts, ignore host checks."; }

action_add_host ()      { echo "COMING SOON"; }
usage_add_host ()       { echo "a|add|add_host"; }
describe_add_host ()    { echo "Define a new host record"; }
```

The minimum required is `param_*`/`action_*` + `usage_*`.  The `describe_*` and `help_*` functions are optional.

Where you may provide multiple parameters in a given call, each run expects only a single action target.  Once an action is matched, it will run and terminate.

## Debugging

The framework includes debugging tooling that assists with common issues in scripting.

### Dump

To examine a variable (e.g. $TEST), use the `dump` helper.

```
TEST="Test is a value"
dump TEST
```

It expects only the name of the target as a parameter and will extract the actual value.  Dump currently only supports a single target at a time.

### Dump Array

There are a couple array dumping utilities available, each presents a different type of output, which may be combined into an adapter front-end at a later date.

```
TEST=( "this is" "orange" "peacock" )
dump_array TEST
dump_array_pretty TEST
dump_assoc_array TEST
```

The `dump_assoc_array` is not Bash 4 associative array, but combined key=value string serialized packed array data.

### Dump Method

When analyzing a script, it's often useful to trace the logical structure, often seen as a stack trace.  While stack trace is pending, the `dump_method` helper does provide a simple means to echo current process details for histrionics.

```
my_method() {
  dump_method "$@"
  echo "this is stuff stuff"
  dump_method "$@"
}
```

By default, dump_method will only print the current function name, file and line.  If passed additional parameters, it assumes these are the parameters for the call and appends them to the printed output string.

## Verbosity

The framework supports both numeric levels via `-v` flags and named levels via long options.

### Numeric Levels

Up to 6 verbosity levels via `-v` through `-vvvvvv`:

```
verbose 0 "This will always show"
verbose 2 "This will show only if more than -vv used"
verbose 6 "This is currently the max tested/used level, -vvvvvv"
```

### Named Levels

When using `bashful.sh`, named verbosity levels are available as route-based flags:

| Flag | Level | Constant |
|---|---|---|
| `--error` | 0 | `__ERROR` |
| `--warn` | 1 | `__WARN` |
| `--info` | 2 | `__INFO` |
| `--debug` | 3 | `__DEBUG` |
| `--trace` | 4 | `__TRACE` |

Named level helpers are also available in code:

```
error "Something failed"
warn  "Something unexpected"
info  "Processing item"
debug "Variable state"
trace "Entering function"
```

### Verbose

To help echo output that's only applicable during certain log-levels, use the `verbose` command instead.  This outputs to `stderr` instead of `stdout` so it doesn't clobber other output and looks for a global verbosity level before output is sent.

### Verbosef

This is an extension of `verbose` but uses `printf` formatting as the first parameter and all other parameters as content fields.

### Verboses

This is a helper to output the current verbosity level as various strings, ie. the original -vvvvvvv or -v3, etc.

### Verb

Similar to `verbose`, `verb` only runs the provided parameter logic if the given verbosity level is high enough.

```
verb 3 "echo something would be printed if using -vvv now"
```
