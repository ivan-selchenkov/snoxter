FooterView = require 'views/footer_view'

module.exports = class EditorLayoutView extends Backbone.View
  id: 'editorLayout'

  template: require './templates/editor_layout'

  remove: =>
    @footerView and @footerView.remove()    

    Backbone.View.prototype.remove.call(this)

  render: ->
    @$el.html @template

    cust = "#{CUST_SERVER}"

    @$('#image_editor').ImageEditor
      debug: false
      init: cust + '/scripts/v2/photoeditor.cgi'
      cust: cust + '/'
      proxy: '/proxy.php'
      api: cust + '/scripts/digiproc'
      uid: UID
      hash: @options.hash
      frames_url: "/frames/"
      exit: (arg) =>
        if @$("#phed_act").attr('checked')
          $.ajax
            type: "GET"
            url: "/v2/phed_act.php"
            dataType: "jsonp"
            data: 
              PHPSESSID: SESSION
              hash: @options.hash

        app.router.navigate "view/#{@options.hash}", trigger: true
      check_pay: =>
        return false
      is_paid: =>
        return false
      session: SESSION




    @footerView = new FooterView()
    @$("#editorFooter").html @footerView.render().$el

    this  
