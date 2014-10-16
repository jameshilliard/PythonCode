#coding=utf-8
__author__ = 'root'

from selenium import webdriver

import time

driver = webdriver.Firefox()

first_url = 'http://www.baidu.com'

print "now access %s" %(first_url)

driver.get(first_url)

#surf news page

second_url = 'http://news.baidu.com'

print "now access %s" %(second_url)

driver.get(second_url)

#back to baidu index

print "back to %s" % (first_url)

driver.back()

#forward to news page

print "forward to %s" %(second_url)

driver.forward()

driver.quit()