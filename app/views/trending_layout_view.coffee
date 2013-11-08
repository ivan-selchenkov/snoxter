TrendingView = require 'views/trending_view'
FooterView = require 'views/footer_view'

module.exports = class TrendingLayoutView extends Backbone.View
  id: 'trandingLayout'
  className: 'layout'

  template: require './templates/welcome_layout'

  initialize: ->
    app.vent.on "layouts:hide", @hide

  remove: ->
    @footerView and @footerView.remove()    
    @trendingView and @trendingView.remove()

    Backbone.View.prototype.remove.call(this)

  render: ->
    @$el.html @template

    # Creating and adding TrendingView
    @trendingView = new TrendingView()

    @$('#sharLayoutLeft').remove()
    @$("#sharLayoutRight").html @trendingView.render("full", 134).$el

    @footerView = new FooterView()
    @$("#sharLayoutFooter").html @footerView.render().$el


    this
