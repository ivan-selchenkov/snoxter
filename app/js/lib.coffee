xtractFile2 = ->
    input = $ "#fileIT"

    result = ""

    if input.files 
        for file in files
            name = file.name
            m = name.match /([^\/\\]+)$/
            if m && m[1]
                name = m[1]

            if name != ""
                result += ", " if result != ""

    result

window.getInvisibleDimension = (obj) ->

    clone = obj.clone()

    clone.css
        visibility: 'hidden'
        width: 'auto'
        height: 'auto'
        maxWidth: 'auto'
        minWidth: 'auto'

    $('body').append clone

    width = clone.outerWidth()
    height = clone.outerHeight()

    clone.remove()

    return { w:width, h:height }
