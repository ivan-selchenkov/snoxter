MusicItemsCollection = require './music_items_collection'

module.exports = class PlaylistItem extends Backbone.Model
    initialize: (attrs, options) ->
        @set 'items', new MusicItemsCollection attrs.items
