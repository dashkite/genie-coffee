import yaml from "js-yaml"
import fs from "node:fs"
import path from "node:path"

rulesFile = path.join __dirname, "lint-rules.yaml"
rulesConfig = yaml.load fs.readFileSync rulesFile, "utf8"

fix = ( context ) ->
  { source, input } = context
  return context unless input?
  
  # Read issues from the lint cache directly
  cachePath = path.join ".masonry", "lint", source.path
  try
    data = JSON.parse fs.readFileSync cachePath, "utf8"
    fileIssues = data.issues ? []
  catch
    fileIssues = []
    
  if fs.existsSync(path.join ".masonry", "lint")
    # If the cache directory exists, we strictly follow the cache
    return context if fileIssues.length == 0
    activeCodes = new Set(fileIssues.map (i) -> i.code)
  else
    # Fallback to checking all rules if lint hasn't run
    activeCodes = new Set(rulesConfig.map (r) -> r.id)
  
  lines = input.split "\n"
  changed = false
  
  for line, i in lines
    codeOnly = line.split('#')[0]
    commentPart = if line.indexOf('#') != -1 then line.slice(line.indexOf('#')) else ""
    
    # Pad strings with spaces so indices match EXACTLY
    stripped = codeOnly.replace /"[^"]*"/g, (m) -> ' '.repeat(m.length)
    stripped = stripped.replace /'[^']*'/g, (m) -> ' '.repeat(m.length)

    for rule in rulesConfig
      continue unless rule.fix?
      continue unless activeCodes.has rule.id
      
      # We need a global regex to iteratively find and replace all matches
      regex = new RegExp rule.pattern, "g"
      
      target = if rule.strip then stripped else codeOnly
      
      while (match = regex.exec target) != null
        if typeof rule.fix == "object"
          # Dictionary mapping
          replacement = rule.fix[match[0]]
        else
          # String substitution using the match
          replacement = match[0].replace(new RegExp(rule.pattern), rule.fix)
          
        if replacement?
          # Replace in codeOnly
          before = codeOnly.substring(0, match.index)
          after = codeOnly.substring(match.index + match[0].length)
          codeOnly = before + replacement + after
          
          # Also update target and stripped so subsequent matches are aligned
          target = before + replacement + target.substring(match.index + match[0].length)
          stripped = before + replacement + stripped.substring(match.index + match[0].length)
          
          # Adjust the regex lastIndex because the string length changed
          regex.lastIndex = match.index + replacement.length
          changed = true

    lines[i] = codeOnly + commentPart
    
  if changed
    output = lines.join "\n"
    # Overwrite the original file in place
    fs.writeFileSync source.path, output, "utf8"
    console.log "Fixed #{ source.path }"
    context.input = output # update context for subsequent steps
    
  context

export default fix
export { fix }
