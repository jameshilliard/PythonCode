#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver
import time
import os

driver = webdriver.Firefox()

file_path = 'file:///' + os.path.abspath('drop_down.html')
driver.get(file_path)
time.sleep(2)

# 定位

m = driver.find_element_by_id("ShippingMethod")

# 点击下来框选项

m.find_element_by_xpath("//option[@value='10.69']").click()

time.sleep(3)

driver.close()