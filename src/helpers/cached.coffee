import FS from "node:fs/promises"
import Path from "node:path"

export default ( name, fx ) ->
  ( context ) ->
    sourcePath = Path.join (context.root ? "."), context.source.path
    cachePath = Path.join ".masonry", name, context.source.path
    
    try
      sourceStat = await FS.stat sourcePath
      cacheStat = await FS.stat cachePath
      if cacheStat.mtimeMs >= sourceStat.mtimeMs
        return context
    catch
      # Continue if cache or source stat fails
      null
      
    current = context
    for f in fx
      current = await f current
      
    unless current?.hasErrors
      await FS.mkdir (Path.dirname cachePath), recursive: true
      await FS.writeFile cachePath, ""
    
    current
