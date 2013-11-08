exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        'javascripts/app.js': /^app/
        'javascripts/vendor.js': /^vendor/
        'test/javascripts/test.js': /^test(\/|\\)(?!vendor)/
        'test/javascripts/test-vendor.js': /^test(\/|\\)(?=vendor)/
      order:
        before: [
          'vendor/scripts/jquery.js'
          'vendor/scripts/jquery-ui.js'
          'vendor/scripts/jquery.blockui.js'
          'vendor/scripts/ie_vendor.js'
          'vendor/scripts/jquery.balloon.js'
          'vendor/scripts/scale.js'
          'vendor/scripts/jquery.jplayer.js'
          'vendor/scripts/jquery.fileupload.js'
          'vendor/scripts/jquery.iframe.js'
          'vendor/scripts/json2.js'
          'vendor/scripts/underscore.js'
          'vendor/scripts/backbone.js'          
          'vendor/scripts/md5.js'
        ]
    stylesheets:
      defaultExtension: 'scss'
      joinTo: 'stylesheets/app.css'
    templates:
      defaultExtension: 'eco'
      joinTo: 'javascripts/app.js'
  minify: no
