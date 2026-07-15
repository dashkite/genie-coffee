# Genie Coffee

*Genie Preset for compiling CoffeeScript*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Genie Coffee provides a standard preset for compiling, linting, and testing CoffeeScript projects within the Genie task runner ecosystem. It leverages Masonry to handle the asset pipeline for Node and browser environments.

## Features

- Integrates CoffeeScript compilation into the Genie task runner.
- Includes pre-configured ESLint rules for CoffeeScript development.
- Provides standard tasks for building, cleaning, linting, and testing.
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

# Triggers coffee:test as part of the test pipeline
npx genie test
```

You can also bypass the full lifecycle to run the specific CoffeeScript tasks directly:

```bash
npx genie coffee:build
npx genie coffee:lint
```

## Other Resources

- [Reference](docs/reference.md)
- [Recipes](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
