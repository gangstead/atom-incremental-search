{$, View, EditorView} = require 'atom'

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
          @subview 'findEditor', new EditorView(mini: true, placeholderText: 'search')

        @div class: 'btn-group btn-toggle btn-group-options', =>
          @button outlet: 'regexOptionButton', class: 'btn', '.*'
          @button outlet: 'caseOptionButton', class: 'btn', 'Aa'

  initialize: (serializeState) ->
    serializeState = serializeState || {}
    @searchModel = new SearchModel(serializeState.modelState)
    @handleEvents()

  handleEvents: ->
    # Setup event handlers

    @on 'core:cancel core:close', => @cancelSearch()

    @findEditor.on 'core:confirm', => @stopSearch()
    @findEditor.getEditor().on 'contents-modified', => @updateSearchText()

    @command 'incremental-search:toggle-regex-option', @toggleRegexOption
    @command 'incremental-search:toggle-case-option', @toggleCaseOption

    @regexOptionButton.on 'click', @toggleRegexOption
    @caseOptionButton.on 'click', @toggleCaseOption

    @command 'incremental-search:focus-editor', => @focusEditor()

    @command 'incremental-search:slurp', => @slurp()

    @searchModel.on 'updatedOptions', =>
      @updateOptionButtons()
      @updateOptionsLabel()

  afterAttach: ->
    unless @tooltipsInitialized
      @regexOptionButton.setTooltip("Use Regex", command: 'incremental-search:toggle-regex-option', commandElement: @findEditor)
      @caseOptionButton.setTooltip("Match Case", command: 'incremental-search:toggle-case-option', commandElement: @findEditor)
      @tooltipsInitialized = true

  hideAllTooltips: ->
    @regexOptionButton.hideTooltip()
    @caseOptionButton.hideTooltip()

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
    @detach()

  detach: ->
    @hideAllTooltips()
    atom.workspaceView.focus()
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
      atom.workspace.addBottomPanel
        item: this
      pattern = ''
      @findEditor.setText(pattern)
      @searchModel.start(pattern)

    if not @findEditor.hasClass('is-focused')
      # The cursor isn't in the editor, so this is either a new search or the user was
      # somewhere else.  Just put the cursor into the editor.
      @findEditor.focus()
      return

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
