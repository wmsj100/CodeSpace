from django.shortcuts import render
from django.http import HttpResponse, HttpResponseRedirect

# Create your views here.
def index(request):
    return render(request, 'blog/index.html')

def lang(request):
    return HttpResponse('lang page')

def linux(request):
    return HttpResponse('linux page')
