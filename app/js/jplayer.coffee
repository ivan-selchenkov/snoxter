$.jPlayer.prototype._cssSelectorAncestor = (ancestor) ->
    @options.cssSelectorAncestor = ancestor
    @_removeUiClass()
    if typeof ancestor is "object"
        @ancestorJq = ancestor
    else
        @ancestorJq = if ancestor then $(ancestor) else [] # Would use $() instead of [], but it is only 1.4+

    if ancestor and this.ancestorJq.length isnt 1
        @_warning
            type: $.jPlayer.warning.CSS_SELECTOR_COUNT
            context: ancestor
            message: $.jPlayer.warningMsg.CSS_SELECTOR_COUNT + this.ancestorJq.length + " found for cssSelectorAncestor."
            hint: $.jPlayer.warningHint.CSS_SELECTOR_COUNT

    @_addUiClass()
    $.each @options.cssSelector, (fn, cssSel) =>
        @_cssSelector fn, cssSel

$.jPlayer.prototype._cssSelector = (fn, cssSel) ->
    if typeof cssSel is 'string'
        if $.jPlayer.prototype.options.cssSelector[fn]

            if @css.jq[fn] and @css.jq[fn].length
                @css.jq[fn].unbind ".jPlayer"
            
            @options.cssSelector[fn] = cssSel;

            @css.cs[fn] = cssSel

            if cssSel
                @css.jq[fn] = $(@css.cs[fn], @ancestorJq)
            else
                @css.jq[fn] = []; # To comply with the css.jq[fn].length check before its use. As of jQuery 1.4 could have used $() for an empty set. 
            
            if @css.jq[fn].length
                # Using jPlayer namespace
                @css.jq[fn].bind "click.jPlayer", (e) =>
                    this[fn] e
                    $(this).blur();
                    false

            if cssSel and @css.jq[fn].length isnt 1 # So empty strings do not generate the warning. ie., they just remove the old one.
                @_warning
                    type: $.jPlayer.warning.CSS_SELECTOR_COUNT
                    context: @css.cs[fn]
                    message: $.jPlayer.warningMsg.CSS_SELECTOR_COUNT + @css.jq[fn].length + " found for " + fn + " method."
                    hint: $.jPlayer.warningHint.CSS_SELECTOR_COUNT
        else
            @_warning
                type: $.jPlayer.warning.CSS_SELECTOR_METHOD
                context: fn
                message: $.jPlayer.warningMsg.CSS_SELECTOR_METHOD
                hint: $.jPlayer.warningHint.CSS_SELECTOR_METHOD
    else
        @_warning
            type: $.jPlayer.warning.CSS_SELECTOR_STRING
            context: cssSel
            message: $.jPlayer.warningMsg.CSS_SELECTOR_STRING
            hint: $.jPlayer.warningHint.CSS_SELECTOR_STRING
###