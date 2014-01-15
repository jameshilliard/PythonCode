#coding=utf-8
__author__ = 'royxu'

#import Class ActionChains

from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains

driver = webdriver.Firefox()

# locate the elements that need double click
right = driver.find_element_by_xpath("XXX")

# right click the elements

ActionChains(driver).context_click(right).perform()

# double click

double_click(on_element)

# drag_and_drop
# drag_and_drop(source,target)
#ActionChains(driver).drag_and_drop(element, target).perform()






