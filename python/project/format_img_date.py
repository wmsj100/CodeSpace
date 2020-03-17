import sys
import os
import json
import shutil
import time
import re

BaseDir = r'E:\我的坚果云\高露\图片\婚纱照和证件照'
TargetDir = r'E:\Code\python\360yunpan'
Separator = '-'

def confirm_dir_exist(dir_path):
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)


def forEachDir(targetDir=None):
    # 通过后缀识别有效文件
    # lumia830手机拍摄时候会生成一个动态的缓存文件，查看照片是有一个动态的效果，后缀是dng
    suffix_set = {'jpg', 'png', 'bmp', 'gif', 'jpeg', 'dng', '3gp', 'mp4'}
    target_files = set()
    all_files = set()
    abandon_files = set()
    DataObj = {}
    hou_zhui = set()

    if not targetDir:
        return False

    for path, __, files in os.walk(targetDir):
        if files:
            for file in files:
                file_path = os.path.join(path, file)
                all_files.add(file_path)
                suffix = file.split('.').pop().lower()
                hou_zhui.add(suffix)
                if suffix in suffix_set:
                    analysis_file(file_path, DataObj, target_files)
                else:
                    abandon_files.add(file_path)
            else:
                continue
    save_to_database(BaseDir, DataObj)
    print('hou zhui is', hou_zhui)
    print("image total is %d" % len(DataObj))
    print("all file is %d" % len(target_files))


def analysis_file(file_path, DataObj, target_files):
    '''# 分析并解析文件的时间'''
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        date_str = ''
        target_files.add(file_name)
        # 过滤前缀
        if re.match(r'^20[012]\d-[01]\d-[0123]\d', file_name):
            date_str = analysis_time_str(file_path, "time_reg")
        elif re.match('^20[012]\d[01]\d[0123]\d', file_name):
            date_str = analysis_time_str(file_path, '20jpg')
        elif file_name.startswith('IMG_'):
            date_str = analysis_time_str(file_path, 'IMG_')
        elif file_name.startswith('C360_'):
            date_str = Separator.join(file_name[5:15].split("-"))
        elif file_name.startswith('Camera_'):
            date_str = analysis_time_str(file_path, 'Camera_')
        elif file_name.startswith('VID_'):
            date_str = analysis_time_str(file_path, 'VID_')
        elif file_name.startswith('WP_'):
            date_str = analysis_time_str(file_path, 'WP_')
        else:
            date_str = analysis_default(file_path)
        
        # 有时间戳才解析
        if date_str:
            struct_date_dir(file_path, file_name, date_str, DataObj, target_files)

def analysis_time_str(file_path, type=''):
    '''解析图片的字符串时间戳，例如IMG_20130113_094300.jpg'''
    start=0
    date_str = ''
    file_name = os.path.basename(file_path)

    if type:
        if 'IMG_' == type or 'VID_' == type:
            start = 4
        elif 'Camera_' == type:
            start = 7
        elif 'WP_' == type:
            start = 3
        elif '20jpg' == type:
            start = 0
        elif 'time_reg' == type:
            date_str = re.match(r'^20[012]\d-[01]\d-[0123]\d', file_name).group()
            date_str = date_str.replace('-', Separator)
    else:
        start = 0

    # 判断时间戳必须全部为数字
    if not date_str:
        if file_name[start:start+8].isdigit():
            year = file_name[start:start+4]
            month = file_name[start+4:start+6]
            day = file_name[start+6:start+8]
            # 月份不大于12，day不大于31
            if int(month) <= 12 and int(day) <= 31:
                date_str = Separator.join([year, month, day])
            else:
                date_str = analysis_default(file_path)
        else:
            date_str = analysis_default(file_path)

    return date_str

def analysis_default(file_path):
    ''' 默认的处理方式'''
    file_meta = os.stat(file_path)
    date_str = time.strftime("%Y{sep}%m{sep}%d".format(sep=Separator), (time.localtime(file_meta.st_mtime)))
    
    return date_str

def struct_date_dir(file_path, file_name, date_str, DataObj, target_files):
    '''获取到时间字符串后创建目录并且复制图片'''
    print(file_name)
    dir_path = os.path.join(TargetDir, date_str[:4],date_str[:7], date_str)
    new_file_path = os.path.join(dir_path, file_name)
    DataObj[file_name] = {'old': file_path, 'new': new_file_path}
    confirm_dir_exist(dir_path)
    if not os.path.isfile(new_file_path):
        shutil.copy2(file_path, new_file_path)
    else:
        print("{file} is already exist!".format(file=new_file_path))

def save_to_database(BaseDir, save_data):
    '''存储数据到文件'''
    with open(os.path.join(TargetDir, 'database.json'), 'w') as file:
        file.write(json.dumps(save_data))


def init():
    # if os.path.exists(TargetDir):
    #     shutil.rmtree(TargetDir)
    forEachDir(BaseDir)


if __name__ == '__main__':
    init()
