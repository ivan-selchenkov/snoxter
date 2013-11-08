module.exports = class ViewerFileItemView extends Backbone.View
  tagName: 'li'
  className: 'viewer_file_item'

  template: require './templates/viewer_file_item'

  events:
    "click": "click"

  initialize: ->
    app.vent.on 'viewer_file_item:unselect', @unselect

    @model.on "item:selected", @select

  click: =>
    @select()

    #app.vent.trigger 'viewer_file_item:select', @model

    if UID == @model.get('uid')
      url = 'view/' + @model.get('hash')
    else
      url = 'view/' + @model.get('hash') + '/' + @model.get('uid')

    app.router.navigate url, trigger: true


  select: =>
    # reset selected item
    app.vent.trigger 'viewer_file_item:unselect'
    @$el.addClass 'selected'

  unselect: =>
    @$el.removeClass 'selected'

  render: ->
    @$el.html @template( model: @model )

    @$('.clip_image_box60').Scale( size: 60 )

    this
