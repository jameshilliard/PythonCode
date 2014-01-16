#coding=utf-8
__author__ = 'royxu'
from selenium import webdriver
import time

driver = webdriver.Firefox()
driver.get("http://passport.kuaibo.com/login/?referrer=http%3A%2F%2Fvod.kuaibo.com%2F%3Fly%3Ddefault")
#登录系统
driver.find_element_by_id("user_name").clear()
driver.find_element_by_id("user_name").send_keys("xxjbs001")
driver.find_element_by_id("user_pwd").clear()
driver.find_element_by_id("user_pwd").send_keys("123456roy")
driver.find_element_by_id("dl_an_submit").click()
time.sleep(2)
#获取所有分页的数量,并打印
total_pages = len(driver.find_element_by_tag_name("select").find_elements_by_tag_name("option"))
print "total page is %s" % (total_pages)
time.sleep(3)
#再次获取所分页,并执行循环翻页操作
pages = driver.find_element_by_tag_name("select").find_elements_by_tag_name("option")
for page in pages:
    page.click()
    time.sleep(2)
time.sleep(3)
driver.quit()