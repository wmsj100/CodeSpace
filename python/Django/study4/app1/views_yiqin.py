#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 ubuntu <ubuntu@VM-0-13-ubuntu>
#
# Distributed under terms of the MIT license.

"""

"""
class YiQinApi:
    url = 'http://myweb.com:8005/api/?format=json'
    param = {'format': 'json'}

class TenXunYinQinApi:
    url = 'https://view.inews.qq.com/g2/getOnsInfo'
    param = {'name': 'disease_h5'}

class WriteToSql:
    def __init__(self, Database, data, target):
        self.__sqlData = list()
        self.__Database = Database
        self.__data = self.__check_target_from_dict(data, target)
        self.__target = target
        __date = self.__check_target_from_dict(data, 'lastUpdateTime').split()[0].split('-')[1:]
        self.__date = '.'.join(__date)

        if self.__data:
            if isinstance(self.__data, dict):
                status, newItem = self.__write_sql(self.__data)
                if status:
                    self.__sqlData.append(self.__Database(**newItem))
            elif isinstance(self.__data, list):
                self.__write_list_to_sql()

            print('sqldate {}'.format(self.__Database.__name__), self.__sqlData)
            if self.__sqlData:
                self.__Database.objects.bulk_create(self.__sqlData)

    def __write_list_to_sql(self):
        for item in self.__data:
            self.__add_parent_for_areaitem(item)

            if item.get('children'):
                for shenItem in item['children']:
                    self.__add_parent_for_areaitem(shenItem, [item['name']])

                    if shenItem.get('children'):
                        for shiItem in shenItem['children']:
                            self.__add_parent_for_areaitem(shiItem, [item['name'], shenItem['name']])
                            # add shi
                            self.__append_sqlorm(shiItem)
                    # add shen
                    self.__append_sqlorm(shenItem)
                # add country
            if self.__target == 'dailyHistory':
                self.__format_dailyHistory(item, 'hubei')
                self.__format_dailyHistory(item, 'notHubei')
                self.__format_dailyHistory(item, 'country')
            elif self.__target == 'wuhanDayList':
                self.__format_wuhanDayList(item, 'wuhan')
                self.__format_wuhanDayList(item, 'notWuhan')
                self.__format_wuhanDayList(item, 'notHubei')
            else:
                self.__append_sqlorm(item)

    def __format_wuhanDayList(self, item, type):
        newItem = dict()
        newItem['date'] = item['date']
        newItem['confirmAdd'] = item[type]['confirmAdd']
        newItem['type'] = type
        self.__append_sqlorm(newItem)

    def __format_dailyHistory(self, item, type):
        newItem = {**item[type]}
        newItem['date'] = item['date']
        newItem['type'] = type
        self.__append_sqlorm(newItem)

    def __append_sqlorm(self, item):
        status, newItem = self.__write_sql(item)

        if status:
            self.__sqlData.append(self.__Database(**newItem))

    def __add_parent_for_areaitem(self, item, parent=[]):
        if self.__target == 'areaTree' or self.__target == 'areaTree-children':
            if len(parent) == 2:
                item['type'] = 'shi'
            elif len(parent) == 1:
                item['type'] = 'shen'
            else:
                item['type'] = 'country'

            item['parent'] = '-'.join(parent);


    def __check_target_from_dict(self, data, target):
        __data = dict()

        try:
            __data = data.get(target)
        except Exception:
            print("data {} do't contain {}".format(data, target))
        return __data

    def __format_areatree(self, item):
        newItem = dict()
        newItem['name'] = item['name']
        newItem['date'] = self.__date
        newItem['confirm'] = item['today']['confirm']
        newItem['totalConfirm'] = item['total']['confirm']
        newItem['totalSuspect'] = item['total']['suspect']
        newItem['totalDead'] = item['total']['dead']
        newItem['totalHeal'] = item['total']['heal']
        newItem['deadRate'] = item['total']['deadRate']
        newItem['healRate'] = item['total']['healRate']
        newItem['parent'] = item['parent']
        newItem['type'] = item['type']
    
        return newItem

    def __write_sql(self, item):
        status = False
        newItem = item

        if self.__target in ('areaTree', 'areaTree-children'):
            newItem = self.__format_areatree(newItem)
            queryDate = self.__Database.objects.filter(name=newItem['name'],date=newItem['date'])
        elif self.__target in ('chinaAdd', 'chinaTotal'):
            newItem['date'] = self.__date
            newItem['type'] = self.__target
            queryDate = self.__Database.objects.filter(date=self.__date, type=self.__target)
        elif self.__target == 'dailyHistory':
            queryDate = self.__Database.objects.filter(date=newItem['date'], type=newItem['type'])
        elif self.__target == 'articleList':
            queryDate = self.__Database.objects.filter(url=newItem['url'])
        elif self.__target == 'wuhanDayList':
            queryDate = self.__Database.objects.filter(date=newItem['date'], type=newItem['type'])
        else:
            date = self.__check_target_from_dict(newItem, 'date')
            queryDate = self.__Database.objects.filter(date=date)

        if queryDate.exists():
            if queryDate.count() > 1:
                queryDate.delete()
                status = True
            else:
                status = self.__check_sql(newItem, queryDate.first())
        else:
            status = True

        return status, newItem

    def __check_sql(self, data, sqlItem):
        for key, val in data.items():
            if sqlItem.serializable_value(key) != val:
                sqlItem.delete()
                return True
        return False
