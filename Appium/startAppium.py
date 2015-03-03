import os
import sys
from datetime import datetime
from appium import webdriver
import time
# print os.getcwd()
# print os.path.dirname(__file__)
desired_caps = {}
desired_caps['platformName'] = 'Android'
desired_caps['platformVersion'] = '5.0.1'
desired_caps['deviceName'] = 'Nexus_5_API_21_x86'
# desired_caps['app']=''
desired_caps['appPackage'] = 'com.android.settings'
desired_caps['appActivity'] = 'Settings'
# print dir(webdriver)
command_url = 'http://localhost:4723/wd/hub'
# android=webdriver.DesiredCapabilities.ANDROID
try:
    
    driver = webdriver.Remote(command_url, desired_caps)
    name = 'android.widget.TextView'
    time.sleep(2)
    
#     elem=driver.find_elements_by_id("android:id/title")
#     for e in elem:
#         print e.text
#         if str(e.text).find('Wi')>=0:
#             e.click()
#             time.sleep(3)
#             break



# Connect without scan
    WiFi_Switch=driver.find_element_by_id("com.android.settings:id/switchWidget").text
    if WiFi_Switch.lower() != 'on':
        driver.find_element_by_id("com.android.settings:id/switchWidget").click()
    driver.find_element_by_xpath("//android.widget.TextView[contains(@text,'Wi')]").click()
    time.sleep(3)
    add_ele=driver.find_element_by_accessibility_id('Add network')
    add_ele.click()
    time.sleep(3)
    driver.find_element_by_id('com.android.settings:id/security').click()
    time.sleep(3)
    driver.find_element_by_xpath("//android.widget.CheckedTextView[contains(@text,'WPA')]").click()
    time.sleep(3)
    ssid_blank=driver.find_element_by_id('com.android.settings:id/ssid')
    ssid_blank.send_keys('TELUS0040-2.4G')
    time.sleep(3)
    driver.find_element_by_id('com.android.settings:id/password').send_keys('m6xeqee46c')
    time.sleep(3)
    driver.find_element_by_xpath("//android.widget.Button[contains(@text,'Save')]").click()
    time.sleep(3)
    for i in range(10):
        status=driver.find_elements_by_id('android:id/summary')[0].text
        if status == 'Connected':
            print "LAN Device Connected!!!"
            break
        

    



#     ele=driver.find_elements_by_class_name(name)
#     for e in ele:
#         print e.text
#         if str(e.text).find('Wi')>=0:
#             e.click()
#             time.sleep(3)
#             break


#     ele=driver.find_element_by_xpath("//android.widget.TextView[contains(@text,'Wi')]")
#     ele.click()
#     time.sleep(3)


#     print ele.text
#     #Display
#     print ele.id
#     #1
#     ele.click()
#     print dir(ele)
#     for ele in elem:
#         print ele.text
# #         print ele.id
#         print '=' * 10 
#     driver.find_element_by_android_uiautomator('new UiSelector().resourceId("android:id/title")')
#     
#     print driver.find_element_by_class_name(name).text
#     driver.find_element_by_android_uiautomator('new UiSelector().resourceId("com.android.settings:id/switchWidget")')
#     js_snippet='mobile:swipe'
#     args={'startX':0.5,'startY':0.2,'startX':0.5,'startY':0.95,'tapCount':1,'duration':10}
#     driver.execute_script(js_snippet,args)
except Exception, e:
    print e
finally:
    driver.quit()
print "PASS"

# driver=webdriver.Remote('http://localhost:4723/wd/hub',desired_caps)
# PATH=lambda p:os.path.abspath(os.path.join(os.path.dirname(__file__),p))
# print os.path.dirname(__file__)
# a=PATH('../../../A/B/C.log')
# print a
# driver.f
