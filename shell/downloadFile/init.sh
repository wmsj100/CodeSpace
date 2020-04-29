#! /bin/bash
#
# init.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
# 第一次执行初始化操作

CurDir=$(pwd)

if [ ! -f $CurDir/showLog.sh ];then
	echo "$CurDir is error, please access downloadFile path"
	exit 1
fi
source $CurDir/showLog.sh

init(){
	local targetPath=$1

	if [ -z "$targetPath" ];then
		showError "Please input downloadFile install path"
		exit 1
	fi

	if [ ! -d "$targetPath" ];then
		showError "$targetPath is not exist, please check"
		exit 1
	fi

	targetPath=$(realpath $targetPath)

	if [ "$targetPath" = "$CurDir" ];then
		showError "Install path can't be current Path"
		exit 1
	fi

	showPrint "Start init downloadFile..."

	# clean file
	rm -f /usr/local/bin/downloadFile
	rm -f /usr/local/bin/checkSo
	rm -f /etc/downloadFile.conf
	rm -rf $targetPath/downloadFile
	# copy code to target path
	if [ ! -f $CurDir/init.sh ];then
		showError "$CurDir error, please input downloadFile path"
		exit 1
	fi
	cp -a $CurDir $targetPath
	# copy conf
	cp config /etc/downloadFile.conf
	sed -i "s|^DownloadFilePath=.*|DownloadFilePath=${targetPath}/downloadFile|g" /etc/downloadFile.conf
	# create softlink
	ln -s $targetPath/downloadFile/downloadFile.sh /usr/local/bin/downloadFile
	ln -s $targetPath/downloadFile/checkSo.sh /usr/local/bin/checkSo

	showOK "Install downloadFile success!!!"
}

init $@
