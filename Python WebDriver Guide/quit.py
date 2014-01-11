#coding=utf-8
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException

import time


def quit(self):
    driver = self.driver
    driver.quit()
