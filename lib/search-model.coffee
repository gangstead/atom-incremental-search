
# I followed the find-and-replace architecture but it really feels like there are two types of models:
# (1) the global search settings and (2) the search results and current result.
#
# Maybe pull the settings and history out into a separate item.  Pass that item into the search model
# when starting a new search?

_ = require 'underscore-plus'
{Emitter} = require 'emissary'

module.exports =
class SearchModel
  Emitter.includeInto(this)

  @resultClass: 'isearch-result'
  @currentClass: 'isearch-current'

  constructor: (state={}) ->

    @editSession = null
    # The active pane item we are searching.

    @startMarker = null
    # Records the cursor position when the search began in case the search is canceled.  This
    # is not a search result and is not in `@markers`.
    #
    # If the user changes buffers with a search open, we are going to lose the starting
    # position.

    @markers = []
    # An array of markers for search results, used to highlight them.

    @currentMarker = null
    # The marker from `markers` that is the current search result.  In isearch, there is always
    # on current result if there are any matches.

    @currentDecoration = null
    # The decoration for @currentMarker indicating it is the current result.
    #
    # We don't track the normal result decorations since they are destroyed when the markers
    # are destroyed but we do need to track this one since we can change the current result
    # without destroying markers.

    @pattern = ''
    @direction = 'forward'
    @useRegex = state.useRegex ? false
    @caseSensitive = state.caseSensitive ? false
    @valid = false

    @history = state.history || []
    # Previous searches.  Each entry is an object with pattern, useRegEx, and caseSensitive.

    # @start()
    # atom.workspaceView.on 'pane-container:active-pane-item-changed', => @activePaneItemChanged()

  hasStarted: ->
    return @startMarker is not null

  activePaneItemChanged: ->
    if @editSession
      @editSession.getBuffer().off(".isearch")
      @editSession = null
      @destroyResultMarkers()

    @start

  start: (pattern=None)->
    # Start a new search.

    @cleanup()

    if pattern
      @pattern = pattern

    paneItem = atom.workspace.getActivePaneItem()
    if paneItem?.getBuffer?()?
      @editSession = paneItem
      @editSession.getBuffer().on "contents-modified.isearch", (args) =>
        @updateMarkers()

      markerAttributes =
        class: 'isearch-start'
        invalidate: 'inside'
        replicate: false
        persistent: false
        isCurrent: false
      range = @editSession.getSelectedBufferRange()
      @startMarker = @editSession.markBufferRange(range, markerAttributes)

      @updateMarkers()

  stopSearch: (pattern) ->
    # If the user has typed faster than the change events and pressed Enter, we will not have
    # actually performed the search for the full pattern.

    if pattern and pattern isnt @pattern and @editSession
      @pattern = pattern
      buffer = @editSession.getBuffer()
      func = buffer[if @direction is 'forward' then 'scan' else 'backwardsScan']
      func.call buffer, @getRegex(), ({range, stop}) =>
        @editSession.setSelectedBufferRange(range)
        stop()

    @cleanup()

  cancelSearch: ->
    if @startMarker
      @editSession?.getCursor().setBufferPosition(@startMarker.getHeadBufferPosition())
    @cleanup()

  cleanup: ->
    # Common clean up code used by stop and cancel.

    unless atom.config.get('isearch.keepOptionsAfterSearch')
      @useRegex = false
      @caseSensitive = false
      @emit 'updatedOptions'

    @startMarker.destroy() if @startMarker
    @startMarker = null

    @destroyResultMarkers()

    if @editSession
      @editSession.getBuffer().off(".isearch")
      @editSession = null

    if @pattern and @history[@history.length-1] isnt @pattern
      @history.push(@pattern)

    @pattern = ''

  updateMarkers: ->
    if not @editSession? or not @pattern
      @destroyResultMarkers()
      return

    @valid = true
    bufferRange = [[0,0],[Infinity,Infinity]]

    updatedMarkers = []
    markersToRemoveById = {}

    markersToRemoveById[marker.id] = marker for marker in @markers

    @editSession.scanInBufferRange @getRegex(), bufferRange, ({range}) =>
      if marker = @findMarker(range)
        delete markersToRemoveById[marker.id]
      else
        marker = @createMarker(range)
      updatedMarkers.push marker

    marker.destroy() for id, marker of markersToRemoveById

    @markers = updatedMarkers

    @moveToClosestResult()


  findNext: ->
    # Called when the user presses the search key and there are already matches.  Move to the next match.
    @moveToClosestResult(true)

  moveToClosestResult: (force) ->
    # Move the cursor to the closest result.  If `force` is set, the cursor must move even if
    # there is a valid result where the cursor is.

    @currentMarker = (@direction is 'forward') && @firstMarkerAfterCursor(force) || @firstMarkerBeforeCursor(force)

    @currentDecoration?.destroy()
    @currentDecoration = null

    if @currentMarker
      @editSession.setSelectedBufferRange(@currentMarker.getBufferRange(), autoscroll: true, flash: true)
      @currentDecoration = @editSession.decorateMarker(@currentMarker, type: 'highlight', class: @constructor.currentClass)


  firstMarkerAfterCursor: (force) ->
    if not @markers.length
      return null

    selection = @editSession.getSelection()
    selectedRange = selection.getBufferRange()
    {start, end} = selectedRange
    start = end if selection.isReversed()

    for marker in @markers
      markerStartPosition = marker.bufferMarker.getStartPosition()
      comp = markerStartPosition.compare(start)
      if comp > 0 || (comp is 0 and not force)
        return marker

    # Wrap around to the first one
    @markers[0]

  firstMarkerBeforeCursor: (force) ->
    if not @markers.length
      return null

    selection = @editSession.getSelection()
    {start, end} = selection.getBufferRange()
    start = end if selection.isReversed()

    prev = null

    for marker in @markers
      markerStartPosition = marker.bufferMarker.getStartPosition()
      comp = markerStartPosition.compare(start)
      if comp is 0 and not force
        return marker

      if comp < 0
        prev = marker
      else
        break

    prev || @markers[@markers.length-1]

  destroyResultMarkers: ->
    @valid = false
    marker.destroy() for marker in @markers ? []
    @markers = []
    @currentMarker = null
    @currentDecoration = null

  update: (newParams={}) ->
    currentParams = {@pattern, @direction, @useRegex, @caseSensitive}
    _.defaults(newParams, currentParams)

    unless @valid and _.isEqual(newParams, currentParams)
      _.extend(this, newParams)
      @updateMarkers()

  getRegex: ->
    flags = 'g'
    flags += 'i' unless @caseSensitive

    if @useRegex
      new RegExp(@pattern, flags)
    else
      new RegExp(_.escapeRegExp(@pattern), flags)

  createMarker: (range) ->
    markerAttributes =
      class: @constructor.resultClass
      invalidate: 'inside'
      replicate: false
      persistent: false
      isCurrent: false
    marker = @editSession.markBufferRange(range, markerAttributes)
    decoration = @editSession.decorateMarker(marker, type: 'highlight', class: @constructor.resultClass)
    marker

  findMarker: (range) ->
    attributes = { class: @constructor.resultClass, startPosition: range.start, endPosition: range.end }
    _.find @editSession.findMarkers(attributes), (marker) -> marker.isValid()
