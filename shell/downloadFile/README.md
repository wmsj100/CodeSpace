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

- bug: 待修复，如果下载网址错误导致临时目录没有清理
- add: 添加compareFile，用于比对俩个文件的区别

## 更新日志

### version: v1.1.7

- 拆分downloadFile项目

### version: v1.1.6 

- update: 添加黑名单过滤机制

### version: v1.1.5

- update: 修改文件遍历从for修改为find

### version: v1.1.4

- bug: 修改来block和pipe文件的报错，添加对于目录的判断

### version: v1.1.3

- add: 新增对于日志文件的分析和界面呈现

### version: v1.1.2

- show: 会在界面打印关于目标的信息，也会在当前目录生成一个目标文件的log xxx.jar.log
- add: checkSoNewAnalysis xxx.jar 真正执行分析的调用，checkSo脚本也是调用这个方法实现分析
- use: downloadFile checkSoNew ,该动作生成checkSo文件后，可以执行 checkSo xxx.jar来分析
- add: checkSoNew 在/usr/local/bin目录生成checkSo脚本，具体调用执行的分析动作
- brief: 新增checkSoNew,checkSoNewAnalysis调用脚本自己的代码来分析目标文件是否包含非aarch64的文件

### version: v1.1.1

- add: 添加push方法，只对开发维护人员

### version: v1.1.0

- update: 重构关于checkSo的功能，优化checkSo分析结果界面打印，并给出文件路径

### version: v1.0.9

- update: 优化脚本参数输入判断，取消参数数量限制，只识别目标参数是否存在，默认第一个参数为下载路径

### version: v1.0.8 

- delete: checkSoInit功能整合到checkSoPull
- update: checkSoCreate 改名为checkSoPull

### version: v1.0.7

- use: downloadFile checkSoCreate . #用于在当前目录创建checkSo，拉取139.9.135.47主机/root/checkSo.zip
- add: 新增checkSoCreate方法，用于在任意目录创建checkSo目录，并且更新/usr/local/bin/checkSo指向链接

### version: v1.0.6

- use: checkSo ./jython-3.14.jar 在任意目标执行该方法即可，不需要先切换到checkSo所在目录在执行./main.sh /root/xxx.jython.jar
- add: 在/usr/local/bin目录生成可执行文件checkSo
- add: 新增checkSoInit方法，去checkSo目录给脚本添加可执行权限

### version: v1.0.5

- update: 优化界面警告信息

### version: v1.0.4

- update: 合并远程操作，减少交互次数，缩短下载时间

### version: v1.0.3

- update: 优化下载文件的界面打印，只保留关键信息

### version: v1.0.2

- update: 统一tar包和git库的下载方式，统一使用 downloadFile xxx.tar.gz/xxx.git

### version: v1.0.1

- bug: 修复文件下载错误回传空包的问题,如果网址不存在，直接返回错误

### version: v1.0.0

- update: 优化软件判断，减少界面输出

### version: v0.9

- param: True 开启自动解压缩，尝试识别压缩格式并自动去解压缩
- param: False 关闭自动解压缩，默认值
- add: 回传文件新增解压缩开关SwitchZip

### version: v0.8

- bug: 修复对于软件包管理器的判断逻辑
- bug: 修复downloadFile version/update生成临时文件

### version: v0.7

- add: 优化打印信息，添加颜色打印

### version: v0.6

- bug: 修复当前docker没有安装which时的报错问题

### version: v0.5

- 使用: downloadFile help
- 3. 新增帮助信息
- 使用: downloadFile version
- 2. 新增版本打印功能
- 使用: downloadFile update
- 1. 新增脚本升级功能，指定使用139.9.135.47主机的脚本为升级源

### version: v0.4

- 范例: downloadFile . git clone https://github.com/wmsj100/study_shell.git (在当前目录会下载文件study_shell.tar.gz)
- # 如果是git协议下载,必须是https方式,如果是ssh方式因为涉及到上传公钥会导致下载失败,可以切换为https
- parma2: 文件地址(https://xxx.xxx.tar.gz) 或者类似git clone https://github.com/vim/vim.git  
- param1: 文件下载路径(. 当前路径,获取其他自定义目录)
- 参数: 俩个参数
- 直接脚本直接调用和交互式切换,如果有传参,则直接调用,没有传参,则进入交互式

### version: v0.3

- 如果是以git方式下载,会增加压缩,回传的是在指定目录下的压缩包文件,缩短回传时间
- 支持的下载文件从之前固定的文件地址增加到类似git clone https://github.com/vim/vim.git  这种方式
- 香港主机的临时下载目录从固定的/tmp到/tmp的随机目录,防止文件冲突

### version: v0.2

- 脚本修改为交互式，直接执行命令进入交换界面
- 文件默认下载到当前执行目录
- 当前脚本会依赖ssh/scp expect
- 脚本需要通过yum|apt下载软件，所以先自行update本地数据库
