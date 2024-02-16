import FS from "node:fs/promises"
import Path from "node:path"
import { command as exec } from "execa"

exists = ( path ) ->
  try
    await FS.readFile path
    true
  catch
    false

sh = ( action, options ) ->
  result = await exec action, 
    { stdout: "inherit", stderr: "inherit", shell: true, options... }
  if result.exitCode != 0
    throw new Error result.stderr
  else result

export { exists, sh }