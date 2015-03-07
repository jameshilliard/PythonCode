#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver
import time

driver = webdriver.Firefox()
driver.get("http://www.baidu.com/")
time.sleep(5)
#点击打开搜索设置
driver.find_element_by_link_text(u"设置").click()
#driver.find_element_by_name("tj_settingicon").click() 
driver.find_element_by_class_name("setpref").click()
#driver.find_element_by_id("SL_1").click()

#点击保存设置 
driver.find_element_by_class_name("prefpanelgo").click()
#获取网页上的警告信息 
alert=driver.switch_to_alert()
print alert
#接收警告信息 
alert.accept() 
#取消对话框
#alert.dismiss()
driver.close()

print"\nend!"