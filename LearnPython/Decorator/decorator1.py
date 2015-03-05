#!/usr/bin/env python
#coding=utf-8

def deco(func):
    def wrapper():
        print "wrapper start"
        func()  
        print "wrapper end\n"
    return wrapper

@deco
def foo():
    print "In foo():"   
    
foo()

