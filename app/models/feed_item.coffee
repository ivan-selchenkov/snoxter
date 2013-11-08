FeedFile = require 'models/feed_file'

module.exports = class FeedItem extends Backbone.Model
    defaults:
        friend_name: "Unknown user"
        fbid: "0"

    initialize: (data) =>
        for share in data.shares
            files = []

            for file in share.files
                files.push(new FeedFile file)

            share.files = files

        @set data
