#!/usr/bin/env python
#coding=utf-8
from time import sleep 
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains

try:

    driver = webdriver.Firefox()

    first_url= 'http://www.baidu.com' 
    print "now access %s" %(first_url)
    driver.get(first_url)

    driver.find_element_by_id("kw").send_keys("hoopchina")
    
    right =driver.find_element_by_id("su")

    above = driver.find_element_by_link_text(u'视频')

    ActionChains(driver).move_to_element(above).perform()
    
    ActionChains(driver).drag_and_drop(above, right).perform()
    sleep(5)
    ActionChains(driver).context_click(above).perform()
    sleep(5)
    ActionChains(driver).double_click(right).perform()
    sleep(5)
    ActionChains(driver).click_and_hold(right).perform()
    sleep(5)

except Exception, e:
    print e
    
finally:
    driver.close()