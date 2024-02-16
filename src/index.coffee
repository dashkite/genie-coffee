import M from "@dashkite/masonry"
import coffee from "@dashkite/masonry-coffee"
import T from "@dashkite/masonry-targets"
import { sh, exists } from "./helpers"
import lint from "./helpers/lint"
import Options from "./helpers/options"

export default ( Genie ) ->

  { targets } = Options.get Genie
  
  Genie.define "coffee:build", "coffee:clean", M.start [
    T.glob targets
    M.read
    M.tr coffee
    M.extension ".js"
    T.write "build/${ build.preset }"
  ]

  # alias
  Genie.define "coffee", "coffee:build"
  
  Genie.on "build", "coffee:build"

  Genie.define "coffee:clean", "clean"

  Genie.define "coffee:lint", "coffee:clean", M.start [
    T.glob targets
    M.read
    M.tr coffee
    lint
    # we write out the code so that we can reference it
    # in case we want to see why lint is complaining
    M.extension ".js"
    T.write "build/${ build.preset }"
  ]
  
  Genie.define "coffee:test", "build", ->
    if await exists "build/node/test/index.js"
      sh "node
        --enable-source-maps
        --trace-warnings
        --unhandled-rejections=strict
        build/node/test/index.js"
    else
      console.warn "no tests defined"

  Genie.on "test", "coffee:test"

  Genie.on "lint", "coffee:lint"