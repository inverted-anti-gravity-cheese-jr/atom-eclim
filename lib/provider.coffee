module.exports = EclimProvider =
  selector: '.source.java'
  inclusionPriority: 1
  excludeLowerPriority: true
  projectsPaths: null

  constructor: (projectsPaths)  ->
    @projectsPaths = projectsPaths

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    new Promise (resolve) ->
      resolve([text: 'something'])

  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->

  dispose: ->
