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


To install SFSCextractor you need to:

either download and extract the zip archive from

   https://github.com/pzirnik/SFSCextractor/archive/0.0.1.zip

and extraxt the archive or clone the repostory

```
git clone https://github.com/pzirnik/SFSCextractor
```

next you need to install the browser extension:
It is in the extension/ directory. 

On chrome you need:

1. just install the extension from webstore

  https://https://chrome.google.com/webstore/search/sfschandler

On firefox you need:

1. just install the extension from

  https://addons.mozilla.org/en-US/firefox/addon/sfschandler/

Then run the install script

```
bash SFSCextrator/install.sh
```

or do the install steps manual

1. make sure you have installed "inotify-tools" on the system

  sudo zypper in inotify-tools

2. copy/create the ~/.SFSCextractorrc file to your home directory
   the file should contain

-------~/.SFSCextractorrc--------------
```# the folder where you download the SFSC attachments
# e.g. your browsers default download folder
DOWNLOAD_FOLDER=~/Downloads

# the folder with your cases
CASES_FOLDER=/hdhome/SFSC 

# loglevel 1=errors 2=verbose
LOGLEVEL=1
```
---------------------------------------

3. copy the SFSCextractor.sh into /usr/bin/ 

```
  sudo cp SFSCextractor.sh /usr/bin/
  sudo chmod 755 /usr/bin/SFSCextractor.sh
```

4. copy the startscript to global systemd users directory

```
  sudo cp SFSCextractor@.service /usr/lib/systemd/user/
```

5. reload systemd at userspace

```
  systemctl --user daemon-reload
```

6. create a instance from the service for your user

```
  mkdir -p ~/.config/systemd/user
  systemctl --user enable SFSCextractor@$USER.service
```

7. start the service or relogin

```
  systemctl --user start SFSCextractor@$USER.service
```

If everything is up and running, in the "view all attachments page"

- just right click on a attachment and choose "Handle with SFSCextractor"
- the download dialog will open and filename is already prepared to be handled with SFSCextractor
- once the download is finished the file will be copied to a folder matching the Casenumber below your CASES_FOLDER
- if the downloaded attachment is an archive it will be extracted.

