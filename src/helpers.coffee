import FS from "node:fs/promises"
import Path from "node:path"
import { command as exec } from "execa"

# TODO where do these go?
#      Don't fit Masonry's iterator-based model

rm = ( target ) ->
  try
    await FS.rm target, recursive: true
  catch error
    unless error.message.startsWith "ENOENT"
      throw error


sh = ( action, options ) ->
  result = await exec action, 
    { stdout: "inherit", stderr: "inherit", shell: true, options... }
  if result.exitCode != 0
    throw new Error result.stderr
  else result

export { rm, sh }