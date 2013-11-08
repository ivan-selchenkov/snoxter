module.exports = class UploadInputView extends Backbone.View
    tagName: 'table'
    className: 'helpComment'

    template: require './templates/upload_input'

    events:
        "click #btnAddMode": "show_mode_select"


    initialize: ->
        @uploads_size = []
        app.vent.on "navigator:sharing_mode_changed", @setSharingModeIcon

    setSharingModeIcon: (cssClass) =>
        @$('#umodesel')
            .removeClass('mode_only_me mode_friends mode_custom')
            .addClass cssClass

    show_mode_select: (e) =>
        app.vent.trigger "navigator:toggle_mode_select"

        if @$('#umodesel').hasClass('opened')
            @$('#umodesel').removeClass('opened').addClass('closed')
        else
            @$('#umodesel').removeClass('closed').addClass('opened')

        false

    init_uploading: ->
        canUploadProgress = $.support.uploadProgress

        file_uploader = @$ '#fileIT'

        file_uploader.fileupload
            sequentialUploads: true
            autoUpload: false
            #limitConcurrentUploads: 1
            dataType: 'json'
            add: (e, uploadObject) =>
                app.uploads.add uploadObject

        # New batch of files
        file_uploader.bind 'fileuploadchange', ( e, uploadObject ) =>
            app.sharingFBResult = null

        # Starting progress requests
        file_uploader.bind 'fileuploadsend', ( e, uploadObject ) =>
            uploadObject.model.startProgress()

        file_uploader.bind 'fileuploadalways', (e, uploadObject) =>
            uploadObject.model.done()

        file_uploader.bind 'fileuploadstart', (e) =>
            app.uploads.trigger 'start'

        file_uploader.bind 'fileuploadstop', (e) =>
            app.uploads.trigger 'stop'

    render: ->
        @$el.html @template        

        @init_uploading()

        this

