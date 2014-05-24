#coding=utf-8
__author__ = 'root'

from selenium import webdriver

driver = webdriver.Firefox()
driver.get("http://www.baidu.com")

print "Maxsize Broswer"

driver.maximize_window()

driver.quit()