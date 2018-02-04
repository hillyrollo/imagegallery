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
var pswp

function checkVideo() {
  if (videoRunning) {
    $("video").each(function () { this.pause() });
    videoRunning = false;
  }
}

// Function to rotate the current image 90 degrees counter clockwise
function rotateImage(){
  vp = pswp.viewportSize;

  var mediaType = "image";
  if(typeof(pswp.currItem.videosrc) !== "undefined") {
    mediaType = "video";
  }

  // Get the max scale factors for the X and Y axis
  if (mediaType == "image") {
    scaleFactorX = vp.x / (pswp.currItem.h * pswp.currItem.fitRatio)
    scaleFactorY = vp.y / (pswp.currItem.w * pswp.currItem.fitRatio)
  } else if (mediaType == "video") {
    pswp.currItem.rotated = true
    scaleAndTranslateVideo(pswp.currItem)
    return
  }

  var scale_factor;
  // Choose whichever scaling factor is the lowest
  // This is the largest the image can get in the current window while preserving aspect ratio
  if(scaleFactorX >= scaleFactorY) {
    scaleFactor = scaleFactorY
  } else {
    scaleFactor = scaleFactorX
  }

  // Apply the CSS to rotate and scale the image
  pswp.currItem.scaleFactor = scaleFactor;
  if(typeof(pswp.currItem.videosrc) != "undefined") {
    //$("video").css("transform", "rotate(-90deg) scale(" + scaleFactor + ")");
  } else {
    $(".pswp__img").css("transform", "rotate(-90deg) scale(" + scaleFactor + ")");
  }
  pswp.currItem.rotated = true;
}

// Set up onclick event for the rotate button
$(document).on('click', '.pswp__button.pswp__button--rotate', rotateImage);


function getVideoScaleFactor(vp, imgW, imgH, rotated) {
  if(rotated == false) {
    sfX = vp.x / imgW;
    sfY = vp.y / imgH;
  } else {
    sfX = vp.x / imgH;
    sfY = vp.y / imgW;
  }

  if(sfX >= sfY) {
    scaleFactor = sfY;
  } else {
    scaleFactor = sfX;
  }
  console.log(scaleFactor)
  return scaleFactor;
}

function scaleAndTranslateVideo(item) {
  vp = pswp.viewportSize
  video = $("#" + item.id)
  video.css("transform", "")

  scaleFactor = getVideoScaleFactor(vp, item.vw, item.vh, item.rotated)

  if(item.rotated == true) {
    scaleDeltaX = (item.vh * scaleFactor) - item.vh
    scaleDeltaY = (item.vw * scaleFactor) - item.vw
    console.log("scaling delta x: ", scaleDeltaX)
    console.log("scaling delta y: ", scaleDeltaY)
    translateY = (vp.x / 2) - (item.vh * scaleFactor) / 2 - scaleDeltaX
    translateX = (vp.y / 2) - (item.vw * scaleFactor) / 2
  } else {
    translateX = (vp.x / 2) - (item.vw * scaleFactor) / 2
    translateY = (vp.y / 2) - (item.vh * scaleFactor) / 2
  }

  css = {}
  css['width'] = item.vw
  css['height'] = item.vh

  if(item.rotated == true) {
    css['transform-origin'] = "top right"

    css['transform'] = " scale(" + scaleFactor + ")"
    video.css(css)
    console.log(video.position())
    offsetX = video.position().left
    offsetY = video.position().top


    console.log("x offset: ", offsetX)
    console.log("y offset: ", offsetY)

    initialXTransform = (item.vw * scaleFactor) + offsetX
    initialYTransform = (item.vh * scaleFactor) + offsetY
    css['transform'] = " translateX(-" + initialXTransform + "px)"
    css['transform'] += " scale(" + scaleFactor + ")"

    finalYOffset = (vp.x - item.vh * scaleFactor) / 2
    finalXOffset = (vp.y - item.vw * scaleFactor) / 2
    css['transform'] += " rotate(-90deg)"
    css['transform'] += " translateY(" + finalYOffset + "px)"
    css['transform'] += " translateX(-" + finalXOffset + "px)"
  } else {
    css['transform-origin'] = "top left"
    css['transform'] = " translateX(" + translateX + "px)"
    css['transform'] += " translateY(" + translateY + "px)"
    css['transform'] += " scale(" + scaleFactor + ")"
  }
  video.css(css)
}

function sizeVideo(vp, imgW, imgH) {
  return;
  var winW = vp.x;
  var winH = vp.y;
  var imgRatio = imgW / imgH;
  var tWidth = winW;
  var tHeight = winH;
  function scaleWB() { tWidth = winW; tHeight = tWidth / imgRatio; }
  function scaleBW() { tHeight = winH; tWidth = tHeight * imgRatio; }
  if (imgRatio >= 1) {
  scaleWB();
    if (tHeight > winH) { scaleBW(); }
    if (tWidth > imgW) { tWidth = imgW; tHeight = imgH; }
  }
  else {
  scaleBW();
    if (tWidth > winW) { scaleWB(); }
    if (tHeight > imgH) { tWidth = imgW; tHeight = imgH; }
  }
  var tLeft = (winW-tWidth)/2;
  var tTop = (winH-tHeight)/2;

  $('video').css({'left':0, 'top':0, 'width':vp.x, 'height':vp.y , visibility: 'visible' })
}

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

  pswp.listen('afterChange', function() {
    checkVideo();
    scaleAndTranslateVideo(pswp.currItem)
    if (typeof(pswp.currItem.videosrc) !== "undefined") {
       //sizeVideo(pswp.viewportSize, pswp.currItem.vw,  pswp.currItem.vh);
       $("#" + pswp.currItem.id).css({'left':0, 'top':0, 'width':pswp.currItem.vw, 'height':pswp.currItem.vh , visibility: 'visible' })
       $("#" + pswp.currItem.id).get(0).play();
       videoRunning = true;
    }
    // Remove rotation/scaling if the image has not been rotated before
    if (pswp.currItem.rotated === false){
      $(".pswp__img").css("transform", "");
    } else {
      // Otherwise, apply the rotation or recalculate it if not defined
      if (typeof(pswp.currItem.scaleFactor) != "undefined") {
        $(".pswp__img").css("transform", "rotate(-90deg) scale(" + pswp.currItem.scaleFactor + ")");
      } else {
        rotateImage();
      }
    }
  });

  pswp.listen('resize', function () {
    scaleAndTranslateVideo(pswp.currItem)
    if (videoRunning) {
      //sizeVideo(pswp.viewportSize, pswp.currItem.vw,  pswp.currItem.vh);
    }

    // If the image has been rotated, we need to run the rotate code again to make
    // the rotated image fit the adjusted screen
    if(pswp.currItem.rotated === true) {
      rotateImage();
    }
  });

  pswp.listen('close', function () {
    checkVideo();
    $("video").each(function () { this.pause() });
    // Reset all images to not be rotated
    for(i = 0; i < pswp.items.length; i++) {
      pswp.items[i].rotated = false;
    }
   });

  pswp.listen('beforeChange', function () {
    checkVideo();
   });
  return pswp;
}
