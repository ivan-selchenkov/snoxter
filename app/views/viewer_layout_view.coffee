TrendingView = require 'views/trending_view'

ViewerFilesView = require 'views/viewer/viewer_files_view'
ViewerShowView = require 'views/viewer/viewer_show_view'

FooterView = require 'views/footer_view'

ViewerItems = require 'models/viewer_items_collection'

module.exports = class ViewerLayoutView extends Backbone.View
  id: 'viewerLayout'

  template: require './templates/viewer_layout'

  remove: =>
    @trendingView and @trendingView.remove()
    @viewerFilesView and @viewerFilesView.remove()    
    @footerView and @footerView.remove()    
    @viewerShowView and @viewerShowView.remove()

    Backbone.View.prototype.remove.call(this)

  change: (o) ->
    @viewerFilesView.update o

  render: ->
    @$el.html @template

    @trendingView = new TrendingView

    @$("#trendingContainer").html @trendingView.render("small", 90).$el
    @trendingView.refresh()

    @viewerItems = new ViewerItems
    
    uid = if @options.uid then @options.uid else UID

    # Creating and adding ViewerView
    @viewerFilesView = new ViewerFilesView
      hash: @options.hash
      uid: uid
      collection: @viewerItems

    @$("#filesBlock").html @viewerFilesView.render().$el

    @viewerShowView = new ViewerShowView collection: @viewerItems
    @$('#viewerLeft').html @viewerShowView.render().$el


    @footerView = new FooterView()
    @$("#viewerFooter").html @footerView.render().$el

    this  
