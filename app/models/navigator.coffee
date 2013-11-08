module.exports = class Navigator extends Backbone.Model
    defaults:
        url: ''
        forceReload: true

    initialize: ->
        @files = new app.Folder

    search_request: (query, type) =>
        app.vent.trigger "navigator:loading", null, { query: query, type: type }

        $.ajax
            type: 'POST'
            dataType: 'jsonp'
            url: "#{CUST_SERVER}/scripts/v2/search.cgi?session=#{SESSION}&uid=#{UID}"
            data: { 
                filter: query
                type: type
            }
            success: (json) =>
                collection = new app.Folder json
                app.vent.trigger "navigator:loaded", collection

    add_folder: (name) =>
        url = @get 'url'

        if url == ''
            path = name
        else
            path = url + '/' + name

        item = new app.FolderItem 
            name: name
            path: path
            filepath: path
            type: "directory"
            sharing: "None"
            checked: false

        @files.add item

        app.vent.trigger "navigator:file_added", item

    change_folder: (url) =>
        if url.substr(-1) == "/"
            url = url.slice(0, -1)

        @set "url", url
        @reload()        

    reload: ->
        app.vent.trigger "navigator:loading", @get("url")
        @files.fetch
            data: 
                dir: @get('url')
                uid: UID
                session: SESSION
            success: =>
                app.vent.trigger "navigator:loaded"

        
