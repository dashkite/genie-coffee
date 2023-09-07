import { install } from "./helpers"

defaults =
  glob: [
    "src/**/*.coffee"
    "test/**/*.coffee"
  ]
  preset: "browser"
  target: "build/browser"

export default ( G ) ->
  options = { defaults..., ( G.get "coffee" )... }
  install G, options
