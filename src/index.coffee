import M from "@dashkite/masonry"
import coffee from "@dashkite/masonry-coffee"
import T from "@dashkite/masonry-targets"
import { rm, sh } from "./helpers"

defaults =
  targets:
    node: [
      glob: [
        "src/**/*.coffee"
        "test/**/*.coffee"
      ]
    ]
    browser: [
      glob: [
        "src/**/*.coffee"
        "test/**/*.coffee"
      ]
    ]

expand = ( targets ) ->
  result = {}
  for target in targets
    result[ target ] = defaults.targets[ target ]
  result

export default ( Genie ) ->
  
  options = { defaults..., ( Genie.get "coffee" )... }

  if Array.isArray options.targets
    options.targets = expand options.targets
  
  Genie.define "coffee", "coffee:clean", M.start [
    T.glob options.targets
    M.read
    M.tr coffee
    M.extension ".js"
    T.write "build/${ build.target }"
  ]

  Genie.define "coffee:clean", -> rm "build"
  Genie.on "clean", "coffee:clean"

  Genie.on "build", "coffee"

  # TODO separate this into separate preset?

  if options.targets.node?
    Genie.define "node:test", "build", ->
      sh "node
        --enable-source-maps
        --trace-warnings
        --unhandled-rejections=strict
        build/node/test/index.js"

    Genie.on "test", "node:test"

  Genie.define "coffee:watch", ->
    W = await import( "@dashkite/masonry-watch" )
    do M.start [
      W.glob options.targets
      W.match type: "file", name: [ "add", "change" ], [
        M.read
        M.tr coffee
        M.extension ".js"
        T.write "build/${ build.target }"
      ]
      W.match type: "file", name: "rm", [
        M.extension ".js"
        T.rm "build/${ build.target }"
      ]
      W.match type: "directory", name: "rm", 
        T.rm "build/${ build.target }"        
    ]

  Genie.on "watch", "coffee:watch&"