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
                    var preview = document.getElementById('p'+ res.responseText);
                    var topPreview = document.getElementById('tp'+ res.responseText);
                    if(preview !== null) {
                        document.getElementById('p'+ res.responseText).addClassName("owned");
                    }
                    if(topPreview !== null) {
                        document.getElementById('tp'+ res.responseText).addClassName("owned");
                    }
                }
            }
        });
    }
}

// Previews in the main section and the top section have the same IDs
// This makes it so highlighting previews in the main section impossible if it's already highlighted
// in the top section.
// This marks the top previews with a different ID so they can be marked separately from the main page content
function fixPopularPreviewIds() {
    var previewDiv = document.getElementById('popular-preview');

    // Only need to run this when there's a popular previews section
    if (previewDiv === null) {
        return;
    }

    var popularPreviews = previewDiv.children[0].children;
    for(var j = 0; j < popularPreviews.length; j++) {
        if (popularPreviews[j].className == "popular-preview-post") {
            // Prepend 't' to second child's ID to mark it as a top preview
            popularPreviews[j].children[1].id = "t" + popularPreviews[j].children[1].id;
        }
    }

}

(function() {
    'use strict';
    fixPopularPreviewIds();
    GM_addStyle("span.owned { background-color: #73dca5; border-radius: 5%; }");
    waitForKeyElements ("*", iterateOverThumbs);
})();
