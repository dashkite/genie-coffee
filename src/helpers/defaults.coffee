defaults =
  targets:
    node: [
      glob: [
        "src/**/*.coffee"
        "test/**/*.coffee"
      ]
    ]
    browser: [
      {
        glob: [
          "src/**/*.coffee"
          "test/client/**/*.coffee"
        ]
      }
      {
        preset: "node"
        glob: [
          "test/**/*.coffee"
          "!test/client/**/*.coffee"
        ]
      }
    ]

export default defaults