#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver

import os

driver = webdriver.Firefox()

file_path = 'file:///' + os.path.abspath('checkbox.html')

driver.get(file_path)

checkboxes = driver.find_element_by_css_selector('input[type=checkbox]')

for checkbox in checkboxes:
    checkbox.click()
   
print len(driver.find_elements_by_css_selector('input[type=checkbox]'))

driver.find_elements_by_css_selector('input[type=checkbox]').pop().click()

driver.quit()