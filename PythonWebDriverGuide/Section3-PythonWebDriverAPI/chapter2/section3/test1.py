#!/usr/bin/env python
# coding=utf-8

__author__ = 'root'

from selenium import webdriver

driver = webdriver.Firefox()
driver.get("http://www.baidu.com/")
#browser.find_element_by_id("kw").send_keys("selenium")
#browser.find_element_by_id("su").click()
#browser.quit()

driver.find_element_by_id("kw").click()
driver.find_element_by_id("kw").clear()
driver.find_element_by_id("kw").send_keys("selenium")
driver.find_element_by_id("su").click()
