module.exports = class UploadItem extends Backbone.Model
    initialize: (uploadObject) ->
        @uploadObject = uploadObject
        @uploadObject.model = this

        @set 'hash', @_calculateHash()
        # Set the current folder as folder for upload        
        @set 'folder', app.navigator.get('url')

        @set 'size', @uploadObject.files[0].size if @uploadObject.files[0].size

        # Configuring uploadObject
        @uploadObject.url = "#{CUST_SERVER}/scripts/v2/upload.cgi?uid=#{UID}&session=#{SESSION}&X-Progress-ID=#{@get('hash')}&ufol=#{@get('folder')}"

        @uploadObject.formData = {}

        @uploadObject.formData.share = app.sharingMode

        if app.sharingMode != 2
            @uploadObject.submit()
        else if app.sharingFBResult
            @_sharingOptions app.sharingFBResult
        else
            FB.ui {
                    method: 'apprequests'
                    message: "I've shared file(s) for you. Check it out!"
                }, (res) =>
                    app.sharingFBResult = res
                    @_sharingOptions app.sharingFBResult

    # Setting sharing users from facebook data
    _sharingOptions: ( res ) ->        
        unless res # User click Cancel button
            @collection.remove(this)
        else # Sharing user's data
            @uploadObject.formData.request = res.request
            @uploadObject.formData.rids = res.to.join "," 

            @uploadObject.submit()


    # Calculating uploading hash/track
    _calculateHash: () ->
        date = new Date()
        time = date.getTime();            
        string = @uploadObject.files[0].lastModifiedDate + @uploadObject.files[0].name + time
        CryptoJS.MD5(string).toString()

    startProgress: =>
        @timer = setInterval( (=> @_updateProgress() ), window.progressUpdateTimeout )

    _updateProgress: ->
        # This request in pending state
        if @trackDeffered and @trackDeffered.state() == "pending"
            return

        @trackDeffered = $.ajax(
            url: window.trackingURL
            dataType: "jsonp"            
            jsonpCallback: "upload_callback" # Server doesn't support json callback's name
            data:
                "X-Progress-ID": @get('hash')
        ).success (json) =>
            @collection.progress( json ) if @collection


    done: (uploadObject) =>
        if @timer
            clearInterval( @timer )
            @timer = false

        if @trackDeffered and @trackDeffered.isResolved and not @trackDeffered.isResolved()
            @trackDeffered.abort()

        @received = @size

        @trigger 'upload:done'

        unless @cancel
            regexp = /\.mp3|\.aac/

            if regexp.test( @uploadObject.files[0].name )
                app.player.load_playlists()
                
            app.navigator.reload()

    cancelUpload: () =>
        @cancel = true

        @uploadObject.jqXHR.abort()

        @done( @uploadObject )

