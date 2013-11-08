module.exports = class UploadingFileView extends Backbone.View

    tagName: "li"
    template: require './templates/uploading_file'

    events:
        "click .cancel_upload": "cancel_upload"

    initialize: ->
        @model.view = this        

        @model.on 'upload:progress', @progress
        @model.on 'upload:done', @dispose

    progress: =>
        percent = ( 100.0 * @model.get('received') / @model.get('size') ).toFixed(1)

        @$('.upload_status').html "#{percent}% of #{@model.get('size')}"

    dispose: =>
        @unbind() # this will unbind all listeners to events from this view. This is probably not necessary because this view will be garbage collected.
        @remove() # uses the default Backbone.View.remove() method which removes this.el from the DOM and removes DOM events.

    cancel_upload: (e) ->
        @model.cancelUpload()
        e.stopPropagation()
        false

    render: ->
        file = @model.uploadObject.files[0]

        @$el.html @template(upload: file)       

        @$('.upload_status').html 'Starting...'

        @$el.css "padding", "2px"

        this
