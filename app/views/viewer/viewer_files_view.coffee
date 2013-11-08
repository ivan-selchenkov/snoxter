ViewerFileItemView = require 'views/viewer/viewer_file_item_view'

module.exports = class ViewerFilesView extends Backbone.View
  id: 'viewer_files_view'

  template: require './templates/viewer_files'

  initialize: (options) ->
    @collection = options.collection
    @collection.on "sync", @synced

  fetch: ->
    @collection.fetch
      data:
        hash: @options.hash 
        uid: @options.uid             

  synced: =>
    @$('.loading').remove()

    for item in @collection.models
        item_view = new ViewerFileItemView( model: item )

        @ul.append(
            item_view.render().$el
        )

    @$('#filesContainer').getNiceScroll().resize()

    @select_item()

  select_item: =>
    viewing_item = @collection.findWhere hash: @options.hash, uid: @options.uid

    unless viewing_item
      for item in @collection.models
        if item.get("type") != "10"
          viewing_item = item
          break

    if viewing_item
      viewing_item.select()

      if viewing_item.get('uid') == UID   
        folder = viewing_item.get('folder')

        folder = "/" unless folder

        @$('#showed_folder').html "Folder <b>" + folder + "</b>"
      else
        @$('#showed_folder').text "Shared files by " + viewing_item.get('username')

      app.vent.trigger 'viewer_file_item:select', viewing_item

  update: (o) ->
    @options = o

    item = @collection.findWhere(hash: o.hash, uid: o.uid)

    if item and item.get_type() != "Folder"
      @select_item()
    else
      @ul.html(
          $('<li/>').addClass("loading").html('Loading...')
      )
      @fetch()

  remove: ->
    @$('#filesContainer').getNiceScroll().hide()
    Backbone.View.prototype.remove.call this

  render: ->
    @$el.html @template

    @ul = @$('#filesContainer ul')

    @$("#filesContainer").niceScroll 
      cursorborder: "0px"
      cursorwidth: "8px"
      cursoropacitymax: "0.4"        

    @ul.append(
        $('<li/>').addClass("loading").html('Loading...')
    )

    @fetch()

    this

