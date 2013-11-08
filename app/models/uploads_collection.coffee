module.exports = class Uploads extends Backbone.Collection
    model: require './upload_item'

    initialize: ->
        @on 'stop', @resetCollection

    resetCollection: =>
        @reset()

    progress: (json) =>
        model = @findWhere hash: json.id

        return unless model

        model.set 'size', json.size
        model.set 'received', json.received
        model.trigger 'upload:progress'

        @uploadProgress()

    uploadProgress: =>
        size = 0
        received = 0

        for item in @models            
            size += item.get('size') if item.get('size')
            received += item.get('received') if item.get('received')

        @trigger 'uploads:progressTotal', 100.0 * received / size



