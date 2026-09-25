import M from "@dashkite/masonry"
import coffee from "@dashkite/masonry-coffee"
import T from "@dashkite/masonry-targets"
import { sh, exists } from "./helpers"
import lint from "./helpers/lint"
import fix from "./helpers/fix"
import audit from "./helpers/audit"
import Options from "./helpers/options"

import cached from "./helpers/cached"

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

  Genie.define "coffee:lint", M.start [
    T.glob targets
    cached "lint", [
      M.read
      M.tr coffee
      lint
      # we write out the code so that we can reference it
      # in case we want to see why lint is complaining
      M.extension ".js"
      T.write "build/${ build.preset }"
    ]
  ]
  
  Genie.define "coffee:lint:clean", ->
    sh "rm -rf .masonry/lint"

  Genie.on "lint:clean", "coffee:lint:clean"
  
  Genie.define "coffee:lint:fix", M.start [
    T.glob targets
    M.read
    fix
  ]
  
  Genie.on "lint:fix", "coffee:lint:fix"

  Genie.define "coffee:audit", M.start [
    T.glob targets
    cached "audit", [
      M.read
      audit
    ]
  ]

  Genie.on "audit", "coffee:audit"

  Genie.define "coffee:audit:clean", ->
    sh "rm -rf .masonry/audit"

  Genie.on "audit:clean", "coffee:audit:clean"

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