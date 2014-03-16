#coding=utf-8
__author__ = 'royxu'

from selenium import webdriver
import time
browser = webdriver.Firefox()

first_url= 'http://www.baidu.com'  #access baidu index page

second_url = 'http://news.baidu.com' #access baidu news page

# 通过get方法获取当前url打印
print "now access %s" %(first_url)
browser.get(first_url)
time.sleep(2)

browser.maximize_window() #maximize the browser

browser.find_element_by_id("kw").send_keys("selenium")


#access baidu news page

print " now access %s" %(second_url)

browser.get(second_url)

time.sleep(2)


#back to baidu index page

print " back to %s "% (first_url)

browser.back()

time.sleep(1)

#foward to baidu news page

print "foward to %s" %(second_url)

browser.forward()

time.sleep(2)

browser.set_window_size(400,800) # modify the browser's size


#browser.find_element_by_id("su").click()

time.sleep(3)

browser.quit()

