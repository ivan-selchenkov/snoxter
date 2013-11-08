ActivityView = require 'views/activity_view'
PlayerView = require 'views/common/player_view'
FooterView = require 'views/footer_view'

module.exports = class ActivityLayoutView extends Backbone.View
  id: 'activityLayout'
  className: 'layout'

  template: require './templates/welcome_layout'

  remove: ->
    @activityView and @activityView.remove()
    @playerView and @playerView.remove()
    @footerView and @footerView.remove()

    Backbone.View.prototype.remove.call(this)

  render: ->
    @$el.html @template

    # Creating and adding feedView
    @activityView = new ActivityView
    @$("#sharLayoutRight").html @activityView.render().el

    @playerView = new PlayerView( model: app.player )
    @$('#player_div').html @playerView.render().$el
    @playerView.expand('slow')

    @footerView = new FooterView()
    @$("#sharLayoutFooter").html @footerView.render().$el

    this
