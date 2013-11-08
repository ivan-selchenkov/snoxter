module.exports = class GetProView extends Backbone.View

  className: 'getpro_view'

  template: require './templates/getpro'

  render: ->
    @$el.html @template
    this
