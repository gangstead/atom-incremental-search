{View, TextEditorView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

SearchModel = require './search-model'

module.exports =
class InputView extends View
  @content: ->
    @div tabIndex: -1, class: 'isearch tool-panel panel-bottom padded', =>
      @div class: 'block', =>
        @span outlet: 'descriptionLabel', class: 'description', 'Incremental Search'
        @span outlet: 'optionsLabel', class: 'options'

      @div class: 'find-container block', =>
        @div class: 'editor-container', =>
          @subview 'findEditor', new TextEditorView(mini: true, placeholderText: 'search')

        @div class: 'btn-group btn-toggle btn-group-options', =>
          @button outlet: 'regexOptionButton', class: 'btn', '.*'
          @button outlet: 'caseOptionButton', class: 'btn', 'Aa'

  initialize: (serializeState) ->
    @subscriptions = new CompositeDisposable
    serializeState = serializeState || {}
    @searchModel = new SearchModel(serializeState.modelState)
    @handleEvents()

  handleEvents: ->
    # Setup event handlers
    @subscriptions.add atom.config.observe 'incremental-search.instantSearch', @handleInstantSearchConfigChange.bind(this)

    @subscriptions.add atom.commands.add @findEditor.element,
      'core:confirm': => @stopSearch()

    @subscriptions.add atom.commands.add @element,
      'core:close': => @cancelSearch()
      'core:cancel': => @cancelSearch()
      'incremental-search:toggle-regex-option': @toggleRegexOption
      'incremental-search:toggle-case-option': @toggleCaseOption
      'incremental-search:focus-editor': => @focusEditor()
      'incremental-search:slurp': => @slurp()

    if atom.config.get('incremental-search.cancelSearchOnBlur')
      @findEditor.on 'blur', =>
        @cancelSearch()

    @regexOptionButton.on 'click', @toggleRegexOption
    @caseOptionButton.on 'click', @toggleCaseOption

    @searchModel.on 'updatedOptions', =>
      @updateOptionButtons()
      @updateOptionsLabel()

  handleInstantSearchConfigChange: (instantSearch) ->
    changeEventListener = if instantSearch then 'onDidChange' else 'onDidStopChanging'
    @changeSubscription?.dispose()
    @changeSubscription = @findEditor.getModel()[changeEventListener] => @updateSearchText()

  attached: ->
    return if @tooltipSubscriptions?
    @tooltipSubscriptions = new CompositeDisposable

    @tooltipSubscriptions.add  atom.tooltips.add @regexOptionButton,
        title: "Use Regex"
        keyBindingCommand: 'incremental-search:toggle-regex-option'
        keyBindingTarget: @findEditor[0]
    @tooltipSubscriptions.add atom.tooltips.add @caseOptionButton,
        title: "Match Case"
        keyBindingCommand: 'incremental-search:toggle-case-option'
        keyBindingTarget: @findEditor[0]

  hideAllTooltips: ->
    @tooltipSubscriptions?.dispose()
    @tooltipSubscriptions = null

  slurp: ->
    @searchModel.slurp()
    @findEditor.setText(@searchModel.pattern)

  toggleRegexOption: =>
    @searchModel.update({pattern: @findEditor.getText(), useRegex: !@searchModel.useRegex})
    @updateOptionsLabel()
    @updateOptionButtons()

  toggleCaseOption: =>
    @searchModel.update({pattern: @findEditor.getText(), caseSensitive: !@searchModel.caseSensitive})
    @updateOptionsLabel()
    @updateOptionButtons()

  updateSearchText: ->
    pattern = @findEditor.getText()
    @searchModel.update({ pattern })

  serialize: ->
    modelState: @searchModel.serialize()

  # Tear down any state and detach
  destroy: ->
    @subscriptions?.dispose()
    @tooltipSubscriptions?.dispose()
    @changeSubscription?.dispose()

  detach: ->
    @hideAllTooltips()
    workspaceElement = atom.views.getView(atom.workspace)
    workspaceElement.focus()
    super()

  trigger: (direction) ->
    # The user pressed one of the shortcut keys.
    #
    # If focus is not in the edit control put it there and do not search.  This works for the
    # initial trigger which displays the form and for cases where the user searched, edited the
    # buffer, and now wants to continue.  (I expect this to be tweaked over time.)
    #
    # Always record the direction in case it changed.

    @searchModel.direction = direction

    @updateOptionsLabel()
    @updateOptionButtons()

    if not @hasParent()
      # This is a new search.
      @inputPanel = atom.workspace.addBottomPanel
        item: this
      pattern = ''
      @findEditor.setText(pattern)
      @searchModel.start(pattern)
      @inputPanel.show()
      @findEditor.focus()
    else
      @inputPanel.show()
      @findEditor.focus()
      if @findEditor.getText()
        # We already have text in the box, so search for the next item
        @searchModel.findNext()
      else
        # There is no text in the box so populate with the previous search.
        if @searchModel.history.length
          pattern = @searchModel.history[@searchModel.history.length-1]
          @findEditor.setText(pattern)
          @searchModel.update({ pattern })

  stopSearch: ->
    # Enter was pressed, so leave the cursor at its current position and clean up.
    @searchModel.stopSearch(@findEditor.getText())
    @detach()

  cancelSearch: ->
    @searchModel.cancelSearch()
    @inputPanel?.hide()
    @detach()

  updateOptionsLabel: ->
    label = []
    if @searchModel.useRegex
      label.push('regex')
    if @searchModel.caseSensitive
      label.push('case sensitive')
    else
      label.push('case insensitive')
    @optionsLabel.text(' (' + label.join(', ') + ')')

  updateOptionButtons: ->
    @setOptionButtonState(@regexOptionButton, @searchModel.useRegex)
    @setOptionButtonState(@caseOptionButton, @searchModel.caseSensitive)

  setOptionButtonState: (optionButton, selected) ->
    if selected
      optionButton.addClass 'selected'
    else
      optionButton.removeClass 'selected'

  focusEditor: ->
    if @searchModel.lastPosition
      @searchModel.moveCursorToCurrent()
      atom.workspaceView.getActiveView().focus()
