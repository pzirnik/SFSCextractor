#!/bin/bash

###############################################################
# SFSCectractor .sh
#
# Waits for special filesnames in the browser download directory
# and move them into a folder with a casenumber. The casenumber
# is part of the special filename.
#
# SFSC[0-9]{8,}_<real_filename>
#
# if the download is detected as archive it will be extracted.
#
# (c) 2020 by Paul Zirnik SUSE Linux GmbH 
###############################################################

# function for logs
log() {
	if [ "${LOGLEVEL}" -ge "${1}" ] ; then
		DATE=$(date +"%Y.%m.%d-%H:%M:%S.%N")
		echo "${DATE} ${2}" >> ~/.SFSCextractor.log
	fi
}

# check if the file is an tar archive
# it looks like there is a bug in tar that does
# not report an error if the file is compressed
# with bzip2 but is not a tar archive at all.
# in this case tar does report success, which is wrong
is_tar() {
	FILELIST=$(${TAR} --list -f "${1}")
	if [ -z "${FILELIST}" -o $? -ne 0 ] ; then
		return -1;
	fi
	return 0;
}

# extract archive and fix file rights
untar() {
	FILENAME=$1
	local tmpdir=$(mktemp)
	if [ -z "${tmpdir}" ] ; then
		log 1 "${FUNCNAME[0]}: Could not create tempdir for archive extraction"
		return -1
	fi
	${TAR} xfv "${FILENAME}" | tee "${tmpdir}" >/dev/null
	if [ $? -ne 0 ] ; then
		rm -f "${tmpdir}"
		return -1
	fi
	if [ "${FIX_ARCHIVE_RIGHTS}" -eq "1" ] ; then
		while read dir ; do
			find "${dir}" \( -type d -exec chmod 0755 {} \; -o -type f -exec chmod 0644 {} \; \)
		done < <(cut -d\/ -f 1 "${tmpdir}" | uniq)
	fi
	rm -f "${tmpdir}"
	return 0;
}

# place the file into casefolder and try to 
# extract archives
handle_file() {
	FILENAME=$1
	CASENO=$2
	log 2 "${FUNCNAME[0]}: Need to handle ${DOWNLOAD_FOLDER}/${FILENAME}" 
	# create directory
	mkdir -p "${CASES_FOLDER}/${CASENO}" || log 1 "${FUNCNAME[0]}: Could not create directory ${CASES_FOLDER}/${CASENO}"
	# compute real filename
	REALNAME=$(echo "${FILENAME}" | sed -ne "s/^SFSC[0-9]\{8,\}_\(.*\)$/\1/p")
	log 2 "${FUNCNAME[0]}: Final filename from ${FILENAME} is ${REALNAME}"	
	if [ -z "${REALNAME}"  ] ; then
		# something went wrong
		log 1 "${FUNCNAME[0]}: Could not get real filename from: ${FILENAME}"
		return	
	fi
	# move file to right place
	mv "${DOWNLOAD_FOLDER}/${FILENAME}" "${CASES_FOLDER}/${CASENO}/${REALNAME}" ||
		log 1 "${FUNCNAME[0]}: Could not move file ${DOWNLOAD_FOLDER}/${FILENAME} to ${CASES_FOLDER}/${CASENO}/${REALNAME}"  
	# check if we need to extract a archive
	cd "${CASES_FOLDER}/${CASENO}" || log 1 "${FUNCNAME[0]}: Could not change into case directory ${CASES_FOLDER}/${CASENO}" 
	TYPE=$(file -b -i "${REALNAME}")
	log 2 "${FUNCNAME[0]}: Filetype of ${REALNAME} is ${TYPE}"
	case "${TYPE}" in
		*x-bzip2*)
			if is_tar "${REALNAME}" ; then
				untar "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not untar ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
			else
				${BUNZIP2} "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not bunzip2 ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
			fi 
			;;
		*gzip*)
                        if is_tar "${REALNAME}" ; then
				untar "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not untar ${CASES_FOLDER}/${CASENO}/${REALNAME}"
			else
                                ${GUNZIP} "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not ungzip ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
                        fi
                        ;;
                *x-xz*)
                        if is_tar "${REALNAME}" ; then
                                untar "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not untar ${CASES_FOLDER}/${CASENO}/${REALNAME}"
                        else
                                ${UNXZ} "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not unxz ${CASES_FOLDER}/${CASENO}/${REALNAME}"
                        fi
                        ;;
		*x-tar*)
			untar "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not untar ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
			;;
		*zip*)
			${UNZIP} "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not unzip ${CASES_FOLDER}/${CASENO}/${REALNAME}" 
			;;
		*x-rar*)
			${UNRAR} "${REALNAME}" || log 1 "${FUNCNAME[0]}: Could not unrar ${CASES_FOLDER}/${CASENO}/${REALNAME}"
			;;
	esac
}

