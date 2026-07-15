# Technical Notes

### Genie Presets and the Task Runner

The `@dashkite/genie-coffee` package is designed as a **Genie Preset**. In the Genie task runner ecosystem, presets act as highly cohesive, modular plugins that encapsulate configuration, dependencies, and complex task orchestration. Rather than expecting developers to manually wire together transpilers, linters, and testing frameworks in every project, a preset bundles these capabilities into a single, importable unit. 

When a developer initializes the preset within their `genie.yml` or Genie script, the preset automatically extends the environment with its specific task logic. This architectural approach promotes immense reusability and ensures that build logic remains consistent across the entire software portfolio.

### Lifecycle Composition

A key convention within the Genie ecosystem is that domain-specific tools register their specialized tasks as dependencies of generalized, higher-level lifecycle tasks. 

For instance, this preset registers the specific `coffee:build` task with the generalized `build` task. Similarly, it registers the `coffee:test` command with the higher-level `test` command.

This convention enables deep composition. A single project might utilize multiple presets simultaneously. You could imagine a web application where the `genie-coffee` preset compiles CoffeeScript into JavaScript, a Pug preset compiles templates into HTML, and a YAML preset compiles configurations into JSON. Because each preset registers its specialized build tasks to the generalized `build` command, invoking `npx genie build` orchestrates the entire complex transpilation pipeline seamlessly, without the developer needing to coordinate the individual compilers. Likewise, invoking `npx genie test` will execute tests from any preset that registered to the `test` lifecycle.

### Masonry pipelines

The preset relies on Masonry (`@dashkite/masonry`) to create the underlying asset compilation pipelines. Masonry provides a declarative way to define asset transformations, such as reading files from disk, running the CoffeeScript transpiler via `@dashkite/masonry-coffee`, and intelligently changing file extensions.

### Target configurations

Target configurations are resolved via `@dashkite/masonry-targets`. The default configuration supports both Node.js and browser targets out-of-the-box, providing necessary isolation between client-side assets and standard Node modules or tests.

### ESLint configuration

The embedded linting task invokes a custom ESLint configuration carefully tailored for CoffeeScript development. It intentionally suppresses certain rules, like `max-lines`, because the transpilation process can occasionally generate disproportionately lengthy output from otherwise concise source files. Similarly, structural idioms in CoffeeScript—like mixins and classes—can cause inflated token counts in the generated JavaScript, necessitating these adjusted linting thresholds.
