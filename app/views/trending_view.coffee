TrendCollection = require 'models/trend_collection'

module.exports = class TrendingView extends Backbone.View
  id: 'tranding_view'

  events:
    "scroll": "scroll"

  scroll: =>
    scrollTop = +@$el.scrollTop()
    scrollHeight = +@$el.prop("scrollHeight")
    height = +@$el.height()

    mayLoadContent = ( scrollTop + height >= scrollHeight - 10 ) and not @loading

    if mayLoadContent
      @refresh()

  initialize: ->
    @collection = new TrendCollection()
    @loading = false
    @last_size = 0
    @imageSize = 0

  refresh: ->
    @loading = true

    @collection.load =>
        @ul.find('li.loading').remove()

        @render_list(@last_size)

        @last_size = @collection.length

        @$el.getNiceScroll().resize()        

        @loading = false

  render_list: (from = 0) ->
    for item in @collection.models[from..]
        srv = item.get "srv"
        sub = item.get "sub"
        uid = item.get "uid"
        hash = item.get "hash"

        if SKIP_CUST
            link = "#{CUST_SERVER}/users/#{sub}/#{uid}/THUMBS/#{hash}.jpg"
        else
            link = "#{CUST_HTTP}#{CUST_PREFIX}#{srv}.#{DOMAIN}/users/#{sub}/#{uid}/THUMBS/#{hash}.jpg"

        @ul.append(
            $('<li/>').append(
                $('<a/>').attr("href", "#view/#{hash}/#{uid}").append(
                    $('<div/>').append(                    
                        $('<img/>').attr('src', link )
                    ).addClass('clip_image_box135').Scale( size: @imageSize )
                )
            )
        )

  remove: ->
    @$el.getNiceScroll().hide()
    Backbone.View.prototype.remove.call this

  render: (css_class, imageSize) ->
    @imageSize = imageSize

    @ul = $('<ul/>')
    @$el.html @ul.append(
      $('<li/>').addClass("loading").html "Loading..."
    )

    @$el.niceScroll 
        cursorborder: "0px"
        cursorwidth: "8px"
        cursoropacitymax: "0.4"        

    @$el.removeClass()

    @$el.addClass css_class

    @refresh()

    this

