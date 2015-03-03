#-*-coding=utf-8
from selenium import webdriver
import os
import time

driver = webdriver.Firefox()
file_path = 'file:///' + os.path.abspath('drop_down.html')
driver.get(file_path)
time.sleep(2)
#先定位到下拉框
m = driver.find_element_by_id("ShippingMethod")
#再点击下拉框下的选项
m.find_element_by_xpath("//option[@value='10.69']").click()
time.sleep(3)
driver.quit()