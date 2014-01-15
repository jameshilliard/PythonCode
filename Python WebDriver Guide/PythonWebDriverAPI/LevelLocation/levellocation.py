#coding=utf-8
from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.action_chains import ActionChains

import time
import os

driver = webdriver.Firefox()
file_path = 'file:///' + os.path.abspath('level_locate.html')
driver.get(file_path)
#点击 Link1 链接(弹出下拉列表)
driver.find_element_by_link_text('Link1').click()
#在父亲元件下找到 link 为 Action 的子元素
time.sleep(5)

menu = driver.find_element_by_id('dropdown1').find_element_by_link_text('Another action')
#鼠标移动到子元素上
ActionChains(driver).move_to_element(menu).perform()

time.sleep(5)

driver.quit()