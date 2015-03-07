#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver
import os
import time

driver = webdriver.Firefox()

file_path = 'file:///' + os.path.abspath('upload_file.html')
driver.get(file_path)

driver.find_element_by_name("file").send_keys('/Users/royxu/Downloads/log3.txt')

time.sleep(2)

driver.close()