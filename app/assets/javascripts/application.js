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

// function rotateCC() {
//   ar = pswp.viewportSize.x / pswp.viewportSize.y
//   console.log(ar)
//   // greater width, flip and scale y
//   if(ar >= (16.0/9.0)) {
//
//   } else {
//     // less width, flip and scale x
//   }
//
//   pswp.currItem.currentRotation -= 90
//   // console.log(pswp.currItem.currentRotation)
//
//   var css;
//
//   var iratio= pswp.currItem.w / pswp.currItem.h
//   var pratio= pswp.viewportSize.x / pswp.viewportSize.y
//   if (pswp.currItem.currentRotation == -90 || pswp.currItem.currentRotation == -270) {
//     iratio= pswp.currItem.h / pswp.currItem.w
//     pratio= pswp.viewportSize.y / pswp.viewportSize.x
//   }
//
//
//   // console.log("image ratio: ", iratio)
//   // console.log("vp ratio: ", pratio)
//   if (iratio < pratio) {
//     // css={width:'auto', height:'100%'};
//   } else {
//     // css={width:'100%', height:'auto'};
//   }
//   // $(".pswp__img").css(css);
//
//   if(pswp.currItem.currentRotation == -360) {
//     pswp.currItem.currentRotation = 0
//   }
//
//   $(".pswp__zoom-wrap").css("transform", "translate3d(100,-200,0)")
//   // sizeImage(pswp.viewportSize, pswp.currItem.h, pswp.currItem.w);
//   // pswp.updateSize(true);
//   $(".pswp__img").css("transform", "rotate("+ pswp.currItem.currentRotation + "deg)")
//   // $('.pswp__img').removeAttr('height')
//   // $(".pswp__img").css("width", "auto !important")
//
//   // pswp.applyZoomPan(1, 0, 0)
// }
//
// function sizeImage(vpW, vpH, imgW, imgH) {
//   var winW = vpW;
//   var winH = vpH;
//   var imgRatio = imgW / imgH;
//   var tWidth = winW;
//   var tHeight = winH;
//   function scaleWB() { tWidth = winW; tHeight = tWidth / imgRatio; }
//   function scaleBW() { tHeight = winH; tWidth = tHeight * imgRatio; }
//   if (imgRatio >= 1) {
//   scaleWB();
//     if (tHeight > winH) { scaleBW(); }
//     if (tWidth > imgW) { tWidth = imgW; tHeight = imgH; }
//   }
//   else {
//   scaleBW();
//     if (tWidth > winW) { scaleWB(); }
//     if (tHeight > imgH) { tWidth = imgW; tHeight = imgH; }
//   }
//   var tLeft = (winW-tWidth)/2;
//   var tTop = (winH-tHeight)/2;
//
//   $('.pswp__img').css({'left':0, 'top':0, 'width':vpW, 'height':vpH , visibility: 'visible' })
// }

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
  if (typeof(pswp.currItem.videosrc) !== "undefined") {
     sizeVideo(pswp.viewportSize, pswp.currItem.vw,  pswp.currItem.vh);
     $("#" + pswp.currItem.id).get(0).play();
     videoRunning = true;
  }
    // $(".pswp__img").css("transform", "rotate(" + pswp.currItem.currentRotation + "deg)")
  });
  pswp.listen('resize', function () {
    if (videoRunning) {
      sizeVideo(pswp.viewportSize, pswp.currItem.vw,  pswp.currItem.vh);
    }
  });
  pswp.listen('close', function () {
    checkVideo();
    $("video").each(function () { this.pause() });
    //
    // for(i = 0; i < pswp.items.length; i++) {
    //   pswp.items[i].currentRotation = 0;
    // }
   });

  pswp.listen('beforeChange', function () {
    checkVideo();
   });
  return pswp;
}
