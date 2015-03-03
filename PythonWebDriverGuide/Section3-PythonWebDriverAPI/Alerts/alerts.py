#coding=utf-8
from selenium import webdriver
import time

driver = webdriver.Firefox()
driver.get("http://www.baidu.com/")
#点击打开搜索设置
driver.find_element_by_name("tj_setting").click()
driver.find_element_by_id("SL_1").click()
#点击保存设置
driver.find_element_by_xpath("//div[@id='gxszButton']/input").click()
#获取网页上的警告信息
alert = driver.switch_to_alert()
#接收警告信息
alert.accept()
driver.quit()