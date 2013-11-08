WelcomeLayoutView = require 'views/welcome_layout_view'
ViewerLayoutView = require 'views/viewer_layout_view'
EditorLayoutView = require 'views/editor_layout_view'
TrendingLayoutView = require 'views/trending_layout_view'
FeedLayoutView = require 'views/feed_layout_view'
ToolbarLayoutView = require 'views/toolbar_layout_view'
HelpLayoutView = require 'views/help_layout_view'
ActivityLayoutView = require 'views/activity_layout_view'

module.exports = class Router extends Backbone.Router

  routes:
    '': 'index'
    '_=_': 'index'
    'path/*path': 'index'
    'search/:query(/:type)': 'search'
    'trending': 'trending'
    'feed': 'feed'
    'toolbar': 'toolbar'
    'help': 'help'
    'getpro': 'getpro'
    'activity': 'activity'
    'view/:hash/:uid/:from': 'viewer'
    'view/:hash/:uid': 'viewer'
    'view/:hash': 'viewer'
    'edit/:hash': 'editor'
    '*all': 'redirect'


  changeActivity: (newActivity) ->
    if app.currentActivity
      app.currentActivity.remove()

    app.currentActivity = newActivity

  index: (path) ->
    console.log "index"

    if window.CUSTOM_PAGE
      page = window.CUSTOM_PAGE
      window.CUSTOM_PAGE = false
      @navigate page, trigger: true
      return

    path = "" unless path

    path = decodeURI path

    if app.currentActivity instanceof WelcomeLayoutView
      app.navigator.change_folder path
    else
      app.menuView.selectTab "my_sharium"

      @changeActivity new WelcomeLayoutView path: path

      $('#container').append app.currentActivity.render().el

  search: (query, type) ->
    query = "" unless query
    type = "" unless type

    query = decodeURI query

    if app.currentActivity instanceof WelcomeLayoutView
      app.navigator.search_request query, type
    else
      app.menuView.selectTab "my_sharium"

      @changeActivity new WelcomeLayoutView search: { type: type, query: query }

      app.container.append app.currentActivity.render().el

  viewer: (hash, uid, from) ->
    if app.currentActivity instanceof ViewerLayoutView
      uid = UID unless uid

      app.currentActivity.change hash: hash, uid: uid
    else
      # app.menuView.selectTab "my_sharium"

      @changeActivity new ViewerLayoutView hash: hash, uid: uid
      app.container.append app.currentActivity.render().$el

  editor: (hash, uid) ->
      app.menuView.selectTab "my_sharium"

      @changeActivity new EditorLayoutView hash: hash
      app.container.append app.currentActivity.render().$el


  trending: ->
    unless app.currentActivity instanceof TrendingLayoutView
      app.menuView.selectTab "trending"

      @changeActivity new TrendingLayoutView
      app.container.append app.currentActivity.render().$el

  feed: ->
    unless app.currentActivity instanceof FeedLayoutView
      app.menuView.selectTab "feed"

      @changeActivity new FeedLayoutView
      app.container.append app.currentActivity.render().$el

  toolbar: ->
    unless app.currentActivity instanceof ToolbarLayoutView
      app.menuView.selectTab "toolbar"

      @changeActivity new ToolbarLayoutView
      app.container.append app.currentActivity.render().$el

  help: ->
    unless app.currentActivity instanceof HelpLayoutView
      app.menuView.selectTab "help"

      @changeActivity new HelpLayoutView
      app.container.append app.currentActivity.render().$el

  activity: ->
    unless app.currentActivity instanceof ActivityLayoutView
      app.menuView.selectTab "my_sharium"

      @changeActivity new ActivityLayoutView
      app.container.append app.currentActivity.render().$el

  redirect: (action) ->
    @index()
