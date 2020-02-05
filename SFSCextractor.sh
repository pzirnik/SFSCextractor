#!/bin/bash

log() {
	if [ "${LOGLEVEL}" -ge "${1}" ] ; then
		DATE=$(date +"%Y.%m.%d-%H:%M:%S.%N")
		echo "${DATE} ${2}" >> ~/.SFSCextractor.log
	fi
}

is_tar() {
	FILELIST=$(/usr/bin/tar --list -f ${1})
	if [ -z "${FILELIST}" -o $? -ne 0 ] ; then
		return -1;
	fi
	return 0;
}

handle_file() {
	FILENAME=$1
	CASENO=$2
	log 2 "Need to handle ${DOWNLOAD_FOLDER}/${FILENAME}" 
	# create directory
	mkdir -p ${CASES_FOLDER}/${CASENO} || log 1 "Could not create directory ${CASES_FOLDER}/${CASENO}"
	# compute real filename
	REALNAME=$(echo ${FILENAME} | sed -ne "s/^SFSC[0-9]\{8,\}_\(.*\)$/\1/p")
	log 2 "Final filename from ${FILENAME} is ${REALNAME}"	
	if [ -z "${REALNAME}"  ] ; then
		# something went wrong
		log 1 "Could not get real filename from: ${FILENAME}"
		return	
	fi
	# move file to right place
	mv ${DOWNLOAD_FOLDER}/${FILENAME} ${CASES_FOLDER}/${CASENO}/${REALNAME} ||
		log 1 "Could not move file ${DOWNLOAD_FOLDER}/${FILENAME} to ${CASES_FOLDER}/${CASENO}/${REALNAME}"  
	# check if we need to extract a archive
	cd ${CASES_FOLDER}/${CASENO} || log 1 "Could not change into case directory ${CASES_FOLDER}/${CASENO}" 
	TYPE=$(file -b -i ${REALNAME})
	log 2 "Filetype of ${REALNAME} is ${TYPE}"
	case "${TYPE}" in
		*x-bzip2*)
			if is_tar ${REALNAME} ; then
				/usr/bin/tar xf ${REALNAME} || log 1 "Could not untar ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
			else
				/usr/bin/bunzip2 ${REALNAME} || log 1 "Could not bunzip2 ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
			fi 
			;;
		*gzip*)
                        if is_tar ${REALNAME} ; then
				/usr/bin/tar xf ${REALNAME} || log 1 "Could not untar ${CASES_FOLDER}/${CASENO}/${REALNAME}"
			else
                                /usr/bin/gunzip ${REALNAME} || log 1 "Could not ungzip ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
                        fi
                        ;;
                *x-xz*)
                        if is_tar ${REALNAME} ; then
                                /usr/bin/tar xf ${REALNAME} || log 1 "Could not untar ${CASES_FOLDER}/${CASENO}/${REALNAME}"
                        else
                                /usr/bin/unxz ${REALNAME} || log 1 "Could not unxz ${CASES_FOLDER}/${CASENO}/${REALNAME}"
                        fi
                        ;;
		*x-tar*)
			/usr/bin/tar xf ${REALNAME} || log 1 "Could not untar ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
			;;
		*zip*)
			/usr/bin/unzip ${REALNAME} || log 1 "Could not unzip ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
			;;
	esac
}

. ~/.SFSCextractorrc

if [ -z "${DOWNLOAD_FOLDER}" ] ; then
	echo "You need to set your dowloadfolder in ~/.SFSCextratorrc" >&2
	exit 1
fi

if [ -z "${CASES_FOLDER}" ] ; then
	echo "You need to set your casesfolder in ~/.SFSCextratorrc" >&2
        exit 1
fi

if [ -z "${LOGLEVEL}" ] ; then
	LOGLEVEL=1
fi

inotifywait -m ${DOWNLOAD_FOLDER} -e attrib -e moved_to --exclude '.*\.(crdownload)|(part)$' -q | while read DIR ACTION FILE ; do
	log 2 "Got action ${ACTION} for ${DIR}/${FILE}"
	CASENO=$(echo ${FILE} | sed -ne "s/^SFSC\([0-9]\{8,\}\)_.*$/\1/p")
	if [ ! -z "${CASENO}"  ] ; then
		log 2 "Caseno for ${DIR}/${FILE} is ${CASENO}" 
		if [ ${ACTION} == "ATTRIB" ] ; then
			log 2 "Waiting for CLOSE_WRITE action on ${DIR}/${FILE}"
			( inotifywait ${DIR}/${FILE} -e close_write -qq && 
				(handle_file ${FILE} ${CASENO} ) &) &
		else 
			( handle_file ${FILE} ${CASENO} ) &	
		fi
	fi
done


