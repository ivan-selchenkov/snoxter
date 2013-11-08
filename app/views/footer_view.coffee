UploadingView = require './welcome_layout/uploading_view'

module.exports = class FooterView extends Backbone.View
    className: "sharLayoutFooterInner"
    template: require './templates/footer'

    events:
        "click #uprog1": "toggle_details"
        "click #uprog2": "toggle_details"

    initialize: ->
        app.uploads.on 'uploads:progressTotal', @progressall
        app.uploads.on 'start', @show_upload_bar
        app.uploads.on 'stop', @hide_upload_bar
        app.vent.on 'footer:total_space', @update_total_space
        app.vent.on 'footer:used_space', @update_used_space

    update_used_space: =>
        su = window.USED_SPACE / 1000000
        su = su.toFixed(2)

        @$('#usedprc').css width: 100.0 * su / ( CSPACE ) + "%"

        @$('#sused').text "#{su} Mb"

        if su > 0
            @$('#progressInfo, #progressBox').show()

    update_total_space: =>
        space = window.CSPACE / 1000.0
        @$('#stotal').text "of #{space} Gb"

    toggle_details: =>
        @$('#upldiv').fadeToggle 'fast', =>
            @uploadingView.scroll.resize()

    show_upload_bar: =>
        @uploadingView = new UploadingView( model: app.uploads )

        @$('#upldiv').html @uploadingView.render().el

        @$('#uprog1, #uprog2, #upldiv').fadeIn 'fast', =>
            @uploadingView.resize()

        @timer = setTimeout( (=> @$('#upldiv').fadeOut('fast') ), 3000 )

    hide_upload_bar: =>
        @$('#uprog1, #uprog2').fadeOut('fast')

        @uploadingView.remove()

        clearTimeout @timer

    progressall: (value) =>
        @$('#uprogbar').css 'width', value + "%"

    render: ->  
        @$el.html @template

        @update_total_space()
        @update_used_space()

        this
