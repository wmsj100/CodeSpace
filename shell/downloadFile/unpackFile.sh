#! /bin/bash
#
# unpackFile.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
# 解压包

# judge file is target for checkSo

# unpack jar type, 
# so: just unpack so
# all: unpack all file
UnpackJarType="so"
OriginPackFileName="" # just storage packFile name like jline.tar.gz
CurrentPackFileName="" # just storage current packFile Name jlien.tar
OriginPackType="" # origin pack type like gz bz2

getPackFileDetail(){
	local filePath=$1
	local result=""
	result=$(checkPackFileType $filePath "detail")
	echo $result
}

checkPackFileType(){
	local filePath=$1
	local type=$2
	local fileType=$(file $filePath | awk -F ' ' '{print $2}')
	local result="error"

	echo $fileType | grep -w -E "^gzip|XZ|POSIX|bzip2$" &>/dev/null
	if [ $? -eq 0 ];then
		if [ "$fileType" = "POSIX" ];then
			fileType=$(file $filePath | awk -F ' ' '{print $3}')
			if [ "$fileType" = "tar" ];then
				result="tar"
			fi
		else
			result="tar"
		fi
	elif [ "$fileType" = "Zip" ];then
		result="Zip"
	elif [ "$fileType" = "RPM" ];then
		result="RPM"
	fi

	if [ -z "$type" ];then
		echo "$result"
	else
		echo "$result|$fileType"
	fi
}

