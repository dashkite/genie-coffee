import * as M from "@dashkite/masonry"
import { coffee } from "@dashkite/masonry-coffee"

export default ( genie ) ->

  options = genie.get "coffee"
  
  genie.on "build", "coffee"

  genie.define "coffee", "clean", M.start [
    M.glob options.glob ? [
      "src/**/*.coffee"
      "test/**/*.coffee"
    ]
    M.read
    M.set "build", -> options.build ? preset: "node"
    M.tr coffee
    M.extension ".js"
    M.write "build/node"
  ]