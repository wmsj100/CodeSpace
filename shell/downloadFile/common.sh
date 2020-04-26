#! /bin/bash
#
# common.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
#

shellDir=$(pwd)
source $shellDir/config
source $shellDir/showLog.sh

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
	local target=$(realpath $1)

	if [ ! -e "$target" ];then
		showError "$target is not exist,please check!!!"
		exit 1
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
	local remoteInfo=root@${StandHost}
	expectShell "scp $remoteInfo:/usr/local/bin/downloadFile /usr/local/bin/"
	showOK "downloadFile update success!!!"
}

# push downloadFile to remote host 139.9.135.47
# just use for developer,Please think more
pushDownloadFile(){
	local remoteInfo=root@${StandHost}
	showPrint "This will force cover remote host file use local host"
	expectShell "scp /usr/local/bin/downloadFile $remoteInfo:/usr/local/bin/downloadFile" 
	checkExpectResultCode
	showOK "Push downloadFile ok!!!"
}
