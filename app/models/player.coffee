PlaylistsCollection = require './playlists_collection'

module.exports = class Player extends Backbone.Model
    defaults:
        isExpanded: false

    initialize: ->
        @on "player:next", @next
        @on "player:prev", @prev

    next: =>
        finded = false
        next = false

        currentPlaylist = @get("currentPlaylist")

        for item in currentPlaylist.get("items").models
            if finded
                next = item
                break

            if item == @get("currentItem")
                finded = true

        if currentPlaylist.get("items").models[0] and not next
            next = currentPlaylist.get("items").models[0]

        if next
            @trigger "player:click_next", next

    prev: =>
        prev = false

        currentPlaylist = @get("currentPlaylist")

        for item in currentPlaylist.get("items").models
            if item == @get("currentItem")
                break

            prev = item

        if prev
            @trigger "player:click_prev", prev
            
    load_playlists: ->
        $.ajax
            dataType: "jsonp"
            url: "#{CUST_SERVER}/scripts/v2/getpls.cgi?callback=?&uid=#{UID}&session=#{SESSION}"
            success: (json) =>
                @set "playlists", new PlaylistsCollection(json)
                @trigger "playlists:changed"
