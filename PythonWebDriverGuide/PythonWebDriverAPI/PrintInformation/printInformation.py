#coding=utf-8
__author__ = 'royxu'

from selenium import webdriver

driver = webdriver.Firefox()
driver.get("http://passport.kuaibo.com/login/?referrer=http%3A%2F%2Fwebcloud.kuaibo.com%2 F")
#登录
driver.find_element_by_id("user_name").clear()
driver.find_element_by_id("user_name").send_keys("username")
driver.find_element_by_id("user_pwd").clear()
driver.find_element_by_id("user_pwd").send_keys("password")
driver.find_element_by_id("dl_an_submit").click()
#获得前面 title,打印
title = driver.title
print title
#拿当前 URL 与预期 URL 做比较
if title == u"快播私有云":
    print "title ok!"
else:
    print "title on!"
#获得前面 URL,打印
now_url = driver.current_url
print now_url
#拿当前 URL 与预期 URL 做比较
if now_url == "http://webcloud.kuaibo.com/":
    print "url ok!"
else:
    print "url on!"
#获得登录成功的用户,打印 now_user=driver.find_element_by_xpath("//div[@id='Nav']/ul/li[4]/a[1]/span").text print now_user
driver.quit()