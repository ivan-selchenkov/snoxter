FileView = require './file_view'

module.exports = class NavigatorView extends Backbone.View
    id: 'navigatorView'
    className: 'welcome_main' # sharLayoutRightContainer'
    template: require './templates/navigator'

    events:        
        "click #fmControlsCheck": "check_all"
        "click #fmbut1": "show_create_new_folder_form"

        "click #button_create_folder": "create_folder"
        "keyup #input_new_folder": "key_pressed"

        "click #fmbut3": "show_search_form"
        "click .fileFilterSearch li": "select_file_filter"

        "click #close_new_folder_form": "close_new_folder_form"
        "click #close_search_form": "close_search_form"

        "click #search_button": "search"
        "keydown #searchp": "keydown"

        "dblclick #files_container": "dblclick_stop"
        "mousedown #files_container": "dblclick_stop"

    select_file_filter: (e) ->
        $('.fileFilterSearch li').removeClass "selected"
        $(e.currentTarget).addClass "selected"
        @search()

    keydown: (e) =>
         if e.which == 13
             e.preventDefault()
             @search()

    search: =>
        query = @$('#searchp').val()
        return if $.trim(query) == ""

        type = @$('.fileFilter li.selected').prop "value"

        query = encodeURI query

        if type == "" or type == 0
            app.router.navigate "search/#{query}", trigger: true
        else
            app.router.navigate "search/#{query}/#{type}", trigger: true

    dblclick_stop: (e) ->
        e.stopPropagation()
        false

    initialize: ->
        app.vent.on 'navigator:loaded', @render_files
        app.vent.on 'navigator:loading', @loading        
        app.vent.on 'navigator:loading', @update_breadcrumbs
        app.vent.on 'navigator:file_added', @add_file
        app.vent.on 'navigator:resize', @resize_scroller


    show_create_new_folder_form: (e) ->
        @show_form e, "create_new_folder_form"
        @$("#input_new_folder").val ""
        @$("#input_new_folder").css color: ''                
        @$("#input_new_folder").focus()
        
        false

    show_search_form: (e, query, type) ->
        if query
            @$('#searchp').val query
        else
            @$('#searchp').val ""

        @show_form e, "search_form"

        false

    show_form: (e, name) ->
        @$('.fmControls2 a').removeClass "selected"
        @$(".subheaderTree").hide()
        @$("##{name}").fadeIn "fast"

        @$container.addClass 'small'

        if e
            $(e.target).addClass "selected"
            e.stopPropagation()

    close_new_folder_form: (e) ->
        @close_form e, "create_new_folder_form"

    close_search_form: (e) ->
        @close_form e, "search_form"
        @loading()
        @render_files()
        @update_breadcrumbs app.navigator.get('url')

    close_form: (e, name) ->
        @$('.fmControls2 a').removeClass "selected"
        @$("##{name}").hide()   
        e.stopPropagation()

        @$container.removeClass 'small'


    is_wrong_folder_name: (folder) ->
        re = new RegExp('[*|:<>?/\\\\!"%\.\,]')    
        re.test(folder)

    key_pressed: (e) ->
        folder = @$("#input_new_folder").val()

        if @is_wrong_folder_name(folder)
            @$("#input_new_folder").css color: 'red'
        else
            @$("#input_new_folder").css color: ''        

            if e.keyCode == 13
                @create_folder(e)

    create_folder: (e) ->
        folder = $.trim( @$("#input_new_folder").val() )

        return if folder == ""

        if @is_wrong_folder_name(folder)
            alert("Incorrect character in the folder's name")
            return

        @close_new_folder_form e

        dir = app.navigator.get("url")

        if dir != "" and dir.substr(-1) != "/"
            dir += "/"

        $.ajax
            type: 'POST'
            dataType: 'jsonp'
            url: "#{CUST_SERVER}/scripts/v2/new_folder.cgi"
            data:
                session: SESSION
                uid: UID
                dir: dir
                folder: folder 
            success: =>
                app.navigator.add_folder( folder )
                app.vent.trigger 'navigator:resize'

    check_all: =>
        app.vent.trigger "navigator:check_all"

    update_breadcrumbs: (url, search) =>
        @$breadcrumbs.html ""
        @$('.fmControls2 a').removeClass "selected"
        @$(".subheaderTree").hide()

        if search
            @$breadcrumbs.append @divider_helper()
            @$breadcrumbs.append @breadcrumb_helper "Search"

            @show_search_form(null, search.query, search.type)
            return

        if url and url != "" and url != "/" 
            items = url.split "/"

            relative_url = ""

            for item in items
                relative_url += item + "/"

                @$breadcrumbs.append @divider_helper()
                @$breadcrumbs.append @breadcrumb_helper( item, relative_url )

    breadcrumb_helper: (name, href) ->
        if href
            $("<div class='breadcrumb'><a href='#path/#{href}'>#{name}</a></div>")
        else
            $("<div class='breadcrumb'><a>#{name}</a></div>")

    divider_helper: ->
        $('<i class="divider"></i>')

    add_file: (item) =>
        @$container.append ( new FileView( model: item ) ).render().$el        

    render_files: (collection) =>
        @$container.find('.loading').remove()

        if collection
            models = collection.models
        else
            models = @model.files.models

        for item in models
            @add_file item

        app.vent.trigger 'navigator:resize'

    loading: =>
        @clear_elements()
        @$container.html $('<div/>').addClass('loading').text('Loading...')

    clear_elements: ->
        app.vent.trigger "navigator:clear"

    remove: ->
        @clear_elements()
        @$container.getNiceScroll().hide()
        Backbone.View.prototype.remove.call this

    resize_scroller: =>
        @scroll.resize()

    render: ->
        @$el.html @template

        @$container = @$('#files_container')

        @$container.niceScroll
            cursorborder: "0px"
            cursorwidth: "8px"
            cursoropacitymax: "0.4"      

        @scroll = @$container.getNiceScroll()  

        @$breadcrumbs = @$('#breadcrumbs')

        if @options.search
            @model.search_request @options.search.query, @options.search.type
            @options.search = null
        else
            if @model.get('forceReload')
                @model.reload()
            else
                @render_files()        

        this