# unzip file
unzipFileToDir(){
	local unzipType=$1
	local filePath=$2
	local unzipPath=$3
	local curPath=$(pwd)
	local suffix=${filePath##*.}

	[ -z "$unzipPath" ] && unzipPath=${filePath}-unpack
	mkdir -p $unzipPath

	if [ "$unzipType" = "tar" ];then
		showPrint "Unpack $filePath"
		tar -xf $filePath -C $unzipPath 2>/dev/null
		rm -f $filePath # unzip file and delete zip file
		mv $unzipPath $filePath
		getPackFileFromDir $filePath
	elif [ "$unzipType" = "Zip" ];then
		showPrint "Unpack $filePath"
		if [ "$suffix" = "jar" -a "$UnpackJarType" = "so" ];then
			unzip -oq -d $unzipPath $filePath *.so 2>/dev/null
		else
			unzip -oq -d $unzipPath $filePath 2>/dev/null
		fi
		rm -f $filePath
		mv $unzipPath $filePath
		getPackFileFromDir $filePath
	elif [ "$unzipType" = "RPM" ];then
		showPrint "Unpack $filePath"
		cd $unzipPath
		rpm2cpio $filePath | cpio -idm 2>/dev/null
		cd $curPath
		rm -f $filePath
		mv $unzipPath $filePath
		getPackFileFromDir $filePath
	elif [ -z "$unzipType" ];then
		showError "Please input param like tar/zip/rpm"
		exit 1
	else
		showPrint "$filePath don't need check"
	fi
}

# check file type and try unpackFile
checkSufixAndUnPackFile(){
	local targetPath=$1
	local fileType=""

	fileType=$(checkPackFileType "$targetPath")
	if [ "$fileType" != "error" ];then
		unzipFileToDir "$fileType" $targetPath
	fi
}

getPackFileFromDir(){
	local targetPath=$1
	local file=""
	local fileList=""
	local fileType=""
	[ -n "$2" ] && UnpackJarType=$2 

	if [ -f "$targetPath" ];then
		checkSufixAndUnPackFile $targetPath
	elif [ -d "$targetPath" ];then
		fileList=$(find $targetPath -type f | egrep -wv "\.($SkipDotDir)" | egrep -v "\.($SkipDotSuffix)$" | egrep -v "(${SkipSuffix})$")
		if [ -n "$fileList" ];then
			if [ $(echo $fileList | awk '{print NF}') -eq 1 ];then
				checkSufixAndUnPackFile $fileList
			else
				for file in $fileList
				do
					checkSufixAndUnPackFile $file
				done
			fi
		fi
	fi
}

# get dir from packFile
getUnpackDir(){
	local type=$1
	local filePath=$2
	local packDir=""

	if [ "$type" = "tar" ];then
		packDir=$(tar -tf $filePath | head -n 1)
	elif [ "$type" = "Zip" ];then
		packDir=$(unzip -l $filePath | head -n 10  | tail -n 1 | awk -F ' ' '{print $NF}' | awk -F '/' '{print $1}')
	fi
	echo "$packDir"
}

# try compress file
unpackDownloadFile(){
	local filePath=$1
	local curdir=${filePath%/*}
	local file=${filePath##*/}
	local suffix=${file##*.}
	local fileType=$(file $CURDIR/$File | awk -F ' ' '{print $2}')
	local fileDir=""

	# filter jar file
	if [ "$suffix" = "jar" ];then
		showPrint "Current download file $file is jar"
		exit 0
	fi

	echo $fileType | grep -w -E "^gzip|XZ|POSIX|bzip2$" &>/dev/null
	if [ $? -eq 0 ];then
		fileDir=$(tar -tf $file | head -n 1)
		tar -xf $file -C $curdir
		showOK "Target dir $curdir/$fileDir unzip ok!!!"
	elif [ "$fileType" = "Zip" ];then
		fileDir=$(unzip -l $file | head -n 10  | tail -n 1 | awk -F ' ' '{print $NF}' | awk -F '/' '{print $1}')
		unzip -oq -d $curdir $file
		showOK "Target dir $curdir/$fileDir unzip ok!!!"
	else
		showPrint "$file can't unzip please check"
	fi
}

# repack file
repackFile(){
	local fileType=$1
	local filePath=$2
	local soTargetPath=$3
	local packTool=$(echo $fileType | awk -F '|' '{print $1}')
	local packType=$(echo $fileType | awk -F '|' '{print $NF}')

	if [ $# -ne 3 ];then
		showError "repackFile: Please check params"
		exit 1
	fi

	if [ "$packTool" = "Zip" ];then
		zip -f $filePath $soTargetPath 
		if [ $? -eq 0 ];then
			showOK "$CheckSoTmpOriginPath/$filePath is OK!!!"
		else
			showPrint "$CheckSoTmpOriginPath/$filePath is don't need replace"
		fi
	elif [ "$packTool" = "tar" ];then
		if [ "$packType" = "gzip" ];then
			gzip -d $filePath
			if [ $? -eq 0 ];then
				CurrentPackFileName=${filePath%.*}
				OriginPackType="$packType"
				repackFile "${packTool}|tar" $CurrentPackFileName $soZipPath
			else
				showError "gzip -d $filePath error"
			fi
		elif [ "$packType" = "bzip2" ];then
			bzip2 -d $filePath
			if [ $? -eq 0 ];then
				CurrentPackFileName=${filePath%.*}
				OriginPackType="$packType"
				repackFile "${packTool}|tar" $CurrentPackFileName $soZipPath
			else
				showError "bzip2 -d $filePath error"
			fi
		elif [ "$packType" = "tar" ];then
			tar -uf $filePath $soTargetPath
			if [ $? -eq 0 ];then
				showOK "$filePath update $soTargetPath OK"
			else
				showError "$filePath update $soTargetPath error"
			fi

		fi

	fi
}

# restore pack file name jline.tar jline.tar.gz
restorePackFile(){
	if [ "$CurrentPackFileName" != "$OriginPackFileName" ];then
		if [ "$OriginPackType" = "bzip2" ];then
			bzip2 "$CurrentPackFileName"
		elif [ "$OriginPackType" = "gzip" ];then
			gzip "$CurrentPackFileName"
		else
			showPrint "$CurrentPackFileName $OriginPackFileName $OriginPackType"
		fi
	fi
}
