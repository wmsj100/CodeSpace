#! /bin/bash
#
# compareFileOrDir.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
# 主要用于分析对比俩个jar包或者目录的不同，并输出打印日志

source $DownloadFilePath/unpackFile.sh

compareInit(){
	checkExist $2
	checkExist $3
	local packFile1=$(realpath $2)
	local packFile2=$(realpath $3)
	local packDir1=${CheckSoTmpPath}/one
	local packDir2=${CheckSoTmpPath}/two
	local logFile=$CheckSoTmpPath/soResult.log

	rm -rf $CheckSoTmpPath
	mkdir -p $packDir1 $packDir2
	cp -rf $packFile1 $packDir1
	cp -rf $packFile2 $packDir2
	touch $logFile
	showPrint "Starting unzip $packFile1,Please wait!!!"
	getPackFileFromDir $packDir1 "all"
	showPrint "Starting unzip $packFile2,Please wait!!!"
	getPackFileFromDir $packDir2 "all"
	showPrint "Starting search $packDir1 $packDir2,Please wait!!!"
	compareEachFile $packDir1 $packDir2/$(basename $packFile2) $logFile
	compareEachFile $packDir2 $packDir1/$(basename $packFile1) $logFile
	showOK "Compare log file $logFile"
}

compareEachFile(){
	local packDir1=$1
	local packDir2=$2
	local logFile=$3
	local file=""
	local compareFile=""
	
	for file in $(find $packDir1 -type f)
	do
		compareFile=${packDir2}/$(echo $file | cut -d '/' -f 7-)
		diff $file $compareFile &>/dev/null

		if [ $? -ne 0 ];then
			showError "$file"
			echo "$file <==> $compareFile" >> $logFile
		fi
	done
}

init $@
