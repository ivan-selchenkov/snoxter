module.exports = class MenuView extends Backbone.View
  className: 'menu'

  template: require './templates/menu'

  initialize: ->
    app.vent.on "menu:feed_events", @update_feed_events

  update_feed_events: (number_of_events) =>
    if number_of_events > 0
      @$('#badge2').text number_of_events
      @$('#badge1').show()
    else
      @$('#badge1').hide()

  selectTab: (name) ->
    @unselectAllTabs()
    @$el.find("#menu_" + name).addClass("active");

  unselectAllTabs: ->
   	@$el.find("li").removeClass("active");

  render: ->
    @$el.html @template
    this
