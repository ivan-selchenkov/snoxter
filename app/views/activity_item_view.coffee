module.exports = class ActivityItemView extends Backbone.View

  className: 'activity_item_view'
  tagName: 'li'

  template: require './templates/activity_item'

  render: ->
    @$el.html @template(model: @model)
    this
