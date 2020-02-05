// ==UserScript==
// @name        SFSC no double click
// @description disable double click events on entire page 
// @version     1.1
// @grant       none
// @include     https://suse.lightning.force.com/*
// @namespace   https://greasyfork.org/users/438027
// @run-at      document-end
// ==/UserScript==
document.addEventListener( 'dblclick', function(event) {   
    event.preventDefault();  
    event.stopPropagation(); 
  },  true
);
