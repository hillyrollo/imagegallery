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

function checkVideo() {
  if (videoRunning) {
    $("video").each(function () { this.pause() });
    // $('video').css({visibility: 'hidden' })
    videoRunning = false;
  }
}

function sizeVideo(vp, imgW, imgH) {
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
  $('video').css({'left':tLeft, 'top':tTop, 'width':tWidth, 'height':tHeight , visibility: 'visible' })
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
  if (typeof(pswp.currItem.videosrc) !== "undefined") {
     sizeVideo(pswp.viewportSize, pswp.currItem.vw,  pswp.currItem.vh);
     $("#" + pswp.currItem.id).get(0).play();
     videoRunning = true;
  }
  });
  pswp.listen('resize', function () {
    if (videoRunning) {
      sizeVideo(pswp.viewportSize, pswp.currItem.vw,  pswp.currItem.vh);
    }
  });
  pswp.listen('close', function () {
    checkVideo();
    $("video").each(function () { this.pause() });
   });
  pswp.listen('beforeChange', function () {
    checkVideo();
   });
  return pswp;
}
