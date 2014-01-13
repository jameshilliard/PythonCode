#!/usr/bin/env python -u
"""
[{'page_navige' : {
                   'name' : 'page_tv2kh_Status_Line_1_Status',
                   'method' : 'get click' , 
                   'value' : 'modemstatus_home.html ID:wanstatus'
                  } ,
  'Page_title' : 'Advanced Setup - Broadband Settings',

  'check_type' : 'assertEqual' ,
  'element_location' : {'method' : 'CSS_SELECTOR' , 
                        'value' : 'td',
                       },
  'property' : 'text',
  'attribute' : '',
  'element_type' : '',
  
  'expected_value' : 'WAN Interface:'
 },
...
]
"""

from copy import deepcopy
from pprint import pprint, pprint
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
import db_helper
import os
import time


class BaseRunner():
    def __init__(self, driver, case_id, product_type, product_version, base_url, debug):
        """
        """
        self.driver = driver
        self.case_id = case_id
        self.product_type = product_type
        self.product_version = product_version
        self.base_url = base_url
        self.verificationErrors = []
        self.current_page = {}
        self.accept_next_alert = True
        self.debug = debug

    def is_element_present(self, how, what):
        try:
            self.driver.find_element(by=how, value=what)
        except NoSuchElementException, e:
            return False
        return True

    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to_alert()
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert.text
        finally:
            self.accept_next_alert = True

    def wait_link_text_exist(self, id, to=10):
        """
        wait till element present
        True
        False
        """

        # print 'in function : wait_id_exist'
        driver = self.driver

        try:
            WebDriverWait(driver, to).until(lambda driver: driver.find_element_by_link_text(id))

            print driver.current_url

        except:
            print 'AT_ERROR : no such element of link_text exist -- %s' % (id)
            return False

        print 'AT_INFO : the element of link_text %s exists' % (id)
        return True


    def wait_id_exist(self, id, to=10):
        """
        wait till element present
        True
        False
        """

        # print 'in function : wait_id_exist'
        driver = self.driver

        try:
            WebDriverWait(driver, to).until(lambda driver: driver.find_element_by_id(id))

            print driver.current_url

        except:
            print 'AT_ERROR : no such element of id exist -- %s' % (id)
            return False

        print 'AT_INFO : the element of id %s exists' % (id)
        return True

    def wait_elem_exist(self, how, what, to=10):
        """
        wait till element present
        True
        False
        """

        driver = self.driver

        try:
            WebDriverWait(driver, to).until(lambda driver: driver.find_element(by=how, value=what))

            print driver.current_url

        except:
            print 'AT_ERROR : no such element of %s exist -- %s' % (how, what)
            return False

        print 'AT_INFO : the element of %s exist -- %s' % (how, what)
        return True

    def wait_elem_appear(self, how, what, to=20, disappear=False):
        """
        wait till element present
        True
        False
        """

        driver = self.driver

        if not disappear:
            for i in range(to):
                try:
                    elem = driver.find_element(by=how, value=what)
                    if elem.is_displayed():
                        print '%s of [%s] showed up' % (what, how)
                        return True
                except Exception, e:
                    print(str(e))
                    if i == to - 1:
                        print 'not show up'
                        return False
                print '%s of [%s] not showed up yet ! %s' % (what, how, i)
                time.sleep(1)
        else:
            for i in range(to):
                try:
                    elem = driver.find_element(by=how, value=what)
                    if elem.is_displayed():
                        print '%s of [%s] not disappeared yet ! %s' % (what, how, i)
                        if i == to - 1:
                            print 'not disappeared'
                            return False
                        time.sleep(1)
                    else:
                        print '%s of [%s] became invisible' % (what, how)
                        return True
                except Exception, e:
                    print(str(e))
                    print '%s of [%s] disappeared' % (what, how)

                    return True

        return False

    def wait_elem_enabled(self, how, what, tmo=5):
        """
        wait till element present
        True
        False
        is_element_present
        is_enabled()
        """

        driver = self.driver

        if self.wait_elem_exist(how, what):

            try:
                waited = 0

                check_interval = 1
                check_retry = int(tmo) / check_interval

                for i in range(check_retry):
                    elem = driver.find_element(by=how, value=what)
                    if elem.is_enabled():
                        print 'wait_elem_enabled passed'
                        #                     print 'INFO : waiting page of %s is %s' % (url, str(waited))
                        return elem
                    else:
                        idx = i + 1
                        if check_retry == idx:
                            print 'ERROR : time out '
                            return False
                        else:
                            print 'try wait_elem_enabled again'
                            waited += check_interval
                            time.sleep(check_interval)

            except:
            #                 print 'AT_ERROR : no such element of id exist -- %s' % (id)
                return False
        else:
            return False

        #         print 'AT_INFO : the element of id %s exists' % (id)
        return True

    def check_url(self, url, tmo):
        print ' dest url :', url
        driver = self.driver

        waited = 0

        check_interval = 2
        check_retry = int(tmo) / check_interval

        for i in range(check_retry):
            cur_url = driver.current_url
            print ' current url : ', cur_url
            if cur_url == url:
                print 'check url passed'
                print 'INFO : waiting page of %s is %s' % (url, str(waited))
                return True
            else:
                idx = i + 1
                if check_retry == idx:
                    print 'ERROR : time out , url %s won\'t show up' % (url)
                    return False
                else:
                    print 'try checking url again'
                    waited += check_interval
                    time.sleep(check_interval)

    def check_title(self, title, tmo):
        print ' dest title :', title
        driver = self.driver

        waited = 0

        check_interval = 2
        check_retry = int(tmo) / check_interval

        for i in range(check_retry):
            cur_title = driver.title
            print ' current title : [%s]' % (cur_title)
            print ' dest title : [%s]' % (title)
            if cur_title == title:
                print 'check title passed'
                print 'INFO : waiting page of %s is %s' % (title, str(waited))
                return True
            else:
                idx = i + 1
                if check_retry == idx:
                    print 'ERROR : time out , title %s won\'t show up' % (title)
                    return False
                else:
                    print 'try checking title again'
                    waited += check_interval
                    time.sleep(check_interval)

    def get_check_point_list(self, case_id, product_type, product_version):
        """
        """
        if self.debug:
            print('get_check_point_list - case id : %s ,product type : %s , product version : %s' % (
            case_id, product_type, product_version))
        check_point_list = []
        check_point_list = db_helper.getAllInfoForGUICheck(case_id, product_type, product_version, self.debug)
        if check_point_list:
            return check_point_list
        else:
            print 'AT_ERROR : the check point list is empty!'
            return False

    def parse_element_location(self, element_location):
        """
        """
        if self.debug:
            print 'parse_element_location : %s' % element_location
        method = None
        value = None
        if element_location.has_key('method'):
            method = element_location.get('method').strip()
            if not method:
                print "AT_ERROR : element_location method is empty"
        else:
            print "AT_ERROR : element_location hasn't key : method"
            return False
        if element_location.has_key('value'):
            value = element_location.get('value')
            if not method:
                print "AT_ERROR : element_location value is empty"
        else:
            print "AT_ERROR : element_location hasn't key : value"
            return False

        return method, value

    def find_element(self, element_location):
        """
        """
        if self.debug:
            print "find_element : %s" % element_location
        driver = self.driver
        method, value = self.parse_element_location(element_location)

        how = getattr(By, method)
        em = driver.find_element(how, value)
        if not em:
            self.verificationErrors.append('Can not found element by <%s> value <%s>' % (how, value))
            return False

        return em

    def element_check(self, check_type, element_location, property, attribute, element_type, expected_value):
        """
        """
        if self.debug:
            print 'element_check'
        driver = self.driver
        real_value = None

        em = self.find_element(element_location)

        if em:
            if 'select' == element_type.lower():
                em = Select(em).first_selected_option()

            if attribute:
                real_value = str(getattr(em, property)(attribute))
            else:
                real_value = getattr(em, property)

            if expected_value != None:
                if os.getenv(expected_value) != None:
                    expected_value = os.getenv(expected_value)
            else:
                print "AT_ERROR : Not specified the expect value"
                return False

            if expected_value != real_value:
                self.verificationErrors[-1].get('error_list').append({'element_location': element_location,
                                                                      'expected_value': expected_value,
                                                                      'real_value': real_value
                })
                self.highlightElement(em)

            return True
        return False

    def parse_page_navige(self, page_navige):
        """
        """
        if self.debug:
            print 'parse_page_navige'
        action_list = []
        method_list = []
        value_list = []

        if page_navige.has_key('method'):
            method_list = page_navige.get('method').split(' ')
        else:
            print "AT_ERROR : page_navige hasn't key : method"
            return False
        if page_navige.has_key('value'):
            value_list = page_navige.get('value').split(' ')
        else:
            print "AT_ERROR : page_navige hasn't key : value"
            return False

        if len(method_list):
            if not len(method_list) == len(value_list):
                print "AT_ERROR : method is not match the valuet <%s>" % (page_navige)
                return False
        else:
            print "AT_ERROR : method list is empty"
            return False

        for idx, method in enumerate(method_list):
            if method == 'click':
                how, what = value_list[idx].split(':')
                if how and what:
                    action = (method, how, what)
            else:
                action = (method, 'uri', value_list[idx])

            action_list.append(action)
        return action_list

    def goto(self, uri):
        """
        """
        if self.debug:
            print 'goto : <%s>' % uri

        driver = self.driver
        try:
            driver.get(self.base_url + uri)
        except Exception, e:
            print 'Exception : ' + str(e)
            return False
        return True

    def gothere(self, page_navige, page_title):
        """
        """
        if self.debug:
            print 'gothere'
        driver = self.driver
        action_list = []
        if self.current_page == page_navige:
            if self.debug:
                print "AT_INFO : GUI check on the same page"
            return True
        else:
            action_list = self.parse_page_navige(page_navige)

            if len(action_list):
                for action in action_list:
                    if action[0] == 'click':
                        how = getattr(By, action[1])
                        em = driver.find_element(how, action[2])
                        if em:
                            em.click()
                        else:
                            print "AT_ERROR : Unable to locate element how : %s , what : %s" % (how, action[2])
                            return False
                    else:
                        self.goto(action[2])
            else:
                print "AT_ERROR : parse page navige to action list is empty"
                return False

            if page_title == driver.title:
                print "AT_INFO : current page title is <%s>" % driver.title
                self.verificationErrors.append({'page_name': page_navige.get('name'), 'error_list': []})
                self.current_page = deepcopy(page_navige)
                return True
            else:
                print "AT_ERROR : current page title is %s" % driver.title
                print "AT_ERROR : unexpect page title , expect page title is %s" % page_title
                return False

    def gui_check(self):
        """
        """
        if self.debug:
            print 'GUI_check'
        check_point_list = self.get_check_point_list(self.case_id, self.product_type, self.product_version)
        if check_point_list:
            for check_point in check_point_list:
                if len(self.current_page):
                    if self.current_page != check_point.get('page_navige'):
                        if len(self.verificationErrors[-1].get('error_list')):
                            self.screen_shot(self.current_page.get('name'))

                if self.gothere(check_point.get('page_navige'), check_point.get('page_title')):
                    self.element_check(check_point.get('check_type'), check_point.get('element_location'), \
                                       check_point.get('property'), check_point.get('attribute'), \
                                       check_point.get('element_type'), check_point.get('expected_value'))
                else:
                    return False
            if len(self.verificationErrors[-1].get('error_list')):
                self.screen_shot(self.current_page.get('name'))
            pprint(self.verificationErrors)
            return True
        else:
            return False

    def screen_shot(self, page_navige_name):
        """
        """
        if self.debug:
            print 'screen_shot'
        currnet_log = os.getenv('G_CURRENTLOG', os.getcwd())
        if not os.path.exists(currnet_log + '/screen_shot'):
            os.mkdir(currnet_log + '/screen_shot')

        browserName = self.driver.capabilities.get('browserName')
        version = self.driver.capabilities.get('version')
        platform = self.driver.capabilities.get('platform')

        screenshot_file = '%s/screen_shot/%s_%s_%s_%s.jpg' % (
        currnet_log, browserName, version, platform, page_navige_name)
        if self.debug:
            print 'screenshot_file :', screenshot_file

        self.driver.save_screenshot(screenshot_file)
        return True

    def highlightElement(self, element):
        """
        """
        driver = self.driver
        driver.execute_script("element = arguments[0];" +
                              "original_style = element.getAttribute('style');" +
                              "element.setAttribute('style', original_style + \";" +
                              "background: yellow; border: 2px solid red;\");" +
                              "setTimeout(function(){element.setAttribute('style', original_style);}, 1000);", element);
                 
