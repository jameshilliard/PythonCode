#coding=utf-8
__author__ = 'royxu'

from selenium import webdriver
import os

driver = webdriver.Firefox()
file_path = 'file:///' + os.path.abspath('checkbox.html')
driver.get(file_path)
# 选择页面上所有的 tag name 为 input 的元素
inputs = driver.find_elements_by_tag_name('input')
#然后从中过滤出 tpye 为 checkbox 的元素,单击勾选
for input in inputs:
    if input.get_attribute('type') == 'checkbox':
        input.click()

driver.quit()