import FS from "node:fs/promises"
import Path from "node:path"

export default ( name, fx ) ->
  ( context ) ->
    sourcePath = Path.join (context.root ? "."), context.source.path
    cachePath = Path.join ".genie/coffee", name, context.source.path
    
    try
      sourceStat = await FS.stat sourcePath
      cacheStat = await FS.stat cachePath
      if cacheStat.mtimeMs >= sourceStat.mtimeMs
        try
          data = JSON.parse await FS.readFile cachePath, "utf8"
          Object.assign context, data
        catch
          # ignore parse errors
        return context
    catch
      null
      
    current = context
    for f in fx
      current = await f current
      
    await FS.mkdir (Path.dirname cachePath), recursive: true
    
    dataToCache = {}
    if current?.cacheable?
      for key in current.cacheable
        dataToCache[key] = current[key]
        
    await FS.writeFile cachePath, JSON.stringify(dataToCache)
    
    current
