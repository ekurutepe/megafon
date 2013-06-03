/*Adapted from Plugin Name: Responsive Flickr Gallery
 Author: Andrew Mead
 Date: 11/17/2012*/
(function ($) {
    //Entrance to the plugin
    $.fn.rfg = function (userOptions) {
        rfg.options = $.extend(true, {}, rfg.defaults, userOptions);
        rfg.el = $(this);

        rfg.el.prepend('<div class="rfg-images"></div>');
        rfg.el.find('.rfg-images').css({
            'height':rfg.options.initialHeight
        });

        //Add a gif to the center of the categories
        rfg.loading.start();

        $(window).load(function () {
            rfg.ajax.buildFlickrCalls();
        });
    };

    //Global gallery object
    var rfg = {};

    //Default options (all can be overridden)
    rfg.defaults = {
        categories:true,
        flickrSets:[],
        flickrOptions: {
            useTitle: false,
            imageSize: 'm'
        },
        categoryOptions:{
            includeAll:true,
            defaultCategory:false
        },
        lightbox:true,
        imageWidth:300,
        spacing:10,
        center:true,
        initialHeight:0
    };

    //Object to manage gallery initialization
    rfg.init = function () {

        //Initalize components based on user options
        if (rfg.options.lightbox) {
            // rfg.lightbox.addOverlay();
            // sgInitalizeLightbox();
            // jQuery('a.gallery').colorbox({ opacity:0.5 , rel:'group1' });
        }
        if (rfg.options.categories) {
            rfg.categories.init();
        }

        rfg.images.resize();
        rfg.images.show();

        //If css transitions are enabled
        rfg.utils.addTransition(rfg.el.find('.rfg-images > div'));
        rfg.categories.filterBy(rfg.options.categoryOptions.defaultCategory);

        //Reorder the gallery (should only do it if num of possible columns changes)
        var resize = function () {
            if ((size.width === $(window).width())) {
                return;
            }
            size.width = $(window).width();
            size.height = $(window).height();
            rfg.images.sort();
            rfg.images.center();
        };
        var size = {
            width: $(window).width(),
            height: $(window).height()
        };
        var resizeTimer;
        $(window).resize(function () {
            clearTimeout(resizeTimer);
            resizeTimer = setTimeout(resize, 200);
        });

        if (navigator.appVersion.indexOf("MSIE 7.") != -1) {
            rfg.el.find('.rfg-categories > li').css('display', 'inline').find('a').css({
                'display':'block',
                'padding':'3px 7px'
            });
        }
    };

    rfg.ajax = {};
    /*Keeps track of the number of sets that are completely loaded*/
    rfg.ajax.buildFlickrCalls = function () {

        var hashtag = window.location.pathname.substring(1);
        var infoApiCall = window.location.origin + "/items/" + hashtag;
        rfg.ajax.makeFlickrCalls(infoApiCall, hashtag);

    };

    rfg.ajax.makeFlickrCalls = function (infoApiCall, hashtag) {
        $.getJSON(infoApiCall, function (data) {
            var category = hashtag;

            var imageCount = 0; //total images data.photoset.photo.length
            $.each(data, function (i, photo) {
              console.log('photo: '+photo.toString());
                var img_src = photo.image;

                var image = $('<img/>').attr('src', img_src).load(function () {
                    var link = $('<a></a>')
                        .attr('href', img_src)
                        .attr('class', 'gallery')
                        .append(image);
                        
                        link.colorbox({rel: 'gal', title: function(){
                          if ( photo.source_type === 'Soundcloud'){
                            SC.oEmbed(photo.audio, { auto_play: true }, function(oEmbed) {
                              console.log('oEmbed response: ' + oEmbed);
                              $.colorbox({html:oEmbed.html});
                              // $('#cboxLoadedContent').html(oEmbed.html);
                            });                            
                          }
                          else if ( photo.source_type === 'YouTube') {
                            console.log("Hello");
                            $(".youtube").colorbox({iframe:true, innerWidth:640, innerHeight:390, html:photo.video});
                          }

                          else {
                            var url = $(this).attr('href');
                            return '<a href="' + photo.source_url + '" target="_blank">View original post on '+ photo.source_type +'</a>';
                            
                          }
                        }});
                    link.attr('title', photo.title);

                    var overlay = $('<div/>').addClass('overlay');
                    overlay.text('over');//TODO
                    
                    var unit = $('<div></div>')
                        .attr('data-category', category)
                        .append(link, overlay);

                    rfg.images.imageArray.push(unit);
                    imageCount++;
                    if (imageCount === data.length) {
                        rfg.images.appendImageArray();
                        rfg.init();
                        jQuery('a.gallery').colorbox({ opacity:0.5 , rel:'group1' });
                    }
                });
            });

        });
    };

    //Object that manages loading gif
    rfg.loading = {
        image:$("<img src='/assets/loading.gif'/>"),
        start:function () {
            this.image.css({
                'position':'absolute',
                'top': (rfg.el.position().top) + 150,
                'left':(rfg.el.width() - this.image.width()) / 2
            });
            rfg.el.prepend(this.image);
        },
        stop:function () {
            this.image.remove();
        }
    };

    //Object to manage the lightbox
    rfg.lightbox = {};
    rfg.lightbox.addOverlay = function () {
        //Create the container for the maximizer graphic
        var units = rfg.el.find('.rfg-images > div')
            .css({'cursor':'pointer'})
            .append('<span></span>');

        if (rfg.utils.transitions) {
            units.find('img').hover(function () {
                $(this).css({
                    'opacity':'.5'
                });
            }, function () {
                $(this).css({
                    'opacity':'1'
                });
            });
        } else {
            //jQuery fallback
            units.find('img').hover(function () {
                $(this).clearQueue().stop().animate({
                    'opacity':'.5'
                }, {
                    duration:'300'
                });
            }, function () {
                $(this).animate({
                    'opacity':'1'
                }, {
                    duration:'300'
                });
            });
        }
    };

    //Category functionality
    rfg.categories = {};
    rfg.categories.init = function () {
        //Get an array of all categories
        categoryList = this.generateCategoryList();

        //Turn category array into HTML <ul> markup
        var categoryMarkup = this.generateMarkup(categoryList);

        //Add the markup to the page
        rfg.el.prepend(categoryMarkup);

        //Add an event handler
        rfg.el.find('.rfg-categories a').on('click', function (e) {
            rfg.categories.filterBy($(e.target).attr('category'));
        });
        var cc = '';
        if ((rfg.options.categoryOptions.defaultCategory) && (categoryList.indexOf(rfg.options.categoryOptions.defaultCategory) !== -1)) {
            cc = rfg.options.categoryOptions.defaultCategory;
        } else {
            cc = categoryList[0]
        }
        rfg.options.categoryOptions.defaultCategory = cc;
        window.location.hash = cc;
    };

    rfg.categories.generateCategoryList = function () {
        var categories = rfg.options.categoryOptions.includeAll ? ["All"] : [];

        rfg.el.find('.rfg-images div').each(function () {
            var categoryArray = $(this).attr('data-category').split(',');

            var cursor = 0;
            for (cursor = 0; cursor < categoryArray.length; cursor++) {
                var category = categoryArray[cursor];
                if ($.inArray(category, categories) == -1) {
                    categories.push(category);
                }
            }
        });

        return categories;
    };

    rfg.categories.generateMarkup = function (categoryList) {
        //Generate a html string for the categories
        var items = "";
        for (var i = 0; i < categoryList.length; i++) {
            items += "<li><a href='#" + categoryList[i] + "' category='" + categoryList[i] + "'>" + categoryList[i] + "</a></li>"
        }
        return ("<ul class='rfg-categories'>" + items + "</ul>");
    };

    rfg.categories.filterBy = function (category) {
        /* If they are setting the same category, do nothing*/
        if (category === rfg.categories.currentCategory) {
            return;
        }
        rfg.categories.setCurrentCategory(category);

        rfg.el.find('.rfg-images > div').each(function () {
            var image = $(this);

            var imageCategories = image.attr('data-category').split(',');

            //Catch images that were intended to go directly to the user
            var urlImage = null;
            if (image.find('a').attr('rel')) {
                urlImage = image.find('a').attr('class').indexOf('gallery') ? true : false;
            } else {
                urlImage = true;
            }

            if ((category === 'All') || ($.inArray(category, imageCategories) !== -1)) {
                image.css({
                    'display':'block'
                });
                image.find('a').attr('class', 'gallery');
            } else {
                //Hide the image
                image.css({
                    'display':'none',
                    'left':'0'
                });
                image.find('a').attr('class', 'gallery');
            }

            if (urlImage) {
                image.find('a').attr('rel', '');
            }
        });

        rfg.images.sort();
        rfg.images.center();
    };

    rfg.categories.setCurrentCategory = function (category) {
        //Remove the current .current-category
        rfg.el.find('.rfg-categories > li > a.rfg-current-category').toggleClass('rfg-current-category');
        rfg.el.find('.rfg-categories > li > a').each(function () {
            if (category === $(this).html()) {
                $(this).toggleClass('rfg-current-category');
            }
        });
        this.currentCategory = category;
    };

    //Add sg.gallery for methods that manipulate images
    rfg.images = {};
    rfg.images.imageArray = [];
    rfg.images.appendImageArray = function () {
        rfg.images.imageArray.randomize();
        rfg.el.find('.rfg-images').append(rfg.images.imageArray);
    };
    //Resize the images based on defaults.imageWidth
    rfg.images.resize = function () {
        var units = rfg.el.find('.rfg-images > div'),
            opts = rfg.options;

        //For each unit, scale it down to the option, imageWidth
        units.each(function () {
            var unit = $(this);

            var image = $(unit.find('img')[0]);
            var oldWidth = image.width(),
                oldHeight = image.height(),
                ratio = opts.imageWidth / oldWidth,
                newWidth = opts.imageWidth,
                newHeight = oldHeight * ratio;

            $.merge(unit, unit.find('*')).css({
                'width':newWidth,
                'height':newHeight
            });
            unit.find('span').css('height', newHeight);
        });
    };

    //Show the images for the first time
    rfg.images.show = function () {
        rfg.el.find('.rfg-images > div')
            .css('opacity', '0')
            .css('visibility', 'visible')
            .each(function () {
                $(this).animate({
                    'opacity':'1'
                }, {
                    duration:100 + Math.floor(Math.random() * 900),
                    complete:function () {
                        rfg.loading.stop();
                    }
                });
            });
    };

    //Sort the images
    rfg.images.sort = function () {
        var units = rfg.el.find('.rfg-images > div'),
            opts = rfg.options;

        var numberOfColumns = 1 + Math.floor((rfg.el.width() - opts.imageWidth) / (opts.imageWidth + opts.spacing));
        numberOfColumns = (numberOfColumns === 0) ? 1 : numberOfColumns;

        //Array to hold column heights
        var columnHeights = [],
            i = 0;
        for (i; i < numberOfColumns; i = i + 1) {
            columnHeights[i] = 0;
        }

        var column,
            tallest = 0,
            actualColumns = 0;

        units.each(function () {
            if ($(this).css('display') == 'none') {
                return;
            }

            actualColumns++;
            column = columnHeights.min();


            if (rfg.utils.transitions) {
                $(this).css({
                    'top':columnHeights[column],
                    'left':column * (opts.imageWidth + opts.spacing)
                });
            } else {
                $(this).animate({
                    'top':columnHeights[column],
                    'left':column * (opts.imageWidth + opts.spacing)
                }, {
                    duration: 500,
                    queue: false
                });
            }

            columnHeights[column] = columnHeights[column] + $(this).height() + opts.spacing;

            //Keep track of tallest column
            if (columnHeights[column] > tallest) {
                tallest = columnHeights[column];
            }
        });

        //Solve the problem of less images than potential columns
        if (rfg.options.center) {
            numberOfColumns = (actualColumns < numberOfColumns) ? actualColumns : numberOfColumns;
        }

        rfg.el.find('.rfg-images').css({
            'height':tallest,
            'width':(numberOfColumns * (opts.imageWidth + opts.spacing)) - opts.spacing
        }, 400);
    };

    rfg.images.center = function () {
        if (!rfg.options.center) {
            return;
        }
        ;

        //Center the .sg-images in its parent
        var images = rfg.el.find('.rfg-images');

        var left = (rfg.el.width() - images.width()) / 2;

        left = (left <= 0) ? 0 : left;

        //I think css transitions don't work here because the previous css trans are not done yet
        images.animate({
            'left':left
        });

        rfg.el.find('.rfg-categories').animate({
            'margin-left':left
        });
    };

    rfg.utils = {};
    rfg.utils.addTransition = function (el) {
        if (rfg.utils.transitions) {
            el.each(function () {
                $(this).css({
                    '-webkit-transition':'all 0.7s ease',
                    '-moz-transition':'all 0.7s ease',
                    '-o-transition':'all 0.7s ease',
                    'transition':'all 0.7s ease'
                });
            });
        }
    };
    rfg.utils.removeTransition = function (el) {
        if (rfg.utils.transitions) {
            el.each(function () {
                $(this).css({
                    '-webkit-transition':'none 0.7s ease',
                    '-moz-transition':'none 0.7s ease',
                    '-o-transition':'none 0.7s ease',
                    'transition':'none 0.7s ease'
                });
            });
        }
    };
    rfg.utils.transitions = (function () {
        function cssTransitions() {
            var div = document.createElement("div");
            var p, ext, pre = ["ms", "O", "Webkit", "Moz"];
            for (p in pre) {
                if (div.style[ pre[p] + "Transition" ] !== undefined) {
                    ext = pre[p];
                    break;
                }
            }
            delete div;
            return ext;
        }

        ;
        return cssTransitions();
    }());

    if (!Array.prototype.indexOf) {
        Array.prototype.indexOf = function (elt /*, from*/) {
            var len = this.length >>> 0;

            var from = Number(arguments[1]) || 0;
            from = (from < 0)
                ? Math.ceil(from)
                : Math.floor(from);
            if (from < 0)
                from += len;

            for (; from < len; from++) {
                if (from in this &&
                    this[from] === elt)
                    return from;
            }
            return -1;
        };
    }

    Array.prototype.min = function () {
        var min = 0,
            i = 0;

        for (i; i < this.length; i = i + 1) {
            //If the current column is smaller that the smallest column (min) then min = current column
            if (this[i] < this[min]) {
                min = i;
            }
        }
        return min;
    };

    Array.prototype.randomize = function () {
        var myArray = this;
        var i = myArray.length;
        if (i == 0) return false;
        while (--i) {
            var j = Math.floor(Math.random() * ( i + 1 ));
            var tempi = myArray[i];
            var tempj = myArray[j];
            myArray[i] = tempj;
            myArray[j] = tempi;
        }
    };
}
    (jQuery)
    )
;