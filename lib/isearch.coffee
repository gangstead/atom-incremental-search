{$} = require 'atom'
{Subscriber} = require 'emissary'

InputView = require './input-view'

module.exports =
  configDefaults:
    keepOptionsAfterSearch: true

  inputView: null

  activate: (state) ->
    @subscriber = new Subscriber()
    @subscriber.subscribeToCommand atom.workspaceView, 'incremental-search:forward', => @findPressed('forward')
    @subscriber.subscribeToCommand atom.workspaceView, 'incremental-search:backward', => @findPressed('backward')

    @subscriber.subscribeToCommand atom.workspaceView, 'core:cancel core:close', ({target}) =>
      if target isnt atom.workspaceView.getActivePaneView()?[0]
        editor = $(target).parents('.editor:not(.mini)')
        return unless editor.length

      @inputView?.detach()

  deactivate: ->
    if @inputView
      @inputView.destroy()
      @inputView = null

  # serialize: ->
  #   isearchViewState: @inputView.serialize()

  findPressed: (direction) ->
    if not @inputView
      @inputView = new InputView()
    @inputView.trigger(direction)
