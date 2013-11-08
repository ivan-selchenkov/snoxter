module.exports = class TrendingCollection extends Backbone.Collection
    model: require './trend_item'

    load: (callback) ->
        $.ajax
            url: "/v2/gettrend.php"
            dataType: "jsonp"
            success: (json) =>
                @add json

                callback() if callback

