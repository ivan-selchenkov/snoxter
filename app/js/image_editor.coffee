$ ->
    $.widget "sharium.ImageEditor",  
        options:
            api: "http://1.thesharium.com/scripts/digiproc"        
            frames_url: "/frames/"

        _setOptions: ->
            @_superApply( arguments )

            @_init_request().done =>
                @savedImage = 0
                @show_image = false
                @_discard()

        _create: ->
            @this = this

            @currentImage = 0
            @savedImage = 0

            $el = @element            
            @$el = $(@element)

            @$submenus = $el.find('.submenu')
            @$menus = $el.find('.menu')

            @$rotate_menu = $el.find('#rotate_menu')
            @$rotate_submenu = $el.find('#rotate_submenu')

            if @options.debug
                $.ajaxSetup
                    timeout: 180000

                for i in [1..8]
                    @$rotate_submenu.append(
                        $('<li/>').append(
                            $('<a/>').attr({ id: "filter#{i}", function: "_instant_action" })
                                     .addClass('action_button ui_button instant_action orientOptionsBtn')
                                     .text(i)
                        )
                    )

            @$crop_menu = $el.find('#crop_menu')
            @$crop_submenu = $el.find('#crop_submenu')

            @$effects_menu = $el.find('#effects_menu')
            
            @$effects_submenu = $el.find('#effects_submenu')

            @$frames_menu = $el.find('#frames_menu')
            @$frames_submenu = $el.find('#frames_submenu')

            @$enchance_menu = $el.find('#enchance_menu')
            @$enchance_submenu = $el.find('#enchance_submenu')

            @$ok_button = $el.find('#ok_button')
            @$cancel_button = $el.find('#cancel_button')

            @$undo_button = $el.find('#undo_button')
            @$redo_button = $el.find('#redo_button')

            @$custom_crop = $el.find('#custom_crop')
            @$square_crop = $el.find('#square_crop')

            @$hidden_div = $el.find('#hidden_div')

            @$hidden_div.css 'zIndex', 9999
            @$hidden_div.html '
                 <div id="img_container" style="width: 70px; height: 70px; background: white; opacity: 0.5; border-radius: 10px; -webkit-border-radius: 10px; -moz-border-radius: 10px;">
                    <img src="img/ajax-loader.gif" style="height: 32px; width: 32px; padding-right: 0px; float: none; margin-left: auto; margin-right: auto; margin-top: 17px;"/>
                 </div>
            '

            @$target_image = $el.find('#target_image')

            @$discard_button = $el.find('#discard_button')
            @$save_button = $el.find('#save_button')

            @$exit_button = $el.find('#exit_button')

            @$target_image_box = $el.find('.target_image_box')
            @$target_image_box.css display: 'block'

            @$framesetter = $el.find '#framesetter'
            @$framesetter.css display: 'none'


            @$framesetter_container = $el.find('#framesetter-container')
            @$framesetter_frame = @$framesetter_container.find('#framesetter-frame')
            @$framesetter_photo = @$framesetter_container.find('#framesetter-photo')
            @$framesetter_slider = @$framesetter.find('#framesetter-slider')
            @$framesetter_rotate = @$framesetter.find('#framesetter-rotate')

            @$sliderHeader = $el.find('#sliderHeader')
            @$sliderHeader.hide()
            @$sliders = @$sliderHeader.find('div.slider').hide()

            @$slider_hue_container = @$sliderHeader.find('#slider_hue')
            @$slider_saturation_container = @$sliderHeader.find('#slider_saturation')
            @$slider_contrast_container = @$sliderHeader.find('#slider_contrast')
            @$slider_brightness_container = @$sliderHeader.find('#slider_brightness')
            @$slider_sharp_container = @$sliderHeader.find('#slider_sharp')

            @$slider_hue = @$sliderHeader.find('#slider_hue .progressTune')
            @$slider_saturation = @$sliderHeader.find('#slider_saturation .progressTune')
            @$slider_contrast = @$sliderHeader.find('#slider_contrast .progressTune')
            @$slider_brightness = @$sliderHeader.find('#slider_brightness .progressTune')
            @$slider_sharp = @$sliderHeader.find('#slider_sharp .progressTune')

            @_slider_init()

            $el.find('#slider_refresh').click =>
                @_framesetter_resize 1
                @$framesetter_slider.slider "option", "value", 0

            $el.find('#rotate_refresh').click =>
                @$framesetter_photo.transform rotate: '0deg'
                @$framesetter_rotate.slider "option", "value", 0

            if typeof this.options.is_paid == "function"
                unless this.options.is_paid()
                    @$el.find('#frames_submenu a[paid="true"]').append '<a href="#" class="orientOptionsBtn"><i class="coin"></i></a>'

            @_show_hidden_div(true)

            # TODO: done
            @_init_request().done =>
                @_update_image().on 'load', =>
                    @$hidden_div.hide()
                    @_events()

            @nextOperationIndex = 0;
            @maxOperationIndex = 0;
            @operations = [];        

        _init_request: ->
            dfd = 
            @_execute_ajax(
                @options.init, 
                { 
                    uid: @options.uid
                    hash: @options.hash,
                    PHPSESSID: @options.session
                },
                'POST',
                'json'
            )

            dfd

        _destroy: ->
            # animate menu
            @$rotate_menu.off 'mouseenter'
            @$crop_menu.off 'mouseenter'
            @$effects_menu.off 'mouseenter'
            @$frames_menu.off 'mouseenter'
            @$enchance_menu.off 'mouseenter'

            @element.find('.action_button').off 'click'

            @$submenus.off 'mouseleave'
            @$submenus.off 'mouseenter'

            @element.off 'mousemove'
            @$undo_button.off 'click'
            @$redo_button.off 'click'

            @$discard_button.off 'click'
            @$save_button.off 'click'

            @$exit_button.off 'click'

        _events: ->
            # animate menu
            @$rotate_menu.on 'mouseenter', $.proxy(@_rotate_menu, this)
            @$crop_menu.on 'mouseenter', $.proxy(@_crop_menu, this, this)
            @$effects_menu.on 'mouseenter', $.proxy(@_effects_menu, this)
            @$frames_menu.on 'mouseenter', $.proxy(@_frames_menu, this)
            @$enchance_menu.on 'mouseenter', $.proxy(@_enchance_menu, this)

            @element.find('.action_button').on 'click', $.proxy(@_action_click, this)

            #@$cancel_button.on 'click', $.proxy(@_cancel_freeze_action, this)
            #@$ok_button.on 'click', $.proxy(@_ok_freeze_action, this)

            @$submenus.on 'mouseleave', $.proxy(@_hide_submenu_timer, this)
            @$submenus.on 'mouseenter', $.proxy(@_reset_submenu_timer, this)

            @element.on 'mousemove', $.proxy(@_move_over, this)

            @$undo_button.on 'click', $.proxy(@_undo, this)
            @$redo_button.on 'click', $.proxy(@_redo, this)

            @$discard_button.on 'click', $.proxy(@_discard, this)
            @$save_button.on 'click', $.proxy(@_save, this)

            @$undo_button.addClass('disabledBtn').block() 
            @$redo_button.addClass('disabledBtn').block()

            @$exit_button.on 'click', $.proxy(
                ->
                    @destroy()
                    if @options.exit instanceof Function
                        @options.exit()
                , this
            )
                
        # Common function to catch all clicks
        _action_click: (e) ->
            $target = $(e.currentTarget)

            action = 
                function: $target.attr "function"
                group: $target.attr "group"
                name: $target.attr "name"
                id: $target.attr "id"
                num: $target.attr "num"
                resizable: $target.attr "resizable"
                paid: $target.attr "paid"

            if @apply_function and action.group != @apply_group
                @apply_function(action)
            else
                @_start_action(action)

        # Starting all function
        _start_action: (action) ->
            return if not action or action instanceof jQuery.Event

            if typeof action == "function"
                action()
            else
                if this[action.function]
                    this[action.function](action)
                else if action.group
                    this[action.group](action)


        # One time actions
        _instant_action: (action) ->
            @currentAction = action.id

            requestData = this["_" + @currentAction]()

            @_request(requestData).done =>
                @currentImage += 1
                @_update_image().on 'load',  =>                    
                    @_unfreeze_all_elements()
                    @$hidden_div.hide()                   
                    @_increment_operation_index()

        _enchance: (action) ->
            @_switch_ok_cancel(true)

            @$ok_button.off 'click'
            @$ok_button.on 'click', $.proxy( @_enchance_finished, this )

            @apply_function = @_enchance_finished
            @apply_group = false            

            @$cancel_button.off 'click'
            @$cancel_button.on 'click', $.proxy( @_cancel_enchance, this )

            this["_" + action.name]()

        _contrast_brightness: () ->
            @$slider_contrast_container.show()
            @$slider_brightness_container.show()

            @$sliderHeader.show()

        _hue_saturation: () ->
            @$slider_hue_container.show()
            @$slider_saturation_container.show()

            @$sliderHeader.show()

        _sharp: () ->
            @$slider_sharp_container.show()

            @$sliderHeader.show()

        _sharp_update: () ->
            sharp = + @$slider_sharp.slider("value")

            data = []

            data.push( name:"sharp", value: "#{sharp}" ) if Math.abs(sharp) > 1

            @_enchance_update( data )

        _contrast_brightness_update: () ->
            contrast = + @$slider_contrast.slider("value")
            brightness = + @$slider_brightness.slider("value")

            data = []

            data.push( name:"contrast", value: "#{contrast}" ) if Math.abs(contrast) > 1
            data.push( name:"brightness", value: "#{brightness}" ) if Math.abs(brightness) > 1

            @_enchance_update( data )


        _hue_saturation_update: () ->
            hue = + @$slider_hue.slider("value")
            saturation = + @$slider_saturation.slider("value")

            data = []

            data.push( name:"hue", value: "#{hue}" ) if Math.abs(hue) > 1
            data.push( name:"saturation", value: "#{saturation}" ) if Math.abs(saturation) > 1

            @_enchance_update( data )

        _enchance_update: (data) ->
            if data.length == 0
                @show_image = false

                @_freeze_all_elements()
                @_show_hidden_div()

                @_update_image().on 'load', =>
                    @_unfreeze_all_elements()
                    @$hidden_div.hide()

            else
                @show_image = @currentImage + 1

                @_request(data).done =>
                    @_update_image().on 'load', =>
                        @_unfreeze_all_elements()
                        @$hidden_div.hide()

        _enchance_finished: (nextAction) ->
            @$sliderHeader.find('.slider').hide()
            @$sliderHeader.hide()

            @_switch_ok_cancel(false)

            if @show_image
                @_increment_operation_index()
                @currentImage = @show_image

            @show_image = false
    
            @_update_undo_redo_state()
    
            @apply_function = false
            @apply_group = false

            @_start_action nextAction

        _cancel_enchance: () ->
            @$sliderHeader.find('.slider').hide()
            @$sliderHeader.hide()

            if @show_image
                @_freeze_all_elements()
                @_show_hidden_div()

                @show_image = false

                @_update_image().on 'load', =>
                    @_unfreeze_all_elements()
                    @$hidden_div.hide()
                    @_update_undo_redo_state()
            else            
                @_update_undo_redo_state()

            @_switch_ok_cancel(false)
            @apply_function = false
            @apply_group = false            



        # Crop actions
        _crop: (action) ->
            @_switch_ok_cancel(true)

            @$ok_button.off 'click'
            @$ok_button.on 'click', $.proxy( @_crop_finished, this )

            @apply_function = @_crop_finished
            @apply_group = "_crop"            

            @$cancel_button.off 'click'
            @$cancel_button.on 'click', $.proxy( @_cancel_crop, this )

            if @$target_image.imgAreaSelect
                @_cancel_ias()

            this["_" + action.function]()


        _crop_finished: (nextAction) ->
            selection = @ias.getSelection(true)

            ratio = 1.0 * @original_image_width / @image_width

            x_coeff = 1.0 / @original_image_width

            y_coeff = 1.0 / @original_image_height

            action =  
                "name": "crop"
                "x1": "#{selection.x1 * ratio * x_coeff}"
                "x2": "#{selection.x2 * ratio * x_coeff}"
                "y1": "#{selection.y1 * ratio * y_coeff}"
                "y2": "#{selection.y2 * ratio * y_coeff}"

            @_cancel_crop()

            @_request(action).done =>
                @currentImage += 1

                @_update_image().on 'load', =>
                    @_unfreeze_all_elements()
                    @_increment_operation_index()
                    @$hidden_div.hide()
                    @_start_action nextAction

        _cancel_crop: ->
            @_switch_ok_cancel(false)
            @_cancel_ias()
            @_update_undo_redo_state()

            @apply_function = false
            @apply_group = false            


        _effect: (action) ->
            @_group_action action

        _frame: (action) ->
            @selectedAction = action

            if @apply_group == "_frame"
                @_highlight_group_action action

                @currentAction.paid = action.paid
                @currentAction.num = action.num
                @currentAction.resizable = action.resizable

                @frame_number = action.num
                @_load_framesetter_frame()
            else
                @_group_action action

                @$framesetter.show()
                @$target_image_box.hide()

                @firstLoad = true
                @$framesetter_photo.width "auto"
                @$framesetter_photo.height "auto"

                @$framesetter_slider.slider "option", "value", 0
                @$framesetter_rotate.slider "option", "value", 0
                @$framesetter_photo.transform rotate: '0deg'

                @_load_framesetter_images(action.num)

                @_init_framesetter()

        _highlight_group_action: (action) ->
            # Select filter
            $ui_buttons = @element.find('.ui_button')

            $ui_buttons.filter("[group=#{action.group}]").parent().removeClass "e_active"
            
            if action.num            
                $ui_buttons.filter("[group=#{action.group}][num=#{action.num}]").parent().addClass "e_active"
            else
                $ui_buttons.filter("[group=#{action.group}][name=#{action.name}]").parent().addClass "e_active"

        _group_action: (action) ->
            group = action.group
            name = action.name
            num = action.num

            callback = if group == "_frame" then @_frame_operation_finished else @_group_operation_finished

            @$ok_button.off 'click'
            @$ok_button.on 'click', $.proxy( callback, this )

            @apply_function = callback
            @apply_group = group

            @$cancel_button.off 'click'
            @$cancel_button.on 'click', $.proxy( @_cancel_group, this )

            @cancel_function = @_cancel_group

            @_highlight_group_action action

            @_switch_ok_cancel(true)

            @currentAction = 
                num: num
                group_name: group
                name: name
                group: true
                paid: action.paid
                resizable: action.resizable || false

            if group != "_frame"
                data =  
                    'name': name

                @show_image = @currentImage + 1

                @_request(data).done =>
                    @_update_image().on 'load', =>
                        @_unfreeze_all_elements()
                        @$hidden_div.hide()

        _init_framesetter: ->
            @fs_position =
                left: +@$framesetter_photo.css('left').slice(0, -2)
                top: +@$framesetter_photo.css('top').slice(0, -2)

            @$framesetter_container.off 'mousedown'
            @$framesetter_container.on 'mousedown', $.proxy(@_framesetter_mousedown, this)
            @$framesetter_container.css cursor: 'pointer'

        _slider_init: ->
            @$framesetter_slider.slider
                min: -1
                max: 1
                step: 0.01
                slide: (e, v) =>
                    if v.value < 0
                        coeff = Math.pow 10, v.value
                    else
                        coeff = Math.pow 3, v.value
                    @_framesetter_resize coeff

            @$framesetter_rotate.slider
                min: -180
                max: 180
                step: 1
                slide: (e, v) =>
                    @$framesetter_photo.transform rotate: v.value + 'deg'

            @$slider_contrast.slider
                min: -100
                max: 100
                step: 1
                change: (e, v) =>
                    @_contrast_brightness_update()

            @$slider_contrast_container.find('.refreshTune').click =>
                @$slider_contrast.slider "value", 0
                @_contrast_brightness_update()


            @$slider_brightness.slider
                min: -100
                max: 100
                step: 1
                change: (e, v) =>
                    @_contrast_brightness_update()

            @$slider_brightness_container.find('.refreshTune').click =>
                @$slider_brightness.slider "value", 0
                @_contrast_brightness_update()

            @$slider_hue.slider
                min: -180
                max: 180
                step: 1
                change: (e, v) =>
                    @_hue_saturation_update()

            @$slider_hue_container.find('.refreshTune').click =>
                @$slider_hue.slider "value", 0
                @_hue_saturation_update()

            @$slider_saturation.slider
                min: -100
                max: 100
                step: 1
                change: (e, v) =>
                    @_hue_saturation_update()

            @$slider_saturation_container.find('.refreshTune').click =>
                @$slider_saturation.slider "value", 0
                @_hue_saturation_update()

            @$slider_sharp.slider
                min: 0
                max: 100
                step: 1
                change: (e, v) =>
                    @_sharp_update()

            @$slider_sharp_container.find('.refreshTune').click =>
                @$slider_sharp.slider "value", 0
                @_sharp_update()

        _framesetter_resize: (coeff) ->

            top0 = @fs_position.top
            h0 = @$framesetter_photo.height()

            left0 = @fs_position.left
            w0 = @$framesetter_photo.width()

            h1 = @fs_image_size.height * coeff
            w1 = @fs_image_size.width * coeff

            css = {}
            css.width = w1
            css.height = h1

            top1 = top0 + (h0 - h1) / 2
            left1 = left0 + (w0 - w1) / 2

            @fs_position.left = left1
            @fs_position.top = top1

            frame_width = @$framesetter_frame.width()
            frame_height = @$framesetter_frame.height()

            left1 = -w1 / 2 if left1 < - ( w1 / 2 )
            left1 = frame_width - w1 / 2 if ( left1 + w1 / 2 ) > frame_width

            top1 = -h1 / 2 if top1 < - ( h1 / 2 )
            top1 = frame_height - h1 / 2 if ( top1 + h1 / 2 ) > frame_height

            css.top = "#{top1}px"
            css.left = "#{left1}px"

            @$framesetter_photo.css css

        # starting move photo in the frame
        _framesetter_mousedown: (e) ->
            @startCoors = { x: e.clientX, y: e.clientY };
            @$framesetter_container.on 'mousemove', $.proxy(@_framesetter_mousemove, this)
            @$framesetter_container.on 'mouseup', $.proxy(@_framesetter_mouseup, this)
            @$framesetter_container.on 'mouseleave', $.proxy(@_framesetter_mouseup, this)
            false

        _framesetter_mouseup: (e) ->
            @$framesetter_container.off 'mousemove'
            @$framesetter_container.off 'mouseup'
            @$framesetter_container.off 'mouseleave'

        _framesetter_mousemove: (e) ->
            delta = 
                x: ( @startCoors.x - e.clientX ) 
                y: ( @startCoors.y - e.clientY )
            
            @_framesetter_drag delta

            @startCoors = 
                x: e.clientX
                y: e.clientY

        _framesetter_drag: (delta) ->
            @fs_position.top -= delta.y
            @fs_position.left -= delta.x

            center_y = @fs_position.top + @$framesetter_photo.height() / 2
            center_x = @fs_position.left + @$framesetter_photo.width() / 2

            if center_y < 0
                @fs_position.top = -@$framesetter_photo.height() / 2

            if center_y > @$framesetter_frame.height()
                @fs_position.top = @$framesetter_frame.height() - @$framesetter_photo.height() / 2

            if center_x < 0
                @fs_position.left = - @$framesetter_photo.width() / 2

            if center_x > @$framesetter_frame.width()
                @fs_position.left = @$framesetter_frame.width() - @$framesetter_photo.width() / 2

            @$framesetter_photo.css
                left: @fs_position.left + 'px'
                top: @fs_position.top + 'px'

        _load_framesetter_frame: ->
            view_width = @$framesetter.width()
            view_height = @$framesetter.height() - 35

            if @firstLoad
                w = @$framesetter_photo.width()
                h = @$framesetter_photo.height()
                # adjust size
                coeff_w = +w / view_width
                coeff_h = +h / view_height

                coeff = if coeff_w > coeff_h then coeff_w else coeff_h

                if coeff > 1
                    w /= coeff
                    h /= coeff
                    @$framesetter_photo.width(w)
                    @$framesetter_photo.height(h)

                @fs_image_size = width: w, height: h

            if @selectedAction.resizable == "true"
                frame_width = @fs_image_size.width
                frame_height = @fs_image_size.height
            else
                min = if @fs_image_size.width < @fs_image_size.height then @fs_image_size.width else @fs_image_size.height
                frame_width = min
                frame_height = min

            unless @firstLoad
                center_y = @fs_position.top + @$framesetter_photo.height() / 2
                center_x = @fs_position.left + @$framesetter_photo.width() / 2

                if center_y < 0 or center_y > frame_height or center_x < 0 or center_x > frame_width
                    centerImage = true

            if @firstLoad or centerImage
                @fs_position = 
                    top: -( @fs_image_size.height - frame_height ) / 2
                    left: -( @fs_image_size.width - frame_width ) / 2

                @$framesetter_photo.css @fs_position

            @$framesetter_frame.css(
                width: frame_width + 'px'
                height: frame_height + 'px'
            )
            @$framesetter_container.css(
                width: frame_width + 'px'
                height: frame_height + 'px'
                marginTop: ( view_height - frame_height ) / 2 + "px"
            )

            @$framesetter_frame.find('img').attr('src', "")
            @$framesetter_frame.find('img').attr('src', "#{@options.frames_url}frame#{@frame_number}.png")
            .css
                width: frame_width + 'px'
                height: frame_height + 'px'

            @firstLoad = false

        _load_framesetter_images: (frame_number) ->
            @$framesetter_photo.off 'load'
            @frame_number = frame_number
            @$framesetter_photo.on 'load', $.proxy( @_load_framesetter_frame, this )

            @$framesetter_photo.attr "src", @$target_image.attr('src')

        _frame_operation_finished: (nextAction) ->
            res = true

            if @currentAction.paid == "true"
                if typeof this.options.check_pay == "function"
                    res = this.options.check_pay()

            return unless res

            if Math.abs( @$framesetter_slider.slider( "value" ) ) < 0.005
                ratio = undefined
            else
                value = +@$framesetter_slider.slider( "value" )

                if value < 0
                    coeff = Math.pow 10, value
                else
                    coeff = Math.pow 3, value

                ratio = coeff.toFixed(4)

            if Math.abs( @$framesetter_rotate.slider( "value" ) ) < 1
                angle = undefined
            else
                a = +@$framesetter_rotate.slider( "value" )

                if a < 0
                    angle = 360 + a
                else
                    angle = a

                angle = angle.toFixed(4)

            w = +@$framesetter_photo.width()
            h = +@$framesetter_photo.height()

            frame_width = @$framesetter_frame.width()
            frame_height = @$framesetter_frame.height()

            x = ( +@$framesetter_photo.css('left').slice(0, -2) + w/2 ) / frame_width # scale * (
            y = ( +@$framesetter_photo.css('top').slice(0, -2) + h/2 ) / frame_height #scale * (

            if @currentAction.resizable
                type = "stretch"
            else
                type = "square"

