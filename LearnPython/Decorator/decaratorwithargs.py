#!/usr/bin/nev python
#coding=utf-8

def myDeco(func):
    print("Hello ,I'm Decorator!")
    #被修饰的函数的参数
    def _myDeco(*args,**kwargs): 
        print("my name:%s",func.__name__)
        ret = func(*args,**kwargs)
        return ret
    return _myDeco
 
@myDeco
def run(a,b):
    print("func run start:")
    print("---------------")
    print("run(%s,%s)" % (a,b))
    print("---------------")
    print("func run end")
 
 
run(1,2)