module.exports = class Events extends Backbone.Model
    initialize: ->
        @start_requests()

    start_requests: ->
        if @last_request and @last_request.state() == "pending"
            setTimeout( (=> @start_requests() ), window.checkFeedTimeout )
            return       

        @last_request = $.ajax
            dataType: "jsonp"
            url: "/v2/chkfeed.php?callback=?"
            success: (json) =>
                app.vent.trigger "menu:feed_events", json.events_count

                window.CSPACE = json.total_space

                app.vent.trigger "footer:total_space"

                setTimeout( (=> @start_requests() ), window.checkFeedTimeout )
