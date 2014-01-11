#coding=utf-8
__author__ = 'royxu'

from selenium import webdriver

import os

from time import sleep

if 'HTTP_PROXY' in os.environ:
    del os.environ['HTTP_PROXY']

dr = webdriver.Firefox()

file_path = 'file:///' + os.path.abspath('form.html')

print 'print file_path'

print file_path

dr.get(file_path)

print 'by id'

dr.find_element_by_id('inputEmail').click()

print 'by name'

dr.find_element_by_name('password').click()

print 'by tag name'

dr.find_element_by_tag_name('form').get_attribute('class')

print 'by class name'

e = dr.find_element_by_class_name('controls')

dr.execute_script('$(arguments[0]).fadeOut().fadeIn()', e)

sleep(2)

print 'by link text'

link = dr.find_element_by_link_text('register')

dr.execute_script('$(arguments[0]).fadeOut().fadeIn()', link)

sleep(2)

print 'by partial link text'

link = dr.find_element_by_partial_link_text('reg')

dr.execute_script('$(arguments[0]).fadeOut().fadeIn()', link)

sleep(2)

print 'by css selecter'

div = dr.find_element_by_css_selector('.controls')

dr.execute_script('$(arguments[0]).fadeOut().fadeIn()', div)

print 'by xpath'

dr.find_element_by_xpath('/html/body/form/div[3]/div/label/input').click()

sleep(2)

dr.quit()





