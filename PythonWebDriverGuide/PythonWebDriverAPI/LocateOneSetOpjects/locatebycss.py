#coding=utf-8
from selenium import webdriver
import os

driver = webdriver.Firefox()
file_path = 'file:///' + os.path.abspath('checkbox.html')
driver.get(file_path)
# 选择所有的 type 为 checkbox 的元素并单击勾选
checkboxes = driver.find_elements_by_css_selector('input[type=checkbox]')
for checkbox in checkboxes:
    checkbox.click()
# 打印当前页面上 type 为 checkbox 的个数
print len(driver.find_elements_by_css_selector('input[type=checkbox]'))
# 把页面上最后1个 checkbox 的勾给去掉
driver.find_elements_by_css_selector('input[type=checkbox]').pop().click()
driver.quit()