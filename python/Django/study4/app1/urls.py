#! /usr/bin/env python
# -*- coding: utf-8 -*-
# vim:fenc=utf-8
#
# Copyright © 2020 ubuntu <ubuntu@VM-0-13-ubuntu>
#
# Distributed under terms of the MIT license.

"""

"""
from django.urls import path
from . import views

urlpatterns = [
    path('index', views.index),
    path('api', views.my_api, name='my_api'),
    path('get_study3', views.get_api, name='get_study3'),
    path('yiqin', views.get_yiqi_api, name='get_yiqi_api'),
    path('mydata', views.get_mydata, name='get_mydata'),
    path('myoss', views.get_oss, name='get_myoss'),
    path('form/', views.form_test, name='form_test'),
        ]
