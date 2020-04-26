#! /bin/bash
#
# download.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
#

shellDir=$(pwd)
source $shellDir/common.sh

RemoteInfo=${RemoteUser}@${RemoteIP}
TMPDir="" # remoteHost tmp dir
URL="" # address for download file
CURDIR="" # download file dir
File="" # download file name
FileType="file" # params is file|git

# get file url
getURL(){
	CURDIR=$(pwd)

	while [ -z "$URL" ];do
		read -p "Input address https://XXX.tar.gz: " URL
	done

	getFileType
}

# get file suffix tar.gz|.git
getFileType(){
	File=${URL##*/}
	local suffix=${URL##*.}

	if [ "$suffix" = "git" ];then
		FileType=git
	elif [ "$suffix" = "svn" ];then
		FileType=svn
	elif [ -n "$suffix" ];then
		FileType=file
	else
		showError "$URL address is not a file or git, please check!!!"
		exit 1
	fi
}

# get download path
getDir(){
	tmp=""
	read -p "Default download path $CURDIR (Y/n) " tmp

	case "$tmp" in
		n*|N*) 
			tmp=""
			while [ -d $(realpath "$tmp" &>/dev/null) ];do
				read -p "Please input download path " tmp
			done
			CURDIR="$(realpath $tmp)"
			;;
		*)
			CURDIR=$(pwd)
	esac
}

remoteCMD(){
	if [ "$FileType" = "file" ];then
		showPrint "Waiting to download $TMPDir/$File"
		expectShell "ssh $RemoteInfo \"mkdir -p $TMPDir;wget -nv $URL -O $TMPDir/$File\""
		checkExpectResultCode
		expectShell "scp $RemoteInfo:$TMPDir/$File $CURDIR"
		expectShell "ssh $RemoteInfo rm -rf $TMPDir"
	elif [ "$FileType" = "git" ];then
		remoteGitCmd
	elif [ "$FileType" = "svn" ];then
		remoteSvnCmd
	else
		showError "FileType must is file|git|svn"
		exit 1
	fi
}

# svn clone
remoteSvnCmd(){
	showError "svn not support, if need, please tell me!!!"
	exit 1
}

# check expect result code
checkExpectResultCode(){
	if [ $? -ne 0 ];then
		showError "$URL address is error, please check!!!"
		exit 1
	fi
}

# remote protocol is git
remoteGitCmd(){
	File=${File%.*}
	local tarFile=${File}.tar.gz
	expectShell "ssh $RemoteInfo \"mkdir -p $TMPDir/$File;git clone $URL $TMPDir/$File\""
	checkExpectResultCode
	expectShell "ssh $RemoteInfo \"cd $TMPDir;tar -zcf $tarFile $File\""
	expectShell "scp $RemoteInfo:$TMPDir/$tarFile $CURDIR"
	expectShell "ssh $RemoteInfo rm -rf $TMPDir"
	File=$tarFile
}


# environment prepare
envPre(){
	local CMD=""
	# 判断包管理器工具,可以自己随意添加
	TMPDir=$(mktemp -u)

	checkCmd yum && CMD="yum"
	checkCmd apt && CMD="apt"

	if [ -z "$CMD" ];then
		showError "You pkg manager is not support"
		exit 1
	fi

	# 判断当前登录用户
	if [ $(whoami) != "root" ];then
		CMD="sudo $CMD"
	fi

	showPrint "Checking relay software..."
	checkCmd ssh || $CMD install -q -y openssh-clients
	checkCmd expect || $CMD install -q -y expect
	checkCmd file || $CMD install -q -y file
	checkCmd unzip || $CMD install -q -y unzip
	checkCmd bzip2 || $CMD install -q -y bzip2
	checkCmd gzip || $CMD install -q -y gzip
	checkCmd xz || $CMD install -q -y xz
	checkCmd cpio || $CMD install -q -y cpio
	checkCmd rpm2cpio || $CMD install -q -y rpm2cpio
}

# print env
printEnv(){
	showPrint $URL
	showPrint $File
	showPrint $CURDIR
}

# cur host cmd like clean tmp file
curHostCMD(){
	showOK "$CURDIR/$File download complete!!!"

	# try unzip file
	if [ "$SwitchZip" = "True" ];then
		showPrint "Try to unzip $File"
		compressFile $CURDIR/$File
	fi
}

# direct use,just use like downloadFile xxx.tar.gz .
judgeDealType(){
	if [ "$#" -lt 2 ];then
		showError "Please input params like downloadFile /tmp xxx.tar.gz"
		exit 1
	fi

	CURDIR=$(realpath $1)
	URL=$2

	if [ ! -d "$CURDIR" ];then
		showError "Your current Path is $CURDIR,Please inpur correct path for download file"
		exit 1
	fi

	getFileType
	automaticCmd
}

# interaction type,need input address and download path
interactionShell(){
	getURL
	getDir
	printEnv
#	automaticCmd
}

automaticCmd(){
	#printEnv
	envPre
	remoteCMD 
	curHostCMD
}


# check shell exec
checkExecute(){
	local path=$1
	local curShell=""

	if [ -z "$path" ];then
		showError "Please check checkExecute params"
		exit 1
	fi

	for curShell in $(find $path -maxdepth 1 -type f -name "*.sh");do
		if [ ! -x "$curShell" ];then
			showPrint "$curShell is not executable,already modify it!"
			chmod +x "$curShell"
		fi
	done
}

init(){
	if [ "$#" -gt 0 ];then
		# if param is update
		if [ "$1" = "update" ];then
			pullDownloadFile
		elif [ "$1" = "pull" ];then
			pullDownloadFile
		elif [ "$1" = "help" ];then
			showHelpInfo "downloadFile"
		elif [ "$1" = "push" ];then
			pushDownloadFile
		else
			judgeDealType $@
		fi
	else
		interactionShell
	fi
}

init $@
