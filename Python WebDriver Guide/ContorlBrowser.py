# coding = utf-8
__author__ = 'royxu'

from selenium import webdriver

import time

import os


if 'HTTP_PROXY' in os.environ:
    del os.environ['HTTP_PROXY']

dr = webdriver.Firefox()

first_url = "http://www.baidu.com"

second_url = "http://www.news.baidu.com"

time.sleep(2)

print "Maxsize the browser"

dr.maximize_window()

time.sleep(2)

print "set the window size of the browser"

dr.set_window_size(1000, 600)

time.sleep(2)

print "Now ,access %s" % (first_url)

dr.get(first_url)

print "title of current page is %s" % (dr.title)

print "url of current page is %s" % (dr.current_url)

time.sleep(2)

print "Now ,access %s" % (second_url)

dr.get(second_url)

print "title of current page is %s" % (dr.title)

print "url of current page is %s" % (dr.current_url)

time.sleep(2)

print "go back %s" % (first_url)

dr.back()

time.sleep(1)

print "go forward %s" % (second_url)

dr.forward()

time.sleep(2)

print "Close Browser by Method close"

dr.close()

print "Browser is closed."

dr.quit()

print "Run Method quit"