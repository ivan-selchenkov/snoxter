FeedCollection = require 'models/feed_collection'
FeedItemView = require 'views/feed_view/feed_item_view'

module.exports = class FeedView extends Backbone.View
  className: 'feed'
  template: require './templates/main'

  remove: ->
    app.feedNiceScroll.hide()
    Backbone.View.prototype.remove.call(this)


  render: ->
    feed_collection = new FeedCollection
    feed_collection.fetch()

    feed_collection.on "success", (collection) =>
        @$el.html ""
        for feed_item in collection.models
            @$el.append new FeedItemView( model: feed_item ).render().el

        @$el.niceScroll 
            cursorborder: "0px"
            cursorwidth: "8px"
            cursoropacitymax: "0.4"        

        app.feedNiceScroll = @$el.getNiceScroll()  

    @$el.html @template
    this
