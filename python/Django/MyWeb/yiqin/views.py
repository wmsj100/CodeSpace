from django.shortcuts import render
from django.http import HttpResponse
from .models import ChinaDayAddList
import json

# Create your views here.

def index(request):
    return render(request, 'yiqin/index.html')

def test_echarts(request, num):
    return render(request, 'yiqin/echarts/test{}.html'.format(num))

def get_china_day_add_list(request):
    sql_data = ChinaDayAddList.objects.values().order_by('date')
    res = {
        'msg': 'ok',
        'status': 200,
        'count': ChinaDayAddList.objects.count(),
        'data': {
            'titles': [],
            'data': [],
            'date': []
        }
     } 


    data_obj = {}
    data_map = {
        'confirm': '确诊',
        'suspect': '疑似', 
        'dead': '死亡', 
        'heal': '出院', 
        'deadRate': '死亡率', 
        'healRate': '治愈率'
    }

    for item in sql_data:
        for key, val in item.items():
            if key in {'id' }:
                continue
            if data_obj.get(key):
                if isinstance(val, str):
                    data_obj[key].append(float(val))
                else:
                    data_obj[key].append(val)
            else:
                if isinstance(val, str):
                    data_obj[key] = [float(val)]
                else:
                    data_obj[key] = [val]

    for key,val in data_obj.items():
        struct = {
            'name': '',
            'type': 'line',
        }
        struct['data'] = val
        if key == 'date':
            res['data']['date'] = val
        else:
            struct['name'] = data_map[key]
            res['data']['titles'].append(data_map[key])
            res['data']['data'].append(struct)


    return HttpResponse(json.dumps(res))
