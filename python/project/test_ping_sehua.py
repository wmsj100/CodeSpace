#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 ubuntu <ubuntu@VM-0-13-ubuntu>
#
# Distributed under terms of the MIT license.

"""
脚本的目的是测试是否可以访问sehua网站，并找出所有的访问网站，并且屏蔽
已经把这些网站举报了，
16020020617365000340
16020020617385300342
http://report.12377.cn:13225/queryReport2.do
"""

import os

def test_ping_web():
    total_web = set()
    enable_web = set()
    str_prefix = 'www.{}sehua.com'
    str_suffix = 'www.sehua{}.com'

    for num in range(1, 61):
        web_prefix = str_prefix.format(num)
        web_suffix = str_suffix.format(num)
        total_web.add(web_prefix)
        total_web.add(web_suffix)

        print(web_prefix)
        if not os.system('ping -c 2 {}'.format(web_prefix)):
            enable_web.add(web_prefix)

        print(web_suffix)
        if not os.system('ping -c 2 {}'.format(web_suffix)):
            enable_web.add(web_suffix)

    #print(total_web)
    print(enable_web)
    #{'www.11sehua.com', 'www.sehua13.com', 'www.sehua42.com', 'www.26sehua.com', 'www.sehua40.com', 'www.sehua21.com', 'www.30sehua.com', 'www.sehua32.com', 'www.sehua59.com', 'www.17sehua.com', 'www.sehua22.com', 'www.38sehua.com', 'www.46sehua.com', 'www.48sehua.com', 'www.57sehua.com', 'www.sehua39.com', 'www.sehua46.com', 'www.47sehua.com', 'www.sehua15.com', 'www.41sehua.com', 'www.34sehua.com', 'www.56sehua.com', 'www.37sehua.com', 'www.22sehua.com', 'www.32sehua.com', 'www.sehua33.com', 'www.21sehua.com', 'www.sehua6.com', 'www.4sehua.com', 'www.51sehua.com', 'www.sehua48.com', 'www.44sehua.com', 'www.36sehua.com', 'www.sehua31.com', 'www.sehua19.com', 'www.sehua53.com', 'www.1sehua.com', 'www.sehua7.com', 'www.49sehua.com', 'www.50sehua.com', 'www.sehua47.com', 'www.31sehua.com', 'www.sehua8.com', 'www.sehua12.com', 'www.sehua43.com', 'www.sehua51.com', 'www.27sehua.com', 'www.sehua14.com', 'www.45sehua.com', 'www.5sehua.com', 'www.2sehua.com', 'www.53sehua.com', 'www.20sehua.com', 'www.23sehua.com', 'www.12sehua.com', 'www.sehua10.com', 'www.sehua16.com', 'www.sehua27.com', 'www.6sehua.com', 'www.sehua23.com', 'www.13sehua.com', 'www.19sehua.com', 'www.sehua50.com', 'www.sehua58.com', 'www.sehua41.com', 'www.43sehua.com', 'www.14sehua.com', 'www.sehua4.com', 'www.sehua24.com', 'www.54sehua.com', 'www.sehua55.com', 'www.59sehua.com', 'www.sehua1.com', 'www.sehua3.com', 'www.sehua9.com', 'www.sehua37.com', 'www.sehua25.com', 'www.29sehua.com', 'www.3sehua.com', 'www.39sehua.com', 'www.sehua52.com', 'www.33sehua.com', 'www.sehua45.com', 'www.60sehua.com', 'www.sehua36.com', 'www.55sehua.com', 'www.sehua54.com', 'www.18sehua.com', 'www.sehua60.com', 'www.24sehua.com', 'www.sehua11.com', 'www.25sehua.com', 'www.sehua35.com', 'www.sehua28.com', 'www.28sehua.com', 'www.sehua49.com', 'www.58sehua.com', 'www.7sehua.com', 'www.16sehua.com', 'www.sehua5.com', 'www.35sehua.com', 'www.sehua17.com', 'www.sehua20.com', 'www.sehua29.com', 'www.40sehua.com', 'www.sehua2.com', 'www.sehua26.com', 'www.9sehua.com', 'www.sehua56.com'}

def init():
    test_ping_web()

if __name__ == '__main__':
    init()
