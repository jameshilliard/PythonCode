#coding=utf-8
__author__ = 'royxu'
from selenium import webdriver

import time

import os

dr = webdriver.Firefox()

file_path = 'file:///' + os.path.abspath('Test4.html')

dr.get(file_path)

print 1

inputs = dr.find_element_by_tag_name('input')

print 2

for input in inputs:

    print 3

    if input.get_attribute('type') == 'checkbox':

        input.click()

time.sleep(2)

dr.quit()

