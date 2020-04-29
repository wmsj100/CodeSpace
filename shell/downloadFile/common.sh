#! /bin/bash
#
# common.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
#

source $DownloadFilePath/config
source $DownloadFileConfPath
source $DownloadFilePath/showLog.sh

expectShell(){
expect <<EOF
	set timeout 3000
	spawn $@
	expect {
		"yes/no" { send "yes\n";exp_continue }
		"password" { send "$PASSWD\n" }
	}
	expect eof
	catch wait result
	exit [lindex \$result 3]
EOF
}

# check expect result code
checkExpectResultCode(){
	if [ $? -ne 0 ];then
		showError "$URL address is error, please check!!!"
		exit 1
	fi
}

# check command is exist
checkCmd(){
	command -v $1 &>/dev/null
	if [ $? -eq 0 ];then
		return 0
	else
		return 1
	fi
}

# check file or dir exist
checkExist(){
	local target=$1
	local type=$2

	if [ -z "$target" ];then
		showError "Param is emtpy, please input param"
		exit 1
	fi

	target=$(realpath $1)

	if [ ! -e "$target" ];then
		showError "$target is not exist,please check!!!"
		exit 1
	fi

	if [ -n "$type" ];then
		if [ "$type" = "dir" ];then
			if [ ! -d "$target" ];then
				showError "$target is not a dir, please check!!!"
				exit 1
			fi
		fi
	fi
}

# check function is defined
checkFuncName(){
	local func=$1

	if [ -z "$func" ];then
		showError "Please input function name!!!"
		exit 1
	fi

	if [ $(type -t "$func") = "function" ];then
		return 0
	else
		showError "$func is not defined, Please check!!!"
		exit 1
	fi
}

# update downloadFile
pullDownloadFile(){
	local tmpDir=$(mktemp -d)
	local remoteInfo=root@${StandHost}
	expectShell "scp $remoteInfo:/root/downloadFile.tar.gz $tmpDir"
	checkExpectResultCode
	rm -f /usr/local/bin/downloadFile
	rm -f /usr/local/bin/checkSo
	rm -rf $DownloadFilePath
	tar -xf $tmpDir/downloadFile.tar.gz -C $(dirname $DownloadFilePath)
	ln -s $DownloadFilePath/downloadFile.sh /usr/local/bin/downloadFile
	ln -s $DownloadFilePath/checkSo.sh /usr/local/bin/checkSo
	rm -rf $tmpDir
	showOK "downloadFile update success!!!"
}

# push downloadFile to remote host 139.9.135.47
# just use for developer,Please think more
pushDownloadFile(){
	local remoteInfo=root@${StandHost}
	local tmpDir=$(mktemp -d)
	showPrint "This will force cover remote host file use local host"
	tar -zcf $tmpDir/downloadFile.tar.gz -C $(dirname $DownloadFilePath) $(basename $DownloadFilePath)
	expectShell "scp $tmpDir/downloadFile.tar.gz $remoteInfo:/root/" 
	checkExpectResultCode
	rm -rf $tmpDir
	showOK "Push downloadFile ok!!!"
}
