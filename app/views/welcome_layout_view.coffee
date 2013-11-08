UploadInputView = require 'views/welcome_layout/upload_input_view'
NavigatorView = require 'views/welcome_layout/navigator_view'
PlayerView = require 'views/common/player_view'
FooterView = require 'views/footer_view'


module.exports = class WelcomeLayoutView extends Backbone.View
  id: 'navigator'
  className: 'layout'

  template: require './templates/files_layout'

  events:
    "click #mode_only_me": "mode_only_me"
    "click #mode_friends": "mode_friends"
    "click #mode_custom": "mode_custom"

  initialize: ->
    app.vent.on "layouts:hide", @hide
    app.vent.on "navigator:toggle_mode_select", @toggle_mode_select
    app.vent.on "toogle:player", @toogle_player


  toogle_player: =>
    $player_block = @$('.player_block')
    $main_block = @$('.main_block')

    unless $player_block.hasClass('expanded')
      $player_block.addClass 'expanded'
      $main_block.addClass 'collapsed'
      # app.vent.trigger 'playlist:expand'
    else
      $player_block.removeClass 'expanded'
      $main_block.removeClass 'collapsed'

  toggle_mode_select: =>
      @$('#sharing_mode').toggle()

  mode_only_me: =>
    app.sharingMode = 0
    @render_mode()

  mode_friends: =>
    app.sharingMode = 1
    @render_mode()

  mode_custom: =>
    app.sharingMode = 2
    @render_mode()

  get_sharing_class: ->    
    switch app.sharingMode
      when 0 then 'mode_only_me'
      when 1 then 'mode_friends'
      when 2 then 'mode_custom'

  render_mode: ->
    sharingClass = @get_sharing_class()

    @$('#sharing_mode')
      .removeClass()
      .addClass sharingClass

    app.vent.trigger 'navigator:sharing_mode_changed', sharingClass

  remove: ->
    @uploadInputView.remove()
    @navigatorView.remove()
    @playerView.remove()
    @footerView.remove()

    Backbone.View.prototype.remove.call this

  render: ->
    @$el.html @template

    @render_mode()

    @$el.attr('unselectable','on').css('UserSelect','none').css('MozUserSelect','none')

    # Creating and adding FilesView
    if @options.path
      app.navigator.set( url: @options.path, forceReload: true ) 
    else
      app.navigator.set( url: "", forceReload: true ) 

    @uploadInputView = new UploadInputView
    @$('.helpContainerRight').html @uploadInputView.render().$el

    @navigatorView = new NavigatorView( model: app.navigator, search: @options.search )
    @$el.find(".main_block").html @navigatorView.render().$el

    @playerView = new PlayerView( model: app.player )
    @$el.find('.player_block').html @playerView.render().$el

    @footerView = new FooterView()
    @$el.find(".footer").html @footerView.render().$el

    this
