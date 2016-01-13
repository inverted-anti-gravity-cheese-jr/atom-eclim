resGlobal = new Array()
module.exports = eclimProvider =
  selector: '.source.java'
  inclusionPriority: 1
  suggestionPriority: 2
  excludeLowerPriority: true
  projectsPaths: null
  eclimMain: null

  constructor: (projectsPaths, eclimMain)  ->
    @projectsPaths = projectsPaths
    @eclimMain = eclimMain

  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix, activatedManually}) ->
    eclimMain = @eclimMain
    projectsPaths = @projectsPaths
    waitingResolve = null
    callback = (resolve) ->
      resolve([{
        text: 'asyncProvided',
        rightLabel: 'asyncProvided'
      }])
      resGlobal = new Array()
      fileName = eclimMain.getFileName()
      if(projectsPaths[fileName] != "not_in_project")
        tmpPaths = projectsPaths[fileName]
        projectPath = tmpPaths["path"]
        projectName = tmpPaths["name"]

        end = atom.workspace.getActiveTextEditor().getCursorBufferPosition()
        posInText = atom.workspace.getActiveTextEditor().getTextInBufferRange([new Range(0,0), end]).length

        cFileName = fileName.replace(projectPath, '')
        if cFileName.indexOf('/') == 0
          cFileName = cFileName.substring(1, cFileName.length)

        command = eclimMain.getEclimLocation() + " -command java_complete -p " + projectName + ' -f ' + cFileName + ' -o ' + posInText.toString() + ' -e utf-8 -l compact'

        atom.workspace.getActiveTextEditor().save()
        exec = require("child_process").exec
        exec(command, (error, stdout, stderr) ->
          completions = JSON.parse(stdout).completions
          parser = new CompletionsParser()
          for i in [0..completions.length] by 1
            res = parser.parse(completions[i])
            if(res != null)
              resGlobal.push(res)
          if typeof(resolve) == 'function'
            resolve(resGlobal)
        )
    #return new Promise (resolve) =>
    #  waitingResolve = resolve
    #  # check and reload Eclipse projects
    #  eclimMain.loadEclipseProject(callback)

    return new Promise((resolve) ->
      # working somehow
      setTimeout ->
        rep = new Array()
        rep.push({
          text: 'asyncProvided',
          rightLabel: 'asyncProvided'
        })
        resolve(rep)
      , 500
      # not working somehow
      #eclimMain.loadEclipseProject(callback, resolve)
      )

  onDidInsertSuggestion: ({editor, triggerPosition, suggestion}) ->
    console.log "Did insert"
    console.log suggestion

  dispose: ->

class CompletionsParser

  parse: (comp) ->
    if(typeof(comp) == "undefined")
      return null
    if comp.type == ""
      compType = "variable"
      info = comp.info
      compName = info.substring(0, info.indexOf(":")).trim()
      compLeft = info.substring(info.indexOf(":") + 1, info.indexOf("-")).trim()
      result = {text: compName, leftLabel: compLeft, type: compType}
    else if comp.type == "f"
      compType = "function"
      info = comp.info
      compLeft = info.substring(info.indexOf(":") + 1, info.indexOf("-")).trim()
      compSnipped = @getSnippet(info)
      compText = @getDisplayName(info)
      result = {snippet: compSnipped, displayText: compText, leftLabel: compLeft, type: compType}
    else if comp.type == "t"
      compType = "class"
      info = comp.info
      compName = info.substring(0, info.indexOf(":")).trim()
      compLeft = compName
      result = {text: compName, leftLabel: compLeft, type: compType}
    else
      result = {text: comp.completion}

    return result

  getDisplayName: (info) -> info.substring(0, info.indexOf(")") + 1)

  getSnippet: (info) ->
    methodName = info.substring(0, info.indexOf("("))
    params = info.substring(info.indexOf("(") + 1, info.indexOf(")"))
    if(params == "")
      return methodName + "()"
    split = params.split(",")
    newParams = ""
    for i in [0..(split.length - 1)] by 1
      paramName = split[i].substring(split[i].indexOf(" ") + 1, split[i].length)
      newParams = newParams + "${" + i.toString() + ":" + paramName + "}"
    return methodName + "(" + newParams + ")"
