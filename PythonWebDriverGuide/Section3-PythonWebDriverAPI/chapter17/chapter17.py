#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver
import time
import os

driver = webdriver.Firefox()
file_path = 'file:///' + os.path.abspath('js.html')
driver.get(file_path)

driver.execute_script('$("#tooltip").fadeOut();')
time.sleep(5)

button = driver.find_element_by_class_name("btn")

driver.execute_script('$(arguments[0]).fadeOut()',button)

time.sleep(5)

driver.quit()