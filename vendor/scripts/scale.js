$.widget("sharium.Scale",  {
    options: {
        size: 90
    },
    _create: function() {
        this._apply();
    },
    _apply: function() {
        var $el = $(this.element);
        var $image = $el.find('img');
        var size = this.options.size;

        $image.load(function() {
            var $this = $(this);
            var height = $this.height();
            var width = $this.width();
            var scale;

            if(width < height) {
                scale = size / width;
                var top = - (height * scale - size) / 2;

                $this.width(size);
                $this.css('top', top + 'px');

            } else {
                scale = size / height;
                var left = - (width * scale - size) / 2;

                $this.height(size);
                $this.css('left', left + 'px');
            }
        });
    }
});