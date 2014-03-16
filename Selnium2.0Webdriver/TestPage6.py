#coding=utf-8
__author__ = 'royxu'
from selenium import webdriver

import time

browser = webdriver.Firefox()

browser.get('http://www.baidu.com')

time.sleep(2)

data=browser.find_element_by_id("cp").text

print data

browser.find_element_by_id('kw').clear()
browser.find_element_by_id('kw').send_keys('selenium')

browser.find_element_by_id('su').submit()
#browser.find_element_by_id('su').click()
browser.quit()

