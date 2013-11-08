ActionCollection = require 'models/action_collection'
ActivityItemView = require 'views/activity_item_view'

module.exports = class ActivityView extends Backbone.View

  className: 'activity_view'

  template: require './templates/activity'

  load: ->
    @collection = new ActionCollection()
    @collection.fetch
        success: (collection, response, options) =>
            @$('.loading').remove()

            for model in collection.models
                ai = new ActivityItemView( model: model )
                @$('.tree').append ai.render().$el

            @$('#actdiv').niceScroll 
              cursorborder: "0px"
              cursorwidth: "8px"
              cursoropacitymax: "0.4"        


  render: ->
    @$el.html @template

    @load()

    this
