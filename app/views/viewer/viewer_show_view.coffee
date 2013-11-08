AddDialogView = require './viewer_add_dialog_view'

module.exports = class ViewerShowView extends Backbone.View
  id: 'viewerShowView'

  template: require './templates/viewer_show'
  playerTemplate: require './templates/viewer_player'
  videoPlayerTemplate: require './templates/video_player'

  events:
    "click #edbtn": "editor"
    "click #like_button": "like_button"
    "click #addtoms": "add_me_file"
    "click #backb": "go_back"

  initialize: ->
    app.vent.on 'viewer_file_item:select', @update

  go_back: =>
    app.router.navigate '#path/' + encodeURI(app.navigator.get('url')), trigger: true

  like_button: =>

    if @$('#like_button').hasClass 'liked'
      post = 0
    else
      post = 1

    @$('#like_button').attr 'disabled', true

    $.ajax
      type: "GET"
      url: "/v2/post_like.php"
      dataType: "jsonp"
      data: 
        PHPSESSID: SESSION
        fuid: @model.get('uid')
        fhash: @model.get('hash')
        fbpost: post
      success: =>
        @$('#like_button').removeAttr 'disabled'

        if post == 1
          @$('#like_button').removeClass('like').addClass 'liked'
          @$('#likes').text +@$('#likes').text() + 1
        else
          @$('#like_button').removeClass('liked').addClass 'like'
          @$('#likes').text +@$('#likes').text() - 1

  add_me_file: =>
    @dialog.show()


  prepare_dialog: (model) ->
    @dialog.remove() if @dialog
    @dialog = new AddDialogView( model: model )
    @dialog.render()

  volume_control: (e) =>
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

    @jplayer.jPlayer "volume", prc / 100

    false
    e.preventDefault()

  update: (model) =>    
    @model = model

    if model.is_my()
      @$('#sharedFile').hide()
      @$('#myFile').show()
      @$('#backb').show()
      @$('#addtoms').hide()

      @$('#myFile .filename').text model.get_path()
      @$('#myFile .filetype').text model.get_type()
      @$('#myFile .size').text model.get('size')

      url = encodeURI(model.get_path())

      @$('#dlorig').attr('href', "/v2/getfile.php?hash=#{model.get('hash')}&attachment=1")

      if model.get("type") == "3"
        @$('#edbtn').show()
      else
        @$('#edbtn').hide()

    else
      @prepare_dialog(model)

      @$('#edbtn').hide()

      @$('#sharedFile').show()
      @$('#myFile').hide()
      @$('#backb').hide()
      @$('#addtoms').show()

      @$('#sharedFile .owner_name').text model.get('username')
      @$('#sharedFile .avatar').attr 'src', "https://graph.facebook.com/#{model.get('fbid')}/picture"
      @$('#sharedFile .shared_filename').text model.get('filename')
      @$('#sharedFile .shared_description').text model.get_type()

    url = encodeURI(model.get_path())
    @$('#dlorig').attr('href', "/v2/getfile.php?hash=#{model.get('hash')}&uid=#{model.get('uid')}&attachment=1")

    if model.get('type') == "2"
      # Video Player
      @container.html @videoPlayerTemplate()

      @jplayer = @$('#jquery_jplayer_2')

      @$('#volct1').click @volume_control

      @jplayer.jPlayer
        ready: =>
          @jplayer.jPlayer "setMedia", { m4v: "/v2/getfilewv.php?hash=#{model.get('hash')}&uid=#{model.get('uid')}" }
        solution:"flash,html"
        swfPath: "jplayer"
        supplied: "m4v"
        wmode: "opaque"
        size:
          width: "552px"
          height: "310px"
          cssClass: "jp-video-360p"

      @jplayer.jPlayer "option", "cssSelectorAncestor", @$("#jp_interface_2")

      @jplayer.jPlayer "option", "cssSelector", {
        play: ".play",
        pause: ".pause",
        mute: ".ruporOn",
        unmute: ".ruporOff",
        currentTime: ".time",
        seekBar: ".progressA",
        playBar: ".progressOn"
      }
    else if model.get('type') == "1"
      # Audio Player
      @container.html @playerTemplate()

      @jplayer = @$('#jquery_jplayer_2')

      @$('#volct1').click @volume_control

      url = encodeURI(model.get_path())

      @jplayer.jPlayer
        ready: =>
            @jplayer.jPlayer "volume", 0.8
            @jplayer.jPlayer "clearMedia"
            @jplayer.jPlayer "setMedia", { mp3: "/v2/getfile.php?hash=#{model.get('hash')}&uid=#{model.get('uid')}" }
            @jplayer.jPlayer "play"
        swfPath: "jplayer"
        supplied: "mp3,m4a,oga"
        solution: "flash,html"
        errorAlerts: true
        # warningAlerts: true

      @jplayer.jPlayer "option", "cssSelectorAncestor", @$("#jp_interface_2")
      @jplayer.jPlayer "option", "cssSelector", {
        play: ".play"
        pause: ".pause"
        mute: ".ruporOn"
        unmute: ".ruporOff"
        currentTime: ".time"
        seekBar: ".progressA"
        playBar: ".progressOn"      
      }
    else
      $img = $('<img/>').attr('src', model.get_preview_path())
      $img.css position: 'absolute', top: -10000, left: -10000

      $img.on 'load', =>
        padding = 20

        cWidth = @container.width()
        cHeight = @container.height()

        iWidth = $img.width()
        iHeight = $img.height()

        coef_x = iWidth / ( cWidth - 20 )
        coef_y = iHeight / ( cHeight - 20 )

        coef = 1

        if coef_x > 1 or coef_y > 1
          coef = if coef_x > coef_y then coef_x else coef_y

        new_iWidth = iWidth / coef
        new_iHeight = iHeight / coef

        $img.css
          width: new_iWidth
          height: new_iHeight
          top: ( cHeight - new_iHeight ) / 2
          left: ( cWidth - new_iWidth ) / 2

      @container.html $img

    @$('#lbtntop').hide()

    $.ajax
      type: "GET"
      url: "/v2/check_lc.php"
      dataType: "jsonp"
      data: 
        PHPSESSID: SESSION
        fuid: model.get('uid')
        fhash: model.get('hash')
      success: (data) =>
        @$('#lbtntop').show()

        if data.nlike > 0
          @$('#likes').text data.nlike
        else
          @$('#likes').text 0

        if data.liked
          @$('#like_button').removeClass('like').addClass 'liked'
        else
          @$('#like_button').removeClass('liked').addClass 'like'

  remove: ->    
    @dialog.remove() if @dialog
    Backbone.View.prototype.remove.call(this)


  editor: =>
    app.router.navigate 'edit/' + @model.get('hash'), trigger: true

  render: ->
    @$el.html @template

    @container = @$('#showContainer')

    this  
