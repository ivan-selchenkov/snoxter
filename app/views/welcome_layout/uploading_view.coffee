UploadingFileView = require './uploading_file_view'

module.exports = class UploadingView extends Backbone.View

    template: require './templates/uploading'    
    className: "uploadingBalloon"

    initialize: ->
        app.uploads.on 'add', @add_upload

    remove: ->
        @scroll.hide()
        Backbone.View.prototype.remove.call this

    add_upload: (model, collection, options) =>
        @$('#no_uploads').remove()

        model.on 'upload:done', @resize

        file = new UploadingFileView( model: model )

        @$el.append file.render().$el

        @resize()

    resize: =>
        @scroll.resize()

    render: ->
        @$el.html @template

        @$el.niceScroll 
            cursorborder: "0px"
            cursorwidth: "8px"
            cursoropacitymax: "0.4"        

        @scroll = @$el.getNiceScroll()

        for upload in @model.models
            @add_upload upload

        this
