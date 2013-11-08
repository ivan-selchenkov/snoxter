module.exports = class PlaylistView extends Backbone.View
    tagName: "ul"
    className: "songsList"
    id: "playlist"

    template: require './../templates/common/playlist'

    events:
        "click li[song-id]": "song_selected"

    initialize: ->
        @model.on "player:click_next", @click_next_prev
        @model.on "player:click_prev", @click_next_prev

    click_next_prev: (item) =>
        id = item.get("id")
        @$("li[song-id=#{id}]").trigger "click", true

    render: ->
        @$el.html @template(models: @collection.get('items').models)        

        currentItem = app.player.get "currentItem"

        unless currentItem
            @$("li[song-id]:first").trigger "click", false
        else
            id = currentItem.get('id')
            @$("li[song-id=#{id}]").addClass "selected"

        this

    song_selected: (e, play = true) ->
        @$el.find("li[song-id]").removeClass "selected"
        $(e.currentTarget).addClass "selected"
        song_id = $(e.currentTarget).attr "song-id"
        music_item = @collection.get('items').where id: +song_id

        if music_item.length > 0
            @model.trigger "music_item:selected", music_item[0], play
        
