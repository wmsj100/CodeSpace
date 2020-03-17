#! /bin/sh
#
# cron_study4.sh
# Copyright (C) 2020 ubuntu <ubuntu@VM-0-13-ubuntu>
#
# Distributed under terms of the MIT license.
#

riqi=$(date "+%Y-%m-%d")
path=/home/ubuntu/Github/python_study/django/study4/app1/yiqin_json
curl http://myweb.com:8006/app1/yiqin > ${path}/yiqin_${riqi}.json

