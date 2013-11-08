module.exports = class BalloonView extends Backbone.View
    className: 'balloonWraper'

    template: require './templates/balloon'

    events:
        "click .button_remove": "button_remove"
        "click .button_share": "button_share"
        "click .button_direct_link": "button_direct_link"
        "mouseleave": "mouseleave"
        "click .button_add_to_playlist": "add_to_playlist"
        "click .sharing_menu li": "sharing_mode_change"

    button_direct_link: (e) =>
        @$('tr.link_row').show()

        unless @model.get('lcode')
            @model.load_link_code().done( (res) =>
                @$('tr.link_row input').val "http://snoxter.in/#{res}" 
            )
        else
            @$('tr.link_row input').val "http://snoxter.in/#{@model.get('lcode')}"

        false

    add_to_playlist: (e) =>
        path = @model.get('filepath')
        plid = app.player.get("currentPlaylist").id

        $.ajax
            type: 'POST'
            dataType: 'jsonp'
            url: "#{CUST_SERVER}/scripts/v2/add_to_playlist.cgi?callback=?"
            data:
                session: SESSION
                uid: UID
                fn: encodeURI(path)
                plid: plid
            success: =>
                app.player.load_playlists()

    deactivate_menu: ->
        @$overlay.css
            height: @$sharingMenu.height()
            width: @$sharingMenu.width()

        @$overlay.show()

    activate_menu: ->
        @$overlay.hide()


    sharing_mode_change: (e) =>
        new_state = $(e.currentTarget).data("sharing")

        return if @model.get_sharing_type() == new_state

        @deactivate_menu()

        if new_state == 2
            FB.ui {
                    method: 'apprequests'
                    message: "I've shared file(s) for you. Check it out!"
                }, (res) =>
                    if res
                        @model.set_sharing_mode new_state, res, =>
                            @$sharingMenu.find('li').removeClass 'selected'
                            @$sharingMenu.find("li[data-sharing=#{new_state}]").addClass 'selected'
                            @activate_menu()
                    else
                        @activate_menu()
        else
            @model.set_sharing_mode new_state, [], =>            
                @$sharingMenu.find('li').removeClass 'selected'
                @$sharingMenu.find("li[data-sharing=#{new_state}]").addClass 'selected'
                @activate_menu()





    mouseleave: (e) =>
        fileViewEl = @options.fileView.$el.get(0)
        toElement = e.toElement || e.relatedTarget


        unless fileViewEl == toElement or $.contains( fileViewEl, toElement )
            @hide()

    button_share: (e) =>
        pos = @$('.button_share').position()        

        @$sharingMenu.css
            top: pos.top + @$('.button_share').height()
            left: pos.left

        @$sharingMenu.show()

    button_remove: =>
        name = @model.get("name")

        if @model.get("type") == "directory" and @model.get("contains") != "Empty folder"
            alert("It's impossible to delete non-empty folder")
            return
        else
            return unless confirm("Delete '#{name}'? Are you sure?")
        
        @model.delete()

    show: =>
        fileWidth = @options.fileView.$el.width()
        fileHeight = @options.fileView.$el.height()
        filePos = @options.fileView.$el.offset()

        balloonPos =
            top: filePos.top - @balloonSize.h - 15 + 30
            left: filePos.left - 30

        @$el.css balloonPos

        @$el.css display: 'block'


    hide: =>
        @$el.css display: 'none'

        @$sharingMenu.css display: 'none'

        @$('tr.link_row').hide()        

    render: =>
        @$el.html @template(item: @model)

        @$el.css display: 'none'

        $('body').append @$el

        @balloonSize = getInvisibleDimension( @$el )

        @$sharingMenu = @$('.sharing_menu')

        @$overlay = @$('.overlay')

        # TODO: Uncomment for colloboration mode for folders

        # if @model.get('type') == 'directory'
        #     @$sharingMenu.find('.item_for_folder').css display: 'block'

        this
