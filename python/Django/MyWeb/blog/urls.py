from django.urls import path
from . import views

app_name = 'blog'

urlpatterns = [
    path('', views.index, name='index'),
    path('lang/', views.lang, name='lang'),
    path('linux/', views.linux, name='linux'),
]
