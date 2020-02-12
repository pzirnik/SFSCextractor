chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
	sendResponse(findCaseNo(request));
});

function findCaseNo(link) {
	//console.log("Got "+link+" from contextMenu");
	var links = document.getElementsByTagName("a");
	var marker = 0;
	var caseno = 0;
	var i;
	var filename = "";
	//console.log(links.length);
	for(i=0;i<links.length;i++) {
		if (links[i].className=="forceBreadCrumbItem") {
			if (links[i].title.match(/^[0-9]{8,}/)) {
				marker = i;
			}
		}
		if (link == links[i].href && marker != 0) {
			caseno=links[marker].title;
			break;
		}
	}
	var filenamespan = links[i].getElementsByClassName("itemTitle");
	if (filenamespan.length == 1) {
		filename=filenamespan[0].title;
	}
	return {url: link, caseno: caseno, filename: filename};
}
