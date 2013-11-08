module.exports = class Folder extends Backbone.Collection
    model: require './folder_item'

    url: ->
        "#{CUST_SERVER}/scripts/v2/dir.cgi?callback=?"

    parse: (data) =>
        window.USED_SPACE = data.sused

        app.vent.trigger "footer:used_space"
        Backbone.Collection.prototype.parse.call(this, data.data)
