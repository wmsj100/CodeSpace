#! /bin/bash
#
# showLog.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
#

# show success echo
showOK(){
	echo -e "\033[32m[SUCCESS] $@ \033[0m"
}

# show error echo
showError(){
	echo -e "\033[31m[ERROR] $@ \033[0m"
}

# show error echo
showPrint(){
	echo -e "\033[34m[INFO] $@ \033[0m"
}

showHelpInfo(){
	local type=$1

	if [ "$type" = "checkSo" ];then
		showPrint "checkSo command info:"
	elif [ "$type" = "compareFile" ];then
		showPrint "compareFile command info:"
	elif [ "$type" = "downloadFile" ];then
		showPrint "downloadFile command info:"
		showPrint "# get tar file to current dir"
		showOK "downloadFile . https://xxx.xxx.tar.gz"
		showPrint "# get tar file to other dir"
		showOK "downloadFile /tmp/aa/bb https://xxx.xxx.tar.gz"
		showPrint "# get git project and compress to project_name.tar.gz to current dir"
		showOK "downloadFile . git clone https://xxx.xxx.git"
		showPrint "# access into interaction shell"
		showPrint "# you should input address for file or git project and download dir"
		showPrint "# default download dir is current dir,you can press 'Enter' key"
		showOK "downloadFile"
		showPrint "# update downloadFile shell"
		showOK "downloadFile update"
		showPrint "# show version of shell"
		showOK "downloadFile version"
	else
		showError "$type is valid, please input downloadFile/checkSo"
		exit 1
	fi
}
