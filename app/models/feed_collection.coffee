FeedItem = require 'models/feed_item'

module.exports = class Feed extends Backbone.Collection
    model: require './feed_item'

    fetch: (options) ->
        $.ajax
            url: "/v2/getfeed.php"
            dataType: "jsonp"
            success: (json) =>
                for item in json
                    @add new FeedItem item

                @trigger "success", this
