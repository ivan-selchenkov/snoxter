module.exports = class FolderItem extends Backbone.Model
    defaults:
        name: ""
        path: ""
        type: "none"
        contains: "Empty folder"
        sharing: "none"
        root: false
        checked: false

    load_link_code: ->
        $.ajax(
            type: 'GET'
            dataType: 'jsonp'
            url: "#{CUST_SERVER}/scripts/v2/getlink.cgi?callback=?"
            data:
                session: SESSION
                uid: UID
                hash: @get('hash')
        ).success (res) =>
            @set "lcode", res

    toggleCheck: ->
        @set 'checked', not @get('checked')

    get_sharing_type: ->
        if @get("sharing") == "friends"
            result = 1
        else if /[0-9,]/.test( @get("sharing") )
            result = 2
        else
            result = 0

    set_sharing_mode: ( new_state, request, callback ) ->

        switch new_state
            when 0
                sharing = '-'
            when 1
                sharing = 'friends'
            when 2
                sharing = request.to.join(',')

        $.ajax(
            url: '/v2/updateaccess.php'
            data:
                PHPSESSID: SESSION
                hash: @get('hash')
                old: @get('sharing')
                'new': sharing
                reqid: request.request
        ).success( =>
            @set "sharing", sharing
            @trigger "folder_item:access_update"
            callback()
        )       


    get_sharing_icon: ->
        result = "/imgs/sharing_private.png"

        switch @get_sharing_type()
            when 1
                result = "/imgs/sharing_friends.png" 
            when 2
                result = "/imgs/sharing_selected.png"

        result

    get_preview: ->
        result_url = "/imgs/file.png";

        switch @get("type")
            when "none"
                result_url = ""
            when "music"
                result_url = "/imgs/musicfile.png"
            when "image", "video" 
                result_url = "#{CUST_SERVER}/users/#{SUBFOLDER}/#{UID}/THUMBS/" + @get("hash") + ".jpg"
            when "directory"
                result_url = "/imgs/folderfile.png"

        result_url

    is_visible: (type) ->

        switch @get("type")
            when "none"
                buttons = []
            when "directory"
                buttons = [] #["share"]
            when "music"
                buttons = ["share", "download", "link", "playlist"]
            else
                buttons = ["share", "download", "link"]

        unless @get('path') in ["Music", "Pictures", "Video", "Screenshots", "Misc"]
            buttons.push 'delete'

        if type in buttons then true else false

    delete: () ->
        $.ajax
            type: 'POST'
            dataType: 'jsonp'      
            url: "#{CUST_SERVER}/scripts/v2/rm_f.cgi?session=#{SESSION}&uid=#{UID}"
            data:
                fn: encodeURI(@get('filepath'))
            success: =>
                app.navigator.reload()
                # @view.clear()
                # @collection.remove(this)



        $.ajax
            type: 'POST'
            dataType: 'jsonp'      
            url: "updateaccess"
            data:
                file: encodeURI(@get('filepath'))
                old: @get('sharing')
                'new': '-'
