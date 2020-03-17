"""
先不想着用递归调用，
先实现思路
走一次循环，再循环中比较相邻俩个值的大小
"""
import sys


def sort_max_list(list):
    for index, num in enumerate(list):
        if index == len(list) - 1:
            break
        else:
            if num > list[index+1]:
                list[index], list[index + 1] = list[index+1], num
        print(list)

def sort_list(list):
    result = []
    for index in range(len(list) - 1):
        sort_max_list(list)

def mao_pao(list):
    for i in range(len(list) -1):
        for j in range(len(list) - i - 1):
            if list[j] > list[j+1]:
                list[j], list[j+1] = list[j+1], list[j]
            print(list)
    
def init():
    temp = [23,9,56,33,1,3,345,12,0]
    sort_list(temp)
#    mao_pao(temp)

if __name__ == '__main__' :
    init()
