FeedShareView = require 'views/feed_view/feed_share_view'

module.exports = class FeedItemView extends Backbone.View
  className: 'feed_item'
  template: require './templates/item'

  render: ->
    @$el.html @template(item: @model)

    for share in @model.get 'shares'
        share_view = new FeedShareView(model: share)
        @$el.append share_view.render().el

    this
