{CompositeDisposable} = require 'atom'
GoogleDiffView        = require './google-diff-view'
helper                = require './helpers'
GoogleListView        = null


googleListView = null
toggleGoogleList = ->
  GoogleListView ?= require './google-list-view'
  googleListView ?= new GoogleListView()
  googleListView.toggle()
  console.log "Toggle"



module.exports =
  
  config:
    copySettingsFromGitDiff:
      type: 'boolean'
      default: true
    showIconsInEditorGutter:
      type: 'boolean'
      default: false
  
  
  subscriptions: null
  
  active: false
  
  toggleCommand: null
  
  
  activate: ->


  consumeGoogleRepoServiceV1: (@gRepo) ->
    helper.setInstance @gRepo
    @gRepo.registerPlugin "google-repo-diff", this


  deactivate: ->
    @gRepo.unregisterPlugin "google-repo-diff"
    googleListView?.cancel()
    googleListView = null


  observe: ->
    atom.workspace.observeTextEditors (editor) ->
      new GoogleDiffView(editor)
      @toggleCommand?.dispose()
      @toggleCommand = atom.commands.add(atom.views.getView(editor), 'google-diff:toggle-diff-list', toggleGoogleList)


  isActive: -> @active


  activatePlugin: ->
    @active = true
    @subscriptions = new CompositeDisposable
    @subscriptions.add @gRepo.onRepoListChange => @observe()
    @observe()


  deactivatePlugin: ->
    @active = false
    @subscriptions.dispose()