Directories = require 'models/directories_collection'


module.exports = class ViewerAddDialogView extends Backbone.View
  id: 'viewerAddDialogView'

  template: require './templates/viewer_add_file'

  events:
    "click #add_file_button": "add_atom"

  initialize: ->
    @directories = new Directories()
    @directories.on 'sync', @directories_loaded

  add_atom: =>
    folder_hash = @mufol.find("option:selected").val()
    folder_text = @mufol.find("option:selected").text()

    return if folder_hash == ""

    share = ''

    if @$('#ishare2').is(":checked")
      share = 'friends'

    play = ''

    if @$('#iplay').is(":checked")
      play = @$('#apls option:selected').val()

    @$el.html("<span id='wait_message'>File processing...</a>")

    $.ajax
      type: 'POST'
      url: '/v2/atoms.php'
      dataType: 'jsonp'
      data:
        PHPSESSID: SESSION
        uid: @model.get('uid')
        hash: @model.get('hash')
        dst: folder_text
        share: share
        play: play
      complete: =>
        @$el.dialog 'close'
        app.player.load_playlists()
        app.router.navigate "path/#{folder_text}", trigger: true


  directories_loaded: () =>
    @mufol.html("")

    for model in @directories.models
      @mufol.append(
        $('<option/>').attr('value', model.get('hash')).text( model.get('filepath') )
      )

  fill_playlists: =>
    $apls = @$('#apls')

    $apls.html("")

    for model in app.player.get('playlists').models
      $apls.append(
        $('<option/>').attr('value', model.get('id')).text( model.get('name') )
      )

  show: ->
    @$el.dialog 'open'
    @directories.fetch
      data:
        session: SESSION
        uid: UID
    
    if @model.get('type') == "1"
      @fill_playlists()    

  render: ->
    @$el.html @template
    @$el.attr 'title', 'Add to My Snoxter'

    @mufol = @$('#mufol')

    $('body').append @$el

    if @model.get('type') == "1"
      @$('#addmusic').show()
    else
      @$('#addmusic').hide()    

    @$el.dialog
      autoOpen: false
      resizable: false
      draggable: true
      #height: 195
      width:370
      modal: true
      position: 'center'

    this  
