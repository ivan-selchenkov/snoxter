FeedFileView = require 'views/feed_view/feed_file_view'

module.exports = class FeedShareView extends Backbone.View
  className: 'feed_share'

  events:
    "click .share_toggle_files": "toggle_more_less"

  toggle_more_less: =>
    $toggle = @$el.find('.share_toggle_files')

    if $toggle.hasClass 'more'
      @$el.find('.feed_file').show()
      $toggle.text("- LESS").removeClass('more').addClass('less')

    else
      @$el.find('.feed_file:gt(5)').hide()
      $toggle.text("+ MORE").removeClass('less').addClass('more')

    app.feedNiceScroll.resize()


  render: ->
    @$el.html ""

    @$el.append $('<div/>').html "has shared #{@model.files.length} file(s). #{@model.datetime}."

    for file in @model.files
      file_view = new FeedFileView(model: file)
      @$el.append file_view.render().$el.hide()


    if @model.files.length > 6
        @$el.append $('<div/>').addClass('share_toggle_files more').text("+ MORE").css('clear', 'both')

    @$el.find('.feed_file:lt(6)').show()

    @$el.append $('<div/>').css('clear', 'both')
    this
