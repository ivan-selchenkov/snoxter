module.exports = class ToolbarView extends Backbone.View

  className: 'toolbar_view'

  template: require './templates/toolbar'

  render: ->
    @$el.html @template
    this
