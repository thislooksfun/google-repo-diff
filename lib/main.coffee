{CompositeDisposable} = require 'atom'
GoogleDiffView        = require './google-diff-view'
helper                = require './helpers'
GoogleListView        = null


# The list view object
googleListView = null

# Called to toggle the list view object's state
toggleGoogleList = ->
  GoogleListView ?= require './google-list-view'  # Require the class, if we haven't already
  googleListView ?= new GoogleListView()          # Create an instance, if we haven't already
  googleListView.toggle()                         # Toggle the view



module.exports =
  
  # The config settings
  config:
    copySettingsFromGitDiff:
      type: 'boolean'
      default: true
    showIconsInEditorGutter:
      type: 'boolean'
      default: false
  
  
  # The {CompositeDisposable} used to store subscriptions
  subscriptions: null
  
  # Whether or not this plugin is activated
  active: false
  
  # The assoc array of the toggle commands
  toggleCommands: {}
  
  
  # Called when atom activates this package - intentionally left blank
  activate: ->
  
  
  # Comsumes the google-repo object
  consumeGoogleRepoServiceV1: (@gRepo) ->
    helper.setInstance @gRepo                       # Put the instance into the helpers - needed to get the proper repository
    @gRepo.registerPlugin "google-repo-diff", this  # Register this plugin
  
  
  # Called when atom deactivates this package
  deactivate: ->
    @gRepo?.unregisterPlugin "google-repo-diff"  # Unregister this plugin, if the gRepo object exists
    googleListView?.cancel()                     # Remove the view from the screen
    googleListView = null                        # Delete the instance
  
  
  observe: ->
    atom.workspace.observeTextEditors (editor) =>
      new GoogleDiffView(editor)  # Create a DiffView for this editor
      
      @toggleCommands[editor.getPath()] ?= atom.commands.add(atom.views.getView(editor), 'google-diff:toggle-diff-list', toggleGoogleList)  # Add the toggle command, if it doesn't already exist
  
  
  # Called to check if this plugin is active
  isActive: -> @active
  
  
  # Called when the 'google-repo' package activates this plugin
  activatePlugin: ->
    return if @active  # If the plugin is already activated, there's no point in continuing
    
    @active = true                                            # State that this plugin is now active
    @subscriptions = new CompositeDisposable                  # Create the subscriptions collection
    @subscriptions.add @gRepo.onRepoListChange => @observe()  # Re-build the observers when the repository list changes
    @observe()                                                # Observe the editor now
  
  
  # Called when the 'google-repo' package deactivates this plugin
  deactivatePlugin: ->
    return unless @active  # If the plugin is already deactivated, there's no point in continuing
    
    @active = false              # State that this plugin is no longer active
    @subscriptions.dispose()     # Dispose of the subscriptions
    @subscriptions = null        # Remove the subscriptions object
    for _, c of @toggleCommands  # For each toggle command...
      c.dispose()                #   Dispose of the object
    @toggleCommands = {}       # Remove the list of toggle commands