Playlist = require 'models/playlist'
PlaylistView = require 'views/common/playlist_view'

module.exports = class PlayerView extends Backbone.View

  className: 'player'

  template: require './../templates/common/player'

  events:
    "click #showHideButton": "show_switch"
    "click #volume_control": "volume_control"

    "change #playlist_select": "playlist_changed"
    "click #add_playlist_button": "show_add_playlist"

    "click .playRight": "play_next"
    "click .playLeft": "play_prev"

  initialize: ->
    @model.on "music_item:selected", @set_music_item  
    @model.on "playlists:changed", @render_playlists

    app.vent.on 'playlist:expand', @expand

  play_next: (e) =>
    app.player.trigger "player:next"
    false

  play_prev: (e) =>
    app.player.trigger "player:prev"
    false
    
  create_playlist: (name) =>
    $.ajax
        type: 'POST'
        dataType: 'jsonp'      
        url: "#{CUST_SERVER}/scripts/v2/create_playlist.cgi?session=#{SESSION}&uid=#{UID}"
        data:
          pln: encodeURI(name)
        success: (id) =>
          $playlist = @$el.find('#playlist_select')
          $playlist.append $('<option/>').val(id).text(name)

          @model.get("playlists").add( new Playlist( { id: id, name: name }) )

          $("option[value=#{id}]", $playlist).attr "selected", true
          $playlist.trigger "change"

  show_add_playlist: =>
    @dialog.find('#newpln').val('')

    @dialog.dialog
      buttons: 
        Ok: =>
          playlist_name = $.trim( @dialog.find('#newpln').val() ).substring(0, 15)

          if playlist_name == ""
            return

          @dialog.dialog 'close'
          
          @create_playlist(playlist_name)

  set_music_item: (item, play) =>
    app.player.set "currentItem", item

    @$("#plsn .songName").html item.get("name")

    app.jplayer.jPlayer "clearMedia"

    app.jplayer.jPlayer "setMedia", { mp3: "/v2/getfile.php?fn=#{item.get("file")}" }

    if play
      app.jplayer.jPlayer "play"

  volume_control: (e) ->
    x = e.pageX - $(e.currentTarget).offset().left

    prc = (x * 100) / 20
    if x >= 18
      prc = 100

    @$('#vce1, #vce2, #vce3').removeClass()

    if prc > 15  and prc <= 30
      @$('#vce1').addClass 'halfloud'    
    else if prc > 30
      @$('#vce1').addClass 'loud'

    if prc > 45 and prc <= 60
      @$('#vce2').addClass 'halfloud'
    else if prc > 60
      @$('#vce2').addClass 'loud'
    
    if prc > 75 and prc <= 90
      @$('#vce3').addClass 'halfloud'
    else if prc > 90
      @$('#vce3').addClass 'loud'

    app.jplayer.jPlayer "volume", prc / 100

    e.preventDefault()

    false    

  show_switch: (e) ->
    if @$('#plistd').is(':hidden')      
      @expand()
    else
      @collapse()

    app.vent.trigger "toogle:player"

    e.preventDefault()
    false

  hide: ->
    @$el.hide()

  show: ->
    @$el.show()

  expand: (speed) =>
    @$('#plistd').show()
    app.vent.trigger 'navigator:resize'    

  collapse: (speed) =>
    @$('#plistd').hide()
    app.vent.trigger 'navigator:resize'    

  init: =>
    app.jplayer.jPlayer "option", "cssSelectorAncestor", @$("#jp_interface_1")
    app.jplayer.jPlayer "option", "cssSelector", {
      play: ".play"
      pause: ".pause"
      mute: ".ruporOn"
      unmute: ".ruporOff"
      currentTime: ".time"
      seekBar: ".progressA"
      playBar: ".progressOn"      
    }

    if app.jplayer.data("jPlayer").status.paused
      @$('#jp_interface_1 .play').show()
      @$('#jp_interface_1 .pause').hide()
    else
      @$('#jp_interface_1 .play').hide()
      @$('#jp_interface_1 .pause').show()

  remove: ->
    @$('#plistdiv').getNiceScroll().hide()        
    @playlist_view and @playlist_view.remove()
    Backbone.View.prototype.remove.call this    

  # fill in playlist select
  render_playlists: =>
    @$('#playlist_select').html ""

    for playlist in @model.get("playlists").models
      name = playlist.get('name')

      if name.length > 18
        name = name.substring(0, 18) + "..."

      @$('#playlist_select').append $('<option/>').val(playlist.get('id')).text name

    selectedPlaylist = app.player.get("selectedPlaylist")

    # select previous selected playlist or 
    if selectedPlaylist
      @$("#playlist_select option[value=#{selectedPlaylist}]").attr "selected", true
    else
      @$("#playlist_select option:first").attr "selected", true

    @playlist_changed()

  playlist_changed: =>
    playlist_id = @$('#playlist_select option:selected').val()

    app.player.set "selectedPlaylist", playlist_id

    currentPlaylist = @model.get("playlists").findWhere id: +playlist_id

    unless currentPlaylist
      return

    @model.set "currentPlaylist", currentPlaylist

    @render_current_playlist()

  render_current_playlist: ->
    playlist = @model.get("currentPlaylist")

    @$('#playlist_name').text playlist.get('name')
    
    @playlist_view = new PlaylistView model: @model, collection: playlist

    @$('#plistdiv')
      .html(@playlist_view.render().el)
      .niceScroll( 
        cursorborder: "0px"
        cursorwidth: "8px"
        cursoropacitymax: "0.4"        
      )


  render: ->
    @$el.html @template

    @dialog = @$el.find("#new_playlist_dialog")

    @init()

    if @model.get('playlists')
      @render_playlists()

    this
