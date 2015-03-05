#!/usr/bin/env PYTHON
#coding=utf-8
"""
http://blog.csdn.net/lovingprince/article/details/6595466
"""

class Foo(object):  
    def test(self): # 定义了实例方法  
        print("object")  
    @classmethod  
    def test2(clss): # 定义了类方法  
        print("class")  
    @staticmethod  
    def test3(): # 定义了静态方法  
        print("static")  
