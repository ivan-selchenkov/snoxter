(function(/*! Brunch !*/) {
  'use strict';

  var globals = typeof window !== 'undefined' ? window : global;
  if (typeof globals.require === 'function') return;

  var modules = {};
  var cache = {};

  var has = function(object, name) {
    return ({}).hasOwnProperty.call(object, name);
  };

  var expand = function(root, name) {
    var results = [], parts, part;
    if (/^\.\.?(\/|$)/.test(name)) {
      parts = [root, name].join('/').split('/');
    } else {
      parts = name.split('/');
    }
    for (var i = 0, length = parts.length; i < length; i++) {
      part = parts[i];
      if (part === '..') {
        results.pop();
      } else if (part !== '.' && part !== '') {
        results.push(part);
      }
    }
    return results.join('/');
  };

  var dirname = function(path) {
    return path.split('/').slice(0, -1).join('/');
  };

  var localRequire = function(path) {
    return function(name) {
      var dir = dirname(path);
      var absolute = expand(dir, name);
      return globals.require(absolute);
    };
  };

  var initModule = function(name, definition) {
    var module = {id: name, exports: {}};
    definition(module.exports, localRequire(name), module);
    var exports = cache[name] = module.exports;
    return exports;
  };

  var require = function(name) {
    var path = expand(name, '.');

    if (has(cache, path)) return cache[path];
    if (has(modules, path)) return initModule(path, modules[path]);

    var dirIndex = expand(path, './index');
    if (has(cache, dirIndex)) return cache[dirIndex];
    if (has(modules, dirIndex)) return initModule(dirIndex, modules[dirIndex]);

    throw new Error('Cannot find module "' + name + '"');
  };

  var define = function(bundle) {
    for (var key in bundle) {
      if (has(bundle, key)) {
        modules[key] = bundle[key];
      }
    }
  }

  globals.require = require;
  globals.require.define = define;
  globals.require.brunch = true;
})();

/*
 * imgAreaSelect jQuery plugin
 * version 0.9.10
 *
 * Copyright (c) 2008-2013 Michal Wojciechowski (odyniec.net)
 *
 * Dual licensed under the MIT (MIT-LICENSE.txt)
 * and GPL (GPL-LICENSE.txt) licenses.
 *
 * http://odyniec.net/projects/imgareaselect/
 *
 */

(function($) {

var abs = Math.abs,
    max = Math.max,
    min = Math.min,
    round = Math.round;

function div() {
    return $('<div/>');
}

$.imgAreaSelect = function (img, options) {
    var

        $img = $(img),

        imgLoaded,

        $box = div(),
        $area = div(),
        $border = div().add(div()).add(div()).add(div()),
        $outer = div().add(div()).add(div()).add(div()),
        $handles = $([]),

        $areaOpera,

        left, top,

        imgOfs = { left: 0, top: 0 },

        imgWidth, imgHeight,

        $parent,

        parOfs = { left: 0, top: 0 },

        zIndex = 0,

        position = 'absolute',

        startX, startY,

        scaleX, scaleY,

        resize,

        minWidth, minHeight, maxWidth, maxHeight,

        aspectRatio,

        shown,

        x1, y1, x2, y2,

        selection = { x1: 0, y1: 0, x2: 0, y2: 0, width: 0, height: 0 },

        docElem = document.documentElement,

        ua = navigator.userAgent,

        $p, d, i, o, w, h, adjusted;

    function viewX(x) {
        return x + imgOfs.left - parOfs.left;
    }

    function viewY(y) {
        return y + imgOfs.top - parOfs.top;
    }

    function selX(x) {
        return x - imgOfs.left + parOfs.left;
    }

    function selY(y) {
        return y - imgOfs.top + parOfs.top;
    }

    function evX(event) {
        return event.pageX - parOfs.left;
    }

    function evY(event) {
        return event.pageY - parOfs.top;
    }

    function getSelection(noScale) {
        var sx = noScale || scaleX, sy = noScale || scaleY;

        return { x1: round(selection.x1 * sx),
            y1: round(selection.y1 * sy),
            x2: round(selection.x2 * sx),
            y2: round(selection.y2 * sy),
            width: round(selection.x2 * sx) - round(selection.x1 * sx),
            height: round(selection.y2 * sy) - round(selection.y1 * sy) };
    }

    function setSelection(x1, y1, x2, y2, noScale) {
        var sx = noScale || scaleX, sy = noScale || scaleY;

        selection = {
            x1: round(x1 / sx || 0),
            y1: round(y1 / sy || 0),
            x2: round(x2 / sx || 0),
            y2: round(y2 / sy || 0)
        };

        selection.width = selection.x2 - selection.x1;
        selection.height = selection.y2 - selection.y1;
    }

    function adjust() {
        if (!imgLoaded || !$img.width())
            return;

        imgOfs = { left: round($img.offset().left), top: round($img.offset().top) };

        imgWidth = $img.width();
        imgHeight = $img.height();

        minWidth = round(options.minWidth / scaleX) || 0;
        minHeight = round(options.minHeight / scaleY) || 0;
        maxWidth = round(min(options.maxWidth / scaleX || 1<<24, imgWidth));
        maxHeight = round(min(options.maxHeight / scaleY || 1<<24, imgHeight));

        if ($().jquery == '1.3.2' && position == 'fixed' &&
            !docElem['getBoundingClientRect'])
        {
            imgOfs.top += max(document.body.scrollTop, docElem.scrollTop);
            imgOfs.left += max(document.body.scrollLeft, docElem.scrollLeft);
        }

        parOfs = /absolute|relative/.test($parent.css('position')) ?
            { left: round($parent.offset().left) - $parent.scrollLeft(),
                top: round($parent.offset().top) - $parent.scrollTop() } :
            position == 'fixed' ?
                { left: $(document).scrollLeft(), top: $(document).scrollTop() } :
                { left: 0, top: 0 };

        left = viewX(0);
        top = viewY(0);

        if (selection.x2 > imgWidth || selection.y2 > imgHeight)
            doResize();
    }

    function update(resetKeyPress) {
        if (!shown) return;

        $box.css({ left: viewX(selection.x1), top: viewY(selection.y1) })
            .add($area).width(w = selection.width).height(h = selection.height);

        $area.add($border).add($handles).css({ left: 0, top: 0 });

        $border
            .width(max(w - $border.outerWidth() + $border.innerWidth(), 0))
            .height(max(h - $border.outerHeight() + $border.innerHeight(), 0));

        $($outer[0]).css({ left: left, top: top,
            width: selection.x1, height: imgHeight });
        $($outer[1]).css({ left: left + selection.x1, top: top,
            width: w, height: selection.y1 });
        $($outer[2]).css({ left: left + selection.x2, top: top,
            width: imgWidth - selection.x2, height: imgHeight });
        $($outer[3]).css({ left: left + selection.x1, top: top + selection.y2,
            width: w, height: imgHeight - selection.y2 });

        w -= $handles.outerWidth();
        h -= $handles.outerHeight();

        switch ($handles.length) {
        case 8:
            $($handles[4]).css({ left: w >> 1 });
            $($handles[5]).css({ left: w, top: h >> 1 });
            $($handles[6]).css({ left: w >> 1, top: h });
            $($handles[7]).css({ top: h >> 1 });
        case 4:
            $handles.slice(1,3).css({ left: w });
            $handles.slice(2,4).css({ top: h });
        }

        if (resetKeyPress !== false) {
            if ($.imgAreaSelect.onKeyPress != docKeyPress)
                $(document).unbind($.imgAreaSelect.keyPress,
                    $.imgAreaSelect.onKeyPress);

            if (options.keys)
                $(document)[$.imgAreaSelect.keyPress](
                    $.imgAreaSelect.onKeyPress = docKeyPress);
        }

        if (msie && $border.outerWidth() - $border.innerWidth() == 2) {
            $border.css('margin', 0);
            setTimeout(function () { $border.css('margin', 'auto'); }, 0);
        }
    }

    function doUpdate(resetKeyPress) {
        adjust();
        update(resetKeyPress);
        x1 = viewX(selection.x1); y1 = viewY(selection.y1);
        x2 = viewX(selection.x2); y2 = viewY(selection.y2);
    }

    function hide($elem, fn) {
        options.fadeSpeed ? $elem.fadeOut(options.fadeSpeed, fn) : $elem.hide();

    }

    function areaMouseMove(event) {
        var x = selX(evX(event)) - selection.x1,
            y = selY(evY(event)) - selection.y1;

        if (!adjusted) {
            adjust();
            adjusted = true;

            $box.one('mouseout', function () { adjusted = false; });
        }

        resize = '';

        if (options.resizable) {
            if (y <= options.resizeMargin)
                resize = 'n';
            else if (y >= selection.height - options.resizeMargin)
                resize = 's';
            if (x <= options.resizeMargin)
                resize += 'w';
            else if (x >= selection.width - options.resizeMargin)
                resize += 'e';
        }

        $box.css('cursor', resize ? resize + '-resize' :
            options.movable ? 'move' : '');
        if ($areaOpera)
            $areaOpera.toggle();
    }

    function docMouseUp(event) {
        $('body').css('cursor', '');
        if (options.autoHide || selection.width * selection.height == 0)
            hide($box.add($outer), function () { $(this).hide(); });

        $(document).unbind('mousemove', selectingMouseMove);
        $box.mousemove(areaMouseMove);

        options.onSelectEnd(img, getSelection());
    }

    function areaMouseDown(event) {
        if (event.which != 1) return false;

        adjust();

        if (resize) {
            $('body').css('cursor', resize + '-resize');

            x1 = viewX(selection[/w/.test(resize) ? 'x2' : 'x1']);
            y1 = viewY(selection[/n/.test(resize) ? 'y2' : 'y1']);

            $(document).mousemove(selectingMouseMove)
                .one('mouseup', docMouseUp);
            $box.unbind('mousemove', areaMouseMove);
        }
        else if (options.movable) {
            startX = left + selection.x1 - evX(event);
            startY = top + selection.y1 - evY(event);

            $box.unbind('mousemove', areaMouseMove);

            $(document).mousemove(movingMouseMove)
                .one('mouseup', function () {
                    options.onSelectEnd(img, getSelection());

                    $(document).unbind('mousemove', movingMouseMove);
                    $box.mousemove(areaMouseMove);
                });
        }
        else
            $img.mousedown(event);

        return false;
    }

    function fixAspectRatio(xFirst) {
        if (aspectRatio)
            if (xFirst) {
                x2 = max(left, min(left + imgWidth,
                    x1 + abs(y2 - y1) * aspectRatio * (x2 > x1 || -1)));

                y2 = round(max(top, min(top + imgHeight,
                    y1 + abs(x2 - x1) / aspectRatio * (y2 > y1 || -1))));
                x2 = round(x2);
            }
            else {
                y2 = max(top, min(top + imgHeight,
                    y1 + abs(x2 - x1) / aspectRatio * (y2 > y1 || -1)));
                x2 = round(max(left, min(left + imgWidth,
                    x1 + abs(y2 - y1) * aspectRatio * (x2 > x1 || -1))));
                y2 = round(y2);
            }
    }

    function doResize() {
        x1 = min(x1, left + imgWidth);
        y1 = min(y1, top + imgHeight);

        if (abs(x2 - x1) < minWidth) {
            x2 = x1 - minWidth * (x2 < x1 || -1);

            if (x2 < left)
                x1 = left + minWidth;
            else if (x2 > left + imgWidth)
                x1 = left + imgWidth - minWidth;
        }

        if (abs(y2 - y1) < minHeight) {
            y2 = y1 - minHeight * (y2 < y1 || -1);

            if (y2 < top)
                y1 = top + minHeight;
            else if (y2 > top + imgHeight)
                y1 = top + imgHeight - minHeight;
        }

        x2 = max(left, min(x2, left + imgWidth));
        y2 = max(top, min(y2, top + imgHeight));

        fixAspectRatio(abs(x2 - x1) < abs(y2 - y1) * aspectRatio);

        if (abs(x2 - x1) > maxWidth) {
            x2 = x1 - maxWidth * (x2 < x1 || -1);
            fixAspectRatio();
        }

        if (abs(y2 - y1) > maxHeight) {
            y2 = y1 - maxHeight * (y2 < y1 || -1);
            fixAspectRatio(true);
        }

        selection = { x1: selX(min(x1, x2)), x2: selX(max(x1, x2)),
            y1: selY(min(y1, y2)), y2: selY(max(y1, y2)),
            width: abs(x2 - x1), height: abs(y2 - y1) };

        update();

        options.onSelectChange(img, getSelection());
    }

    function selectingMouseMove(event) {
        x2 = /w|e|^$/.test(resize) || aspectRatio ? evX(event) : viewX(selection.x2);
        y2 = /n|s|^$/.test(resize) || aspectRatio ? evY(event) : viewY(selection.y2);

        doResize();

        return false;

    }

    function doMove(newX1, newY1) {
        x2 = (x1 = newX1) + selection.width;
        y2 = (y1 = newY1) + selection.height;

        $.extend(selection, { x1: selX(x1), y1: selY(y1), x2: selX(x2),
            y2: selY(y2) });

        update();

        options.onSelectChange(img, getSelection());
    }

    function movingMouseMove(event) {
        x1 = max(left, min(startX + evX(event), left + imgWidth - selection.width));
        y1 = max(top, min(startY + evY(event), top + imgHeight - selection.height));

        doMove(x1, y1);

        event.preventDefault();

        return false;
    }

    function startSelection() {
        $(document).unbind('mousemove', startSelection);
        adjust();

        x2 = x1;
        y2 = y1;

        doResize();

        resize = '';

        if (!$outer.is(':visible'))
            $box.add($outer).hide().fadeIn(options.fadeSpeed||0);

        shown = true;

        $(document).unbind('mouseup', cancelSelection)
            .mousemove(selectingMouseMove).one('mouseup', docMouseUp);
        $box.unbind('mousemove', areaMouseMove);

        options.onSelectStart(img, getSelection());
    }

    function cancelSelection() {
        $(document).unbind('mousemove', startSelection)
            .unbind('mouseup', cancelSelection);
        hide($box.add($outer));

        setSelection(selX(x1), selY(y1), selX(x1), selY(y1));

        if (!(this instanceof $.imgAreaSelect)) {
            options.onSelectChange(img, getSelection());
            options.onSelectEnd(img, getSelection());
        }
    }

    function imgMouseDown(event) {
        if (event.which != 1 || $outer.is(':animated')) return false;

        adjust();
        startX = x1 = evX(event);
        startY = y1 = evY(event);

        $(document).mousemove(startSelection).mouseup(cancelSelection);

        return false;
    }

    function windowResize() {
        doUpdate(false);
    }

    function imgLoad() {
        imgLoaded = true;

        setOptions(options = $.extend({
            classPrefix: 'imgareaselect',
            movable: true,
            parent: 'body',
            resizable: true,
            resizeMargin: 10,
            onInit: function () {},
            onSelectStart: function () {},
            onSelectChange: function () {},
            onSelectEnd: function () {}
        }, options));

        $box.add($outer).css({ visibility: '' });

        if (options.show) {
            shown = true;
            adjust();
            update();
            $box.add($outer).hide().fadeIn(options.fadeSpeed||0);
        }

        setTimeout(function () { options.onInit(img, getSelection()); }, 0);
    }

    var docKeyPress = function(event) {
        var k = options.keys, d, t, key = event.keyCode;

        d = !isNaN(k.alt) && (event.altKey || event.originalEvent.altKey) ? k.alt :
            !isNaN(k.ctrl) && event.ctrlKey ? k.ctrl :
            !isNaN(k.shift) && event.shiftKey ? k.shift :
            !isNaN(k.arrows) ? k.arrows : 10;

        if (k.arrows == 'resize' || (k.shift == 'resize' && event.shiftKey) ||
            (k.ctrl == 'resize' && event.ctrlKey) ||
            (k.alt == 'resize' && (event.altKey || event.originalEvent.altKey)))
        {
            switch (key) {
            case 37:
                d = -d;
            case 39:
                t = max(x1, x2);
                x1 = min(x1, x2);
                x2 = max(t + d, x1);
                fixAspectRatio();
                break;
            case 38:
                d = -d;
            case 40:
                t = max(y1, y2);
                y1 = min(y1, y2);
                y2 = max(t + d, y1);
                fixAspectRatio(true);
                break;
            default:
                return;
            }

            doResize();
        }
        else {
            x1 = min(x1, x2);
            y1 = min(y1, y2);

            switch (key) {
            case 37:
                doMove(max(x1 - d, left), y1);
                break;
            case 38:
                doMove(x1, max(y1 - d, top));
                break;
            case 39:
                doMove(x1 + min(d, imgWidth - selX(x2)), y1);
                break;
            case 40:
                doMove(x1, y1 + min(d, imgHeight - selY(y2)));
                break;
            default:
                return;
            }
        }

        return false;
    };

    function styleOptions($elem, props) {
        for (var option in props)
            if (options[option] !== undefined)
                $elem.css(props[option], options[option]);
    }

    function setOptions(newOptions) {
        if (newOptions.parent)
            ($parent = $(newOptions.parent)).append($box.add($outer));

        $.extend(options, newOptions);

        adjust();

        if (newOptions.handles != null) {
            $handles.remove();
            $handles = $([]);

            i = newOptions.handles ? newOptions.handles == 'corners' ? 4 : 8 : 0;

            while (i--)
                $handles = $handles.add(div());

            $handles.addClass(options.classPrefix + '-handle').css({
                position: 'absolute',
                fontSize: 0,
                zIndex: zIndex + 1 || 1
            });

            if (!parseInt($handles.css('width')) >= 0)
                $handles.width(5).height(5);

            if (o = options.borderWidth)
                $handles.css({ borderWidth: o, borderStyle: 'solid' });

            styleOptions($handles, { borderColor1: 'border-color',
                borderColor2: 'background-color',
                borderOpacity: 'opacity' });
        }

        scaleX = options.imageWidth / imgWidth || 1;
        scaleY = options.imageHeight / imgHeight || 1;

        if (newOptions.x1 != null) {
            setSelection(newOptions.x1, newOptions.y1, newOptions.x2,
                newOptions.y2);
            newOptions.show = !newOptions.hide;
        }

        if (newOptions.keys)
            options.keys = $.extend({ shift: 1, ctrl: 'resize' },
                newOptions.keys);

        $outer.addClass(options.classPrefix + '-outer');
        $area.addClass(options.classPrefix + '-selection');
        for (i = 0; i++ < 4;)
            $($border[i-1]).addClass(options.classPrefix + '-border' + i);

        styleOptions($area, { selectionColor: 'background-color',
            selectionOpacity: 'opacity' });
        styleOptions($border, { borderOpacity: 'opacity',
            borderWidth: 'border-width' });
        styleOptions($outer, { outerColor: 'background-color',
            outerOpacity: 'opacity' });
        if (o = options.borderColor1)
            $($border[0]).css({ borderStyle: 'solid', borderColor: o });
        if (o = options.borderColor2)
            $($border[1]).css({ borderStyle: 'dashed', borderColor: o });

        $box.append($area.add($border).add($areaOpera)).append($handles);

        if (msie) {
            if (o = ($outer.css('filter')||'').match(/opacity=(\d+)/))
                $outer.css('opacity', o[1]/100);
            if (o = ($border.css('filter')||'').match(/opacity=(\d+)/))
                $border.css('opacity', o[1]/100);
        }

        if (newOptions.hide)
            hide($box.add($outer));
        else if (newOptions.show && imgLoaded) {
            shown = true;
            $box.add($outer).fadeIn(options.fadeSpeed||0);
            doUpdate();
        }

        aspectRatio = (d = (options.aspectRatio || '').split(/:/))[0] / d[1];

        $img.add($outer).unbind('mousedown', imgMouseDown);

        if (options.disable || options.enable === false) {
            $box.unbind('mousemove', areaMouseMove).unbind('mousedown', areaMouseDown);
            $(window).unbind('resize', windowResize);
        }
        else {
            if (options.enable || options.disable === false) {
                if (options.resizable || options.movable)
                    $box.mousemove(areaMouseMove).mousedown(areaMouseDown);

                $(window).resize(windowResize);
            }

            if (!options.persistent)
                $img.add($outer).mousedown(imgMouseDown);
        }

        options.enable = options.disable = undefined;
    }

    this.remove = function () {
        setOptions({ disable: true });
        $box.add($outer).remove();
    };

    this.getOptions = function () { return options; };

    this.setOptions = setOptions;

    this.getSelection = getSelection;

    this.setSelection = setSelection;

    this.cancelSelection = cancelSelection;

    this.update = doUpdate;

    var msie = (/msie ([\w.]+)/i.exec(ua)||[])[1],
        opera = /opera/i.test(ua),
        safari = /webkit/i.test(ua) && !/chrome/i.test(ua);

    $p = $img;

    while ($p.length) {
        zIndex = max(zIndex,
            !isNaN($p.css('z-index')) ? $p.css('z-index') : zIndex);
        if ($p.css('position') == 'fixed')
            position = 'fixed';

        $p = $p.parent(':not(body)');
    }

    zIndex = options.zIndex || zIndex;

    if (msie)
        $img.attr('unselectable', 'on');

    $.imgAreaSelect.keyPress = msie || safari ? 'keydown' : 'keypress';

    if (opera)

        $areaOpera = div().css({ width: '100%', height: '100%',
            position: 'absolute', zIndex: zIndex + 2 || 2 });

    $box.add($outer).css({ visibility: 'hidden', position: position,
        overflow: 'hidden', zIndex: zIndex || '0' });
    $box.css({ zIndex: zIndex + 2 || 2 });
    $area.add($border).css({ position: 'absolute', fontSize: 0 });

    img.complete || img.readyState == 'complete' || !$img.is('img') ?
        imgLoad() : $img.one('load', imgLoad);

    if (!imgLoaded && msie && msie >= 7)
        img.src = img.src;
};

$.fn.imgAreaSelect = function (options) {
    options = options || {};

    this.each(function () {
        if ($(this).data('imgAreaSelect')) {
            if (options.remove) {
                $(this).data('imgAreaSelect').remove();
                $(this).removeData('imgAreaSelect');
            }
            else
                $(this).data('imgAreaSelect').setOptions(options);
        }
        else if (!options.remove) {
            if (options.enable === undefined && options.disable === undefined)
                options.enable = true;

            $(this).data('imgAreaSelect', new $.imgAreaSelect(this, options));
        }
    });

    if (options.instance)
        return $(this).data('imgAreaSelect');

    return this;
};

})(jQuery);
;

