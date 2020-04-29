#! /bin/bash
#
# checkSo.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
# 用于分析目标是否有非aarch64架构的动态库或二进制文件

DefaultPlatform="AArch64" # target compile platform is aarch64
JarLogName="JarResult.log"
OutLogName="out.csv"
NonJarLogName="NonJarResult.log"
DownloadFileConfPath=/etc/downloadFile.conf
if [ ! -f "$DownloadFileConfPath" ];then
	echo "$DownloadFileConfPath is not exist, please check !!!"
	exit 1
fi
source $DownloadFileConfPath
if [ -z "$DownloadFilePath" ];then
	echo "check $DownloadFileConfPath, DownloadFilePath is not config or empty, check!!!"
	exit 1
fi
source $DownloadFilePath/common.sh
source $DownloadFilePath/unpackFile.sh
source $DownloadFilePath/comparePackFile.sh

# create checkSo dir,use checkSo code to analysis target
checkSoPull(){
	checkExist $1 dir
	local targetPath=$(realpath $1)
	local checkSoZipPath=$targetPath/checkSo.zip
	local checkSoPath=${checkSoZipPath%.*}

	expectShell "scp ${StandHost}:/root/checkSo.zip $targetPath"
	checkExpectResultCode
	unzip -oq -d $targetPath $checkSoZipPath
	rm -f $checkSoZipPath
	showOK "$checkSoPath already ok!!!"
	checkExecute $checkSoPath
	sed -i "s|^CheckSoGlobalPath=.*|CheckSoGlobalPath=${checkSoPath}|g" $DownloadFileConfPath
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

# analysis tar/jar/rpm
checkSoNewAnalysis(){
	checkExist $1
	local targetPath=$(realpath $1)
	local soResult=${CheckSoTmpPath}/soResult.log
	rm -rf $CheckSoTmpPath
	mkdir -p $CheckSoTmpPath
	cp -rf $targetPath $CheckSoTmpPath # copy file to tmp
	showPrint "Starting analysis $targetPath,Please wait!!!"
	getPackFileFromDir $CheckSoTmpPath
	showPrint "Starting search dynamic lib $targetPath,Please wait!!!"
	searchSoFromDir $CheckSoTmpPath
	if [ -f "$soResult" ];then
		cp $soResult ${targetPath}.log
		showOK "${targetPath}.log Please check!!!"
	else
		showOK "$targetPath is OK XD!!!"
	fi
	analysisSoLog $targetPath
}

searchSoFromDir(){
	local targetPath=$1
	local file=""
	local fileList=""
	local fileType=""

	fileList=$(find $targetPath -type f | egrep -wv "\.($SkipDotDir)" | egrep -v "\.($SkipDotSuffix)$" | egrep -v "(${SkipSuffix})$")

	if [ -n "$fileList" ];then
		for file in $fileList
		do

			fileType=$(file $file | awk -F ' ' '{print $2}')
			if [ "$fileType" = "ELF" ];then
				checkSoFile $file
			fi
		done
	fi
}

# check file is aarch64
checkSoFile(){
	local filePath=$1
	local machine=$(readelf -h $filePath | grep -w Machine | awk -F ' ' '{print $NF}')
	local soName=""
	local soType=""
	echo $machine | grep -iw "$DefaultPlatform" &>/dev/null
	if [ $? -ne 0 ];then
		soName=$(readelf -d $filePath | grep -w "SONAME" | awk '{print $NF}' | grep -o "[a-zA-Z0-9.-]*")
		soType=$(readelf -h $filePath | grep -w "Class" | awk '{print $NF}')
		showError "${filePath} $machine $soName $soType"  
		echo "$filePath $machine $soName $soType" >> $CheckSoTmpPath/soResult.log
	fi
}

# analysis soResult.log and try replace file
analysisSoLog(){
	set -x
	if [ -f $CheckSoTmpPath/soResult.log ];then
		local filePath=""
		local soName=""
		local soType=""
		local targetPath=$1
		local fileName=$(basename $targetPath)
		OriginPackFileName=$fileName
		CurrentPackFileName=$fileName

		mkdir -p $CheckSoTmpOriginPath
		cp -a $targetPath $CheckSoTmpOriginPath

		while read line 
		do
			[ -z "$line" ] && continue
			filePath=$(echo $line | awk -F ' ' '{print $1}')
			soName=$(echo $line | awk -F ' ' '{print $(NF-1)}')
			soType=$(echo $line | awk -F ' ' '{print $NF}')
			checkStorageSoExist $filePath $soName $soType $CurrentPackFileName
			
		done < $CheckSoTmpPath/soResult.log
		restorePackFile

		if [ -f $CheckSoTmpPath/soReplace.log ];then
			showError "Check error log for $CheckSoTmpPath/soReplace.log"
		else
			showOK "$CheckSoTmpOriginPath/$fileName is complete!!!"
		fi
	fi
}

# check storage so is exist
checkStorageSoExist(){
	local soPath=$1
	local soName=$2
	local soType=$3
	local fileName=$4
	local soStoragePath=""

	if [ "$soType" = "ELF32" ];then
		soType="Linux32"
	elif [ "$soType" = "ELF64" ];then
		soType="Linux64"
	else
		showError "$soPath $soName $soType is not support"
	fi

	soStoragePath=$SoStoragePath/$soType/$soName

	if [ -f "$soStoragePath" ];then
		replaceSoFromStorage $soPath $soStoragePath $fileName
	elif [ "$soType" = "Linux32" ];then
		soStoragePath=$SoStoragePath/Linux64/$soName
		if [ -f "$soStoragePath" ];then
			replaceSoFromStorage $soPath $soStoragePath $fileName
		else
			showError "$soStoragePath is not exist, please check!!!"
			echo "$soStoragePath is not exist" >> $CheckSoTmpPath/soReplace.log
		fi
	else
		showError "$soStoragePath is not exist, please check!!!"
		echo "$soStoragePath is not exist" >> $CheckSoTmpPath/soReplace.log
	fi

}

replaceSoFromStorage(){
	local soPath=$1
	local soStoragePath=$2
	local fileName=$3
	local soZipPath=$(echo $soPath | awk -F "${OriginPackFileName}/" '{print $NF}')
	local fileType=""
	
	cd $CheckSoTmpOriginPath
	fileType=$(getPackFileDetail "$fileName")
	mkdir -p $(dirname $soZipPath)
	cp $soStoragePath $soZipPath
	repackFile "$fileType" $fileName $soZipPath
}

checkSoAnalysis(){
	checkExist $1
	local targetFile=$(realpath $1)

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
		elif [ "$type" = "compare" ];then
			compareInit $@
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
