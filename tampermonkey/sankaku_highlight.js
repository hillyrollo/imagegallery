// ==UserScript==
// @name         Sankaku Complex Owned Highlighter
// @namespace    https://chan.sankakucomplex.com
// @version      0.1
// @description  Highlights images that you already have downloaded to your image gallery app while browsing the Sankaku Channel
// @author       You
// @require      http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js
// @require  https://gist.github.com/raw/2625891/waitForKeyElements.js
// @match        https://chan.sankakucomplex.com/*
// @grant GM_xmlhttpRequest
// @grant GM_addStyle
// ==/UserScript==

var thumbs;
var currentThumb;
var thumbsCount = 0;

function iterateOverThumbs(jNode) {
    thumbs = document.getElementsByClassName('preview');
    for(thumbsCount; thumbsCount < thumbs.length; thumbsCount++) {
        var postURL = thumbs[thumbsCount].parentElement.href;
        currentThumb = thumbs[thumbsCount];
        var resp = GM_xmlhttpRequest({
            method: "GET",
            url: "http://192.168.1.200/check?url=" + postURL,
            onload: function(res) {
                if(typeof res.responseText != "undefined") {
                    console.log("trying to add class for id: ", res.responseText);
                    document.getElementById('p'+ res.responseText).addClassName("owned");
                }
            }
        });
    }
}

(function() {
    'use strict';
    GM_addStyle("span.owned { background-color: #73dca5; border-radius: 5%; }");
    waitForKeyElements ("*", iterateOverThumbs);
})();
