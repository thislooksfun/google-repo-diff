{$$, SelectListView} = require 'atom-space-pen-views'
helper               = require './helpers'

module.exports =
class GoogleListView extends SelectListView
  initialize: ->
    super
    @panel = atom.workspace.addModalPanel(item: this, visible: false)
    @addClass('diff-list-view')

  getEmptyMessage: (itemCount) ->
    if itemCount is 0
      'No diffs in file'
    else
      super

  getFilterKey: ->
    'lineText'

  attach: ->
    @storeFocusedElement()
    @panel.show()
    @focusFilterEditor()

  viewForItem: ({oldStart, newStart, oldLines, newLines, lineText}) ->
    $$ ->
      @li class: 'two-lines', =>
        @div lineText, class: 'primary-line'
        @div "-#{oldStart},#{oldLines} +#{newStart},#{newLines}", class: 'secondary-line'

  populate: ->
    diffs = helper.repositoryForPath(@editor.getPath())?.getLineDiffs(@editor.getPath(), @editor.getText()) ? []
    for diff in diffs
      bufferRow = if diff.newStart > 0 then diff.newStart - 1 else diff.newStart
      diff.lineText = @editor.lineTextForBufferRow(bufferRow)?.trim() ? ''
    @setItems(diffs)

  toggle: ->
    console.log "Toggling:"
    if @panel.isVisible()
      console.log "  a"
      @cancel()
    else if @editor = atom.workspace.getActiveTextEditor()
      console.log "  b"
      @populate()
      @attach()
    console.log "  c"

  cancelled: ->
    @panel.hide()

  confirmed: ({newStart}) ->
    @cancel()

    bufferRow = if newStart > 0 then newStart - 1 else newStart
    @editor.setCursorBufferPosition([bufferRow, 0], autoscroll: true)
    @editor.moveToFirstCharacterOfLine()
