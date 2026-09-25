report = ( context ) ->
  if context.issues?
    for issue in context.issues
      if issue.isError
        console.error issue.text
      else
        console.warn issue.text
  context

export default report
export { report }
