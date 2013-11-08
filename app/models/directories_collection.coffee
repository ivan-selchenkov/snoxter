# Getting listing of directories

module.exports = class Directories extends Backbone.Collection
    model: require './folder_item'

    url: ->
        "#{CUST_SERVER}/scripts/v2/directories.cgi?callback=?"
