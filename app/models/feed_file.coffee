module.exports = class FeedFile extends Backbone.Model
    defaults:
        filename: undefined
        hash: undefined
        type: undefined
        path: undefined


    display_name: ->
        len = 20

        name = @get('filename')

        if name.length > len
            name = name.substring(0, len) + "..."

        name