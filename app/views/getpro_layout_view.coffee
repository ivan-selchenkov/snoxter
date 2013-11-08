module.exports = class GetproLayoutView extends Backbone.View
  id: 'getproLayout'
  className: 'layout'

  template: require './templates/welcome_layout'

  initialize: ->
    app.vent.on "layouts:hide", @hide

  render: ->
    @$el.html @template

    @$el.find('#sharLayoutLeft').hide()

    @$el.find("#sharLayoutRight").html app.getproView.render().el

    this

  show: =>
    # Adding footer
    @$el.find("#sharLayoutFooter").html app.footerView.el

    app.vent.trigger 'layouts:hide'
    @$el.show()

  hide: =>
    @$el.hide()
  
