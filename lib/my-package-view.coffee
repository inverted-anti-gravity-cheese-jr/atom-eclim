module.exports =
class MyPackageView
  constructor: (serializedState, eclimLocation) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('my-package')

    element = @element
    command = eclimLocation + ' -command project_list'

    exec = require("child_process").exec
    exec(command, (error, stdout, stderr) ->
      message = document.createElement('div')
      message.textContent = stdout
      message.classList.add('message')
      element.appendChild(message)
    )

    # Create message element


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
