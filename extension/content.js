chrome.runtime.onMessage.addListener((request, sender, sendResponse) => {
	sendResponse(findCaseNo(request));
});

function findCaseNo(link) {
	//console.log("Got "+link+" from contextMenu");
	var links = document.getElementsByTagName("a");
	var marker = 0;
	var caseno = 0;
	var i, j;
	var filename = "";
	var pages;
	var filenamespan;
	//console.log(links.length);
	for(i=0;i<links.length;i++) {
		if (links[i].title.match(/^[0-9]{8,}/)) {
			marker = i;
		}
		if (link == links[i].href && marker != 0) {
			caseno=links[marker].title;
			break;
		}
	}
	//casno not found we are on the 6 attachments view
	if (caseno == 0) {
		pages = document.getElementsByClassName("flexipagePage");
		findcase2: {
			for (j=0;j<pages.length;j++){
				if (pages[j].getElementsByClassName("uiOutputText")[0].innerText.match(/[0-9]+/)) {
					links = pages[j].getElementsByTagName("a");
					for (i=0; i<links.length;i++){
						if (link == links[i].href) {
							caseno = pages[j].getElementsByClassName("uiOutputText")[0].innerText;
							break findcase2;
						}
					}
				}
			}
		}
	}
	filenamespan = links[i].getElementsByClassName("itemTitle");
	if (filenamespan.length == 1) {
		filename=filenamespan[0].title;
	}
	return {url: link, caseno: caseno, filename: filename};
}
