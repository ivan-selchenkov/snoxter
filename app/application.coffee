Router = require 'routers/router'

Vent = require 'models/vent'
Folder = require 'models/folder_collection'
FolderItem = require 'models/folder_item'
Player = require 'models/player'
Navigator = require 'models/navigator'
Uploads = require 'models/uploads_collection'
UploadItem = require 'models/upload_item'

MenuView = require 'views/menu_view'

ActivityView = require 'views/activity_view'

Events = require 'models/events'

# ************** Trending ****************************

require 'js/jplayer'
require 'js/lib'
require 'js/fileupload'
require 'js/image_editor'

module.exports = class Application

  constructor: ->
    $ =>
      @initialize()
      Backbone.history.start pushState:false

  initialize: (page) ->
    # ******* Welcome Layout *************
    @Folder = Folder
    @FolderItem = FolderItem

    @UploadItem = UploadItem

    @vent = new Vent()
    @events = new Events()
    @navigator = new Navigator()
    @player = new Player()    

    @router = new Router()
    @menuView = new MenuView()
    @activityView = new ActivityView()
    @uploads = new Uploads()

    @pro = true
    @script = "http://json"

    @rigthLayout = $ '#sharLayoutRight'
    @container = $ '#container'

    @render_init()

  render_init: ->
    @jplayer = $('#jquery_jplayer_1')

    @jplayer.jPlayer
        ready: =>
            @player.load_playlists()
            @jplayer.jPlayer "volume", 0.8
        swfPath: "jplayer"
        supplied: "mp3,m4a,oga"
        solution: "flash,html"

    @jplayer.bind $.jPlayer.event.ended, (e) =>
        app.player.trigger "player:next"

    $('#container').prepend @menuView.render().el

window.app = new Application()
$.support.cors = true
window.progressUpdateTimeout = 3000
window.checkFeedTimeout = 3000
app.sharingMode = 1
window.trackingURL = CUST_SERVER + "/utracking"
window.balloonDelay = 1000

window.upload_callback = (json) =>
    #app.uploads.trigger 'progress', json    
