#! /bin/bash
#
# compareFileOrDir.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
# 主要用于分析对比俩个jar包或者目录的不同，并输出打印日志

# compare file or dir
# origin and target must be like; example must be all file or dir, can't compare file to dir
# if file is zip, zip protocol must is equal,can't compare gzip to bzip2
compareFileOrDir(){
	if [ $# -ne 3 ];then
		showError "$0 error, you params is $@, please check"
		exit 1
	fi

	shift
	local origin=$(realpath $1)
	local target=$(realpath $2)
	local originType=$(file $origin | awk -F ' ' '{print $2}')
	local targetType=$(file $target | awk -F ' ' '{print $2}')

	if [ -f "$origin" ];then
		if [ ! -f "$target" ];then
			showError "$origin and $target type is not equal, please check!!!"
			exit 1
		else

		fi
	elif [ -d "$origin" ];then
		if [ ! -d "$target" ];then
			showError "$origin and $target type is not equal, please check!!!"
			exit 1
		fi
	fi

	if [ "$originType" != "$targetType" ];then
		showError "$origin type is $originType, $target type is $targetType, please check!!!"
		exit 1
	fi

} 

init(){
	if [ "$#" -gt 0 ];then
		# if param is update
		if [ "$1" = "update" ];then
			pullDownloadFile
		elif [ "$1" = "push" ];then
			pushDownloadFile
		elif [ "$1" = "help" ];then
			showHelpInfo "compareFile"
		elif [ "$1" = "compare" ];then
			shift
			compareFileOrDir $@
		fi
	else
		showError "$0 need file or dir to analysis!!!"
		exit 1
	fi
}

init $@
