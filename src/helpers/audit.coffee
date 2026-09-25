import execa from "execa"
import yaml from "js-yaml"
import fs from "node:fs"
import path from "node:path"
import chalk from "chalk"

rulesFile = path.join __dirname, "audit-rules.yaml"
rulesConfig = yaml.load fs.readFileSync rulesFile, "utf8"

isPretty = ->
  not Boolean(
    process.env.CI or
    process.env.NO_COLOR or
    process.env.TERM == "dumb"
  )

audit = ( context ) ->
  { source, input } = context
  return context unless input?

  lines = input.split "\n"
  numberedLines = lines.map (line, i) -> "#{i + 1}: #{line}"
  numberedCode = numberedLines.join "\n"
  
  rulesText = rulesConfig.map((r) -> "- #{r.title}: #{r.description}").join "\n"

  prompt = """
    You are an expert CoffeeScript code auditor reviewing semantic rules.
    Review the following code file: `#{source.path}`.
    The code has line numbers prepended.
    
    Check the code for violations of the following semantic rules:
    #{rulesText}
    
    If you find any violations, you MUST output them strictly in the following XML format:
    <issue task="audit" file="#{source.path}" line="[LINE_NUMBER]" severity="warn">
      <message>[DESCRIPTION OF ISSUE]</message>
    </issue>
    
    Only output the raw XML nodes. Do NOT include markdown code blocks, explanations, or conversational text.
    If there are no violations, output exactly: <!-- OK -->
    
    Code:
    #{numberedCode}
  """
  
  try
    { stdout } = await execa "agy", ["--print", prompt]
    output = stdout?.trim()
    output = "" if output == "<!-- OK -->"
    
    if output and output.length > 0
      if isPretty()
        console.warn "\n", chalk.cyan.bold "  ◆ #{ source.path } (Audit)"
        
        # Crude XML parsing for CLI
        regex = /<issue[^>]*line="([^"]+)"[^>]*>[\s\S]*?<message>([\s\S]*?)<\/message>/g
        hasMatch = false
        while (match = regex.exec output) != null
          hasMatch = true
          line = match[1]
          message = match[2].trim()
          
          pipe = chalk.dim "│"
          loc = chalk.dim "    ↳ line #{ line }"
          msg = "      #{ pipe } " + chalk.yellow "⚠ #{ message }"
          
          excerpt = lines[ parseInt(line) - 1 ]?.trim()
          if excerpt? and excerpt.length > 0
            code = "      #{ pipe } #{ excerpt }"
            console.warn "#{ loc }\n#{ code }\n#{ msg }"
          else
            console.warn "#{ loc }\n#{ msg }"
            
        if not hasMatch
          # If the LLM disobeyed and output conversational text, just print it.
          console.warn chalk.yellow output
      else
        console.log output
  catch err
    console.error chalk.red "Audit failed for #{source.path}: #{err.message}"
    
  context

export default audit
export { audit }
