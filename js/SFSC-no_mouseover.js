// ==UserScript==
// @name        SFSC no mouseover
// @description disable mouseover on entire page 
// @version     1.0
// @grant       none
// @include     https://suse.lightning.force.com/*
// @namespace   https://greasyfork.org/users/438027
// @run-at      document-end
// ==/UserScript==
document.addEventListener( 'mouseover', function(event) {
    if (!event.shiftKey) {
    	event.preventDefault();  
    	event.stopPropagation();
    }
  },  true
);
