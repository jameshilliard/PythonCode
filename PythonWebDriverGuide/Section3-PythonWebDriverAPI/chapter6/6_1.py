#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver
import time

driver = webdriver.Firefox()

driver.get("http://www.baidu.com")

driver.find_element_by_link_text(u"登录").click()

time.sleep(3)

#通过二次定位找到用户名输入框 
div_username=driver.find_element_by_class_name("tang-content").find_element_by_name("userName") 

div_username.send_keys("roytest004")

div_userpasswd=driver.find_element_by_class_name("tang-content").find_element_by_name("password") 
div_userpasswd.send_keys("349756329")

div_login=driver.find_element_by_class_name("tang-content").find_element_by_id("TANGRAM__PSP_8__submit") 
div_login.click()

title = driver.title 

print title

#获得前面 URL,打印
now_url = driver.current_url
print now_url
#拿当前 URL 与预期 URL 做比较
if now_url == "http://www.baidu.com":
   print "url ok!"
else:
   print "url on!"
   
driver.close()