ToolbarView = require 'views/toolbar_view'
PlayerView = require 'views/common/player_view'
FooterView = require 'views/footer_view'

module.exports = class ToolbarLayoutView extends Backbone.View
  id: 'toolbarLayout'
  className: 'layout'

  template: require './templates/welcome_layout'

  remove: ->
    @toolbarView and @toolbarView.remove()
    @playerView and @playerView.remove()
    @footerView and @footerView.remove()

    Backbone.View.prototype.remove.call(this)

  render: ->
    @$el.html @template

    @toolbarView = new ToolbarView()
    @$el.find("#sharLayoutRight").html @toolbarView.render().el

    @playerView = new PlayerView( model: app.player )
    @$('#player_div').html @playerView.render().$el
    @playerView.expand('slow')

    @footerView = new FooterView()
    @$("#sharLayoutFooter").html @footerView.render().$el

    this
