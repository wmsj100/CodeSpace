#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020  <@DEEP-2020TGTVHB>
#
# Distributed under terms of the MIT license.

"""
比较列表和集合的性能
"""
import time

def find_union_price_useing_list(products):
    unique_price_list = []

    for __, price in products:
        if price not in unique_price_list:
            unique_price_list.append(price)

    return len(unique_price_list)

def find_unique_price_useing_set(products):
    unique_price_set = set()

    for __, price in products:
        if price not in unique_price_set:
            unique_price_set.add(price)

    return len(unique_price_set)

id = [ x for x in range(100000)]
price = [x for x in range(200000,300000)]
products = list(zip(id, price))

# time for list
start_time_list = time.perf_counter()
find_union_price_useing_list(products)
end_time_list = time.perf_counter()
print("time is {}".format(end_time_list - start_time_list))
# time is 106.41455579999999

start_time_set = time.perf_counter()
find_unique_price_useing_set(products)
end_time_set = time.perf_counter()
print("time is {}".format(end_time_set - start_time_set))
# 0.030215960000006703

# 可以看到俩者差距有3521倍