/*!
 * jCarousel - Riding carousels with jQuery
 *   http://sorgalla.com/jcarousel/
 *
 * Copyright (c) 2006 Jan Sorgalla (http://sorgalla.com)
 * Dual licensed under the MIT (http://www.opensource.org/licenses/mit-license.php)
 * and GPL (http://www.opensource.org/licenses/gpl-license.php) licenses.
 *
 * Built on top of the jQuery library
 *   http://jquery.com
 *
 * Inspired by the "Carousel Component" by Bill Scott
 *   http://billwscott.com/carousel/
 */

/*global window, jQuery */
(function($) {
    // Default configuration properties.
    var defaults = {
        vertical: false,
        rtl: false,
        start: 1,
        offset: 1,
        size: null,
        scroll: 3,
        visible: null,
        animation: 'normal',
        easing: 'swing',
        auto: 0,
        wrap: null,
        initCallback: null,
        setupCallback: null,
        reloadCallback: null,
        itemLoadCallback: null,
        itemFirstInCallback: null,
        itemFirstOutCallback: null,
        itemLastInCallback: null,
        itemLastOutCallback: null,
        itemVisibleInCallback: null,
        itemVisibleOutCallback: null,
        animationStepCallback: null,
        buttonNextHTML: '<div></div>',
        buttonPrevHTML: '<div></div>',
        buttonNextEvent: 'click',
        buttonPrevEvent: 'click',
        buttonNextCallback: null,
        buttonPrevCallback: null,
        itemFallbackDimension: null
    }, windowLoaded = false;

    $(window).bind('load.jcarousel', function() { windowLoaded = true; });

    /**
     * The jCarousel object.
     *
     * @constructor
     * @class jcarousel
     * @param e {HTMLElement} The element to create the carousel for.
     * @param o {Object} A set of key/value pairs to set as configuration properties.
     * @cat Plugins/jCarousel
     */
    $.jcarousel = function(e, o) {
        this.options    = $.extend({}, defaults, o || {});

        this.locked          = false;
        this.autoStopped     = false;

        this.container       = null;
        this.clip            = null;
        this.list            = null;
        this.buttonNext      = null;
        this.buttonPrev      = null;
        this.buttonNextState = null;
        this.buttonPrevState = null;

        // Only set if not explicitly passed as option
        if (!o || o.rtl === undefined) {
            this.options.rtl = ($(e).attr('dir') || $('html').attr('dir') || '').toLowerCase() == 'rtl';
        }

        this.wh = !this.options.vertical ? 'width' : 'height';
        this.lt = !this.options.vertical ? (this.options.rtl ? 'right' : 'left') : 'top';

        // Extract skin class
        var skin = '', split = e.className.split(' ');

        for (var i = 0; i < split.length; i++) {
            if (split[i].indexOf('jcarousel-skin') != -1) {
                $(e).removeClass(split[i]);
                skin = split[i];
                break;
            }
        }

        if (e.nodeName.toUpperCase() == 'UL' || e.nodeName.toUpperCase() == 'OL') {
            this.list      = $(e);
            this.clip      = this.list.parents('.jcarousel-clip');
            this.container = this.list.parents('.jcarousel-container');
        } else {
            this.container = $(e);
            this.list      = this.container.find('ul,ol').eq(0);
            this.clip      = this.container.find('.jcarousel-clip');
        }

        if (this.clip.size() === 0) {
            this.clip = this.list.wrap('<div></div>').parent();
        }

        if (this.container.size() === 0) {
            this.container = this.clip.wrap('<div></div>').parent();
        }

        if (skin !== '' && this.container.parent()[0].className.indexOf('jcarousel-skin') == -1) {
            this.container.wrap('<div class=" '+ skin + '"></div>');
        }

        this.buttonPrev = $('.jcarousel-prev', this.container);

        if (this.buttonPrev.size() === 0 && this.options.buttonPrevHTML !== null) {
            this.buttonPrev = $(this.options.buttonPrevHTML).appendTo(this.container);
        }

        this.buttonPrev.addClass(this.className('jcarousel-prev'));

        this.buttonNext = $('.jcarousel-next', this.container);

        if (this.buttonNext.size() === 0 && this.options.buttonNextHTML !== null) {
            this.buttonNext = $(this.options.buttonNextHTML).appendTo(this.container);
        }

        this.buttonNext.addClass(this.className('jcarousel-next'));

        this.clip.addClass(this.className('jcarousel-clip')).css({
            position: 'relative'
        });

        this.list.addClass(this.className('jcarousel-list')).css({
            overflow: 'hidden',
            position: 'relative',
            top: 0,
            margin: 0,
            padding: 0
        }).css((this.options.rtl ? 'right' : 'left'), 0);

        this.container.addClass(this.className('jcarousel-container')).css({
            position: 'relative'
        });

        if (!this.options.vertical && this.options.rtl) {
            this.container.addClass('jcarousel-direction-rtl').attr('dir', 'rtl');
        }

        var di = this.options.visible !== null ? Math.ceil(this.clipping() / this.options.visible) : null;
        var li = this.list.children('li');

        var self = this;

        if (li.size() > 0) {
            var wh = 0, j = this.options.offset;
            li.each(function() {
                self.format(this, j++);
                wh += self.dimension(this, di);
            });

            this.list.css(this.wh, (wh + 100) + 'px');

            // Only set if not explicitly passed as option
            if (!o || o.size === undefined) {
                this.options.size = li.size();
            }
        }

        // For whatever reason, .show() does not work in Safari...
        this.container.css('display', 'block');
        this.buttonNext.css('display', 'block');
        this.buttonPrev.css('display', 'block');

        this.funcNext   = function() { self.next(); };
        this.funcPrev   = function() { self.prev(); };
        this.funcResize = function() { 
            if (self.resizeTimer) {
                clearTimeout(self.resizeTimer);
            }

            self.resizeTimer = setTimeout(function() {
                self.reload();
            }, 100);
        };

        if (this.options.initCallback !== null) {
            this.options.initCallback(this, 'init');
        }

        if (!windowLoaded && $.browser.safari) {
            this.buttons(false, false);
            $(window).bind('load.jcarousel', function() { self.setup(); });
        } else {
            this.setup();
        }
    };

    // Create shortcut for internal use
    var $jc = $.jcarousel;

    $jc.fn = $jc.prototype = {
        jcarousel: '0.2.8'
    };

    $jc.fn.extend = $jc.extend = $.extend;

    $jc.fn.extend({
        /**
         * Setups the carousel.
         *
         * @method setup
         * @return undefined
         */
        setup: function() {
            this.first       = null;
            this.last        = null;
            this.prevFirst   = null;
            this.prevLast    = null;
            this.animating   = false;
            this.timer       = null;
            this.resizeTimer = null;
            this.tail        = null;
            this.inTail      = false;

            if (this.locked) {
                return;
            }

            this.list.css(this.lt, this.pos(this.options.offset) + 'px');
            var p = this.pos(this.options.start, true);
            this.prevFirst = this.prevLast = null;
            this.animate(p, false);

            $(window).unbind('resize.jcarousel', this.funcResize).bind('resize.jcarousel', this.funcResize);

            if (this.options.setupCallback !== null) {
                this.options.setupCallback(this);
            }
        },

        /**
         * Clears the list and resets the carousel.
         *
         * @method reset
         * @return undefined
         */
        reset: function() {
            this.list.empty();

            this.list.css(this.lt, '0px');
            this.list.css(this.wh, '10px');

            if (this.options.initCallback !== null) {
                this.options.initCallback(this, 'reset');
            }

            this.setup();
        },

        /**
         * Reloads the carousel and adjusts positions.
         *
         * @method reload
         * @return undefined
         */
        reload: function() {
            if (this.tail !== null && this.inTail) {
                this.list.css(this.lt, $jc.intval(this.list.css(this.lt)) + this.tail);
            }

            this.tail   = null;
            this.inTail = false;

            if (this.options.reloadCallback !== null) {
                this.options.reloadCallback(this);
            }

            if (this.options.visible !== null) {
                var self = this;
                var di = Math.ceil(this.clipping() / this.options.visible), wh = 0, lt = 0;
                this.list.children('li').each(function(i) {
                    wh += self.dimension(this, di);
                    if (i + 1 < self.first) {
                        lt = wh;
                    }
                });

                this.list.css(this.wh, wh + 'px');
                this.list.css(this.lt, -lt + 'px');
            }

            this.scroll(this.first, false);
        },

        /**
         * Locks the carousel.
         *
         * @method lock
         * @return undefined
         */
        lock: function() {
            this.locked = true;
            this.buttons();
        },

        /**
         * Unlocks the carousel.
         *
         * @method unlock
         * @return undefined
         */
        unlock: function() {
            this.locked = false;
            this.buttons();
        },

        /**
         * Sets the size of the carousel.
         *
         * @method size
         * @return undefined
         * @param s {Number} The size of the carousel.
         */
        size: function(s) {
            if (s !== undefined) {
                this.options.size = s;
                if (!this.locked) {
                    this.buttons();
                }
            }

            return this.options.size;
        },

        /**
         * Checks whether a list element exists for the given index (or index range).
         *
         * @method get
         * @return bool
         * @param i {Number} The index of the (first) element.
         * @param i2 {Number} The index of the last element.
         */
        has: function(i, i2) {
            if (i2 === undefined || !i2) {
                i2 = i;
            }

            if (this.options.size !== null && i2 > this.options.size) {
                i2 = this.options.size;
            }

            for (var j = i; j <= i2; j++) {
                var e = this.get(j);
                if (!e.length || e.hasClass('jcarousel-item-placeholder')) {
                    return false;
                }
            }

            return true;
        },

        /**
         * Returns a jQuery object with list element for the given index.
         *
         * @method get
         * @return jQuery
         * @param i {Number} The index of the element.
         */
        get: function(i) {
            return $('>.jcarousel-item-' + i, this.list);
        },

        /**
         * Adds an element for the given index to the list.
         * If the element already exists, it updates the inner html.
         * Returns the created element as jQuery object.
         *
         * @method add
         * @return jQuery
         * @param i {Number} The index of the element.
         * @param s {String} The innerHTML of the element.
         */
        add: function(i, s) {
            var e = this.get(i), old = 0, n = $(s);

            if (e.length === 0) {
                var c, j = $jc.intval(i);
                e = this.create(i);
                while (true) {
                    c = this.get(--j);
                    if (j <= 0 || c.length) {
                        if (j <= 0) {
                            this.list.prepend(e);
                        } else {
                            c.after(e);
                        }
                        break;
                    }
                }
            } else {
                old = this.dimension(e);
            }

            if (n.get(0).nodeName.toUpperCase() == 'LI') {
                e.replaceWith(n);
                e = n;
            } else {
                e.empty().append(s);
            }

            this.format(e.removeClass(this.className('jcarousel-item-placeholder')), i);

            var di = this.options.visible !== null ? Math.ceil(this.clipping() / this.options.visible) : null;
            var wh = this.dimension(e, di) - old;

            if (i > 0 && i < this.first) {
                this.list.css(this.lt, $jc.intval(this.list.css(this.lt)) - wh + 'px');
            }

            this.list.css(this.wh, $jc.intval(this.list.css(this.wh)) + wh + 'px');

            return e;
        },

        /**
         * Removes an element for the given index from the list.
         *
         * @method remove
         * @return undefined
         * @param i {Number} The index of the element.
         */
        remove: function(i) {
            var e = this.get(i);

            // Check if item exists and is not currently visible
            if (!e.length || (i >= this.first && i <= this.last)) {
                return;
            }

            var d = this.dimension(e);

            if (i < this.first) {
                this.list.css(this.lt, $jc.intval(this.list.css(this.lt)) + d + 'px');
            }

            e.remove();

            this.list.css(this.wh, $jc.intval(this.list.css(this.wh)) - d + 'px');
        },

        /**
         * Moves the carousel forwards.
         *
         * @method next
         * @return undefined
         */
        next: function() {
            if (this.tail !== null && !this.inTail) {
                this.scrollTail(false);
            } else {
                this.scroll(((this.options.wrap == 'both' || this.options.wrap == 'last') && this.options.size !== null && this.last == this.options.size) ? 1 : this.first + this.options.scroll);
            }
        },

        /**
         * Moves the carousel backwards.
         *
         * @method prev
         * @return undefined
         */
        prev: function() {
            if (this.tail !== null && this.inTail) {
                this.scrollTail(true);
            } else {
                this.scroll(((this.options.wrap == 'both' || this.options.wrap == 'first') && this.options.size !== null && this.first == 1) ? this.options.size : this.first - this.options.scroll);
            }
        },

        /**
         * Scrolls the tail of the carousel.
         *
         * @method scrollTail
         * @return undefined
         * @param b {Boolean} Whether scroll the tail back or forward.
         */
        scrollTail: function(b) {
            if (this.locked || this.animating || !this.tail) {
                return;
            }

            this.pauseAuto();

            var pos  = $jc.intval(this.list.css(this.lt));

            pos = !b ? pos - this.tail : pos + this.tail;
            this.inTail = !b;

            // Save for callbacks
            this.prevFirst = this.first;
            this.prevLast  = this.last;

            this.animate(pos);
        },

        /**
         * Scrolls the carousel to a certain position.
         *
         * @method scroll
         * @return undefined
         * @param i {Number} The index of the element to scoll to.
         * @param a {Boolean} Flag indicating whether to perform animation.
         */
        scroll: function(i, a) {
            if (this.locked || this.animating) {
                return;
            }

            this.pauseAuto();
            this.animate(this.pos(i), a);
        },

        /**
         * Prepares the carousel and return the position for a certian index.
         *
         * @method pos
         * @return {Number}
         * @param i {Number} The index of the element to scoll to.
         * @param fv {Boolean} Whether to force last item to be visible.
         */
        pos: function(i, fv) {
            var pos  = $jc.intval(this.list.css(this.lt));

            if (this.locked || this.animating) {
                return pos;
            }

            if (this.options.wrap != 'circular') {
                i = i < 1 ? 1 : (this.options.size && i > this.options.size ? this.options.size : i);
            }

            var back = this.first > i;

            // Create placeholders, new list width/height
            // and new list position
            var f = this.options.wrap != 'circular' && this.first <= 1 ? 1 : this.first;
            var c = back ? this.get(f) : this.get(this.last);
            var j = back ? f : f - 1;
            var e = null, l = 0, p = false, d = 0, g;

            while (back ? --j >= i : ++j < i) {
                e = this.get(j);
                p = !e.length;
                if (e.length === 0) {
                    e = this.create(j).addClass(this.className('jcarousel-item-placeholder'));
                    c[back ? 'before' : 'after' ](e);

                    if (this.first !== null && this.options.wrap == 'circular' && this.options.size !== null && (j <= 0 || j > this.options.size)) {
                        g = this.get(this.index(j));
                        if (g.length) {
                            e = this.add(j, g.clone(true));
                        }
                    }
                }

                c = e;
                d = this.dimension(e);

                if (p) {
                    l += d;
                }

                if (this.first !== null && (this.options.wrap == 'circular' || (j >= 1 && (this.options.size === null || j <= this.options.size)))) {
                    pos = back ? pos + d : pos - d;
                }
            }

            // Calculate visible items
            var clipping = this.clipping(), cache = [], visible = 0, v = 0;
            c = this.get(i - 1);
            j = i;

            while (++visible) {
                e = this.get(j);
                p = !e.length;
                if (e.length === 0) {
                    e = this.create(j).addClass(this.className('jcarousel-item-placeholder'));
                    // This should only happen on a next scroll
                    if (c.length === 0) {
                        this.list.prepend(e);
                    } else {
                        c[back ? 'before' : 'after' ](e);
                    }

                    if (this.first !== null && this.options.wrap == 'circular' && this.options.size !== null && (j <= 0 || j > this.options.size)) {
                        g = this.get(this.index(j));
                        if (g.length) {
                            e = this.add(j, g.clone(true));
                        }
                    }
                }

                c = e;
                d = this.dimension(e);
                if (d === 0) {
                    throw new Error('jCarousel: No width/height set for items. This will cause an infinite loop. Aborting...');
                }

                if (this.options.wrap != 'circular' && this.options.size !== null && j > this.options.size) {
                    cache.push(e);
                } else if (p) {
                    l += d;
                }

                v += d;

                if (v >= clipping) {
                    break;
                }

                j++;
            }

             // Remove out-of-range placeholders
            for (var x = 0; x < cache.length; x++) {
                cache[x].remove();
            }

            // Resize list
            if (l > 0) {
                this.list.css(this.wh, this.dimension(this.list) + l + 'px');

                if (back) {
                    pos -= l;
                    this.list.css(this.lt, $jc.intval(this.list.css(this.lt)) - l + 'px');
                }
            }

            // Calculate first and last item
            var last = i + visible - 1;
            if (this.options.wrap != 'circular' && this.options.size && last > this.options.size) {
                last = this.options.size;
            }

            if (j > last) {
                visible = 0;
                j = last;
                v = 0;
                while (++visible) {
                    e = this.get(j--);
                    if (!e.length) {
                        break;
                    }
                    v += this.dimension(e);
                    if (v >= clipping) {
                        break;
                    }
                }
            }

            var first = last - visible + 1;
            if (this.options.wrap != 'circular' && first < 1) {
                first = 1;
            }

            if (this.inTail && back) {
                pos += this.tail;
                this.inTail = false;
            }

            this.tail = null;
            if (this.options.wrap != 'circular' && last == this.options.size && (last - visible + 1) >= 1) {
                var m = $jc.intval(this.get(last).css(!this.options.vertical ? 'marginRight' : 'marginBottom'));
                if ((v - m) > clipping) {
                    this.tail = v - clipping - m;
                }
            }

            if (fv && i === this.options.size && this.tail) {
                pos -= this.tail;
                this.inTail = true;
            }

            // Adjust position
            while (i-- > first) {
                pos += this.dimension(this.get(i));
            }

            // Save visible item range
            this.prevFirst = this.first;
            this.prevLast  = this.last;
            this.first     = first;
            this.last      = last;

            return pos;
        },

        /**
         * Animates the carousel to a certain position.
         *
         * @method animate
         * @return undefined
         * @param p {Number} Position to scroll to.
         * @param a {Boolean} Flag indicating whether to perform animation.
         */
        animate: function(p, a) {
            if (this.locked || this.animating) {
                return;
            }

            this.animating = true;

            var self = this;
            var scrolled = function() {
                self.animating = false;

                if (p === 0) {
                    self.list.css(self.lt,  0);
                }

                if (!self.autoStopped && (self.options.wrap == 'circular' || self.options.wrap == 'both' || self.options.wrap == 'last' || self.options.size === null || self.last < self.options.size || (self.last == self.options.size && self.tail !== null && !self.inTail))) {
                    self.startAuto();
                }

                self.buttons();
                self.notify('onAfterAnimation');

                // This function removes items which are appended automatically for circulation.
                // This prevents the list from growing infinitely.
                if (self.options.wrap == 'circular' && self.options.size !== null) {
                    for (var i = self.prevFirst; i <= self.prevLast; i++) {
                        if (i !== null && !(i >= self.first && i <= self.last) && (i < 1 || i > self.options.size)) {
                            self.remove(i);
                        }
                    }
                }
            };

            this.notify('onBeforeAnimation');

            // Animate
            if (!this.options.animation || a === false) {
                this.list.css(this.lt, p + 'px');
                scrolled();
            } else {
                var o = !this.options.vertical ? (this.options.rtl ? {'right': p} : {'left': p}) : {'top': p};
                // Define animation settings.
                var settings = {
                    duration: this.options.animation,
                    easing:   this.options.easing,
                    complete: scrolled
                };
                // If we have a step callback, specify it as well.
                if ($.isFunction(this.options.animationStepCallback)) {
                    settings.step = this.options.animationStepCallback;
                }
                // Start the animation.
                this.list.animate(o, settings);
            }
        },

        /**
         * Starts autoscrolling.
         *
         * @method auto
         * @return undefined
         * @param s {Number} Seconds to periodically autoscroll the content.
         */
        startAuto: function(s) {
            if (s !== undefined) {
                this.options.auto = s;
            }

            if (this.options.auto === 0) {
                return this.stopAuto();
            }

            if (this.timer !== null) {
                return;
            }

            this.autoStopped = false;

            var self = this;
            this.timer = window.setTimeout(function() { self.next(); }, this.options.auto * 1000);
        },

        /**
         * Stops autoscrolling.
         *
         * @method stopAuto
         * @return undefined
         */
        stopAuto: function() {
            this.pauseAuto();
            this.autoStopped = true;
        },

        /**
         * Pauses autoscrolling.
         *
         * @method pauseAuto
         * @return undefined
         */
        pauseAuto: function() {
            if (this.timer === null) {
                return;
            }

            window.clearTimeout(this.timer);
            this.timer = null;
        },

        /**
         * Sets the states of the prev/next buttons.
         *
         * @method buttons
         * @return undefined
         */
        buttons: function(n, p) {
            if (n == null) {
                n = !this.locked && this.options.size !== 0 && ((this.options.wrap && this.options.wrap != 'first') || this.options.size === null || this.last < this.options.size);
                if (!this.locked && (!this.options.wrap || this.options.wrap == 'first') && this.options.size !== null && this.last >= this.options.size) {
                    n = this.tail !== null && !this.inTail;
                }
            }

            if (p == null) {
                p = !this.locked && this.options.size !== 0 && ((this.options.wrap && this.options.wrap != 'last') || this.first > 1);
                if (!this.locked && (!this.options.wrap || this.options.wrap == 'last') && this.options.size !== null && this.first == 1) {
                    p = this.tail !== null && this.inTail;
                }
            }

            var self = this;

            if (this.buttonNext.size() > 0) {
                this.buttonNext.unbind(this.options.buttonNextEvent + '.jcarousel', this.funcNext);

                if (n) {
                    this.buttonNext.bind(this.options.buttonNextEvent + '.jcarousel', this.funcNext);
                }

                this.buttonNext[n ? 'removeClass' : 'addClass'](this.className('jcarousel-next-disabled')).attr('disabled', n ? false : true);

                if (this.options.buttonNextCallback !== null && this.buttonNext.data('jcarouselstate') != n) {
                    this.buttonNext.each(function() { self.options.buttonNextCallback(self, this, n); }).data('jcarouselstate', n);
                }
            } else {
                if (this.options.buttonNextCallback !== null && this.buttonNextState != n) {
                    this.options.buttonNextCallback(self, null, n);
                }
            }

            if (this.buttonPrev.size() > 0) {
                this.buttonPrev.unbind(this.options.buttonPrevEvent + '.jcarousel', this.funcPrev);

                if (p) {
                    this.buttonPrev.bind(this.options.buttonPrevEvent + '.jcarousel', this.funcPrev);
                }

                this.buttonPrev[p ? 'removeClass' : 'addClass'](this.className('jcarousel-prev-disabled')).attr('disabled', p ? false : true);

                if (this.options.buttonPrevCallback !== null && this.buttonPrev.data('jcarouselstate') != p) {
                    this.buttonPrev.each(function() { self.options.buttonPrevCallback(self, this, p); }).data('jcarouselstate', p);
                }
            } else {
                if (this.options.buttonPrevCallback !== null && this.buttonPrevState != p) {
                    this.options.buttonPrevCallback(self, null, p);
                }
            }

            this.buttonNextState = n;
            this.buttonPrevState = p;
        },

        /**
         * Notify callback of a specified event.
         *
         * @method notify
         * @return undefined
         * @param evt {String} The event name
         */
        notify: function(evt) {
            var state = this.prevFirst === null ? 'init' : (this.prevFirst < this.first ? 'next' : 'prev');

            // Load items
            this.callback('itemLoadCallback', evt, state);

            if (this.prevFirst !== this.first) {
                this.callback('itemFirstInCallback', evt, state, this.first);
                this.callback('itemFirstOutCallback', evt, state, this.prevFirst);
            }

            if (this.prevLast !== this.last) {
                this.callback('itemLastInCallback', evt, state, this.last);
                this.callback('itemLastOutCallback', evt, state, this.prevLast);
            }

            this.callback('itemVisibleInCallback', evt, state, this.first, this.last, this.prevFirst, this.prevLast);
            this.callback('itemVisibleOutCallback', evt, state, this.prevFirst, this.prevLast, this.first, this.last);
        },

        callback: function(cb, evt, state, i1, i2, i3, i4) {
            if (this.options[cb] == null || (typeof this.options[cb] != 'object' && evt != 'onAfterAnimation')) {
                return;
            }

            var callback = typeof this.options[cb] == 'object' ? this.options[cb][evt] : this.options[cb];

            if (!$.isFunction(callback)) {
                return;
            }

            var self = this;

            if (i1 === undefined) {
                callback(self, state, evt);
            } else if (i2 === undefined) {
                this.get(i1).each(function() { callback(self, this, i1, state, evt); });
            } else {
                var call = function(i) {
                    self.get(i).each(function() { callback(self, this, i, state, evt); });
                };
                for (var i = i1; i <= i2; i++) {
                    if (i !== null && !(i >= i3 && i <= i4)) {
                        call(i);
                    }
                }
            }
        },

        create: function(i) {
            return this.format('<li></li>', i);
        },

        format: function(e, i) {
            e = $(e);
            var split = e.get(0).className.split(' ');
            for (var j = 0; j < split.length; j++) {
                if (split[j].indexOf('jcarousel-') != -1) {
                    e.removeClass(split[j]);
                }
            }
            e.addClass(this.className('jcarousel-item')).addClass(this.className('jcarousel-item-' + i)).css({
                'float': (this.options.rtl ? 'right' : 'left'),
                'list-style': 'none'
            }).attr('jcarouselindex', i);
            return e;
        },

        className: function(c) {
            return c + ' ' + c + (!this.options.vertical ? '-horizontal' : '-vertical');
        },

        dimension: function(e, d) {
            var el = $(e);

            if (d == null) {
                return !this.options.vertical ?
                       (el.outerWidth(true) || $jc.intval(this.options.itemFallbackDimension)) :
                       (el.outerHeight(true) || $jc.intval(this.options.itemFallbackDimension));
            } else {
                var w = !this.options.vertical ?
                    d - $jc.intval(el.css('marginLeft')) - $jc.intval(el.css('marginRight')) :
                    d - $jc.intval(el.css('marginTop')) - $jc.intval(el.css('marginBottom'));

                $(el).css(this.wh, w + 'px');

                return this.dimension(el);
            }
        },

        clipping: function() {
            return !this.options.vertical ?
                this.clip[0].offsetWidth - $jc.intval(this.clip.css('borderLeftWidth')) - $jc.intval(this.clip.css('borderRightWidth')) :
                this.clip[0].offsetHeight - $jc.intval(this.clip.css('borderTopWidth')) - $jc.intval(this.clip.css('borderBottomWidth'));
        },

        index: function(i, s) {
            if (s == null) {
                s = this.options.size;
            }

            return Math.round((((i-1) / s) - Math.floor((i-1) / s)) * s) + 1;
        }
    });

    $jc.extend({
        /**
         * Gets/Sets the global default configuration properties.
         *
         * @method defaults
         * @return {Object}
         * @param d {Object} A set of key/value pairs to set as configuration properties.
         */
        defaults: function(d) {
            return $.extend(defaults, d || {});
        },

        intval: function(v) {
            v = parseInt(v, 10);
            return isNaN(v) ? 0 : v;
        },

        windowLoaded: function() {
            windowLoaded = true;
        }
    });

    /**
     * Creates a carousel for all matched elements.
     *
     * @example $("#mycarousel").jcarousel();
     * @before <ul id="mycarousel" class="jcarousel-skin-name"><li>First item</li><li>Second item</li></ul>
     * @result
     *
     * <div class="jcarousel-skin-name">
     *   <div class="jcarousel-container">
     *     <div class="jcarousel-clip">
     *       <ul class="jcarousel-list">
     *         <li class="jcarousel-item-1">First item</li>
     *         <li class="jcarousel-item-2">Second item</li>
     *       </ul>
     *     </div>
     *     <div disabled="disabled" class="jcarousel-prev jcarousel-prev-disabled"></div>
     *     <div class="jcarousel-next"></div>
     *   </div>
     * </div>
     *
     * @method jcarousel
     * @return jQuery
     * @param o {Hash|String} A set of key/value pairs to set as configuration properties or a method name to call on a formerly created instance.
     */
    $.fn.jcarousel = function(o) {
        if (typeof o == 'string') {
            var instance = $(this).data('jcarousel'), args = Array.prototype.slice.call(arguments, 1);
            return instance[o].apply(instance, args);
        } else {
            return this.each(function() {
                var instance = $(this).data('jcarousel');
                if (instance) {
                    if (o) {
                        $.extend(instance.options, o);
                    }
                    instance.reload();
                } else {
                    $(this).data('jcarousel', new $jc(this, o));
                }
            });
        }
    };

})(jQuery);
;

