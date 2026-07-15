# Reference

## Module Exports

### `default`

The default export is an initializer function that configures Genie tasks for CoffeeScript projects.

$\text{default}(Genie: \text{object}) \rightarrow \text{void}$

The initializer reads the target configuration from options, and defines specific build, clean, lint, and test tasks on the provided Genie instance.

### `Options.get`

Retrieves configuration options for the CoffeeScript preset.

$\text{get}(Genie: \text{object}) \rightarrow \text{object}$

Merges default options with any options specified in `Genie.get("coffee")`.

## Genie Tasks

The initialization function registers the following commands with the Genie task manager. These are invoked via the Genie CLI rather than as standard JavaScript module functions.

### `coffee:build`

Builds the CoffeeScript source files according to the defined targets. It transpiles CoffeeScript to JavaScript. 

This task is automatically registered to run whenever the higher-level Genie `build` command is invoked, ensuring CoffeeScript transpilation is a native part of the standard build lifecycle.

### `coffee`

An alias for the `coffee:build` task.

### `coffee:clean`

An alias for the `clean` task.

### `coffee:lint`

Lints the CoffeeScript source files using ESLint. The rules are pre-configured to handle common CoffeeScript output patterns gracefully. This task is automatically registered to run with the higher-level Genie `lint` command.

### `coffee:test`

Runs tests using the compiled output in `build/node/test/index.js` if it exists. Sets standard Node.js flags for source maps and trace warnings. This task is automatically registered to run with the higher-level Genie `test` command.
