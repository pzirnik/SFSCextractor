SFSCextractor will automaticaly create a case directory,
move the downloaded attachemnts into the case directory and try to
extract them. 
For this to work you need to precede the original filename with 

  "SFSC\<casnumber\>_" 

when downloading a attachment (in the download dialog of the browser).

e.g.

for SFSC case 0012345

  supportconfig_1234567891.tar.gz 

needs to be namend

  SFSC0012345_supportconfig_1234567891.tar.gz

To help you doing this there is a browser extension
named "SFSChandler", you need to add it to your browser.

However there two types of attachments in Salesforce.

- SCC or other uploaded attachments
- email attachments

Currently SFSChandler can not handle email attachments.
you can identify them when hovering over the download link. If
it displays "javascript: void(0)" SFSChandler can not handle
the attachment. For this case please read below for making your
job at least little bit easyier.


To install SFSCextractor you need to:

either download and extract the zip archive from

   https://github.com/pzirnik/SFSCextractor/archive/0.0.1.zip

or clone the repostory

```
git clone https://github.com/pzirnik/SFSCextractor
```

next you need to install the browser extension:

On chrome you need:

1. just install the extension from webstore

  https://chrome.google.com/webstore/search/sfschandler

On firefox you need:

1. just install the extension from

  https://addons.mozilla.org/en-US/firefox/addon/sfschandler/

Then run the install script in the SFSCextractor folder

```
./install.sh
```

If everything is up and running, in the "related -> attachments" tab and the "view all attachments" page

- just right click on a attachment and choose "Handle with SFSCextractor"
- the download dialog will open and filename is already prepared to be handled with SFSCextractor
- once the download is finished the file will be copied to a folder matching the Casenumber below your CASES_FOLDER
- if the downloaded attachment is an archive it will be extracted.

To handle email attachments with SFSCextractor:

There some userscripts in the js/ folder or online at

  https://greasyfork.org/en/users/438027-paul-zirnik

you need to install the "SFSC direct download link"  
in greasemonkey or tampermonkey. If this is done, reload your
birowser tab and now you can do following:

1. In your browser settings choose "always ask for download location"

2. on the "view all attachments" page just click somewhere on the
   page that is not a link. This will add a cut&paste text to the
   breadcumb navigation like: > SFSC12345678_
 
3. copy the text into your copy buffer

4. click on the attachment

5. now the download dialog will open and allow you to change the download folder
   and also the filename. Just paste the text prior the filename. Now SFSCextractor
   can also handle this downloads.

