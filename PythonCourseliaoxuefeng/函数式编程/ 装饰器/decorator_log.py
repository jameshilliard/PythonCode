#!/usr/bin/env python
#coding=utf-8
import functools

"""
请编写一个decorator，能在函数调用的前后打印出'begin call'和'end call'的日志。

再思考一下能否写出一个@log的decorator，使它既支持：

@log
def f():
    pass

又支持：
    
@log('execute')
def f():
    pass
"""


def log(text):
  
    if isinstance(text, str):
    
        def decorator(func):
            @functools.wraps(func)
            def wrapper(*args, **kw):
                print '%s %s():' % (text, func.__name__)
                return func(*args, **kw)
            return wrapper
        return decorator
    else:  
        def wrapper():
            print "Start Call"
            text()
            print "End Call"
        return wrapper      

@log
def call():
    print "I am calling !!!"
    
call()

@log('test')
def test():
    print "I am testing !!!"
    
test()


