BalloonView = require './balloon'

module.exports = class FileView extends Backbone.View
    className: 'file_item'

    template: require './templates/file'

    events:
        # TODO: selecting file
        # "click .filemarker": "check"
        "dblclick .filemarker": "stopPropagation"

        "click": "click"

        "mouseenter": "add_hover"
        "mouseleave": "remove_hover"

    initialize: ->
        app.vent.on "navigator:clear", @clear

        # TODO: selecting file
        # app.vent.on "navigator:check_all", @check
        @model.on "folder_item:access_update", @update_access

        @model.view = this

    update_access: =>
        @$('.sharing_icon img').attr 'src', @model.get_sharing_icon()

    image_loaded: =>
        $icon = @$('.icon')

        $img = @$('.icon_image')

        width = $img.width()
        height = $img.height()

        min_size = $icon.width()

        if width > height
            $img.height( min_size )

            $img.css left: - ( $img.width() - min_size ) / 2

        else
            $img.width( min_size )

            $img.css top: - ( $img.height() - min_size ) / 2

    add_hover: =>
        @timer = setTimeout( (=> @_show_balloon() ), window.balloonDelay )        

        # TODO: selecting file
        # unless @$el.hasClass 'checked'
        #     @$('.filemarker').addClass 'hover'

    _show_balloon: ->
        @balloon.show()

        @timer = false

    remove_hover: (e) =>      
        balloonEl = @balloon.$el.get(0)
        toElement = e.toElement || e.relatedTarget if e

        unless not toElement or balloonEl == toElement or $.contains( balloonEl, toElement )
            @balloon.hide()
            
            if @timer
                clearTimeout @timer

        # TODO: selecting file
        # @$('.filemarker').removeClass 'hover'

    clear: =>
        @balloon.remove()
        @remove()

    click: ->
        if @model.get("type") == "directory"
            app.router.navigate "path/#{@model.get("path")}", trigger: true
        else 
            app.router.navigate "view/#{@model.get('hash')}", trigger: true

        false

    # TODO: selecting file
    # check: =>
    #     @model.toggleCheck()
    #     @remove_hover()
    #     @$el.toggleClass "checked"

    stopPropagation: (e) ->
        e.stopPropagation()

    render: ->
        @$el.html @template( model: @model )

        @balloon = new BalloonView model: @model, fileView: this

        @balloon.render()

        @$el.css position: 'relative'

        @$('.icon_image').on 'load', @image_loaded

        @$el.addClass 'checked' if @model.get('checked')

        this
