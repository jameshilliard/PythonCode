#coding=utf-8
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException

import time


def login(self):
    driver = self.driver
    driver.maximize_window()
    driver.find_element_by_id("user_name").clear()
    driver.find_element_by_id("user_name").send_keys("testing360")
    driver.find_element_by_id("user_pwd").clear()
    driver.find_element_by_id("user_pwd").send_keys("198876")
    driver.find_element_by_id("dl_an_submit").click()
    time.sleep(3)

