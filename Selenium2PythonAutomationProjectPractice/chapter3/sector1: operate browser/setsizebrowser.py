#coding=utf-8
__author__ = 'root'

from selenium import webdriver

import time

driver = webdriver.Firefox()
driver.get("http://m.mail.10086.cn")

print "set the browser's size: weight 480, height 800"

driver.set_window_size(480, 800)

driver.quit()