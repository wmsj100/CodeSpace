#! /bin/bash
#
# checkSo.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
# 用于分析目标是否有非aarch64架构的动态库或二进制文件


# modify shell absolute path
createCheckSoShell(){
	local checkSoFile=/usr/local/bin/checkSo
	echo -E "#!/bin/bash
downloadFile checkSoAnalysis \$@
" >"$checkSoFile"

	if [ ! -x "$checkSoFile" ];then
		chmod +x "$checkSoFile"
	fi
}

# create checkSo dir,use checkSo code to analysis target
checkSoPull(){
	local targetPath=$(realpath $1)
	local checkSoZipPath=$targetPath/checkSo.zip
	local checkSoPath=${checkSoZipPath%.*}
	checkExist $targetPath

	expectShell "scp ${StandHost}:/root/checkSo.zip $targetPath"
	checkExpectResultCode
	unzip -oq -d $targetPath $checkSoZipPath
	rm -f $checkSoZipPath
	showOK "$checkSoPath already ok!!!"
	checkExecute $checkSoPath
	createCheckSoShell $checkSoPath
	sed -i "s|^CheckSoGlobalPath=.*|CheckSoGlobalPath=${checkSoPath}|g" /usr/local/bin/downloadFile
}

# analysis tar/jar/rpm
checkSoNewAnalysis(){
	local targetPath=$(realpath $1)
	local soResult=${CheckSoTmpPath}/soResult.log
	checkExist $targetPath
	rm -rf $CheckSoTmpPath
	mkdir -p $CheckSoTmpPath
	cp -rf $targetPath $CheckSoTmpPath # copy file to tmp
	showPrint "Starting analysis $targetPath,Please wait!!!"
	checkTargetFileFromTmp $CheckSoTmpPath
	if [ -f "$soResult" ];then
		cp $soResult ${targetPath}.log
		showOK "${targetPath}.log Please check!!!"
	else
		showOK "$targetPath is OK XD!!!"
	fi
}


# check file is aarch64
checkSoFile(){
	local filePath=$1
	local machine=$(readelf -h $filePath | grep -w Machine | awk -F ' ' '{print $NF}')
	echo $machine | grep -iw "$DefaultPlatform" &>/dev/null
	if [ $? -ne 0 ];then
		showError "${filePath} is $machine"  
		echo "$filePath ==> $machine" >> $CheckSoTmpPath/soResult.log
	fi
}

# copy dir or file to temp
checkTargetFileFromTmp(){
	local targetPath=$1
	local file=""
	local fileList=""
	local skipDotDir="git|github|svn"
	local skipDotSuffix="py|PY|pyc|pyw|derived|decTest|ht|sh|txt|whl|yml|xml|png|gif|jgp|jpeg|svg|woff|woff2|json|ico|pem|log|java|html|css|js|ts|bat|exe|c|md|doc|egg-info|class|jsp|properties|MF"
	local skipSuffix="NOTICE|LICENSE|DEPENDENCIES|README"

	if [ -f "$targetPath" ];then
#		echo "scan $targetPath"
		judgeFileForCheckSo $targetPath
	elif [ -d "$targetPath" ];then
		fileList=$(find $targetPath -type f | egrep -wv "\.($skipDotDir)" | egrep -v "\.($skipDotSuffix)$" | egrep -v "(${skipSuffix})$")
		if [ -n "$fileList" ];then
			for file in $fileList
			do
				checkTargetFileFromTmp $file
			done
		fi
	fi
}

checkSoAnalysis(){
	local targetFile=$(realpath $1)
	checkExist $targetFile

	if [ ! -d "$CheckSoGlobalPath" ];then
		showError "$CheckSoGlobalPath is not exist, Please check"
		exit 1
	fi

	cd $CheckSoGlobalPath

	for file in $JarLogName $OutLogName $NonJarLogName
	do
		echo "" > $file
	done

	./main.sh $targetFile
	checkSoLog $targetFile
}

checkSoLog(){
	local targetFile=$1
	local targetDir=${targetFile%/*}
	local log=${targetFile}.log
	local nonJarLog=""
	local outLog=""
	local jarLog=""

	[ -f "$log" ] && rm "$log"
	cd $CheckSoGlobalPath

	nonJarLog=$(cat $NonJarLogName | grep -Ev "^$|UTC|CST|2020$" 2>/dev/null)
	if [ -n "$nonJarLog" ];then
		echo -E "$CheckSoGlobalPath/$NonJarLogName ==> $nonJarLog" >> $log
		showError "$nonJarLog Check $CheckSoGlobalPath/$NonJarLogName"
	fi

	outLog=$(cat $OutLogName | grep -Ev "^$" 2>/dev/null)
	if [ -n "$outLog" ];then
		echo -E "$CheckSoGlobalPath/$OutLogName ==> $outLog" >> $log
		showError "$outLog Check $CheckSoGlobalPath/$OutLogName"
	fi

	jarLog=$(cat $JarLogName | grep -Ev "^$" 2>/dev/null)
	if [ -n "$jarLog" ];then
		echo -E "$CheckSoGlobalPath/$JarLogName ==> $jarLog" >> $log
		showError "$jarLog Check $CheckSoGlobalPath/$JarLogName"
	fi

	if [ -f "$log" ];then
		showPrint "Detail log $log"
	else
		showOK "$targetFile is OK XD!!!"
	fi
}


init(){
	if [ "$#" -gt 0 ];then
		local type=$1
		# if param is update
		if [ -f "$type" -o -d "$type" ];then
			checkSoNewAnalysis $type
		elif [ "$type" = "update" ];then
			pullDownloadFile
		elif [ "$type" = "help" ];then
			showHelpInfo "checkSo"
		elif [ "$type" = "pull" ];then
			checkSoPull $2
		elif [ "$type" = "scan" ];then
			checkSoAnalysis $2
		elif [ "$type" = "newScan" ];then
			checkSoNewAnalysis $2
		else
			showError "Param error, please input update/help/pull/scan/newScan..."
			exit 1
		fi
	else
		showError "$0 need file or dir to analysis!!!"
		exit 1
	fi
}

init $@
