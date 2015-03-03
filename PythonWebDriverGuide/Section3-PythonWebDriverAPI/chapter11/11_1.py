#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver
import time
driver = webdriver.Firefox()
driver.get("http://www.baidu.com/")
driver.maximize_window()

time.sleep(5)
#点击登录链接
#driver.find_element_by_name("tj_login").click()
driver.find_element_by_link_text(u"登录").click()

#通过二次定位找到用户名输入框 
div=driver.find_element_by_class_name("tang-content").find_element_by_name("userName") 
div.send_keys("roytest004")
#输入登录密码
driver.find_element_by_name("password").send_keys("349756329")
#点击登录 
driver.find_element_by_id("TANGRAM__PSP_10__submit").click()
driver.quit()