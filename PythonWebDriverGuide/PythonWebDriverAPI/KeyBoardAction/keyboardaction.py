#coding=utf-8
__author__ = 'royxu'

from selenium import webdriver
# import class Key
from selenium.webdriver.common.keys import Keys

import time

driver = webdriver.Firefox()
driver.get("http://www.baidu.com")

# ether content in the editbox
driver.find_element_by_id("kw").send_keys("seleniumm")
time.sleep(3)
# delete the m
driver.find_element_by_id("kw").send_keys(Keys.BACK_SPACE)
time.sleep(3)

#ether blankspace+"教程"
driver.find_element_by_id("kw").send_keys(u"教程")
time.sleep(3)

#ctrl+a
print "ctrl + a"
driver.find_element_by_id("kw").send_keys(Keys.CONTROL, 'a')
time.sleep(10)

driver.find_element_by_id("kw").clear()

print "ctrl + x"

#ctrl+x
driver.find_element_by_id("kw").send_keys(Keys.CONTROL, 'x')
time.sleep(10)

# delete the letter
driver.find_element_by_id("kw").send_keys(Keys.BACK_SPACE)
time.sleep(5)

#ctrl+v
print "ctrl + v"

driver.find_element_by_id("kw").send_keys(Keys.CONTROL, 'v')
time.sleep(10)

#use Enter Keys to click
print "Enter"
driver.find_element_by_id("kw").send_keys(Keys.ENTER)
time.sleep(10)

driver.quit()