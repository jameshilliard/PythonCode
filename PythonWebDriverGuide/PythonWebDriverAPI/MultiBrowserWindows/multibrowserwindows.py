#coding=utf-8
from selenium import webdriver
import time

driver = webdriver.Firefox()
driver.get("http://www.baidu.com/")
#获得当前窗口
nowhandle = driver.current_window_handle
#打开注册新窗口
driver.find_element_by_name("tj_reg").click()
#获得所有窗口
allhandles = driver.window_handles
#循环判断窗口是否为当前窗口
for handle in allhandles:
    if handle != nowhandle:
        driver.switch_to_window(handle)
        print 'now register window!'
        #切换到邮箱注册标签
        driver.find_element_by_id("TANGRAM__PSP_4__submit").click()
        time.sleep(5)
        driver.close()
#回到原先的窗口
driver.switch_to_window(nowhandle)
driver.find_element_by_id("kw").send_keys(u"注册成功!")
time.sleep(3)
driver.quit()