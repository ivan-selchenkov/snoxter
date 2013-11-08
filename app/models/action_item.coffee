module.exports = class ActionItem extends Backbone.Model
    get_action: ->
        result = ""

        switch @get("type")
            when 1
                result = "shared"
            when 2
                result = "changed sharing"
            when 3
                result = "disabled sharing"
            when 4
                result = "deleted"
            when 6
                result = "added"
            when 7
                result = "created"

        "you #{result}"

