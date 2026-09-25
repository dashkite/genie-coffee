# Genie Coffee

*Genie Preset for compiling CoffeeScript*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Genie Coffee provides a standard preset for compiling, linting, and testing CoffeeScript projects within the Genie task runner ecosystem. It leverages Masonry to handle the asset pipeline for Node and browser environments.

## Features

- Integrates CoffeeScript compilation into the Genie task runner.
- Includes pre-configured ESLint rules and custom regex linting for CoffeeScript development.
- Features semantic LLM-driven auditing to enforce architectural DashKite guidelines.
- Supports deterministic auto-fixing of custom rule violations.
- Transposes lint diagnostics and code excerpts back to original CoffeeScript sources via source maps.
- Provides dual-mode lint reporting: interactive terminal UI and structured XML for CI and LLMs.
- Provides standard tasks for building, cleaning, linting, auditing, and testing.
- Supports distinct compilation targets for Node.js and browser environments.

## Installation

```bash
pnpm install -D @dashkite/genie-coffee
```

## Usage

Because it is published with a `genie-` prefix, Genie automatically discovers and registers this preset when installed as a `devDependency`. You do not need to manually instantiate or import it in your configuration.

Once installed, the preset automatically hooks its compilation, linting, and testing capabilities into the standard Genie lifecycle tasks. You can trigger them natively using standard CLI commands:

```bash
# Triggers coffee:build as part of the overall build pipeline
npx genie build

# Triggers coffee:lint as part of the overall lint pipeline
npx genie lint

# Triggers coffee:lint:fix to automatically resolve determinable custom rule violations
npx genie lint:fix

# Triggers coffee:audit to semantically evaluate the codebase against architectural guidelines
npx genie audit

# Triggers coffee:test as part of the test pipeline
npx genie test
```

You can also bypass the full lifecycle to run the specific CoffeeScript tasks directly:

```bash
npx genie coffee:build
npx genie coffee:lint
npx genie coffee:audit
```

## Linting

Genie Coffee includes a dedicated lint task (`coffee:lint`) defined as a hook for Genie's standard `lint` lifecycle task (`Genie.on "lint", "coffee:lint"`) rather than an alias, allowing other linters (such as for other file types or languages) to run in concert.

### Source Map Transposition

Although lint rules evaluate the compiled JavaScript output, Genie Coffee decodes the composite source map to transpose line and column numbers back to the original `.coffee` source files. Each diagnostic is paired with an excerpt of the original CoffeeScript source code where the issue occurred.

### Dual-Mode Reporting

#### Interactive Mode (Default)

When run in an interactive terminal, diagnostics are formatted for readability using cyan file headers, box-drawing characters, and severity indicators:

```text
  ◆ src/bundle.coffee
    ↳ line 10, column 1
      │ stripVersion = ( str ) ->
      │ ⚠ 'stripVersion' is assigned a value but never used.

    ↳ line 47, column 25
      │ resolveSourceDiskPath = ( root, sourceUrl, destination, moduleGraph ) ->
      │ ⚠ Async function has too many parameters (4). Maximum allowed is 3.
```

#### CI & LLM-Driven Review Mode (`CI=true`)

When running in automated CI environments or alongside LLM-driven agents (e.g. Gemini, automated code review bots), setting `CI=true` (or `NO_COLOR=1` / `TERM=dumb`) activates machine-readable output:

```bash
CI=true npx genie lint
```

In this mode, ANSI formatting and decorative glyphs are suppressed. Diagnostics are emitted as self-contained, streaming XML `<issue>` blocks with escaped code excerpts and messages:

```xml
<issue task="lint" file="src/bundle.coffee" line="10" column="1" severity="warn">
  <code>stripVersion = ( str ) -&gt;</code>
  <message>'stripVersion' is assigned a value but never used.</message>
</issue>
```

## Auditing

Genie Coffee includes a semantic audit pipeline (`coffee:audit`) designed to evaluate subjective, architectural DashKite coding guidelines that cannot be caught by regex or ESLint.

When the audit task runs, it utilizes the embedded generative language model to semantically parse the original `.coffee` files against the prompt-engineered guidelines defined in `src/helpers/audit-rules.yaml`. Just like `lint`, it operates incrementally and caches results inside `.masonry/audit` to avoid superfluous LLM evaluations on unchanged files. 

Violations are emitted using the same structured XML `issue` format as the linter, making them seamlessly consumable by Antigravity agents during Continuous Alignment loops.

## Other Resources

- [Reference](docs/reference.md)
- [Recipes](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
