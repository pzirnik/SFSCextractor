var contextMenuItem = {
	id: "SFSCextractor",
	title: "Handle with SFSCextractor",
	contexts: ["link"]
};

chrome.contextMenus.create(contextMenuItem);
chrome.contextMenus.onClicked.addListener(function(link, tab){
	if (link.menuItemId == "SFSCextractor") {
		if (tab) {
			//console.log(link);
			chrome.tabs.sendMessage(tab.id, link.linkUrl, handleDownload);
		}
	}
});

function handleDownload (response) {
        //console.log(response.url);
	//console.log(response.caseno);	
	//console.log(response.filename);
	if (response.caseno > 0 && response.filename.length >= 3) {
		var id = response.url.match(/\/ContentDocument\/(.*)\/view$/);
		if (!id) {
			id = response.url.match(/\/document\/download\/(.*)\?/);
		}
		if (id) {
			var realurl = "https://suse.my.salesforce.com/sfc/servlet.shepherd/document/download/"+id[1]+"?operationContext=S1";
	        	chrome.downloads.download({url: realurl, filename: "SFSC"+response.caseno+"_"+response.filename}); 
		}
	}
}
