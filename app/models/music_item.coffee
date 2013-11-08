module.exports = class MusicItem extends Backbone.Model
    display_song: ->
        len = 25

        name = @get('song')

        if name.length > len
            name = name.substring(0, len) + "..."

        name        
