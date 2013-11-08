FeedView = require 'views/feed_view/feed_view'
PlayerView = require 'views/common/player_view'
FooterView = require 'views/footer_view'

module.exports = class FeedLayoutView extends Backbone.View
  id: 'feedLayout'
  className: 'layout'

  template: require './templates/welcome_layout'

  remove: ->
    @feedView and @feedView.remove()
    @playerView and @playerView.remove()
    @footerView and @footerView.remove()

    Backbone.View.prototype.remove.call(this)

  render: ->
    @$el.html @template

    # Creating and adding feedView
    @feedView = new FeedView
    @$("#sharLayoutRight").html @feedView.render().el

    @playerView = new PlayerView( model: app.player )
    @$('#player_div').html @playerView.render().$el
    @playerView.expand('slow')

    @footerView = new FooterView()
    @$("#sharLayoutFooter").html @footerView.render().$el


    this
