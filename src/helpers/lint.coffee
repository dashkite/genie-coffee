import { ESLint } from "eslint"
import chalk from "chalk"
import { SourceMap } from "node:module"
import yaml from "js-yaml"
import fs from "node:fs"
import path from "node:path"

linter = new ESLint
  baseConfig:
    env:
      browser: true
      node: true
    parserOptions:
      sourceType: "module"
      ecmaVersion: "latest"
    rules:
      "no-unused-vars": [
        "warn"
        argsIgnorePattern: "^_"
      ]
      "no-unreachable": "warn"
      "no-unsafe-finally": "warn"
      "no-unsafe-optional-chaining": "warn"
      "use-isnan": "warn"
      "camelcase": [
        "warn"
        allow: [
          "_interop_require_default"
          "_interop_require_wildcard"
          "_export_star"
        ]
      ]
      "complexity": "warn"
      "max-depth": "warn"
      # CS transpiler sometimes takes small functions
      # and makes them large, plus linter misreports
      # their length ...
      # "max-lines": "warn"
      # "max-statements": "warn"
      # mixins get turned into functions by CS transpiler
      # "max-lines-per-function": "warn"
      "max-params": "warn"
      "new-cap": "warn"
      "no-useless-catch": "warn"
      "no-useless-call": "warn"
      "no-useless-computed-key": "warn"

defaults =
  targets:
    node: [
      glob: [
        "{src,test}/**/*.coffee"
      ]
    ]
    browser: [
      glob: [
        "{src,test}/**/*.coffee"
      ]
    ]

sourceMapRegex = /(?:\/\/[#@]|\/\*[#@])\s*sourceMappingURL=data:application\/json;(?:charset=[^;]+;)?base64,([A-Za-z0-9+/=]+)/

extractSourceMap = ( code ) ->
  match = code?.match sourceMapRegex
  return null unless match?
  try
    json = Buffer.from(match[1], "base64").toString "utf8"
    new SourceMap JSON.parse json
  catch
    null

transpose = ( message, sourceMap ) ->
  return message unless sourceMap?
  entry = sourceMap.findEntry message.line - 1, message.column - 1
  if entry?.originalLine? and entry?.originalColumn?
    line = entry.originalLine + 1
    column = entry.originalColumn + 1
  else
    { line, column } = message

  if message.endLine? and message.endColumn?
    endEntry = sourceMap.findEntry message.endLine - 1, message.endColumn - 1
    if endEntry?.originalLine? and endEntry?.originalColumn?
      endLine = endEntry.originalLine + 1
      endColumn = endEntry.originalColumn + 1

  {
    message...
    line
    column
    endLine: endLine ? message.endLine
    endColumn: endColumn ? message.endColumn
  }

isPretty = ->
  not Boolean(
    process.env.CI or
    process.env.NO_COLOR or
    process.env.TERM == "dumb"
  )

escapeXml = ( str ) ->
  str
    .replace /&/g, "&amp;"
    .replace /</g, "&lt;"
    .replace />/g, "&gt;"

format = ({ line, column, message, severity, code }, excerpt, file) ->
  if isPretty()
    pipe = chalk.dim "│"
    icon = if severity == 2 then "✖" else "⚠"
    color = if severity == 2 then chalk.red else chalk.yellow
    loc = chalk.dim "    ↳ line #{ line }, column #{ column }"
    msg = "      #{ pipe } " + color "#{ icon } #{ message }"
    if excerpt? and excerpt.length > 0
      codeBlock = "      #{ pipe } #{ excerpt }"
      "#{ loc }\n#{ codeBlock }\n#{ msg }"
    else
      "#{ loc }\n#{ msg }"
  else
    severityName = if severity == 2 then "error" else "warn"
    codeTag = if excerpt? and excerpt.length > 0
      "\n  <code>#{ escapeXml excerpt }</code>"
    else
      ""
    codeAttr = if code then " code=\"#{ escapeXml code }\"" else ""
    """<issue task="lint" file="#{ file }" line="#{ line }" column="#{ column }"#{ codeAttr } severity="#{ severityName }">#{ codeTag }
  <message>#{ escapeXml message }</message>
</issue>"""

rulesFile = path.join __dirname, "lint-rules.yaml"
rulesConfig = yaml.load fs.readFileSync rulesFile, "utf8"

checkCustomRules = ( lines ) ->
  messages = []
  for line, i in lines
    lineNum = i + 1
    codeOnly = line.split('#')[0]
    stripped = codeOnly.replace(/"[^"]*"/g, '""').replace(/'[^']*'/g, "''")

    for rule in rulesConfig
      target = if rule.strip then stripped else (if rule.strip == false then line else codeOnly)
      regex = new RegExp rule.pattern
      
      if regex.test target
        if rule.negative_lookahead?
          negativeRegex = new RegExp rule.negative_lookahead
          if negativeRegex.test target
            continue
            
        messages.push
          line: lineNum
          column: 1
          message: rule.message
          severity: rule.severity
          code: rule.id

  messages

lint = do ({ warn, error } = {}) ->
  warn = 1
  error = 2
  newline = "\n"
  ( context ) ->
    { source, output, input } = context
    sourceMap = extractSourceMap output
    lines = input?.split "\n"
    
    context.issues = []
    context.cacheable ?= []
    context.cacheable.push "issues"
    
    results = await linter.lintText output, filePath: source.path
    
    hasPrintedHeader = false
    getHeader = ->
      if not hasPrintedHeader
        hasPrintedHeader = true
        if isPretty() then newline + chalk.cyan.bold("  ◆ #{ source.path }") else ""
      else ""

    # 1. Process ESLint Messages
    for { messages } in results
      for message, index in messages
        header = getHeader()
        transposed = transpose message, sourceMap
        transposed.code = message.ruleId
        excerpt = lines?[ transposed.line - 1 ]?.trim()
        formatted = format transposed, excerpt, source.path
        
        text = if header then "#{header}\n#{formatted}" else formatted
        context.issues.push { text, isError: error == transposed.severity, code: transposed.code }

    # 2. Process Custom CoffeeScript Static Rules
    if lines?
      customMessages = checkCustomRules lines
      for message, index in customMessages
        header = getHeader()
        excerpt = lines?[ message.line - 1 ]?.trim()
        formatted = format message, excerpt, source.path
        
        text = if header then "#{header}\n#{formatted}" else formatted
        context.issues.push { text, isError: error == message.severity, code: message.code }

    context

export default lint
export { lint }

