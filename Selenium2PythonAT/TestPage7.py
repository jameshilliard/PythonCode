#coding=utf-8
__author__ = 'royxu'

from selenium import webdriver

import time

import os

browser = webdriver.Firefox()

file_path = 'file:///' + os.path.abspath('frame.html')

browser.get(file_path)

browser.implicitly_wait(30)

browser.switch_to_frame("f1")

time.sleep(3)

browser.switch_to_frame("f2")

browser.find_element_by_id("kw").send_keys("selenium")

time.sleep(3)

browser.quit()