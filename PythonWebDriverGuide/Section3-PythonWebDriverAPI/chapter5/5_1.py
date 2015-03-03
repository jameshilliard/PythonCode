#!/usr/bin/env python
#coding=utf-8

from selenium import webdriver

from selenium.webdriver.common.keys import Keys

import time

driver = webdriver.Firefox()

driver.get('http://www.baidu.com')

#输入框输入内容
driver.find_element_by_id("kw").send_keys("selenium")

time.sleep(3)
#删除多输入的一个 m

driver.find_element_by_id("kw").send_keys(Keys.BACK_SPACE)

time.sleep(3)

#输入空格键+“教程”

driver.find_element_by_id("kw").send_keys(Keys.SPACE) 

driver.find_element_by_id("kw").send_keys(u"教程") 

time.sleep(3)


#ctrl+a 全选输入框内容 
driver.find_element_by_id("kw").send_keys(Keys.CONTROL,'a')

time.sleep(3)

#ctrl+x 剪切输入框内容 

driver.find_element_by_id("kw").send_keys(Keys.CONTROL,'x')

time.sleep(3)
#输入框重新输入内容,搜索 

driver.find_element_by_id("kw").send_keys(Keys.CONTROL,'v') 

time.sleep(3)

#通过回车键盘来代替点击操作 
driver.find_element_by_id("su").send_keys(Keys.ENTER) 

time.sleep(3)

driver.quit()