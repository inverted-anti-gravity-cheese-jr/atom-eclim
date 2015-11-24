provider = require './provider'
{CompositeDisposable} = require 'atom'

eclimLocation = ''
projectsPaths = new Object()

module.exports = eclimMain =
  selector: '.source.java'

  activate: (state) ->
    provider.constructor(projectsPaths, @)
    eclimLocation = 'D:/offspin/eclipsewithgradle/eclipse/eclim'
    @loadEclipseProject(() -> )

    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-text-editor','atom-eclim:toggle': => @toggle()
    @subscriptions.add atom.commands.add 'atom-text-editor','atom-eclim:build': => @build()

  loadEclipseProject: (callback) ->
    if(typeof(projectsPaths[fileName]) == "undefined")
      projCommand = eclimLocation + ' -command project_list'
      exec = require("child_process").exec
      fileName = @getFileName()
      exec(projCommand, (error, stdout, stderr) ->
        console.log stdout
        list = JSON.parse(stdout)
        tmpProjectPaths = {"name": "", "path": ""}
        iter = (elem) ->
          elemPath = elem.path.replace(/\\/g, "/")
          if fileName.indexOf(elemPath) > -1 && elem.path.length > tmpProjectPaths["path"]
            tmpProjectPaths["name"] = elem.name
            tmpProjectPaths["path"] = elemPath
        iter elem for elem in list
        if tmpProjectPaths["name"] != ""
          projectsPaths[fileName] = tmpProjectPaths
        else
          projectsPaths[fileName] = "not_in_project"
        callback()
      )
    else
      callback()

  deactivate: ->
    provider.dispose()

  getProvider: ->
    provider

  serialize: ->

  getFileName: -> atom.workspace.getActiveTextEditor().getPath().replace(/\\/g, "/")

  getEclimLocation: -> eclimLocation

  build: ->
    # if(projectName == "")
    #   loadEclipseProject();
    # if(projectName != "")
    #   command = eclimLocation + " -command java_complete -p " + projectName + ' -f ' + fileName + ' -o ' + posInText.toString() + ' -e utf-8 -l compact'
    #   console.log(command)
    #   exec = require("child_process").exec
    #   exec(command, (error, stdout, stderr) ->
    #     console.log(stdout)
    # )

  toggle: ->
    fileName = @getFileName()
    callback = () ->
      if(projectsPaths[fileName] != "not_in_project")
        tmpPaths = projectsPaths[fileName]
        projectPath = tmpPaths["path"]
        projectName = tmpPaths["name"]
        cFileName = fileName.replace(projectPath, '')
        if cFileName.indexOf('/') == 0
          cFileName = cFileName.substring(1, cFileName.length)
        end = atom.workspace.getActiveTextEditor().getCursorBufferPosition()
        posInText = atom.workspace.getActiveTextEditor().getTextInBufferRange([new Range(0,0), end]).length

        command = eclimLocation + " -command java_import_organize -p " + projectName + ' -f ' + cFileName + ' -o ' + posInText.toString() + ' -e utf-8'
        atom.workspace.getActiveTextEditor().save()
        exec = require("child_process").exec
        exec(command)
    @loadEclipseProject(callback)
