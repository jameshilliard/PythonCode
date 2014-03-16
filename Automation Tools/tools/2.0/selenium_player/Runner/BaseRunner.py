#!/usr/bin/env python -u
"""
VAutomation Test Engine Class
"""

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support.ui import Select
import time, os
from pprint import pprint
import subprocess, signal, select


class BaseRunner():
    """
    """
    baseurl = None

    driver = None

    #    loc_login_usr = 'admin_user_name'
    #
    #    loc_login_pwd = 'admin_password'
    #
    #    loc_login_apply = 'apply_btn'
    #
    #    loc_logout_btn = 'logout_btn'
    #
    #    url_adv_page = '/advancedsetup_schedulingaccess.html'
    #
    #    url_uti_page = '/utilities_reboot.html'
    #
    #    url_reset_page = '/utilities_restoredefaultsettings.html'
    #
    #    url_wan_setting_page = '/advancedsetup_wanipaddress.html'


    #current_result = False

    def __init__(self, driver):
        """
        """

    #        dut_ip = os.getenv('G_PROD_IP_BR0_0_0')
    #
    #        if not dut_ip:
    #            print 'AT_ERROR : no G_PROD_IP_BR0_0_0 specified'
    #            exit(1)
    #        else:
    #            self.baseurl = 'http://' + dut_ip
    #
    #        self.driver = driver


    def wait_link_text_exist(self, id, to=10):
        """
        wait till element present
        True
        False
        """

        #print 'in function : wait_id_exist'
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

        #print 'in function : wait_id_exist'
        driver = self.driver

        try:
            WebDriverWait(driver, to).until(lambda driver: driver.find_element_by_id(id))

            print driver.current_url

        except:
            print 'AT_ERROR : no such element of id exist -- %s' % (id)
            return False

        print 'AT_INFO : the element of id %s exists' % (id)
        return True


    def login(self):
        """
        login
        True
        False
        """


    def logout(self):
        """
        logout 
        True
        False
        """

        driver.get(self.baseurl + self.url_wan_setting_page)


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
                    
            
    
        
        
