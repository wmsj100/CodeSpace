#! /bin/bash
#
# unpackFile.sh
# Copyright (C) 2020 wanghao <wanghao054@chinasoftinc.com>
#
# Distributed under terms of the MIT license.
# 解压包


# unzip file
unzipFileToDir(){
	local unzipType=$1
	local filePath=$2
	local unzipPath="${filePath}-unpack"
	local curPath=$(pwd)
	local suffix=${filePath##*.}

	mkdir -p $unzipPath

	if [ "$unzipType" = "tar" ];then
		showPrint "Unpack $filePath"
		tar -xf $filePath -C $unzipPath 2>/dev/null
		rm -f $filePath # unzip file and delete zip file
		checkTargetFileFromTmp $unzipPath
	elif [ "$unzipType" = "Zip" ];then
		showPrint "Unpack $filePath"
		if [ "$suffix" = "jar" ];then
			unzip -oq -d $unzipPath $filePath *.so 2>/dev/null
		else
			unzip -oq -d $unzipPath $filePath 2>/dev/null
		fi
		rm -f $filePath
		checkTargetFileFromTmp $unzipPath
	elif [ "$unzipType" = "RPM" ];then
		showPrint "Unpack $filePath"
		cd $unzipPath
		rpm2cpio $filePath | cpio -idm 2>/dev/null
		cd $curPath
		rm -f $filePath
		checkTargetFileFromTmp $unzipPath
	elif [ -z "$unzipType" ];then
		showError "Please input param like tar/zip/rpm"
		exit 1
	else
		showPrint "$filePath don't need check"
	fi
}

# judge file is target for checkSo
judgeFileForCheckSo(){
	local filePath=$1
	local fileType=$(file $filePath | awk -F ' ' '{print $2}')
	local suffix=${filePath##*.}

	echo $fileType | grep -w -E "^gzip|XZ|POSIX|bzip2$" &>/dev/null
	if [ $? -eq 0 ];then
		if [ "$fileType" = "POSIX" ];then
			fileType=$(file $filePath | awk -F ' ' '{print $3}')
			if [ "$fileType" = "tar" ];then
				unzipFileToDir "tar" $filePath
			fi
		else
			unzipFileToDir "tar" $filePath
		fi
	elif [ "$fileType" = "Zip" ];then
		unzipFileToDir "Zip" $filePath
	elif [ "$fileType" = "RPM" ];then
		unzipFileToDir "RPM" $filePath
	elif [ "$fileType" = "ELF" ];then
		checkSoFile $filePath
	fi
}

# try compress file
compressFile(){
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