# source the configurationfile
. ~/.SFSCextractorrc

# check if everything is set
if [ -z "${DOWNLOAD_FOLDER}" ] ; then
	echo "You need to set your downloadfolder in ~/.SFSCextratorrc" >&2
	exit 1
fi

if [ -z "${CASES_FOLDER}" ] ; then
	echo "You need to set your casesfolder in ~/.SFSCextratorrc" >&2
        exit 1
fi

if [ -z "${FIX_ARCHIVE_RIGHTS}" ] ; then
	FIX_ARCHIVE_RIGHTS=1
fi

if [ -z "${LOGLEVEL}" ] ; then
	LOGLEVEL=1
fi

TAR=$(which tar)
UNZIP=$(which unzip)
UNXZ=$(which unxz)
GUNZIP=$(which gunzip)
BUNZIP2=$(which bunzip2)
UNRAR=$(which unrar)

if [ -z "${TAR}" -o -z "${UNZIP}" -o -z "${UNXZ}" -o -z "${GUNZIP}" -o -z "${BUNZIP2}" -o -z "${UNRAR}" ] ; then
	echo "not all extractor tools are installed, check: tar, unzip, unxz, gunzip, bunzip2 and unrar"
	exit 1
fi

INOTIFY=$(which inotifywait)

if [ -z "${INOTIFY}" ] ; then
	echo "inotifywait is not instelled"
	exit 1
fi

# depending on the tmp folder and the download folder chrome and firefox
# either download the file into a tmp directory and then move the file to
# the download directory. Or they create the file directly in download directory.
# MOVED_TO we get if the download is moved from the tmp location.
# If we get ATTRIB we need to wait for a CLOSE_WRITE that indicates download is
# finished
${INOTIFY} -m "${DOWNLOAD_FOLDER}" -e attrib -e moved_to -e close_write -e moved_from --exclude '.*\.(crdownload)|(part)$' -q | while read DIR ACTION FILE ; do
	log 2 "${FUNCNAME[0]}: ${ACTION} action for ${DIR}${FILE}"
	# only take care on files with special name
	# extract the casenumber already for later use
	CASENO=$(echo "${FILE}" | sed -ne "s/^SFSC\([0-9]\{8,\}\)_.*$/\1/p")
	if [ ! -z "${CASENO}"  ] ; then
    FILE_VAR=$(echo "${FILE}" | tr -d -c "a-zA-Z0-9_")
    VAR_CONTENT="${FILE_VAR}"
		case ${ACTION} in
			"CLOSE_WRITE,CLOSE")
        log 2 "${FUNCNAME[0]}: FILE_VAR=${FILE_VAR} VAR_CONTENT=${!VAR_CONTENT}"
				if [ "${!VAR_CONTENT}" == "1" ] ; then
					log 2 "${FUNCNAME[0]}: Caseno for ${DIR}${FILE} is ${CASENO}"
					eval "unset ${FILE_VAR}"
					(handle_file "${FILE}" "${CASENO}") &
				fi
				;;
			"ATTRIB")
        eval "${FILE_VAR}='1'"
				;;
			"MOVED_TO")
				log 2 "${FUNCNAME[0]}: Caseno for ${DIR}${FILE} is ${CASENO}"
        eval "unset ${FILE_VAR}"
				(handle_file "${FILE}" "${CASENO}") &
				;;
			*)
        eval "unset ${FILE_VAR}"
				;;
		esac 
	fi
done
