#! /bin/sh
#
# cron_study4.sh
# Copyright (C) 2020 ubuntu <ubuntu@VM-0-13-ubuntu>
#
# Distributed under terms of the MIT license.
#

riqi=$(date "+%Y-%m-%d")
path=/home/ubuntu/Documents/GitHub/CodeSpace/python/Django/study4/app1/yiqin_json
curl http://myweb.com:8001/app1/yiqin > ${path}/yiqin_${riqi}.json

