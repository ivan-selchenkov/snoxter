module.exports = class ViewerItem extends Backbone.Model

    select: ->
        @trigger "item:selected"

    is_my: ->
        if UID == @get("uid") then true else false

    get_path: ->
        result = @get('filename')

        if @get('folder')
            result = @get('folder') + '/' + result

        result       
        
    get_type: ->
        switch @get('type')
            when "0"
                result = "File"
            when "1"
                result = "Music file"
            when "2"
                result = "Video"
            when "3"
                result = "Image"
            when "10"
                result = "Folder"

        extra = @get 'extra'

        if extra
            result = "#{result}, #{extra}"

        result

    get_preview_path: ->
        srv = @get "srv"
        sub = @get "sub"
        uid = @get "uid"
        hash = @get "hash"

        result_url = "/imgs/file.png"

        switch @get("type")
            when "1"
                result_url = "/imgs/musicfile.png"
            when "2", "3" 
                if SKIP_CUST
                    result_url = "#{CUST_SERVER}/users/#{sub}/#{uid}/THUMBS/#{hash}.2.jpg"
                else
                    result_url = "#{CUST_HTTP}#{CUST_PREFIX}#{srv}.#{DOMAIN}/users/#{sub}/#{uid}/THUMBS/#{hash}.2.jpg"
            when "10"
                result_url = "/imgs/folderfile.png"

        result_url

