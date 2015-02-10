#coding:utf-8
from appium import webdriver
from time import sleep

desired_caps = {}
desired_caps['platformName'] = 'Android'
desired_caps['platformVersion'] = '4.4'
desired_caps['deviceName'] = 'Android Emulator'
desired_caps['app'] = 'Calculator.apk'
desired_caps['appPackage'] = 'com.android.calculator2'
desired_caps['appActivity'] = '.Calculator'

dr = webdriver.Remote('http://localhost:4723/wd/hub', desired_caps)
sleep(3)

dr.find_element_by_id('com.android.calculator2:id/digit9').click()