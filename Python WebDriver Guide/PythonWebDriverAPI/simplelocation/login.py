__author__ = 'royxu'
#coding=utf-8

from selenium import webdriver

driver = webdriver.Firefox()

driver = webdriver.Firefox()
driver.get("http://passport.kuaibo.com/login/?referrer=http%3A%2F%2Fwebcloud.kuaibo.com%2F")
driver.find_element_by_id("user_name").clear()
size = driver.find_element_by_id("user_name").size
print size

#text = driver.find_elements_by_class_name("footer").text
text = driver.find_element_by_id("dl_an_submit").text
print text

attribute = driver.find_element_by_id("user_name").get_attribute('type')
print attribute

result = driver.find_element_by_id("user_name").is_displayed()
print result

driver.find_element_by_id("user_name").send_keys("username")
driver.find_element_by_id("user_pwd").clear()
driver.find_element_by_id("user_pwd").send_keys("password")
driver.find_element_by_id("dl_an_submit").click()
#通过 submit() 来提交操作 #driver.find_element_by_id("dl_an_submit").submit()
driver.quit()