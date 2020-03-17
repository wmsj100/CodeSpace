from django.http import HttpResponse
from django.core import serializers
from django.shortcuts import render
from .models import Blog, ChinaDayList, ChinaDayAddList, DailyNewAddHistory, DailyDeadRateHistory, DailyHealRateHistory, AreaTree, ChinaAdd, DailyHistory, ArticleList, WuhanDayList
import requests
import json
from .views_yiqin import YiQinApi, WriteToSql, TenXunYinQinApi
from .views_oss import GetOSS
from django import forms

def jsonData(data):
    return serializers.serialize('json', data)

def index(request):
    data = Blog.objects.all()
    return HttpResponse(jsonData(data), content_type='application/json')

def my_api(request):
    dic = {}
    if request.method == 'GET':
        dic['message'] = 0
        return HttpResponse(json.dumps(dic))
    else:
        dic['message'] = 'function error'
        return HttpResponse(json.dumps(dic))

def get_api(request):

    yiqin_api = YiQinApi()
    res = requests.get(yiqin_api.url, params=yiqin_api.param)

    if res.ok:
        return HttpResponse(res.json(), content_type='application/json')

def write_to_sql(data):
    try:
        json_data = json.loads(data)
    except:
        return HttpResponse("query tenxun yiqin jiekou error 500")

    WriteToSql(ChinaDayList, json_data, 'chinaDayList')
    WriteToSql(ChinaDayAddList, json_data, 'chinaDayAddList')
    WriteToSql(DailyHistory, json_data, 'dailyHistory')
    WriteToSql(DailyNewAddHistory, json_data, 'dailyNewAddHistory')
    WriteToSql(DailyDeadRateHistory, json_data, 'dailyDeadRateHistory')
    WriteToSql(DailyHealRateHistory, json_data, 'dailyHealRateHistory')
    WriteToSql(AreaTree, json_data, 'areaTree')
    WriteToSql(AreaTree, json_data, 'areaTree-children')
    WriteToSql(ChinaAdd, json_data, 'chinaAdd')
    WriteToSql(ChinaAdd, json_data, 'chinaTotal')
    WriteToSql(ArticleList, json_data, 'articleList')
    WriteToSql(WuhanDayList, json_data, 'wuhanDayList')


def get_yiqi_api(request):
    yiqin_api = TenXunYinQinApi()
    res = requests.get(yiqin_api.url, params=yiqin_api.param)

    if res.ok:
        print(res.status_code)
        try:
            data = res.json()['data']
        except:
            raise
        write_to_sql(data)
        return HttpResponse(data, content_type='application/json')

def get_mydata(request):
    tab = ['中国', '西安', '山西', '陕西']
    reg_str = '|'.join(tab)
    resp = AreaTree.objects.filter(name__regex=reg_str).order_by('name').values()

    return HttpResponse(json.dumps(list(resp)))

def get_oss(request):
    if request.method == 'GET':
        data = GetOSS('wmsj100test')
        return render(request, 'app1/oss_list.html', {'data': data.list})
#        return HttpResponse(data.list)
    elif request.method == 'POST':
        return HttpResponse(request)

def form_test(request):
    if request.method == 'POST':
        formObj = forms.Form(request.POST)
        if formObj.is_valid():
            img = request.FILES.get('imgfile')
            print(img)
            return HttpResponse(img)
    else:
        form = AddForm()
    return render(request, 'app1/form.html', {'form': form})
