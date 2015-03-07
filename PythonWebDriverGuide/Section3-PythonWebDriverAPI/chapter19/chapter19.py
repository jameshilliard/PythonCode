#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver
import time

driver = webdriver.Firefox()
driver.get("http://www.youdao.com")

#get Cookie

cookie = driver.get_cookies()

driver.add_cookie({'name':'key-aaaaaaaa', 'value':'value-bbbbbbbb'})

for cookie in driver.get_cookies():
    print "%s -> %s" % (cookie['name'], cookie['value'])

driver.delete_cookie("CookieName")

driver.delete_all_cookies()

time.sleep(2)

driver.quit()