# "name": "frame3" 
# "type": "string" ("square|stretch", square - если рамка квадратная, stretch - тянущаяся)
# "num": "#" 
# "x": "string" (float в виде string, 4 знака после запятой.)
# "y": "string" (float в виде string, 4 знака после запятой.)
# "scale":"string" (float в виде стринг, 2 знака после запятой.) Необязательный
# "angle":"string" Необязательный

            action =  
                name: "frame3"
                type: type
                num: @currentAction.num
                x: x.toFixed(4)
                y: y.toFixed(4)
                scale: ratio
                angle: angle

            @_request(action).done =>
                @currentImage += 1

                @_update_image( =>
                    @$framesetter.hide()
                    @$target_image_box.show()
                ).on 'load', =>
                    @_unfreeze_all_elements()
                    @_switch_ok_cancel(false)
                    $ui_buttons = @element.find('.ui_button')
                    $ui_buttons.removeAttr 'active'
                    @_increment_operation_index()
                    @_update_undo_redo_state()
                    @$submenus.find("a[group]").parent().removeClass "e_active"
                    @$hidden_div.hide()
                    @show_image = false

                    @apply_function = false
                    @apply_group = false
                    @_start_action nextAction

        _group_operation_finished: (nextAction) ->
            @_switch_ok_cancel(false)
            @_increment_operation_index()

            $ui_buttons = @element.find('.ui_button')
            $ui_buttons.removeAttr 'active'

            @_update_undo_redo_state()

            @$submenus.find("a[group]").parent().removeClass "e_active"

            @currentImage++
            @show_image = false

            @apply_function = false
            @apply_group = false

            @_start_action nextAction

        _cancel_group: ->
            @_switch_ok_cancel(false)

            @element.find('.submenu a').parent().removeClass 'e_active'
            @show_image = false

            if @apply_group == "_frame"
                @$framesetter.hide()
                @$target_image_box.show()
            else
                @_show_hidden_div()

                @_update_image().on 'load', =>
                    @$hidden_div.hide()
                    @_update_undo_redo_state()

            @apply_function = false
            @apply_group = false

        _discard: ->
            if @savedImage
                @currentImage = @savedImage
            else
                @currentImage = 0

            @show_image = false

            @element.find('.submenu a').parent().removeClass 'e_active'

            if @cancel_function
                @cancel_function()
                @cancel_function = false

            @apply_function = false
            @apply_group = false

            @nextOperationIndex = 0
            @maxOperationIndex = 0
            @operations = []

            @_show_hidden_div()
            @_switch_ok_cancel false

            @_update_image().on 'load', =>
                @$hidden_div.hide()

            @_update_undo_redo_state()

        _save: ->
            if typeof @apply_function == "function"
                @apply_function( $.proxy( @_save_finish, this ) )
            else
                @_save_finish()

        _save_finish: ->
            if @nextOperationIndex > 0
                send_operation = @operations[0..@nextOperationIndex - 1]

                @_request( send_operation, $.proxy(@_saving_data, this) ).always =>
                    @destroy()

                    if @options.exit instanceof Function
                        @options.exit(true)
            else            
                @destroy()
                if @options.exit instanceof Function
                    @options.exit(false)

        _saving_data: (actions) ->
            myData = 
               "proc" : "offline"
               "PHPSESSID" : @options.session               
               "uid" : @options['uid']
               "hash" : @options['hash'] 

            myData.operations = actions

            myData

        _undo: ->
            @currentImage--
            @nextOperationIndex--

            @_freeze_all_elements()
            @_show_hidden_div()

            @_update_image().on 'load', =>                
                @$hidden_div.hide()
                @_unfreeze_all_elements()
                @_update_undo_redo_state()


        _redo: ->
            @currentImage++
            @_increment_operation_index()

            @_freeze_all_elements()
            @_show_hidden_div()
            
            @_update_image().on 'load', =>
                @$hidden_div.hide()
                @_unfreeze_all_elements()
                @_update_undo_redo_state()


        _move_over: (e) ->
            $submenu = @$el.find('.showed_submenu')

            if($submenu.length == 0)
                return

            offset = $submenu.offset()
            left = offset.left
            top = offset.top
            w = $submenu.outerWidth()
            h = $submenu.outerHeight()

            x = e.pageX
            y = e.pageY

            if( x < left - 20 or y > top + h + 20 or x > left + w + 20 )
                @_hide_submenu_timer()

        _increment_operation_index: ->
            @nextOperationIndex++

            if @maxOperationIndex < @nextOperationIndex
                @maxOperationIndex = @nextOperationIndex

            @_update_undo_redo_state()
            
        _decrement_operation_index: ->
            @nextOperationIndex--
            @_update_undo_redo_state()

        _reset_submenu_timer: ->
            if @hideTimeout
                clearTimeout @hideTimeout
                @hideTimeout = false

        _hide_submenu_timer: ->
            unless @hideTimeout
                @hideTimeout = setTimeout($.proxy(@_hide_submenu, this), 700)

        _hide_submenu: ->
            @$submenus.hide()
            @$el.find('.effects_submenu.optionPointerTop').hide()
            @$el.find('.frames_submenu.optionPointerTop').hide()

            @$menus.removeClass('showed_menu')
            @$submenus.removeClass('showed_submenu')
            @hideTimeout = false

        _compile_url: ->
            # /users/3last_digits([UID])/[UID]/THUMBS/[HASH_IMAGE].pe1.jpg

            length = @options['uid'].length
            subuid = + @options['uid'].substring(length - 3)

            image_index = if @show_image then @show_image else @currentImage

            return "#{@options['cust']}users/#{subuid}/#{@options['uid']}/THUMBS/#{@options['hash']}.pe#{image_index}.jpg?" + randString()

        _show_hidden_div: (fullHide = false) ->
            if @$target_image_box.css('display') == "none"
                obj = @$framesetter
            else
                obj = @$target_image_box

            position = obj.position()
            height = obj.height()
            width = obj.width()

            if height == 0
                height = "100%"

            if width == 0
                width = "100%"

            if fullHide
                @$hidden_div.css 'background', 'white'
            else
                @$hidden_div.css 'background', 'none'

            @$hidden_div.show()

            @$hidden_div.css 'height', height
            @$hidden_div.css 'width', width
            @$hidden_div.css 'left', position.left
            @$hidden_div.css 'top', position.top

            @$hidden_div.find('#img_container').css 'margin', '0 auto'
            @$hidden_div.find('#img_container').css 'marginTop', (height - 70) / 2

        _update_undo_redo_state: () ->
            if @nextOperationIndex > 0
                @$undo_button.removeClass('disabledBtn').unblock()                
            else
                @$undo_button.addClass('disabledBtn').block()

            if @nextOperationIndex >= 0 and @maxOperationIndex > @nextOperationIndex
                @$redo_button.removeClass('disabledBtn').unblock()
            else
                @$redo_button.addClass('disabledBtn').block()

        _freeze_all_elements: ->
            $ui_buttons = @element.find '.ui_button[active!=0]'
            @_freeze_elements $ui_buttons

            @$sliderHeader.find('div.slider div.progressTune').slider "disable"

        _unfreeze_all_elements: ->
            $ui_buttons = @element.find '.ui_button[active!=0]'
            @_unfreeze_elements $ui_buttons

            @$sliderHeader.find('div.slider div.progressTune').slider "enable"

        _freeze_elements: ($elements) ->
            $elements.block()
            $elements.not('[group]').addClass 'disabledBtn'
            $elements.filter('[group]').parent().addClass 'disabledLI'

        _unfreeze_elements: ($elements) ->
            $elements.unblock()
            $elements.not('[group]').removeClass 'disabledBtn'
            $elements.filter('[group]').parent().removeClass 'disabledLI'

        _make_request_data: (action) ->
            myData = 
               "proc" : "online"
               "PHPSESSID" : @options.session
               "hash" : @options['hash'] 
               "uid" : @options['uid']
               "source" : "pe" + "#{@currentImage}"
               "target" : "pe" + "#{@currentImage + 1}"

            myData.operations = []

            if action instanceof Array
                for item in action
                    myData.operations.push item
            else            
                myData.operations.push action

            myData

        _request: (action, _make_request_data) ->
            @_freeze_all_elements()
            @_show_hidden_div()

            unless _make_request_data
                _make_request_data = $.proxy(@_make_request_data, this)

            dfd = @_send_ajax(action, _make_request_data)

            dfd.fail =>
                @_unfreeze_all_elements()
                @$hidden_div.hide()

            dfd

        _update_image: (beforeLoad) ->
            @$target_image.attr 'src', @_compile_url()

            @$target_image.off 'load'            

            return @$target_image.on 'load', =>
                if typeof beforeLoad == "function"
                    beforeLoad()
                # Using clone element we can find real photo size
                $clone = $ '<img/>'
                $clone.css width: 'auto', height: 'auto', position: 'absolute', left: '-50000px'

                this.element.append $clone

                # real size of image we can find only after load (render in our clone element)
                $clone.on 'load', (e) =>                    
                    $img = $(e.currentTarget)
                    
                    @original_image_width = $img.width()
                    @original_image_height = $img.height()

                    $img.remove()

                $clone.attr 'src', @$target_image.attr 'src'

                box_w = @$target_image_box.width()
                box_h = @$target_image_box.height()

                @image_width = @$target_image.width()
                @image_height = @$target_image.height()

                left = ( box_w - @image_width ) / 2
                top = ( box_h - @image_height ) / 2

                @$target_image.css top: top, left: left

        _send_ajax: (action, _make_request_data) ->
            @element.find('#request').text $.toJSON(_make_request_data(action))

            @_execute_ajax(@options['api'], $.toJSON(_make_request_data(action)), 'POST')
            .done (data) =>
                @element.find('#response').text "OK" + data
                @operations[@nextOperationIndex] = action
                if @maxOperationIndex > @nextOperationIndex
                    @maxOperationIndex = @nextOperationIndex

        _execute_ajax: (url, data, method, dataType = "html") ->
            dfd = false

            unless $.support.cors
                dfd = $.ajax
                    url: @options.proxy
                    data : 
                        url: url
                        type: 'POST'
                        data: data
                    type : 'POST'
                    dataType: dataType
            else
                dfd = $.ajax
                    url: url
                    data : data
                    type : method

            dfd

        _rotate_menu: ->
            @_over_menu @$rotate_menu, @$rotate_submenu

        _crop_menu: ->
            @_over_menu @$crop_menu, @$crop_submenu

        _effects_menu: ->
            @_over_menu @$effects_menu, @$effects_submenu
            @$effects_submenu.Carousel()            
            @$el.find('.effects_submenu.optionPointerTop').show()

        _frames_menu: ->
            @_over_menu @$frames_menu, @$frames_submenu
            @$frames_submenu.Carousel()
            @$el.find('.frames_submenu.optionPointerTop').show()

        _enchance_menu: ->
            @_over_menu @$enchance_menu, @$enchance_submenu

        _over_menu: ($menu, $submenu) ->
            if $menu.hasClass('showed_menu')
                return

            @$menus.removeClass('showed_menu')
            $menu.addClass('showed_menu')

            @$submenus.removeClass('showed_submenu').hide()
            @$el.find('.effects_submenu.optionPointerTop').hide()
            @$el.find('.frames_submenu.optionPointerTop').hide()

            $submenu.addClass('showed_submenu').show()

        _autolevel: ->
            "name": "autolevel"

        _rotate_left: ->
            "name": "rotation"
            "angle" : "270"

        _rotate_right: ->
            "name": "rotation"
            "angle" : "90"

        _filter1: ->
            "name": "filter1"

        _filter2: ->
            "name": "filter2"

        _filter3: ->
            "name": "filter3"

        _filter4: ->
            "name": "filter4"

        _filter5: ->
            "name": "filter5"

        _filter6: ->
            "name": "filter6"

        _filter7: ->
            "name": "filter7"

        _filter8: ->
            "name": "filter8"

        _flip_horizontal: ->
            "name": "flip"
            "orientation" : "h"

        _flip_vertical: ->
            "name": "flip"
            "orientation" : "v"

        _switch_ok_cancel: (show) ->
            if show
                @$ok_button.show()
                @$cancel_button.show()
                @$undo_button.hide()
                @$redo_button.hide()
            else
                @$ok_button.hide()
                @$cancel_button.hide()
                @$undo_button.show()
                @$redo_button.show()

                @_update_undo_redo_state()

        _custom_crop: ->
            selection =
                x1: @image_width * 0.2
                y1: @image_height * 0.2
                x2: @image_width * 0.8 
                y2: @image_height * 0.8
            
            @_ias handles: true, selection: selection

        _square_crop: ->
            dimension = if @image_width < @image_height then @image_width else @image_height

            selection =  
                x1: ( @image_width - dimension * 0.6 ) / 2
                y1: ( @image_height - dimension * 0.6 ) / 2
                x2: ( @image_width + dimension * 0.6 ) / 2
                y2: ( @image_height + dimension * 0.6 ) / 2

            @_ias handles: true, aspectRatio: "1:1", selection: selection

        _4_3_crop: ->
            dimension = if @image_width < @image_height then @image_width else @image_height

            normalized = dimension * 0.9

            selection = 
                x1: ( @image_width - normalized ) / 2
                y1: ( @image_height - normalized * 3 / 4 ) / 2
                x2: ( @image_width + normalized ) / 2
                y2: ( @image_height + normalized * 3 / 4 ) / 2

            @_ias handles: true, aspectRatio: "4:3", selection: selection

        _3_4_crop: ->
            dimension = if @image_width < @image_height then @image_width else @image_height

            normalized = dimension * 0.9

            selection = 
                x1: ( @image_width - normalized * 3 / 4 ) / 2
                y1: ( @image_height - normalized ) / 2
                x2: ( @image_width + normalized * 3 / 4 ) / 2
                y2: ( @image_height + normalized ) / 2

            @_ias handles: true, aspectRatio: "3:4", selection: selection

        _16_9_crop: ->
            dimension = if @image_width < @image_height then @image_width else @image_height

            normalized = dimension * 0.9

            selection =  
                x1: ( @image_width - normalized ) / 2
                y1: ( @image_height - normalized * 9 / 16 ) / 2
                x2: ( @image_width + normalized ) / 2
                y2: ( @image_height + normalized * 9 / 16 ) / 2

            @_ias handles: true, aspectRatio: "16:9", selection: selection

        _9_16_crop: ->
            dimension = if @image_width < @image_height then @image_width else @image_height

            normalized = dimension * 0.9

            selection =  
                x1: ( @image_width - normalized * 9 / 16 ) / 2
                y1: ( @image_height - normalized ) / 2
                x2: ( @image_width + normalized * 9 / 16 ) / 2
                y2: ( @image_height + normalized ) / 2

            @_ias handles: true, aspectRatio: "9:16", selection: selection

        _cancel_ias: ->
            @$target_image.imgAreaSelect remove: true


        _ias: (options) ->
            @$submenus.hide()

            options.minHeight = 32
            options.minWidth = 32

            @$target_image.imgAreaSelect options

            @ias = @$target_image.imgAreaSelect instance: true 

            @ias.setSelection options.selection.x1, options.selection.y1, options.selection.x2, options.selection.y2, true
            @ias.setOptions show: true 
            @ias.update()



    $.widget "snoxter.Carousel",  
        options:
            delay: 3000

        _create: ->

            @this = this

            @$el = $(this.element)

            @$content = @$el.find("ul").first()

            @cw = @$content.width()

            @$el.addClass('carousel_container')
    
            @w = @$el.width()
            @h = @$el.height()

            outerWidth = @$el.outerWidth()

            @padding = ( outerWidth - @w )  / 2

            @$next = $('<div/>')
                .addClass('carousel_next')
            @$prev = $('<div/>')
                .addClass('carousel_prev')

            @$next_padding = $('<div/>').addClass('carousel_button').css
                position: 'absolute'
                top: '0px'
                left: outerWidth - @padding
                width: @padding
                height: @h

            @$prev_padding = $('<div/>').addClass('carousel_button').css
                position: 'absolute'
                top: '0px'
                left: '0px'
                width: @padding
                height: @h

            @$el.append( @$next_padding.append ( @$next ))
            @$el.append( @$prev_padding.append ( @$prev ))

            iconW = @$next.width()
            iconH = @$next.height()

            @$next.css marginTop: ( @h / 2 - iconH / 2 )
            @$prev.css marginTop: ( @h / 2 - iconH / 2 )

            @$next.css marginLeft: ( @padding - iconW ) / 2
            @$prev.css marginLeft: (@padding - iconW) / 2

            @_events()

        _destroy: ->

        _events: ->
            @$next.on 'mouseenter', $.proxy( @_scroll_next, this )
            @$next.on 'mouseleave', $.proxy( @_scroll_stop, this )
                
            @$prev.on 'mouseenter', $.proxy( @_scroll_prev, this )
            @$prev.on 'mouseleave', $.proxy( @_scroll_stop, this )

            @$el.on 'mouseenter', $.proxy( @_scroll_stop, this )

        _scroll_stop: ->
            @$content.stop()

        _scroll_next: ->
            delay = this.options.delay * ( Math.abs( @$content.position().left + ( @cw - @w ) ) / @cw )

            @$content.animate { left: - ( @cw - @w ) }, 
                duration: delay
                easing: "linear"

        _scroll_prev: ->
            delay = this.options.delay * ( Math.abs( @$content.position().left ) / @cw )

            @$content.animate { left: 0 + @padding }, 
                duration: delay
                easing: "linear"
