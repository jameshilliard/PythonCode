#coding=utf-8
from selenium import webdriver
driver = webdriver.Firefox()
driver.get("http://www.baidu.com")
print "浏览器最大化" 
driver.maximize_window() 
#将浏览器最大化显示 driver.quit()