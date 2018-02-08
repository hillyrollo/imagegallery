// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= xxxrequire turbolinks
//= require_tree .
//= require photoswipe
//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/autocomplete
//= require autocomplete-rails
var videoRunning = false;
var pswp;

// Pauses all running videos
function checkVideo() {
  if (videoRunning) {
    $("video").each(function () { this.pause() });
    videoRunning = false;
  }
}

// Rotates the current item by 90 degrees clockwise.
function rotateCurrentItem(direction = "c") {
  // Clockwise rotation(default)
  if(direction == "c") {
    if(pswp.currItem.rotation == 270) {
      pswp.currItem.rotation = 0;
    } else {
      pswp.currItem.rotation += 90;
    }
  } else {
    // Counter-clockwise rotation
    if(pswp.currItem.rotation == 0) {
      pswp.currItem.rotation = 270;
    } else {
      pswp.currItem.rotation -= 90;
    }
  }
}

// Function to scale the current image to the size of the screen, accounting for rotation
function scaleCurrentItem() {
  vp = pswp.viewportSize;

  // If the current item is a video, run the specific function to scale the video
  // videos have a separate process to scale
  if(typeof(pswp.currItem.videosrc) !== "undefined") {
    scaleCurrentVideo();
    return;
  }

  if(pswp.currItem.rotation == 0 || pswp.currItem.rotation == 180) {
    scaleFactorX = vp.x / (pswp.currItem.w * pswp.currItem.fitRatio);
    scaleFactorY = vp.y / (pswp.currItem.h * pswp.currItem.fitRatio);
  } else {
    scaleFactorX = vp.x / (pswp.currItem.h * pswp.currItem.fitRatio);
    scaleFactorY = vp.y / (pswp.currItem.w * pswp.currItem.fitRatio);
  }

  // Choose whichever scaling factor is the lowest
  // This is the largest the image can get in the current window while preserving aspect ratio
  if(scaleFactorX >= scaleFactorY) {
    scaleFactor = scaleFactorY;
  } else {
    scaleFactor = scaleFactorX;
  }

  // Apply the CSS to rotate and scale the image
  pswp.currItem.scaleFactor = scaleFactor;
  $(".pswp__img").css("transform", "rotate("+ pswp.currItem.rotation +"deg) scale(" + scaleFactor + ")");
}

// Scales the current video to fit the current screen. Takes into account image size, screen size, and rotation
function scaleCurrentVideo() {
  vp = pswp.viewportSize;
  video = $("#" + pswp.currItem.id);
  // Reset any current transformations before applying the new one
  video.css("transform", "");

  scaleFactor = getCurrentVideoScaleFactor();

  css = {};
  css['width'] = pswp.currItem.vw;
  css['height'] = pswp.currItem.vh;

  if(pswp.currItem.rotation == 90 || pswp.currItem.rotation == 270) {
    // Translate x y
    translateX = (vp.x / 2) - (pswp.currItem.vw / 2);
    translateY = (vp.y / 2) - (pswp.currItem.vh / 2);
    css['transform'] = "translate(" + translateX + "px, " + translateY + "px)";
    // rotate
    css['transform'] += " rotate("+ pswp.currItem.rotation +"deg)";
    // scale
    css['transform'] += " scale(" + scaleFactor + ")";
  } else {
    translateX = (vp.x / 2) - (pswp.currItem.vw / 2);
    translateY = (vp.y / 2) - (pswp.currItem.vh / 2);

    css['transform'] = " translateX(" + translateX + "px)";
    css['transform'] += " translateY(" + translateY + "px)";
    css['transform'] += " rotate("+ pswp.currItem.rotation +"deg)";
    css['transform'] += " scale(" + scaleFactor + ")";
  }

  video.css(css)
}

// Gets the maximum scale factor of a video, accounting for rotation and screen size
function getCurrentVideoScaleFactor() {
  if(pswp.currItem.rotation == 0 || pswp.currItem.rotation == 180) {
    sfX = vp.x / pswp.currItem.vw;
    sfY = vp.y / pswp.currItem.vh;
  } else {
    sfX = vp.x / pswp.currItem.vh;
    sfY = vp.y / pswp.currItem.vw;
  }

  if(sfX >= sfY) {
    scaleFactor = sfY;
  } else {
    scaleFactor = sfX;
  }
  return scaleFactor;
}

// Set up onclick event for the rotate button
// Rotates the image by 90 degrees and scales it to the screen
$(document).on('click', '.pswp__button.pswp__button--rotate', function() { rotateCurrentItem(); scaleCurrentItem(); });
$(document).on('click', '.pswp__button.pswp__button--rotate-cc', function() { rotateCurrentItem("cc"); scaleCurrentItem(); });

var createPhotoSwipe = function(i) {
  var pswpElement = document.querySelectorAll('.pswp')[0];

  // define options (if needed)
  var options = {
      index: i, // start at first slide
      preload: [2,2],
      barsSize: {top: 0, bottom: 0},
      shareEl: false
  };

  // Initializes and opens PhotoSwipe
  var pswp = new PhotoSwipe(pswpElement, PhotoSwipeUI_Default, items, options);

  // Set up event listeners
  // When a slide changes, we have to fit the image/video to the screen
  pswp.listen('afterChange', function() {
    scaleCurrentItem();
    // If the new slide is a video, perform the correct scaling and start playing
    if (typeof(pswp.currItem.videosrc) !== "undefined") {
      checkVideo();
      $("#" + pswp.currItem.id).css({ visibility: 'visible' });
      $("#" + pswp.currItem.id).get(0).play();
      videoRunning = true;
    }
  });

  // When the view port is resized, we need to fit the image/video to screen
  pswp.listen('resize', function () {
    scaleCurrentItem();
  });

  // When photoswipe is closed, we need to stop all videos, and reset rotation for all items
  pswp.listen('close', function () {
    checkVideo();
    // Make sure all videos are paused before closing
    $("video").each(function () { this.pause() });
    // Reset all images to not be rotated
    for(i = 0; i < pswp.items.length; i++) {
      pswp.items[i].rotation = 0;
    }
  });

  // Before changing items, we have to stop all videos playing
  pswp.listen('beforeChange', function () {
    checkVideo();
  });

  return pswp;
}
