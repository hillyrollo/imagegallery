// ==UserScript==
// @name         Sankaku Complex Download Button
// @namespace    https://chan.sankakucomplex.com
// @version      0.1
// @description  Adds a button to add the current image you're looking at to the image gallery
// @author       You
// @match        https://chan.sankakucomplex.com/post/show/*
// @grant GM_xmlhttpRequest
// ==/UserScript==

// Bind 'd' key to trigger the download button
$(document).keypress(function(event) {
    if(event.charCode != 100) {
        return;
    } else {
        document.getElementById("ig-add").click();
    }
});

(function() {
    'use strict';

    // Set up span with button
    var zNode       = document.createElement ('span');
    zNode.innerHTML = '<button id="ig-add" type="button">Add to ImageGallery</button>';
    zNode.setAttribute ('id', 'ig-container');
    document.getElementsByClassName("content")[0].prepend(zNode);

    // Activate the newly added button.
    document.getElementById ("ig-add").addEventListener (
        "click", AddToImageGallery, false
    );

    function AddToImageGallery(zEvent) {
        document.getElementById('ig-add').disabled = true;

        // Make HTTP request
        var postURL = window.location.href;
        var resp = GM_xmlhttpRequest({
            method: "POST",
            url: "http://192.168.1.200/?url=" + postURL,
            onload: function(res) {
                // Update with result when request completes
                var txt = document.createTextNode(res.responseText);
                var span = document.getElementById('ig-container');
                span.appendChild(txt);
            }
        });
    }
})();
