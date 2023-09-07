import { install , sh } from "./helpers"

defaults =
  glob: [
    "src/**/*.coffee"
    "test/**/*.coffee"
  ]
  preset: "node"
  target: "build/node"

export default ( G ) ->

  options = { defaults..., ( G.get "coffee" )... }
  install G, options

  G.on "test", ->
    sh "node
      --enable-source-maps
      --trace-warnings
      --unhandled-rejections=strict
      #{ options.target }/test/index.js"
