{$} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

InputView = require './input-view'

module.exports =
  inputView: null

  activate: (state) ->
    @subscriber = new CompositeDisposable
    @subscriber.add atom.commands.add 'atom-workspace', 'incremental-search:forward', => @findPressed('forward')
    @subscriber.add atom.commands.add 'atom-workspace', 'incremental-search:backward', => @findPressed('backward')

    handleEditorCancel = ({target}) =>
      isMiniEditor = target.tagName is 'ATOM-TEXT-EDITOR' and target.hasAttribute('mini')
      unless isMiniEditor
        @inputView?.inputPanel.hide()

    @subscriber.add atom.commands.add 'atom-workspace',
      'core:cancel': handleEditorCancel
      'core:close': handleEditorCancel

  deactivate: ->
    @inputView?.destroy()
    @inputView = null

  # serialize: ->
  #   isearchViewState: @inputView.serialize()

  findPressed: (direction) ->
    @createViews()

    @inputView.trigger(direction)

  createViews: ->
    return if @inputView?

    @inputView = new InputView()
