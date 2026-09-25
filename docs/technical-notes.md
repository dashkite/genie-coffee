# Technical Notes

### Genie Presets and the Task Runner

The `@dashkite/genie-coffee` package is designed as a **Genie Preset**. In the Genie task runner ecosystem, presets act as highly cohesive, modular plugins that encapsulate configuration, dependencies, and complex task orchestration. Rather than expecting developers to manually wire together transpilers, linters, and testing frameworks in every project, a preset bundles these capabilities into a single, importable unit. 

When a developer initializes the preset within their `genie.yml` or Genie script, the preset automatically extends the environment with its specific task logic. This architectural approach promotes immense reusability and ensures that build logic remains consistent across the entire software portfolio.

### Lifecycle Composition

A key convention within the Genie ecosystem is that domain-specific tools register their specialized tasks as dependencies of generalized, higher-level lifecycle tasks. 

For instance, this preset registers the specific `coffee:build` task with the generalized `build` task. Similarly, it hooks `coffee:lint` into the higher-level `lint` lifecycle task (`Genie.on "lint", "coffee:lint"`), allowing multiple linters to run in concert, and registers the `coffee:test` command with the higher-level `test` command.

This convention enables deep composition. A single project might utilize multiple presets simultaneously. You could imagine a web application where the `genie-coffee` preset compiles CoffeeScript into JavaScript, a Pug preset compiles templates into HTML, and a YAML preset compiles configurations into JSON. Because each preset registers its specialized build tasks to the generalized `build` command, invoking `npx genie build` orchestrates the entire complex transpilation pipeline seamlessly, without the developer needing to coordinate the individual compilers. Likewise, invoking `npx genie test` will execute tests from any preset that registered to the `test` lifecycle.

### Masonry pipelines

The preset relies on Masonry (`@dashkite/masonry`) to create the underlying asset compilation pipelines. Masonry provides a declarative way to define asset transformations, such as reading files from disk, running the CoffeeScript transpiler via `@dashkite/masonry-coffee`, and intelligently changing file extensions.

### Target configurations

Target configurations are resolved via `@dashkite/masonry-targets`. The default configuration supports both Node.js and browser targets out-of-the-box, providing necessary isolation between client-side assets and standard Node modules or tests.

### ESLint configuration

The embedded linting task invokes a custom ESLint configuration carefully tailored for CoffeeScript development. It intentionally suppresses certain rules, like `max-lines`, because the transpilation process can occasionally generate disproportionately lengthy output from otherwise concise source files. Similarly, structural idioms in CoffeeScript—like mixins and classes—can cause inflated token counts in the generated JavaScript, necessitating these adjusted linting thresholds.

### Custom Lint Rules

To enforce syntactic DashKite coding guidelines that cannot be easily caught by standard ESLint parsers (which analyze the generated JavaScript AST), `genie-coffee` utilizes a custom regex-based linting engine. Rules are defined in `src/helpers/lint-rules.yaml`.

When adding a new syntactic rule, define the following fields:
- `id`: A unique, kebab-case identifier for the rule (e.g., `single-quotes`).
- `pattern`: The regex pattern to match violations against the raw CoffeeScript source.
- `message`: The descriptive warning message to output.
- `severity`: Standard ESLint severity mapping (1 for warning, 2 for error).
- `fix` (optional): If the violation can be deterministically resolved, provide a string replacement pattern (e.g., `"$1 ("`) or an object map mapping captured tokens to their replacements.
- `negative_lookahead` (optional): Additional regex exclusions to prevent false positives.
- `strip` (optional): A boolean indicating whether to strip comments/strings before evaluating the regex.

### Semantic Audit Rules

For subjective or complex structural DashKite coding guidelines that cannot be deterministically caught by regex (e.g., "avoid superfluous defensive checks"), `genie-coffee` implements a semantic auditing phase powered by a generative language model.

To instruct the agent to evaluate the codebase against new architectural guidelines, add a rule to `src/helpers/audit-rules.yaml`. Each rule requires only:
- `title`: A succinct name for the guideline.
- `description`: A thorough, prompt-engineered explanation of the anti-pattern, including context on why it violates the guidelines and what valid alternatives look like.
