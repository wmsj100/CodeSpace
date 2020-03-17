from django.urls import path
from . import views

app_name = 'yiqin'

urlpatterns = [
    path('', views.index, name = 'index'),        
    path('echarts/test<int:num>/', views.test_echarts, name='echarts_test'),
    path('api/chinadayaddlist/', views.get_china_day_add_list, name='chinadayaddlist'),
]
