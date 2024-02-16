import defaults from "./defaults"

expand = ( targets ) ->
  result = {}
  for target in targets
    result[ target ] = defaults.targets[ target ]
  result

Options = 

  get: ( Genie ) ->
    options = { defaults..., ( Genie.get "coffee" )... }
    if Array.isArray options.targets
      options.targets = expand options.targets
    options

export default Options