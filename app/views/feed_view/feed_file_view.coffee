module.exports = class FeedFileView extends Backbone.View
  className: 'feed_file'
  template: require './templates/file'

  render: ->

    preview_url = "/imgs/file.png"


    switch @model.get("type")
        when "1"
            preview_url = "/imgs/musicfile.png"
        when "3", "2" 
            # TODO: Set correct path
            if SKIP_CUST
                preview_url = "#{CUST_SERVER}/users/#{@model.get('subuid')}/#{@model.get('uid')}/THUMBS/#{@model.get("hash")}.jpg"
            else
                preview_url = "#{CUST_HTTP}#{CUST_PREFIX}#{@model.get('server')}.#{DOMAIN}/users/#{@model.get('subuid')}/#{@model.get('uid')}/THUMBS/#{@model.get("hash")}.jpg"
        when "directory"
            preview_url = "/imgs/folderfile.png"

    @model.set 'preview_url', preview_url

    @$el.html @template(file: @model)

    if @model.get("type") in [ "2", "3" ]        
        @$el.Scale( size: 95 )
    else
        @$("img").css height: "95px"

    this
