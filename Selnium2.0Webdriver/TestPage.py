__author__ = 'royxu'

import os
from selenium import webdriver

chromedriver = "/Users/royxu/homebrew/Cellar/chromedriver/2.6/bin/chromedriver"

os.environ["webdriver.chrome.driver"] = chromedriver

browser = webdriver.Chrome(chromedriver)

browser.get("http://www.baidu.com")
browser.find_element_by_id("kw").send_keys("selenium")
browser.find_element_by_id("su").click()
browser.quit()