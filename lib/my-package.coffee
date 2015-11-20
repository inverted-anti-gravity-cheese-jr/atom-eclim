MyPackageView = require './my-package-view'
{CompositeDisposable} = require 'atom'

eclimLocation = ''
projectName = ''
projectPath = ''

module.exports = MyPackage =
  myPackageView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    eclimLocation = 'D:\\offspin\\eclipsewithgradle\\eclipse\\eclim'

    projCommand = eclimLocation + ' -command project_list'
    exec = require("child_process").exec
    if(projectName == "")
      exec(projCommand, (error, stdout, stderr) ->
        list = JSON.parse(stdout)
        iter = (elem) ->
          elemPath = elem.path.replace(/\\/g, "/")
          editorPath = atom.workspace.getActiveTextEditor().getPath().replace(/\\/g, "/")
          if editorPath.indexOf(elemPath) > -1 && elem.path.length > projectPath.length
            projectName = elem.name
            projectPath = elem.path
        iter elem for elem in list
        console.log(projectName)
      )

    @myPackageView = new MyPackageView(state.myPackageViewState, eclimLocation)
    @modalPanel = atom.workspace.addModalPanel(item: @myPackageView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'my-package:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @myPackageView.destroy()

  serialize: ->
    myPackageViewState: @myPackageView.serialize()

  myautocom: ->
    command = eclimLocation + " -command java_complete -p " + projectName + ' -f ' + fileName + ' -o ' + posInText.toString() + ' -e utf-8 -l compact'
    console.log(command)

    exec = require("child_process").exec
    exec(command, (error, stdout, stderr) ->
      console.log(stdout)
    )


  toggle: ->
    console.log('MyPackage was toggled!')
    end = atom.workspace.getActiveTextEditor().getCursorBufferPosition()
    console.log(end.row)
    console.log()

    if(projectName != "")
      console.log(projectName + " " + projectPath)
      fileName = atom.workspace.getActiveTextEditor().getPath().replace(/\\/g, "/").replace(projectPath, '')
      if fileName.indexOf('/') == 0
        fileName = fileName.substring(1, fileName.length)
      posInText = atom.workspace.getActiveTextEditor().getTextInBufferRange([new Range(0,0), end]).length

      command = eclimLocation + " -command java_import_organize -p " + projectName + ' -f ' + fileName + ' -o ' + posInText.toString() + ' -e utf-8'
      console.log(command)

      exec = require("child_process").exec
      exec(command, (error, stdout, stderr) ->
        console.log(stdout)
      )

    # if @modalPanel.isVisible()
    #   @modalPanel.hide()
    # else
    #   @modalPanel.show()