/**
 * jQuery JSON plugin 2.4-alpha
 *
 * @author Brantley Harris, 2009-2011
 * @author Timo Tijhof, 2011-2012
 * @source This plugin is heavily influenced by MochiKit's serializeJSON, which is
 *         copyrighted 2005 by Bob Ippolito.
 * @source Brantley Harris wrote this plugin. It is based somewhat on the JSON.org
 *         website's http://www.json.org/json2.js, which proclaims:
 *         "NO WARRANTY EXPRESSED OR IMPLIED. USE AT YOUR OWN RISK.", a sentiment that
 *         I uphold.
 * @license MIT License <http://www.opensource.org/licenses/mit-license.php>
 */
(function ($) {
    'use strict';

    var escape = /["\\\x00-\x1f\x7f-\x9f]/g,
        meta = {
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        hasOwn = Object.prototype.hasOwnProperty;

    /**
     * jQuery.toJSON
     * Converts the given argument into a JSON representation.
     *
     * @param o {Mixed} The json-serializable *thing* to be converted
     *
     * If an object has a toJSON prototype, that will be used to get the representation.
     * Non-integer/string keys are skipped in the object, as are keys that point to a
     * function.
     *
     */
    $.toJSON = typeof JSON === 'object' && JSON.stringify ? JSON.stringify : function (o) {
        if (o === null) {
            return 'null';
        }

        var pairs, k, name, val,
            type = $.type(o);

        if (type === 'undefined') {
            return undefined;
        }

        // Also covers instantiated Number and Boolean objects,
        // which are typeof 'object' but thanks to $.type, we
        // catch them here. I don't know whether it is right
        // or wrong that instantiated primitives are not
        // exported to JSON as an {"object":..}.
        // We choose this path because that's what the browsers did.
        if (type === 'number' || type === 'boolean') {
            return String(o);
        }
        if (type === 'string') {
            return $.quoteString(o);
        }
        if (typeof o.toJSON === 'function') {
            return $.toJSON(o.toJSON());
        }
        if (type === 'date') {
            var month = o.getUTCMonth() + 1,
                day = o.getUTCDate(),
                year = o.getUTCFullYear(),
                hours = o.getUTCHours(),
                minutes = o.getUTCMinutes(),
                seconds = o.getUTCSeconds(),
                milli = o.getUTCMilliseconds();

            if (month < 10) {
                month = '0' + month;
            }
            if (day < 10) {
                day = '0' + day;
            }
            if (hours < 10) {
                hours = '0' + hours;
            }
            if (minutes < 10) {
                minutes = '0' + minutes;
            }
            if (seconds < 10) {
                seconds = '0' + seconds;
            }
            if (milli < 100) {
                milli = '0' + milli;
            }
            if (milli < 10) {
                milli = '0' + milli;
            }
            return '"' + year + '-' + month + '-' + day + 'T' +
                hours + ':' + minutes + ':' + seconds +
                '.' + milli + 'Z"';
        }

        pairs = [];

        if ($.isArray(o)) {
            for (k = 0; k < o.length; k++) {
                pairs.push($.toJSON(o[k]) || 'null');
            }
            return '[' + pairs.join(',') + ']';
        }

        // Any other object (plain object, RegExp, ..)
        // Need to do typeof instead of $.type, because we also
        // want to catch non-plain objects.
        if (typeof o === 'object') {
            for (k in o) {
                // Only include own properties,
                // Filter out inherited prototypes
                if (hasOwn.call(o, k)) {
                    // Keys must be numerical or string. Skip others
                    type = typeof k;
                    if (type === 'number') {
                        name = '"' + k + '"';
                    } else if (type === 'string') {
                        name = $.quoteString(k);
                    } else {
                        continue;
                    }
                    type = typeof o[k];

                    // Invalid values like these return undefined
                    // from toJSON, however those object members
                    // shouldn't be included in the JSON string at all.
                    if (type !== 'function' && type !== 'undefined') {
                        val = $.toJSON(o[k]);
                        pairs.push(name + ':' + val);
                    }
                }
            }
            return '{' + pairs.join(',') + '}';
        }
    };

    /**
     * jQuery.evalJSON
     * Evaluates a given json string.
     *
     * @param str {String}
     */
    $.evalJSON = typeof JSON === 'object' && JSON.parse ? JSON.parse : function (str) {
        /*jshint evil: true */
        return eval('(' + str + ')');
    };

    /**
     * jQuery.secureEvalJSON
     * Evals JSON in a way that is *more* secure.
     *
     * @param str {String}
     */
    $.secureEvalJSON = typeof JSON === 'object' && JSON.parse ? JSON.parse : function (str) {
        var filtered =
            str
            .replace(/\\["\\\/bfnrtu]/g, '@')
            .replace(/"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?/g, ']')
            .replace(/(?:^|:|,)(?:\s*\[)+/g, '');

        if (/^[\],:{}\s]*$/.test(filtered)) {
            /*jshint evil: true */
            return eval('(' + str + ')');
        }
        throw new SyntaxError('Error parsing JSON, source is not valid.');
    };

    /**
     * jQuery.quoteString
     * Returns a string-repr of a string, escaping quotes intelligently.
     * Mostly a support function for toJSON.
     * Examples:
     * >>> jQuery.quoteString('apple')
     * "apple"
     *
     * >>> jQuery.quoteString('"Where are we going?", she asked.')
     * "\"Where are we going?\", she asked."
     */
    $.quoteString = function (str) {
        if (str.match(escape)) {
            return '"' + str.replace(escape, function (a) {
                var c = meta[a];
                if (typeof c === 'string') {
                    return c;
                }
                c = a.charCodeAt();
                return '\\u00' + Math.floor(c / 16).toString(16) + (c % 16).toString(16);
            }) + '"';
        }
        return '"' + str + '"';
    };

}(jQuery));
;

/*! Copyright (c) 2011 Brandon Aaron (http://brandonaaron.net)
 * Licensed under the MIT License (LICENSE.txt).
 *
 * Thanks to: http://adomas.org/javascript-mouse-wheel/ for some pointers.
 * Thanks to: Mathias Bank(http://www.mathias-bank.de) for a scope bug fix.
 * Thanks to: Seamus Leahy for adding deltaX and deltaY
 *
 * Version: 3.0.6
 * 
 * Requires: 1.2.2+
 */

(function($) {

var types = ['DOMMouseScroll', 'mousewheel'];

if ($.event.fixHooks) {
    for ( var i=types.length; i; ) {
        $.event.fixHooks[ types[--i] ] = $.event.mouseHooks;
    }
}

$.event.special.mousewheel = {
    setup: function() {
        if ( this.addEventListener ) {
            for ( var i=types.length; i; ) {
                this.addEventListener( types[--i], handler, false );
            }
        } else {
            this.onmousewheel = handler;
        }
    },
    
    teardown: function() {
        if ( this.removeEventListener ) {
            for ( var i=types.length; i; ) {
                this.removeEventListener( types[--i], handler, false );
            }
        } else {
            this.onmousewheel = null;
        }
    }
};

$.fn.extend({
    mousewheel: function(fn) {
        return fn ? this.bind("mousewheel", fn) : this.trigger("mousewheel");
    },
    
    unmousewheel: function(fn) {
        return this.unbind("mousewheel", fn);
    }
});


function handler(event) {
    var orgEvent = event || window.event, args = [].slice.call( arguments, 1 ), delta = 0, returnValue = true, deltaX = 0, deltaY = 0;
    event = $.event.fix(orgEvent);
    event.type = "mousewheel";
    
    // Old school scrollwheel delta
    if ( orgEvent.wheelDelta ) { delta = orgEvent.wheelDelta/120; }
    if ( orgEvent.detail     ) { delta = -orgEvent.detail/3; }
    
    // New school multidimensional scroll (touchpads) deltas
    deltaY = delta;
    
    // Gecko
    if ( orgEvent.axis !== undefined && orgEvent.axis === orgEvent.HORIZONTAL_AXIS ) {
        deltaY = 0;
        deltaX = -1*delta;
    }
    
    // Webkit
    if ( orgEvent.wheelDeltaY !== undefined ) { deltaY = orgEvent.wheelDeltaY/120; }
    if ( orgEvent.wheelDeltaX !== undefined ) { deltaX = -1*orgEvent.wheelDeltaX/120; }
    
    // Add event and delta to the front of the arguments
    args.unshift(event, delta, deltaX, deltaY);
    
    return ($.event.dispatch || $.event.handle).apply(this, args);
}

})(jQuery);;
/*!
 * jQuery 2d Transform v0.9.3
 * http://wiki.github.com/heygrady/transform/
 *
 * Copyright 2010, Grady Kuhnline
 * Dual licensed under the MIT or GPL Version 2 licenses.
 * http://jquery.org/license
 * 
 * Date: Sat Dec 4 15:46:09 2010 -0800
 */
///////////////////////////////////////////////////////
// Transform
///////////////////////////////////////////////////////
(function($, window, document, undefined) {
    /**
     * @var Regex identify the matrix filter in IE
     */
    var rmatrix = /progid:DXImageTransform\.Microsoft\.Matrix\(.*?\)/,
        rfxnum = /^([\+\-]=)?([\d+.\-]+)(.*)$/,
        rperc = /%/;
    
    // Steal some code from Modernizr
    var m = document.createElement( 'modernizr' ),
        m_style = m.style;
        
    function stripUnits(arg) {
        return parseFloat(arg);
    }
    
    /**
     * Find the prefix that this browser uses
     */ 
    function getVendorPrefix() {
        var property = {
            transformProperty : '',
            MozTransform : '-moz-',
            WebkitTransform : '-webkit-',
            OTransform : '-o-',
            msTransform : '-ms-'
        };
        for (var p in property) {
            if (typeof m_style[p] != 'undefined') {
                return property[p];
            }
        }
        return null;
    }
    
    function supportCssTransforms() {
        if (typeof(window.Modernizr) !== 'undefined') {
            return Modernizr.csstransforms;
        }
        
        var props = [ 'transformProperty', 'WebkitTransform', 'MozTransform', 'OTransform', 'msTransform' ];
        for ( var i in props ) {
            if ( m_style[ props[i] ] !== undefined  ) {
                return true;
            }
        }
    }
        
    // Capture some basic properties
    var vendorPrefix            = getVendorPrefix(),
        transformProperty       = vendorPrefix !== null ? vendorPrefix + 'transform' : false,
        transformOriginProperty = vendorPrefix !== null ? vendorPrefix + 'transform-origin' : false;
    
    // store support in the jQuery Support object
    $.support.csstransforms = supportCssTransforms();
    
    // IE9 public preview 6 requires the DOM names
    if (vendorPrefix == '-ms-') {
        transformProperty = 'msTransform';
        transformOriginProperty = 'msTransformOrigin';
    }
    
    /**
     * Class for creating cross-browser transformations
     * @constructor
     */
    $.extend({
        transform: function(elem) {
            // Cache the transform object on the element itself
            elem.transform = this;
            
            /**
             * The element we're working with
             * @var jQueryCollection
             */
            this.$elem = $(elem);
                        
            /**
             * Remember the matrix we're applying to help the safeOuterLength func
             */
            this.applyingMatrix = false;
            this.matrix = null;
            
            /**
             * Remember the css height and width to save time
             * This is only really used in IE
             * @var Number
             */
            this.height = null;
            this.width = null;
            this.outerHeight = null;
            this.outerWidth = null;
            
            /**
             * We need to know the box-sizing in IE for building the outerHeight and outerWidth
             * @var string
             */
            this.boxSizingValue = null;
            this.boxSizingProperty = null;
            
            this.attr = null;
            this.transformProperty = transformProperty;
            this.transformOriginProperty = transformOriginProperty;
        }
    });
    
    $.extend($.transform, {
        /**
         * @var Array list of all valid transform functions
         */
        funcs: ['matrix', 'origin', 'reflect', 'reflectX', 'reflectXY', 'reflectY', 'rotate', 'scale', 'scaleX', 'scaleY', 'skew', 'skewX', 'skewY', 'translate', 'translateX', 'translateY']
    });
    
    /**
     * Create Transform as a jQuery plugin
     * @param Object funcs
     * @param Object options
     */
    $.fn.transform = function(funcs, options) {
        return this.each(function() {
            var t = this.transform || new $.transform(this);
            if (funcs) {
                t.exec(funcs, options);
            }
        });
    };
    
    $.transform.prototype = {
        /**
         * Applies all of the transformations
         * @param Object funcs
         * @param Object options
         * forceMatrix - uses the matrix in all browsers
         * preserve - tries to preserve the values from previous runs
         */
        exec: function(funcs, options) {
            // extend options
            options = $.extend(true, {
                forceMatrix: false,
                preserve: false
            }, options);
    
            // preserve the funcs from the previous run
            this.attr = null;
            if (options.preserve) {
                funcs = $.extend(true, this.getAttrs(true, true), funcs);
            } else {
                funcs = $.extend(true, {}, funcs); // copy the object to prevent weirdness
            }
            
            // Record the custom attributes on the element itself
            this.setAttrs(funcs);
            
            // apply the funcs
            if ($.support.csstransforms && !options.forceMatrix) {
                // CSS3 is supported
                return this.execFuncs(funcs);
            } else if ($.browser.msie || ($.support.csstransforms && options.forceMatrix)) {
                // Internet Explorer or Forced matrix
                return this.execMatrix(funcs);
            }
            return false;
        },
        
        /**
         * Applies all of the transformations as functions
         * @param Object funcs
         */
        execFuncs: function(funcs) {
            var values = [];
            
            // construct a CSS string
            for (var func in funcs) {
                // handle origin separately
                if (func == 'origin') {
                    this[func].apply(this, $.isArray(funcs[func]) ? funcs[func] : [funcs[func]]);
                } else if ($.inArray(func, $.transform.funcs) !== -1) {
                    values.push(this.createTransformFunc(func, funcs[func]));
                }
            }
            this.$elem.css(transformProperty, values.join(' '));
            return true;
        },
        
        /**
         * Applies all of the transformations as a matrix
         * @param Object funcs
         */
        execMatrix: function(funcs) {
            var matrix,
                tempMatrix,
                args;
            
            var elem = this.$elem[0],
                _this = this;
            function normalPixels(val, i) {
                if (rperc.test(val)) {
                    // this really only applies to translation
                    return parseFloat(val) / 100 * _this['safeOuter' + (i ? 'Height' : 'Width')]();
                }
                return toPx(elem, val);
            }
            
            var rtranslate = /translate[X|Y]?/,
                trans = [];
                
            for (var func in funcs) {
                switch ($.type(funcs[func])) {
                    case 'array': args = funcs[func]; break;
                    case 'string': args = $.map(funcs[func].split(','), $.trim); break;
                    default: args = [funcs[func]];
                }
                
                if ($.matrix[func]) {
                    
                    if ($.cssAngle[func]) {
                        // normalize on degrees
                        args = $.map(args, $.angle.toDegree);                       
                    } else if (!$.cssNumber[func]) {
                        // normalize to pixels
                        args = $.map(args, normalPixels);
                    } else {
                        // strip units
                        args = $.map(args, stripUnits);
                    }
                    
                    tempMatrix = $.matrix[func].apply(this, args);
                    if (rtranslate.test(func)) {
                        //defer translation
                        trans.push(tempMatrix);
                    } else {
                        matrix = matrix ? matrix.x(tempMatrix) : tempMatrix;
                    }
                } else if (func == 'origin') {
                    this[func].apply(this, args);
                }
            }
            
            // check that we have a matrix
            matrix = matrix || $.matrix.identity();
            
            // Apply translation
            $.each(trans, function(i, val) { matrix = matrix.x(val); });

            // pull out the relevant values
            var a = parseFloat(matrix.e(1,1).toFixed(6)),
                b = parseFloat(matrix.e(2,1).toFixed(6)),
                c = parseFloat(matrix.e(1,2).toFixed(6)),
                d = parseFloat(matrix.e(2,2).toFixed(6)),
                tx = matrix.rows === 3 ? parseFloat(matrix.e(1,3).toFixed(6)) : 0,
                ty = matrix.rows === 3 ? parseFloat(matrix.e(2,3).toFixed(6)) : 0;
            
            //apply the transform to the element
            if ($.support.csstransforms && vendorPrefix === '-moz-') {
                // -moz-
                this.$elem.css(transformProperty, 'matrix(' + a + ', ' + b + ', ' + c + ', ' + d + ', ' + tx + 'px, ' + ty + 'px)');
            } else if ($.support.csstransforms) {
                // -webkit, -o-, w3c
                // NOTE: WebKit and Opera don't allow units on the translate variables
                this.$elem.css(transformProperty, 'matrix(' + a + ', ' + b + ', ' + c + ', ' + d + ', ' + tx + ', ' + ty + ')');
            } else if ($.browser.msie) {
                // IE requires the special transform Filter
                
                //TODO: Use Nearest Neighbor during animation FilterType=\'nearest neighbor\'
                var filterType = ', FilterType=\'nearest neighbor\''; //bilinear
                var style = this.$elem[0].style;
                var matrixFilter = 'progid:DXImageTransform.Microsoft.Matrix(' +
                        'M11=' + a + ', M12=' + c + ', M21=' + b + ', M22=' + d +
                        ', sizingMethod=\'auto expand\'' + filterType + ')';
                var filter = style.filter || $.css( this.$elem[0], "filter" ) || "";
                style.filter = rmatrix.test(filter) ? filter.replace(rmatrix, matrixFilter) : filter ? filter + ' ' + matrixFilter : matrixFilter;
                
                // Let's know that we're applying post matrix fixes and the height/width will be static for a bit
                this.applyingMatrix = true;
                this.matrix = matrix;
                
                // IE can't set the origin or translate directly
                this.fixPosition(matrix, tx, ty);
                
                this.applyingMatrix = false;
                this.matrix = null;
            }
            return true;
        },
        
        /**
         * Sets the transform-origin
         * This really needs to be percentages
         * @param Number x length
         * @param Number y length
         */
        origin: function(x, y) {
            // use CSS in supported browsers
            if ($.support.csstransforms) {
                if (typeof y === 'undefined') {
                    this.$elem.css(transformOriginProperty, x);
                } else {
                    this.$elem.css(transformOriginProperty, x + ' ' + y);
                }
                return true;
            }
            
            // correct for keyword lengths
            switch (x) {
                case 'left': x = '0'; break;
                case 'right': x = '100%'; break;
                case 'center': // no break
                case undefined: x = '50%';
            }
            switch (y) {
                case 'top': y = '0'; break;
                case 'bottom': y = '100%'; break;
                case 'center': // no break
                case undefined: y = '50%'; //TODO: does this work?
            }
            
            // store mixed values with units, assumed pixels
            this.setAttr('origin', [
                rperc.test(x) ? x : toPx(this.$elem[0], x) + 'px',
                rperc.test(y) ? y : toPx(this.$elem[0], y) + 'px'
            ]);
            //console.log(this.getAttr('origin'));
            return true;
        },
        
        /**
         * Create a function suitable for a CSS value
         * @param string func
         * @param Mixed value
         */
        createTransformFunc: function(func, value) {
            if (func.substr(0, 7) === 'reflect') {
                // let's fake reflection, false value 
                // falsey sets an identity matrix
                var m = value ? $.matrix[func]() : $.matrix.identity();
                return 'matrix(' + m.e(1,1) + ', ' + m.e(2,1) + ', ' + m.e(1,2) + ', ' + m.e(2,2) + ', 0, 0)';
            }
            
            //value = _correctUnits(func, value);
            
            if (func == 'matrix') {
                if (vendorPrefix === '-moz-') {
                    value[4] = value[4] ? value[4] + 'px' : 0;
                    value[5] = value[5] ? value[5] + 'px' : 0;
                }
            }
            return func + '(' + ($.isArray(value) ? value.join(', ') : value) + ')';
        },
        
        /**
         * @param Matrix matrix
         * @param Number tx
         * @param Number ty
         * @param Number height
         * @param Number width
         */
        fixPosition: function(matrix, tx, ty, height, width) {
            // now we need to fix it!
            var calc = new $.matrix.calc(matrix, this.safeOuterHeight(), this.safeOuterWidth()),
                origin = this.getAttr('origin'); // mixed percentages and px
            
            // translate a 0, 0 origin to the current origin
            var offset = calc.originOffset(new $.matrix.V2(
                rperc.test(origin[0]) ? parseFloat(origin[0])/100*calc.outerWidth : parseFloat(origin[0]),
                rperc.test(origin[1]) ? parseFloat(origin[1])/100*calc.outerHeight : parseFloat(origin[1])
            ));
            
            // IE glues the top-most and left-most pixels of the transformed object to top/left of the original object
            //TODO: This seems wrong in the calculations
            var sides = calc.sides();

            // Protect against an item that is already positioned
            var cssPosition = this.$elem.css('position');
            if (cssPosition == 'static') {
                cssPosition = 'relative';
            }
            
            //TODO: if the element is already positioned, we should attempt to respect it (somehow)
            //NOTE: we could preserve our offset top and left in an attr on the elem
            var pos = {top: 0, left: 0};
            
            // Approximates transform-origin, tx, and ty
            var css = {
                'position': cssPosition,
                'top': (offset.top + ty + sides.top + pos.top) + 'px',
                'left': (offset.left + tx + sides.left + pos.left) + 'px',
                'zoom': 1
            };

            this.$elem.css(css);
        }
    };
    
    /**
     * Ensure that values have the appropriate units on them
     * @param string func
     * @param Mixed value
     */
    function toPx(elem, val) {
        var parts = rfxnum.exec($.trim(val));
        
        if (parts[3] && parts[3] !== 'px') {
            var prop = 'paddingBottom',
                orig = $.style( elem, prop );
                
            $.style( elem, prop, val );
            val = cur( elem, prop );
            $.style( elem, prop, orig );
            return val;
        }
        return parseFloat( val );
    }
    
    function cur(elem, prop) {
        if ( elem[prop] != null && (!elem.style || elem.style[prop] == null) ) {
            return elem[ prop ];
        }

        var r = parseFloat( $.css( elem, prop ) );
        return r && r > -10000 ? r : 0;
    }
})(jQuery, this, this.document);


///////////////////////////////////////////////////////
// Safe Outer Length
///////////////////////////////////////////////////////
(function($, window, document, undefined) {
    $.extend($.transform.prototype, {
        /**
         * @param void
         * @return Number
         */
        safeOuterHeight: function() {
            return this.safeOuterLength('height');
        },
        
        /**
         * @param void
         * @return Number
         */
        safeOuterWidth: function() {
            return this.safeOuterLength('width');
        },
        
        /**
         * Returns reliable outer dimensions for an object that may have been transformed.
         * Only use this if the matrix isn't handy
         * @param String dim height or width
         * @return Number
         */
        safeOuterLength: function(dim) {
            var funcName = 'outer' + (dim == 'width' ? 'Width' : 'Height');
            
            if (!$.support.csstransforms && $.browser.msie) {
                // make the variables more generic
                dim = dim == 'width' ? 'width' : 'height';
                
                // if we're transforming and have a matrix; we can shortcut.
                // the true outerHeight is the transformed outerHeight divided by the ratio.
                // the ratio is equal to the height of a 1px by 1px box that has been transformed by the same matrix.
                if (this.applyingMatrix && !this[funcName] && this.matrix) {
                    // calculate and return the correct size
                    var calc = new $.matrix.calc(this.matrix, 1, 1),
                        ratio = calc.offset(),
                        length = this.$elem[funcName]() / ratio[dim];
                    this[funcName] = length;
                    
                    return length;
                } else if (this.applyingMatrix && this[funcName]) {
                    // return the cached calculation
                    return this[funcName];
                }
                
                // map dimensions to box sides          
                var side = {
                    height: ['top', 'bottom'],
                    width: ['left', 'right']
                };
                
                // setup some variables
                var elem = this.$elem[0],
                    outerLen = parseFloat($.curCSS(elem, dim, true)), //TODO: this can be cached on animations that do not animate height/width
                    boxSizingProp = this.boxSizingProperty,
                    boxSizingValue = this.boxSizingValue;
                
                // IE6 && IE7 will never have a box-sizing property, so fake it
                if (!this.boxSizingProperty) {
                    boxSizingProp = this.boxSizingProperty = _findBoxSizingProperty() || 'box-sizing';
                    boxSizingValue = this.boxSizingValue = this.$elem.css(boxSizingProp) || 'content-box';
                }
                
                // return it immediately if we already know it
                if (this[funcName] && this[dim] == outerLen) {
                    return this[funcName];
                } else {
                    this[dim] = outerLen;
                }
                
                // add in the padding and border
                if (boxSizingProp && (boxSizingValue == 'padding-box' || boxSizingValue == 'content-box')) {
                    outerLen += parseFloat($.curCSS(elem, 'padding-' + side[dim][0], true)) || 0 +
                                  parseFloat($.curCSS(elem, 'padding-' + side[dim][1], true)) || 0;
                }
                if (boxSizingProp && boxSizingValue == 'content-box') {
                    outerLen += parseFloat($.curCSS(elem, 'border-' + side[dim][0] + '-width', true)) || 0 +
                                  parseFloat($.curCSS(elem, 'border-' + side[dim][1] + '-width', true)) || 0;
                }
                
                // remember and return the outerHeight
                this[funcName] = outerLen;
                return outerLen;
            }
            return this.$elem[funcName]();
        }
    });
    
    /**
     * Determine the correct property for checking the box-sizing property
     * @param void
     * @return string
     */
    var _boxSizingProperty = null;
    function _findBoxSizingProperty () {
        if (_boxSizingProperty) {
            return _boxSizingProperty;
        } 
        
        var property = {
                boxSizing : 'box-sizing',
                MozBoxSizing : '-moz-box-sizing',
                WebkitBoxSizing : '-webkit-box-sizing',
                OBoxSizing : '-o-box-sizing'
            },
            elem = document.body;
        
        for (var p in property) {
            if (typeof elem.style[p] != 'undefined') {
                _boxSizingProperty = property[p];
                return _boxSizingProperty;
            }
        }
        return null;
    }
})(jQuery, this, this.document);


///////////////////////////////////////////////////////
// Attr
///////////////////////////////////////////////////////
(function($, window, document, undefined) {
    var rfuncvalue = /([\w\-]*?)\((.*?)\)/g, // with values
        attr = 'data-transform',
        rspace = /\s/,
        rcspace = /,\s?/;
    
    $.extend($.transform.prototype, {       
        /**
         * This overrides all of the attributes
         * @param Object funcs a list of transform functions to store on this element
         * @return void
         */
        setAttrs: function(funcs) {
            var string = '',
                value;
            for (var func in funcs) {
                value = funcs[func];
                if ($.isArray(value)) {
                    value = value.join(', ');
                }
                string += ' ' + func + '(' + value + ')'; 
            }
            this.attr = $.trim(string);
            this.$elem.attr(attr, this.attr);
        },
        
        /**
         * This sets only a specific atribute
         * @param string func name of a transform function
         * @param mixed value with proper units
         * @return void
         */
        setAttr: function(func, value) {
            // stringify the value
            if ($.isArray(value)) {
                value = value.join(', ');
            }
            
            // pull from a local variable to look it up
            var transform = this.attr || this.$elem.attr(attr);
            if (!transform || transform.indexOf(func) == -1) {
                // we don't have any existing values, save it
                // we don't have this function yet, save it
                this.attr = $.trim(transform + ' ' + func + '(' + value + ')');
                this.$elem.attr(attr, this.attr);
            } else {
                // replace the existing value
                var funcs = [], parts;
                
                // regex split
                rfuncvalue.lastIndex = 0; // reset the regex pointer
                while (parts = rfuncvalue.exec(transform)) {
                    if (func == parts[1]) {
                        funcs.push(func + '(' + value + ')');
                    } else {
                        funcs.push(parts[0]);
                    }
                }
                this.attr = funcs.join(' ');
                this.$elem.attr(attr, this.attr);
            }
        },
        
        /**
         * @return Object
         */
        getAttrs: function() {
            var transform = this.attr || this.$elem.attr(attr);
            if (!transform) {
                // We don't have any existing values, return empty object
                return {};
            }
            
            // replace the existing value
            var attrs = {}, parts, value;
            
            rfuncvalue.lastIndex = 0; // reset the regex pointer
            while ((parts = rfuncvalue.exec(transform)) !== null) {
                if (parts) {
                    value = parts[2].split(rcspace);
                    attrs[parts[1]] = value.length == 1 ? value[0] : value;
                }
            }
            return attrs;
        },
        
        /**
         * @param String func 
         * @return mixed
         */
        getAttr: function(func) {
            var attrs = this.getAttrs();
            if (typeof attrs[func] !== 'undefined') {
                return attrs[func];
            }
            
            //TODO: move the origin to a function
            if (func === 'origin' && $.support.csstransforms) {
                // supported browsers return percentages always
                return this.$elem.css(this.transformOriginProperty).split(rspace);
            } else if (func === 'origin') {
                // just force IE to also return a percentage
                return ['50%', '50%'];
            }
            
            return $.cssDefault[func] || 0;
        }
    });
    
    // Define 
    if (typeof($.cssAngle) == 'undefined') {
        $.cssAngle = {};
    }
    $.extend($.cssAngle, {
        rotate: true,
        skew: true,
        skewX: true,
        skewY: true
    });
    
    // Define default values
    if (typeof($.cssDefault) == 'undefined') {
        $.cssDefault = {};
    }
    
    $.extend($.cssDefault, {
        scale: [1, 1],
        scaleX: 1,
        scaleY: 1,
        matrix: [1, 0, 0, 1, 0, 0],
        origin: ['50%', '50%'], // TODO: allow this to be a function, like get
        reflect: [1, 0, 0, 1, 0, 0],
        reflectX: [1, 0, 0, 1, 0, 0],
        reflectXY: [1, 0, 0, 1, 0, 0],
        reflectY: [1, 0, 0, 1, 0, 0]
    });
    
    // Define functons with multiple values
    if (typeof($.cssMultipleValues) == 'undefined') {
        $.cssMultipleValues = {};
    }
    $.extend($.cssMultipleValues, {
        matrix: 6,
        origin: {
            length: 2,
            duplicate: true
        },
        reflect: 6,
        reflectX: 6,
        reflectXY: 6,
        reflectY: 6,
        scale: {
            length: 2,
            duplicate: true
        },
        skew: 2,
        translate: 2
    });
    
    // specify unitless funcs
    $.extend($.cssNumber, {
        matrix: true,
        reflect: true,
        reflectX: true,
        reflectXY: true,
        reflectY: true,
        scale: true,
        scaleX: true,
        scaleY: true
    });
    
    // override all of the css functions
    $.each($.transform.funcs, function(i, func) {
        $.cssHooks[func] = {
            set: function(elem, value) {
                var transform = elem.transform || new $.transform(elem),
                    funcs = {};
                funcs[func] = value;
                transform.exec(funcs, {preserve: true});
            },
            get: function(elem, computed) {
                var transform = elem.transform || new $.transform(elem);
                return transform.getAttr(func);
            }
        };
    });
    
    // Support Reflection animation better by returning a matrix
    $.each(['reflect', 'reflectX', 'reflectXY', 'reflectY'], function(i, func) {
        $.cssHooks[func].get = function(elem, computed) {
            var transform = elem.transform || new $.transform(elem);
            return transform.getAttr('matrix') || $.cssDefault[func];
        };
    });
})(jQuery, this, this.document);
///////////////////////////////////////////////////////
// Animation
///////////////////////////////////////////////////////
(function($, window, document, undefined) {
    /**
     * @var Regex looks for units on a string
     */
    var rfxnum = /^([+\-]=)?([\d+.\-]+)(.*)$/;
    
    /**
     * Doctors prop values in the event that they contain spaces
     * @param Object prop
     * @param String speed
     * @param String easing
     * @param Function callback
     * @return bool
     */
    var _animate = $.fn.animate;
    $.fn.animate = function( prop, speed, easing, callback ) {
        var optall = $.speed(speed, easing, callback),
            mv = $.cssMultipleValues;
        
        // Speed always creates a complete function that must be reset
        optall.complete = optall.old;
        
        // Capture multiple values
        if (!$.isEmptyObject(prop)) {
            if (typeof optall.original === 'undefined') {
                optall.original = {};
            }
            $.each( prop, function( name, val ) {
                if (mv[name]
                    || $.cssAngle[name]
                    || (!$.cssNumber[name] && $.inArray(name, $.transform.funcs) !== -1)) {
                    
                    // Handle special easing
                    var specialEasing = null;
                    if (jQuery.isArray(prop[name])) {
                        var mvlen = 1, len = val.length;
                        if (mv[name]) {
                            mvlen = (typeof mv[name].length === 'undefined' ? mv[name] : mv[name].length);
                        }
                        if ( len > mvlen
                            || (len < mvlen && len == 2)
                            || (len == 2 && mvlen == 2 && isNaN(parseFloat(val[len - 1])))) {
                            
                            specialEasing = val[len - 1];
                            val.splice(len - 1, 1);
                        }
                    }
                    
                    // Store the original values onto the optall
                    optall.original[name] = val.toString();
                    
                    // reduce to a unitless number (to trick animate)
                    prop[name] = parseFloat(val);
                }
            } );
        }
        
        //NOTE: we edited prop above to trick animate
        //NOTE: we pre-convert to an optall so we can doctor it
        return _animate.apply(this, [arguments[0], optall]);
    };
    
    var prop = 'paddingBottom';
    function cur(elem, prop) {
        if ( elem[prop] != null && (!elem.style || elem.style[prop] == null) ) {
            //return elem[ prop ];
        }

        var r = parseFloat( $.css( elem, prop ) );
        return r && r > -10000 ? r : 0;
    }
    
    var _custom = $.fx.prototype.custom;
    $.fx.prototype.custom = function(from, to, unit) {
        var multiple = $.cssMultipleValues[this.prop],
            angle = $.cssAngle[this.prop];
        
        //TODO: simply check for the existence of CSS Hooks?
        if (multiple || (!$.cssNumber[this.prop] && $.inArray(this.prop, $.transform.funcs) !== -1)) {
            this.values = [];
            
            if (!multiple) {
                multiple = 1;
            }
            
            // Pull out the known values
            var values = this.options.original[this.prop],
                currentValues = $(this.elem).css(this.prop),
                defaultValues = $.cssDefault[this.prop] || 0;
            
            // make sure the current css value is an array
            if (!$.isArray(currentValues)) {
                currentValues = [currentValues];
            }
            
            // make sure the new values are an array
            if (!$.isArray(values)) {
                if ($.type(values) === 'string') {
                    values = values.split(',');
                } else {
                    values = [values];
                }
            }
            
            // make sure we have enough new values
            var length = multiple.length || multiple, i = 0;
            while (values.length < length) {
                values.push(multiple.duplicate ? values[0] : defaultValues[i] || 0);
                i++;
            }
            
            // calculate a start, end and unit for each new value
            var start, parts, end, //unit,
                fx = this,
                transform = fx.elem.transform;
                orig = $.style(fx.elem, prop);

            $.each(values, function(i, val) {
                // find a sensible start value
                if (currentValues[i]) {
                    start = currentValues[i];
                } else if (defaultValues[i] && !multiple.duplicate) {
                    start = defaultValues[i];
                } else if (multiple.duplicate) {
                    start = currentValues[0];
                } else {
                    start = 0;
                }
                
                // Force the correct unit on the start
                if (angle) {
                    start = $.angle.toDegree(start);
                } else if (!$.cssNumber[fx.prop]) {
                    parts = rfxnum.exec($.trim(start));
                    if (parts[3] && parts[3] !== 'px') {
                        if (parts[3] === '%') {
                            start = parseFloat( parts[2] ) / 100 * transform['safeOuter' + (i ? 'Height' : 'Width')]();
                        } else {
                            $.style( fx.elem, prop, start);
                            start = cur(fx.elem, prop);
                            $.style( fx.elem, prop, orig);
                        }
                    }
                }
                start = parseFloat(start);
                
                // parse the value with a regex
                parts = rfxnum.exec($.trim(val));
                
                if (parts) {
                    // we found a sensible value and unit
                    end = parseFloat( parts[2] );
                    unit = parts[3] || "px"; //TODO: change to an appropriate default unit
                    
                    if (angle) {
                        end = $.angle.toDegree(end + unit);
                        unit = 'deg';
                    } else if (!$.cssNumber[fx.prop] && unit === '%') {
                        start = (start / transform['safeOuter' + (i ? 'Height' : 'Width')]()) * 100;
                    } else if (!$.cssNumber[fx.prop] && unit !== 'px') {
                        $.style( fx.elem, prop, (end || 1) + unit);
                        start = ((end || 1) / cur(fx.elem, prop)) * start;
                        $.style( fx.elem, prop, orig);
                    }
                    
                    // If a +=/-= token was provided, we're doing a relative animation
                    if (parts[1]) {
                        end = ((parts[1] === "-=" ? -1 : 1) * end) + start;
                    }
                } else {
                    // I don't know when this would happen
                    end = val;
                    unit = ''; 
                }
                                
                // Save the values
                fx.values.push({
                    start: start,
                    end: end,
                    unit: unit
                });             
            });
        }
        return _custom.apply(this, arguments);
    };
    
    /**
     * Animates a multi value attribute
     * @param Object fx
     * @return null
     */
    $.fx.multipleValueStep = {
        _default: function(fx) {
            $.each(fx.values, function(i, val) {
                fx.values[i].now = val.start + ((val.end - val.start) * fx.pos);
            });
        }
    };
    $.each(['matrix', 'reflect', 'reflectX', 'reflectXY', 'reflectY'], function(i, func) {
        $.fx.multipleValueStep[func] = function(fx) {
            var d = fx.decomposed,
                $m = $.matrix;
                m = $m.identity();
            
            d.now = {};
            
            // increment each part of the decomposition and recompose it        
            $.each(d.start, function(k) {               
                // calculate the current value
                d.now[k] = parseFloat(d.start[k]) + ((parseFloat(d.end[k]) - parseFloat(d.start[k])) * fx.pos);
                
                // skip functions that won't affect the transform
                if (((k === 'scaleX' || k === 'scaleY') && d.now[k] === 1) ||
                    (k !== 'scaleX' && k !== 'scaleY' && d.now[k] === 0)) {
                    return true;
                }
                
                // calculating
                m = m.x($m[k](d.now[k]));
            });
            
            // save the correct matrix values for the value of now
            var val;
            $.each(fx.values, function(i) {
                switch (i) {
                    case 0: val = parseFloat(m.e(1, 1).toFixed(6)); break;
                    case 1: val = parseFloat(m.e(2, 1).toFixed(6)); break;
                    case 2: val = parseFloat(m.e(1, 2).toFixed(6)); break;
                    case 3: val = parseFloat(m.e(2, 2).toFixed(6)); break;
                    case 4: val = parseFloat(m.e(1, 3).toFixed(6)); break;
                    case 5: val = parseFloat(m.e(2, 3).toFixed(6)); break;
                }
                fx.values[i].now = val;
            });
        };
    });
    /**
     * Step for animating tranformations
     */
    $.each($.transform.funcs, function(i, func) {
        $.fx.step[func] = function(fx) {
            var transform = fx.elem.transform || new $.transform(fx.elem),
                funcs = {};
            
            if ($.cssMultipleValues[func] || (!$.cssNumber[func] && $.inArray(func, $.transform.funcs) !== -1)) {
                ($.fx.multipleValueStep[fx.prop] || $.fx.multipleValueStep._default)(fx);
                funcs[fx.prop] = [];
                $.each(fx.values, function(i, val) {
                    funcs[fx.prop].push(val.now + ($.cssNumber[fx.prop] ? '' : val.unit));
                });
            } else {
                funcs[fx.prop] = fx.now + ($.cssNumber[fx.prop] ? '' : fx.unit);
            }
            
            transform.exec(funcs, {preserve: true});
        };
    });
    
    // Support matrix animation
    $.each(['matrix', 'reflect', 'reflectX', 'reflectXY', 'reflectY'], function(i, func) {
        $.fx.step[func] = function(fx) {
            var transform = fx.elem.transform || new $.transform(fx.elem),
                funcs = {};
                
            if (!fx.initialized) {
                fx.initialized = true;

                // Reflections need a sensible end value set
                if (func !== 'matrix') {
                    var values = $.matrix[func]().elements;
                    var val;
                    $.each(fx.values, function(i) {
                        switch (i) {
                            case 0: val = values[0]; break;
                            case 1: val = values[2]; break;
                            case 2: val = values[1]; break;
                            case 3: val = values[3]; break;
                            default: val = 0;
                        }
                        fx.values[i].end = val;
                    });
                }
                
                // Decompose the start and end
                fx.decomposed = {};
                var v = fx.values;
                
                fx.decomposed.start = $.matrix.matrix(v[0].start, v[1].start, v[2].start, v[3].start, v[4].start, v[5].start).decompose();
                fx.decomposed.end = $.matrix.matrix(v[0].end, v[1].end, v[2].end, v[3].end, v[4].end, v[5].end).decompose();
            }
            
            ($.fx.multipleValueStep[fx.prop] || $.fx.multipleValueStep._default)(fx);
            funcs.matrix = [];
            $.each(fx.values, function(i, val) {
                funcs.matrix.push(val.now);
            });
            
            transform.exec(funcs, {preserve: true});
        };
    });
})(jQuery, this, this.document);
///////////////////////////////////////////////////////
// Angle
///////////////////////////////////////////////////////
(function($, window, document, undefined) {
    /**
     * Converting a radian to a degree
     * @const
     */
    var RAD_DEG = 180/Math.PI;
    
    /**
     * Converting a radian to a grad
     * @const
     */
    var RAD_GRAD = 200/Math.PI;
    
    /**
     * Converting a degree to a radian
     * @const
     */
    var DEG_RAD = Math.PI/180;
    
    /**
     * Converting a degree to a grad
     * @const
     */
    var DEG_GRAD = 2/1.8;
    
    /**
     * Converting a grad to a degree
     * @const
     */
    var GRAD_DEG = 0.9;
    
    /**
     * Converting a grad to a radian
     * @const
     */
    var GRAD_RAD = Math.PI/200;
    
    
    var rfxnum = /^([+\-]=)?([\d+.\-]+)(.*)$/;
    
    /**
     * Functions for converting angles
     * @var Object
     */
    $.extend({
        angle: {
            /**
             * available units for an angle
             * @var Regex
             */
            runit: /(deg|g?rad)/,
            
            /**
             * Convert a radian into a degree
             * @param Number rad
             * @return Number
             */
            radianToDegree: function(rad) {
                return rad * RAD_DEG;
            },
            
            /**
             * Convert a radian into a degree
             * @param Number rad
             * @return Number
             */
            radianToGrad: function(rad) {
                return rad * RAD_GRAD;
            },
            
            /**
             * Convert a degree into a radian
             * @param Number deg
             * @return Number
             */
            degreeToRadian: function(deg) {
                return deg * DEG_RAD;
            },
            
            /**
             * Convert a degree into a radian
             * @param Number deg
             * @return Number
             */
            degreeToGrad: function(deg) {
                return deg * DEG_GRAD;
            },
            
            /**
             * Convert a grad into a degree
             * @param Number grad
             * @return Number
             */
            gradToDegree: function(grad) {
                return grad * GRAD_DEG;
            },
            
            /**
             * Convert a grad into a radian
             * @param Number grad
             * @return Number
             */
            gradToRadian: function(grad) {
                return grad * GRAD_RAD;
            },
            
            /**
             * Convert an angle with a unit to a degree
             * @param String val angle with a unit
             * @return Number
             */
            toDegree: function (val) {
                var parts = rfxnum.exec(val);
                if (parts) {
                    val = parseFloat( parts[2] );
                    switch (parts[3] || 'deg') {
                        case 'grad':
                            val = $.angle.gradToDegree(val);
                            break;
                        case 'rad':
                            val = $.angle.radianToDegree(val);
                            break;
                    }
                    return val;
                }
                return 0;
            }
        }
    });
})(jQuery, this, this.document);
///////////////////////////////////////////////////////
// Matrix
///////////////////////////////////////////////////////
(function($, window, document, undefined) {
    /**
     * Matrix object for creating matrices relevant for 2d Transformations
     * @var Object
     */
    if (typeof($.matrix) == 'undefined') {
        $.extend({
            matrix: {}
        });
    }
    var $m = $.matrix;
    
    $.extend( $m, {
        /**
         * A 2-value vector
         * @param Number x
         * @param Number y
         * @constructor
         */
        V2: function(x, y){
            if ($.isArray(arguments[0])) {
                this.elements = arguments[0].slice(0, 2);
            } else {
                this.elements = [x, y];
            }
            this.length = 2;
        },
        
        /**
         * A 2-value vector
         * @param Number x
         * @param Number y
         * @param Number z
         * @constructor
         */
        V3: function(x, y, z){
            if ($.isArray(arguments[0])) {
                this.elements = arguments[0].slice(0, 3);
            } else {
                this.elements = [x, y, z];
            }
            this.length = 3;
        },
        
        /**
         * A 2x2 Matrix, useful for 2D-transformations without translations
         * @param Number mn
         * @constructor
         */
        M2x2: function(m11, m12, m21, m22) {
            if ($.isArray(arguments[0])) {
                this.elements = arguments[0].slice(0, 4);
            } else {
                this.elements = Array.prototype.slice.call(arguments).slice(0, 4);
            }
            this.rows = 2;
            this.cols = 2;
        },
        
        /**
         * A 3x3 Matrix, useful for 3D-transformations without translations
         * @param Number mn
         * @constructor
         */
        M3x3: function(m11, m12, m13, m21, m22, m23, m31, m32, m33) {
            if ($.isArray(arguments[0])) {
                this.elements = arguments[0].slice(0, 9);
            } else {
                this.elements = Array.prototype.slice.call(arguments).slice(0, 9);
            }
            this.rows = 3;
            this.cols = 3;
        }
    });
    
    /** generic matrix prototype */
    var Matrix = {
        /**
         * Return a specific element from the matrix
         * @param Number row where 1 is the 0th row
         * @param Number col where 1 is the 0th column
         * @return Number
         */
        e: function(row, col) {
            var rows = this.rows,
                cols = this.cols;
            
            // return 0 on nonsense rows and columns
            if (row > rows || col > rows || row < 1 || col < 1) {
                return 0;
            }
            
            return this.elements[(row - 1) * cols + col - 1];
        },
        
        /**
         * Taken from Zoomooz
         * https://github.com/jaukia/zoomooz/blob/c7a37b9a65a06ba730bd66391bbd6fe8e55d3a49/js/jquery.zoomooz.js
         */
        decompose: function() {
            var a = this.e(1, 1),
                b = this.e(2, 1),
                c = this.e(1, 2),
                d = this.e(2, 2),
                e = this.e(1, 3),
                f = this.e(2, 3);
                
            // In case the matrix can't be decomposed
            if (Math.abs(a * d - b * c) < 0.01) {
                return {
                    rotate: 0 + 'deg',
                    skewX: 0 + 'deg',
                    scaleX: 1,
                    scaleY: 1,
                    translateX: 0 + 'px',
                    translateY: 0 + 'px'
                };
            }
            
            // Translate is easy
            var tx = e, ty = f;
            
            // factor out the X scale
            var sx = Math.sqrt(a * a + b * b);
            a = a/sx;
            b = b/sx;
            
            // factor out the skew
            var k = a * c + b * d;
            c -= a * k;
            d -= b * k;
            
            // factor out the Y scale
            var sy = Math.sqrt(c * c + d * d);
            c = c / sy;
            d = d / sy;
            k = k / sy;
            
            // account for negative scale
            if ((a * d - b * c) < 0.0) {
                a = -a;
                b = -b;
                //c = -c; // accomplishes nothing to negate it
                //d = -d; // accomplishes nothing to negate it
                sx = -sx;
                //sy = -sy //Scale Y shouldn't ever be negated
            }
            
            // calculate the rotation angle and skew angle
            var rad2deg = $.angle.radianToDegree;
            var r = rad2deg(Math.atan2(b, a));
            k = rad2deg(Math.atan(k));
            
            return {
                rotate: r + 'deg',
                skewX: k + 'deg',
                scaleX: sx,
                scaleY: sy,
                translateX: tx + 'px',
                translateY: ty + 'px'
            };
        }
    };
    
    /** Extend all of the matrix types with the same prototype */
    $.extend($m.M2x2.prototype, Matrix, {
        toM3x3: function() {
            var a = this.elements;
            return new $m.M3x3(
                a[0], a[1], 0,
                a[2], a[3], 0,
                0,    0,    1
            );  
        },
        
        /**
         * Multiply a 2x2 matrix by a similar matrix or a vector
         * @param M2x2 | V2 matrix
         * @return M2x2 | V2
         */
        x: function(matrix) {
            var isVector = typeof(matrix.rows) === 'undefined';
            
            // Ensure the right-sized matrix
            if (!isVector && matrix.rows == 3) {
                return this.toM3x3().x(matrix);
            }
            
            var a = this.elements,
                b = matrix.elements;
            
            if (isVector && b.length == 2) {
                // b is actually a vector
                return new $m.V2(
                    a[0] * b[0] + a[1] * b[1],
                    a[2] * b[0] + a[3] * b[1]
                );
            } else if (b.length == a.length) {
                // b is a 2x2 matrix
                return new $m.M2x2(
                    a[0] * b[0] + a[1] * b[2],
                    a[0] * b[1] + a[1] * b[3],
                    
                    a[2] * b[0] + a[3] * b[2],
                    a[2] * b[1] + a[3] * b[3]
                );
            }
            return false; // fail
        },
        
        /**
         * Generates an inverse of the current matrix
         * @param void
         * @return M2x2
         * @link http://www.dr-lex.be/random/matrix_inv.html
         */
        inverse: function() {
            var d = 1/this.determinant(),
                a = this.elements;
            return new $m.M2x2(
                d *  a[3], d * -a[1],
                d * -a[2], d *  a[0]
            );
        },
        
        /**
         * Calculates the determinant of the current matrix
         * @param void
         * @return Number
         * @link http://www.dr-lex.be/random/matrix_inv.html
         */
        determinant: function() {
            var a = this.elements;
            return a[0] * a[3] - a[1] * a[2];
        }
    });
    
    $.extend($m.M3x3.prototype, Matrix, {
        /**
         * Multiply a 3x3 matrix by a similar matrix or a vector
         * @param M3x3 | V3 matrix
         * @return M3x3 | V3
         */
        x: function(matrix) {
            var isVector = typeof(matrix.rows) === 'undefined';
            
            // Ensure the right-sized matrix
            if (!isVector && matrix.rows < 3) {
                matrix = matrix.toM3x3();
            }
            
            var a = this.elements,
                b = matrix.elements;
            
            if (isVector && b.length == 3) {
                // b is actually a vector
                return new $m.V3(
                    a[0] * b[0] + a[1] * b[1] + a[2] * b[2],
                    a[3] * b[0] + a[4] * b[1] + a[5] * b[2],
                    a[6] * b[0] + a[7] * b[1] + a[8] * b[2]
                );
            } else if (b.length == a.length) {
                // b is a 3x3 matrix
                return new $m.M3x3(
                    a[0] * b[0] + a[1] * b[3] + a[2] * b[6],
                    a[0] * b[1] + a[1] * b[4] + a[2] * b[7],
                    a[0] * b[2] + a[1] * b[5] + a[2] * b[8],

                    a[3] * b[0] + a[4] * b[3] + a[5] * b[6],
                    a[3] * b[1] + a[4] * b[4] + a[5] * b[7],
                    a[3] * b[2] + a[4] * b[5] + a[5] * b[8],

                    a[6] * b[0] + a[7] * b[3] + a[8] * b[6],
                    a[6] * b[1] + a[7] * b[4] + a[8] * b[7],
                    a[6] * b[2] + a[7] * b[5] + a[8] * b[8]
                );
            }
            return false; // fail
        },
        
        /**
         * Generates an inverse of the current matrix
         * @param void
         * @return M3x3
         * @link http://www.dr-lex.be/random/matrix_inv.html
         */
        inverse: function() {
            var d = 1/this.determinant(),
                a = this.elements;
            return new $m.M3x3(
                d * (  a[8] * a[4] - a[7] * a[5]),
                d * (-(a[8] * a[1] - a[7] * a[2])),
                d * (  a[5] * a[1] - a[4] * a[2]),
                
                d * (-(a[8] * a[3] - a[6] * a[5])),
                d * (  a[8] * a[0] - a[6] * a[2]),
                d * (-(a[5] * a[0] - a[3] * a[2])),
                
                d * (  a[7] * a[3] - a[6] * a[4]),
                d * (-(a[7] * a[0] - a[6] * a[1])),
                d * (  a[4] * a[0] - a[3] * a[1])
            );
        },
        
        /**
         * Calculates the determinant of the current matrix
         * @param void
         * @return Number
         * @link http://www.dr-lex.be/random/matrix_inv.html
         */
        determinant: function() {
            var a = this.elements;
            return a[0] * (a[8] * a[4] - a[7] * a[5]) - a[3] * (a[8] * a[1] - a[7] * a[2]) + a[6] * (a[5] * a[1] - a[4] * a[2]);
        }
    });
    
    /** generic vector prototype */
    var Vector = {      
        /**
         * Return a specific element from the vector
         * @param Number i where 1 is the 0th value
         * @return Number
         */
        e: function(i) {
            return this.elements[i - 1];
        }
    };
    
    /** Extend all of the vector types with the same prototype */
    $.extend($m.V2.prototype, Vector);
    $.extend($m.V3.prototype, Vector);
})(jQuery, this, this.document);
///////////////////////////////////////////////////////
// Matrix Calculations
///////////////////////////////////////////////////////
(function($, window, document, undefined) {
    /**
     * Matrix object for creating matrices relevant for 2d Transformations
     * @var Object
     */
    if (typeof($.matrix) == 'undefined') {
        $.extend({
            matrix: {}
        });
    }
    
    $.extend( $.matrix, {
        /**
         * Class for calculating coordinates on a matrix
         * @param Matrix matrix
         * @param Number outerHeight
         * @param Number outerWidth
         * @constructor
         */
        calc: function(matrix, outerHeight, outerWidth) {
            /**
             * @var Matrix
             */
            this.matrix = matrix;
            
            /**
             * @var Number
             */
            this.outerHeight = outerHeight;
            
            /**
             * @var Number
             */
            this.outerWidth = outerWidth;
        }
    });
    
    $.matrix.calc.prototype = {
        /**
         * Calculate a coord on the new object
         * @return Object
         */
        coord: function(x, y, z) {
            //default z and w
            z = typeof(z) !== 'undefined' ? z : 0;
            
            var matrix = this.matrix,
                vector;
                
            switch (matrix.rows) {
                case 2:
                    vector = matrix.x(new $.matrix.V2(x, y));
                    break;
                case 3:
                    vector = matrix.x(new $.matrix.V3(x, y, z));
                    break;
            }
            
            return vector;
        },
        
        /**
         * Calculate the corners of the new object
         * @return Object
         */
        corners: function(x, y) {
            // Try to save the corners if this is called a lot
            var save = !(typeof(x) !=='undefined' || typeof(y) !=='undefined'),
                c;
            if (!this.c || !save) {
                y = y || this.outerHeight;
                x = x || this.outerWidth;
                
                c = {
                    tl: this.coord(0, 0),
                    bl: this.coord(0, y),
                    tr: this.coord(x, 0),
                    br: this.coord(x, y)
                };
            } else {
                c = this.c;
            }
            
            if (save) {
                this.c = c;
            }
            return c;
        },
        
        /**
         * Calculate the sides of the new object
         * @return Object
         */
        sides: function(corners) {
            // The corners of the box
            var c = corners || this.corners();
            
            return {
                top: Math.min(c.tl.e(2), c.tr.e(2), c.br.e(2), c.bl.e(2)),
                bottom: Math.max(c.tl.e(2), c.tr.e(2), c.br.e(2), c.bl.e(2)),
                left: Math.min(c.tl.e(1), c.tr.e(1), c.br.e(1), c.bl.e(1)),
                right: Math.max(c.tl.e(1), c.tr.e(1), c.br.e(1), c.bl.e(1))
            };
        },
        
        /**
         * Calculate the offset of the new object
         * @return Object
         */
        offset: function(corners) {
            // The corners of the box
            var s = this.sides(corners);
            
            // return size
            return {
                height: Math.abs(s.bottom - s.top), 
                width: Math.abs(s.right - s.left)
            };
        },
        
        /**
         * Calculate the area of the new object
         * @return Number
         * @link http://en.wikipedia.org/wiki/Quadrilateral#Area_of_a_convex_quadrilateral
         */
        area: function(corners) {
            // The corners of the box
            var c = corners || this.corners();
            
            // calculate the two diagonal vectors
            var v1 = {
                    x: c.tr.e(1) - c.tl.e(1) + c.br.e(1) - c.bl.e(1),
                    y: c.tr.e(2) - c.tl.e(2) + c.br.e(2) - c.bl.e(2)
                },
                v2 = {
                    x: c.bl.e(1) - c.tl.e(1) + c.br.e(1) - c.tr.e(1),
                    y: c.bl.e(2) - c.tl.e(2) + c.br.e(2) - c.tr.e(2)
                };
                
            return 0.25 * Math.abs(v1.e(1) * v2.e(2) - v1.e(2) * v2.e(1));
        },
        
        /**
         * Calculate the non-affinity of the new object
         * @return Number
         */
        nonAffinity: function() {
            // The corners of the box
            var sides = this.sides(),
                xDiff = sides.top - sides.bottom,
                yDiff = sides.left - sides.right;
            
            return parseFloat(parseFloat(Math.abs(
                (Math.pow(xDiff, 2) + Math.pow(yDiff, 2)) /
                (sides.top * sides.bottom + sides.left * sides.right)
            )).toFixed(8));
        },
        
        /**
         * Calculate a proper top and left for IE
         * @param Object toOrigin
         * @param Object fromOrigin
         * @return Object
         */
        originOffset: function(toOrigin, fromOrigin) {
            // the origin to translate to
            toOrigin = toOrigin ? toOrigin : new $.matrix.V2(
                this.outerWidth * 0.5,
                this.outerHeight * 0.5
            );
            
            // the origin to translate from (IE has a fixed origin of 0, 0)
            fromOrigin = fromOrigin ? fromOrigin : new $.matrix.V2(
                0,
                0
            );
            
            // transform the origins
            var toCenter = this.coord(toOrigin.e(1), toOrigin.e(2));
            var fromCenter = this.coord(fromOrigin.e(1), fromOrigin.e(2));
            
            // return the offset
            return {
                top: (fromCenter.e(2) - fromOrigin.e(2)) - (toCenter.e(2) - toOrigin.e(2)),
                left: (fromCenter.e(1) - fromOrigin.e(1)) - (toCenter.e(1) - toOrigin.e(1))
            };
        }
    };
})(jQuery, this, this.document);
///////////////////////////////////////////////////////
// 2d Matrix Functions
///////////////////////////////////////////////////////
(function($, window, document, undefined) {
    /**
     * Matrix object for creating matrices relevant for 2d Transformations
     * @var Object
     */
    if (typeof($.matrix) == 'undefined') {
        $.extend({
            matrix: {}
        });
    }
    var $m = $.matrix,
        $m2x2 = $m.M2x2,
        $m3x3 = $m.M3x3;
    
    $.extend( $m, {
        /**
         * Identity matrix
         * @param Number size
         * @return Matrix
         */
        identity: function(size) {
            size = size || 2;
            var length = size * size,
                elements = new Array(length),
                mod = size + 1;
            for (var i = 0; i < length; i++) {
                elements[i] = (i % mod) === 0 ? 1 : 0;
            }
            return new $m['M'+size+'x'+size](elements);
        },
        
        /**
         * Matrix
         * @return Matrix
         */
        matrix: function() {
            var args = Array.prototype.slice.call(arguments);
            // arguments are in column-major order
            switch (arguments.length) {
                case 4:
                    return new $m2x2(
                        args[0], args[2],
                        args[1], args[3]
                    );
                case 6:
                    return new $m3x3(
                        args[0], args[2], args[4],
                        args[1], args[3], args[5],
                        0,       0,       1
                    );
            }
        },
        
        /**
         * Reflect (same as rotate(180))
         * @return Matrix
         */
        reflect: function() {
            return new $m2x2(
                -1,  0,
                 0, -1
            );
        },
        
        /**
         * Reflect across the x-axis (mirrored upside down)
         * @return Matrix
         */
        reflectX: function() {  
            return new $m2x2(
                1,  0,
                0, -1
            );
        },
        
        /**
         * Reflect by swapping x an y (same as reflectX + rotate(-90))
         * @return Matrix
         */
        reflectXY: function() {
            return new $m2x2(
                0, 1,
                1, 0
            );
        },
        
        /**
         * Reflect across the y-axis (mirrored)
         * @return Matrix
         */
        reflectY: function() {
            return new $m2x2(
                -1, 0,
                 0, 1
            );
        },
        
        /**
         * Rotates around the origin
         * @param Number deg
         * @return Matrix
         * @link http://www.w3.org/TR/SVG/coords.html#RotationDefined
         */
        rotate: function(deg) {
            //TODO: detect units
            var rad = $.angle.degreeToRadian(deg),
                costheta = Math.cos(rad),
                sintheta = Math.sin(rad);
            
            var a = costheta,
                b = sintheta,
                c = -sintheta,
                d = costheta;
                
            return new $m2x2(
                a, c,
                b, d
            );
        },
        
        /**
         * Scale
         * @param Number sx
         * @param Number sy
         * @return Matrix
         * @link http://www.w3.org/TR/SVG/coords.html#ScalingDefined
         */
        scale: function (sx, sy) {
            sx = sx || sx === 0 ? sx : 1;
            sy = sy || sy === 0 ? sy : sx;
            
            return new $m2x2(
                sx, 0,
                0, sy
            );
        },
        
        /**
         * Scale on the X-axis
         * @param Number sx
         * @return Matrix
         */
        scaleX: function (sx) {
            return $m.scale(sx, 1);
        },
        
        /**
         * Scale on the Y-axis
         * @param Number sy
         * @return Matrix
         */
        scaleY: function (sy) {
            return $m.scale(1, sy);
        },
        
        /**
         * Skews on the X-axis and Y-axis
         * @param Number degX
         * @param Number degY
         * @return Matrix
         */
        skew: function (degX, degY) {
            degX = degX || 0;
            degY = degY || 0;
            
            //TODO: detect units
            var radX = $.angle.degreeToRadian(degX),
                radY = $.angle.degreeToRadian(degY),
                x = Math.tan(radX),
                y = Math.tan(radY);
            
            return new $m2x2(
                1, x,
                y, 1
            );
        },
        
        /**
         * Skews on the X-axis
         * @param Number degX
         * @return Matrix
         * @link http://www.w3.org/TR/SVG/coords.html#SkewXDefined
         */
        skewX: function (degX) {
            return $m.skew(degX);
        },
        
        /**
         * Skews on the Y-axis
         * @param Number degY
         * @return Matrix
         * @link http://www.w3.org/TR/SVG/coords.html#SkewYDefined
         */
        skewY: function (degY) {
            return $m.skew(0, degY);
        },
        
        /**
         * Translate
         * @param Number tx
         * @param Number ty
         * @return Matrix
         * @link http://www.w3.org/TR/SVG/coords.html#TranslationDefined
         */
        translate: function (tx, ty) {
            tx = tx || 0;
            ty = ty || 0;
            
            return new $m3x3(
                1, 0, tx,
                0, 1, ty,
                0, 0, 1
            );
        },
        
        /**
         * Translate on the X-axis
         * @param Number tx
         * @return Matrix
         * @link http://www.w3.org/TR/SVG/coords.html#TranslationDefined
         */
        translateX: function (tx) {
            return $m.translate(tx);
        },
        
        /**
         * Translate on the Y-axis
         * @param Number ty
         * @return Matrix
         * @link http://www.w3.org/TR/SVG/coords.html#TranslationDefined
         */
        translateY: function (ty) {
            return $m.translate(0, ty);
        }
    });
})(jQuery, this, this.document);;

/**
 * Function generates a random string for use in unique IDs, etc
 *
 * @param <int> n - The length of the string
 */
function randString(n)
{
    if(!n)
        n = 5;

    var text = '';
    var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    for(var i=0; i < n; i++)
    {
        text += possible.charAt(Math.floor(Math.random() * possible.length));
    }

    return text;
};

