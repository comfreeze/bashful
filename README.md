#BASHFUL v0.1

##Synopsis

A collection of various scripting hacks used over time to consolidate and provide a simple framework for future scripting.

##Inspiration/Goals

* Provide modular collection, easily loaded from a single entry point
  * fashion loading after `requirejs` or similar
* Capture scripting used in the past into atomic functions
* Deliver a uniform bootstrapping syntax

##Implementation

The base directory contains elements that demonstrate existing integrations of the principles.  These are generally
 useful tools, but are primarily here to demonstrate integration.

Primary entry point:
```
source $( dirname -- "$0" )/require.sh $*
```
This code assumes the script called is in the parent directory to the require collection.  This can be changed, but is
 convenient for local relativity out-of-the-box.

Loading libraries:
```
require array
require string
```
The above loads to modules from the require collection; `array` and `string`, each of which house utilities for 
interacting with their self-titled entities.

Documentation assistant:
```
require help $*
```
This code is optional and run by the execution workflow, but can be called out of sequence to generate help in any workflow. 

Execution
```
run $*
```
Calling `run $*` should be the last (or one of) that your script calls and will kicks off all the other setup 

##Bootstrapping

The framework provides several helpers to get a new script started fast.  Typically we define the configuration variables at the top level for quick reference:

```
#
# CONFIG
###################
USAGE_TITLE="SSH Toolkit"
```

`USAGE_TITLE` is actually a special value that allows definition of the help header title.  Whatever text is provided in this variable will appear in all help out.

Include the basic require include logic:

```
#
# USE REQUIRE
###################
source $( dirname -- "$0" )/require.sh $*
```

NOTE: the `$*` ensure the current script passes all it's parameters into the require framework.  This allows the require framework to work on parameters behind the scenes.  It can also be used to customize how require sees it's operating environment by manually injecting or controlling values in this set.

Typically this is followed by the definition of any global use libraries:

```
#
# LIBRARIES
###################
require verbosity $*
require array
require string
```

Three example demonstrate 1 parameter supporting library and 2 plain libraries with no parameters.  Most libraries should expose their own configuration methods if requiring interaction, but some libraries also will need access to additional data not explicit in the environment and can be provided as subsequent options.

Most scripts will have various option flags available to them, and adding them only requires following a few simple guidelines for the framework to assist.

```
#
# PARAMETERS
###################
# Anonymity
param_anonymous ()      { dump_method "$@"; apply_options COMMANDS "${ANON_HOST}"; }
usage_anonymous ()      { echo "-a|--anonymous"; }
describe_anonymous ()   { echo "Support anonymous hosts, ignore host checks."; }
help_anonymous ()       { cat << EOF

Description:
  $( describe_anonymous )  Applies any options stored in ANON_HOST, currently:

    ${ANON_HOST}

EOF
}
```

Four functions are defined above, each sharing a common suffix and using pre-defined prefix naming.  `param_*` defines a parameter logic, but alone is not accessible.  `usage_*` defines how to utilize the defined parameter, first applicable flags, ie. `-a` or `--anonymous` and then any applicable subsequent data fields.  `describe_*` provides a one line description of the parameter.  `help_*` provides a more complex help explanation of the parameter.

Using these 4 types, we define a parameter named `anonymous` above.  The framework will automatically be able to generate help documentation and integrate the flags throughout the script with all 4 provided.  The minimum require is `param_*` and `usage_*` while the others are optional expansions.

Similar, but distinctly different in one particular way, are actions.  Where you may provide multiple parameters in a given call, each run expect only a single action target.  Once an action is matched, it will run and terminate.

```
#
# ACTION
###################
# Define a new Host Record
action_add_host ()      { echo "COMING SOON"; }
usage_add_host ()       { echo "a|add|add_host ${_REF_FORMAT}"; }
describe_add_host ()    { echo "Define a new host record"; }
help_add_host ()        { cat << EOF

Description:
  $( describe_add_host )  Guided tools for creating ssh config records.
EOF
}
```

Again, in similar definition format, `usage_*`, `describe_*` and `help_*` provide the same features as with parameters.  Instead of `param_*` prefix, this is given an `action_*` prefix.  This separates it and indicates its and executable sub-routine instead of configuration helper.  Otherwise, actions and parameters are roughly indistinquishable in logical behavior.

Finally, to allow the framework to process all the defined logic, execute the default workflow:

```
#
# EXECUTION
###################
run $*
```

##Debugging

Another feature of the framework is including some debugging tooling that assists with some common issues in scripting.

###Dump

To examine a variable (e.g. $TEST), use the `dump` helper.

```
TEST="Test is a value"
dump TEST
```

It expects only the name of the target as a parameter and will extract the actual value.  Dump currently only supports a single target at a time.

###Dump Array

There are a couple array dumping utilities available, each presents a different type of output, which may be combined into an adapter front-end at a later date.

```
TEST=( "this is" "orange" "peacock" )
dump_array TEST
dump_array_pretty TEST
dump_assoc_array TEST
```

The `dump_assoc_array` is not Bash 4 associative array, but combined key=value string serialized packed array data.

###Dump Method

When analyzing a script, it's often useful to trace the logical structure, often seen as a stack trace.  While stack trace is pending, the `dump_method` helper does provide a simple means to echo current process details for histrionics.

```
my_method() {
  dump_method "$@"
  echo "this is stuff stuff"
  dump_method "$@"
}
```

By default, dump_method will only print the current function name, file and line.  If passed additional parameters, it assumes these are the parameters for the call and appends them to the printed output string.

##Verbosity

The verbosity library allows definition of up to 6 verbosity levels by default (`-v`...`-vvvvvv`).

###Verbose

To help echo output that's only applicable during certain log-levels, use the `verbose` command instead.  This outputs to `stderr` instead of `stdout` so it doesn't clobber other output (can be configured) and looks for a global verbosity level before output is sent and ignores if level is not high enough.

```
verbose 0 "This will always show"
verbose 2 "This will show only if more than -vv used"
verbose 6 "This is currently the max tested/used level, -vvvvvv"
```

####Verbosef

This is an extension of `verbose` but uses `printf` formatting as the first parameter and all other parameters as content fields.

###Verboses

This is a helper to output the current verbosity level as various strings, ie. the original -vvvvvvv or -v3, etc.

###Verb

Similar to `verbose`, `verb` only runs the provided parameter logic if the given verbosity level is high enough.

```
verb 3 "echo something would be printed if using -vvv now"
```

A poor example but demonstrates the logic without requiring further context.  Alternative uses could be for triggering different jobs or variable targets based on verbosity, ie. `-vv` or greater is `dev`, `-v` is staging, and no `-v` is production/qa.  This proves difficult to maintain but is another example of potential uses.  The framework currently uses it for detecting and appending various tracing information throughout runtime. 
