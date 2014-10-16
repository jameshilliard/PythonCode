# coding = utf-8

__author__ = 'royxu'

from selenium import webdriver

import time

browser = webdriver.Firefox()

browser.get("http://www.baidu.com")

time.sleep(0.3)

browser.find_element_by_id("kw").send_keys("selenium")

browser.find_element_by_id("su").click()

time.sleep(3)

print browser.title

browser.quit()
