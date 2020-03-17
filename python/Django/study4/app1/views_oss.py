#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 ubuntu <ubuntu@VM-0-13-ubuntu>
#
# Distributed under terms of the MIT license.

"""
查询接口返回oss的oss://wmsjtest/str/a数据
"""
from .class_Bucket import Bucket
import oss2

class GetOSS(Bucket):
    def __init__(self,bucket_name='wmsj100test', config_path=''):
        super().__init__(bucket_name, config_path)
        self.list = self.__get_oss_list()

    def __get_oss_list(self):
        result = set()
        for item in oss2.ObjectIterator(self.bucket):
            result.add(item.key)
        return result


