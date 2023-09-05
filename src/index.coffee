import * as M from "@dashkite/masonry"
import { coffee } from "@dashkite/masonry-coffee"

defaults =
  glob: [
    "src/**/*.coffee"
    "test/**/*.coffee"
  ]
  preset: "node"

export default ( G ) ->

  options = { defaults..., ( G.get "coffee" )... }
  
  G.on "build", "coffee"

  G.define "coffee", "clean", M.start [
    M.glob options.glob
    M.read
    M.set "build", -> options.build ? preset: "node"
    M.tr coffee
    M.extension ".js"
    M.write "build/node"
  ]

  G.on "clean", M.rm "build"
