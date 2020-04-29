# README

## Description

- 脚本主要功能是download file and checkSo jar

## API

### down load file

- `downloadFile update` 从主机端升级脚本
- `downloadFile version` 打印脚本版本号
- `downloadFile` 交互式操作文件下载
- `downloadFile /curDir https://www.xxx.xxx.tar.gz` 下载文件到本地指定目录
- `downloadFile . https://www.xxx.xxx.tar.gz` 下载文件到当前目录
- `downloadFile push` 推送当前脚本到主机，限开发维护人员使用，防止推送错误脚本覆盖主机版本
- `switchZip` 自动解压开关，默认关机，如果设置为`True`，当下载完成后会尝试解压下载文件到下载目录

### checkSo

- `downloadFile checkSoPull /opt`  拉取主机端的checkSo代码到本地/opt并解压，在/usr/local/bin目录生成`checkSo`可执行文件，
  - `checkSo xxx.jar` 调用checkSo分析目标文件，结束后在目标文件生成同名的.log日志文件方便查看结果
  - `downloadFile checkSoNew` 更新`/usr/local/bin/checkSo`,调用downloadFile的代码来分析目标文件
    - `checkSo xxx.jar` 调用downloadFile代码分析目标文件，有分析过程和结果打印，分析结束后生成目标文件.log日志文件

	- `CheckSoTmpPath` 调用downloadFile分析文件会把文件拷贝到该参数指定目录`/tmp/CheckSo-unpack`，可以在downloadFile脚本中修改

## 待解决

- add: 添加compareFile，用于比对俩个文件的区别
