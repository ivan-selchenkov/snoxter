HelpView = require 'views/help_view'
PlayerView = require 'views/common/player_view'
FooterView = require 'views/footer_view'

module.exports = class HelpLayoutView extends Backbone.View
  id: 'feedLayout'
  className: 'layout'

  template: require './templates/welcome_layout'

  remove: ->
    @helpView and @helpView.remove()
    @playerView and @playerView.remove()
    @footerView and @footerView.remove()

    Backbone.View.prototype.remove.call(this)


  render: ->
    @$el.html @template

    @helpView = new HelpView()
    @$("#sharLayoutRight").html @helpView.render().$el

    @playerView = new PlayerView( model: app.player )
    @$('#player_div').html @playerView.render().$el
    @playerView.expand('slow')

    @footerView = new FooterView()
    @$("#sharLayoutFooter").html @footerView.render().$el

    this

