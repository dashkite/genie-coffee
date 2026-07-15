# Testing

The testing approach for `@dashkite/genie-coffee` leverages `@dashkite/amen` and `@dashkite/amen-console` to ensure the preset initializes correctly without errors.

The primary test suite focuses on importing the package and verifying its default export is accessible. Because this library orchestrates other build tools, extensive unit testing of individual functions is deferred in favor of integration validation within the Genie pipeline.

To execute the tests for the preset itself, you invoke the internal test script:

```bash
pnpm run test
```

Which executes `scripts/test` under the hood.

However, an important capability of the preset is that it registers a `coffee:test` task and binds it to the higher-level Genie `test` lifecycle hook. This means that for any project consuming the `genie-coffee` preset, developers can trigger their compiled test suites using the standard command:

```bash
npx genie test
```

When invoked in a consumer project, Genie runs the `coffee:test` task, which typically executes the compiled test file at `build/node/test/index.js` using Node.js with source map support enabled.
