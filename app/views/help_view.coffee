module.exports = class HelpView extends Backbone.View

  className: 'help_view'

  template: require './templates/help'

  render: ->
    @$el.html @template
    this
