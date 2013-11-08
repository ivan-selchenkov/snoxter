module.exports = class ViewerItems extends Backbone.Collection
    model: require './viewer_item'

    url: "/v2/viewer_files.php?callback=?"
        
