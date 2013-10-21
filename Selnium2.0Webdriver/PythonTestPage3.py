#coding=utf-8
__author__ = 'royxu'

from selenium import webdriver
import time

browser = webdriver.Firefox()
browser.get("http://www.baidu.com")
time.sleep(2)

browser.find_element_by_id("kw").send_keys("selenium")

browser.find_element_by_name("wd").send_keys("selenium")

browser.find_element_by_tag_name("input").send_keys("selenium")

browser.find_element_by_class_name("s_ipt").send_keys("selenium")

browser.find_element_by_css_selector("#kw").send_keys("selenium")

browser.find_element_by_xpath("//input[@id='kw']").send_keys("selenium")

browser.find_element_by_id("su").click()

time.sleep(3)

browser.quit()






