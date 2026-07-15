# Recipes

## Framing a Genie preset

A Genie preset operates as a composable plugin for the Genie task manager. Instead of writing build and orchestration logic from scratch, creators can plug a preset directly into their Genie environment. The CoffeeScript preset automatically binds its specialized tasks—like compiling, linting, and testing—to the standard lifecycle events of the Genie build process. This integration ensures that when a developer invokes a generic build command, the CoffeeScript transpilation happens reliably in the background without requiring additional orchestration.

## Executing CLI tasks for CoffeeScript

When developers initialize this preset, it automatically registers the underlying `coffee:build` transpilation step with the higher-level Genie `build` command, and the `coffee:test` execution step with the higher-level `test` command. This ensures that CoffeeScript compilation and testing occur seamlessly as part of standard development workflows.

To execute the standard build pipeline:

```bash
npx genie build
```

To execute the standard test pipeline:

```bash
npx genie test
```

The preset also registers its specific tasks independently, giving creators the ability to transpile CoffeeScript code at will, bypassing the full lifecycle when they only want to compile their scripts.

To run the specific CoffeeScript build command directly:

```bash
npx genie coffee:build
```

You can also run the linter independently to quickly verify your syntax:

```bash
npx genie coffee:lint
```

## Using the CoffeeScript preset

This task sets up the standard CoffeeScript preset in a new or existing Genie configuration file.

The preset defines compilation, linting, and testing tasks, attaching them to standard Genie lifecycle hooks like `build`, `test`, and `lint`. By passing the `Genie` instance to the preset function, the environment instantly inherits all the CoffeeScript tooling capabilities.

```coffeescript
import Genie from "@dashkite/genie"
import coffee from "@dashkite/genie-coffee"

# Initialize the preset
coffee Genie
```

## Configuring custom targets via YAML

You can configure the files included in the CoffeeScript build process by defining custom targets in your Genie configuration using YAML. This approach separates your configuration data from your task logic, keeping your environment clean.

By default, the preset looks for source files in `src/**/*.coffee` and test files in `test/**/*.coffee`. You can override this behavior by declaring the `coffee` options in a `genie.yml` file. Genie automatically merges this file into its internal configuration state.

```yaml
# genie.yml
coffee:
  targets:
    node:
      - glob:
          - "app/**/*.coffee"
          - "spec/**/*.coffee"
```

## Configuring custom targets programmatically

For scenarios where dynamic configuration is necessary, developers can construct custom targets directly within the Genie script. The preset reads from the `coffee` key in the Genie state when initializing the target options.

You can set these options using `Genie.set` before invoking the preset initializer.

```coffeescript
import Genie from "@dashkite/genie"
import coffee from "@dashkite/genie-coffee"

# Define custom target options programmatically
Genie.set "coffee",
  targets:
    node: [
      glob: [
        "app/**/*.coffee"
        "spec/**/*.coffee"
      ]
    ]

# Initialize the preset
coffee Genie
```
