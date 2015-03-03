#coding=utf-8
from selenium import webdriver
import time
driver = webdriver.Firefox()
#访问百度首页
first_url= 'http://www.baidu.com' 
print "now access %s" %(first_url)
driver.get(first_url)
size = driver.find_element_by_id('kw').size
print size

text=driver.find_element_by_id("cp").text 
print text

attribute=driver.find_element_by_id("kw").get_attribute('type') 

print attribute

result=driver.find_element_by_id("kw").is_displayed() 

print result

driver.quit()