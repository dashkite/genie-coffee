import * as M from "@dashkite/masonry"
import coffee from "@dashkite/masonry-coffee"

install = ( G, { preset, glob, target }) ->
  
  G.define "clean:#{ preset }", M.rm target

  G.define "coffee:#{ preset }", "clean:#{ preset }", M.start [
    M.glob glob
    M.read
    M.set "build", -> { preset, glob, target }
    M.tr coffee
    M.extension ".js"
    M.write target
  ]

  G.on "build", "coffee:#{ preset }"

import { command as exec } from "execa"

sh = ( action, options ) ->
  result = await exec action, 
    { stdout: "inherit", stderr: "inherit", shell: true, options... }
  if result.exitCode != 0
    throw new Error result.stderr
  else result

export { install, sh }