#!/usr/bin/env python -u
"""
VAutomation Test Engine Class
"""

from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait # available since 2.4.0
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.expected_conditions import element_to_be_clickable
import time, os
from pprint import pprint
import subprocess, signal, select
from BaseRunner import BaseRunner


class Runner_VCAH001_31_30L_30(BaseRunner):
    """
    """
    baseurl = None

    driver = None

    loc_login_usr = 'admin_user_name'

    loc_login_pwd = 'admin_password'

    loc_login_apply = 'apply_btn'

    loc_ipv6_wan_apply = 'Apply'

    loc_logout_btn = 'logout_btn'

    loc_ipv6wan_enable = 'ipv6_on'

    loc_ipv6_wan_type = 'ipv6_wan_type'

    loc_ipv6_wan_6rd_type_static = 'ipv6_wan_6rd_type_static'

    loc_ipv6_wan_6rd_type_dhcp = 'ipv6_wan_6rd_type_dhcp'

    loc_ipv6_wan_dns1 = 'ipv6_wan_dns1'

    loc_ipv6_wan_dns2 = 'ipv6_wan_dns2'

    loc_ipv6_wan_dns_dhcp = 'ipv6_wan_dns_dhcp'

    loc_ipv6_wan_dns_static = 'ipv6_wan_dns_static'

    #loc_ipv6_wansetting

    url_adv_page = '/advancedsetup_schedulingaccess.html'

    url_uti_page = '/utilities_reboot.html'

    url_reset_page = '/utilities_restoredefaultsettings.html'

    url_wan_setting_page = '/advancedsetup_wanipaddress.html'

    url_wan_ipv6_page = '/ipv6_wansetting.html'

    url_wan_ipv6_cgi = '/ipv6_wansetting.cgi'


    #current_result = False

    def __init__(self, driver):
        """
        """

        dut_ip = os.getenv('G_PROD_IP_BR0_0_0')

        if not dut_ip:
            print 'AT_ERROR : no G_PROD_IP_BR0_0_0 specified'
            exit(1)
        else:
            self.baseurl = 'http://' + dut_ip

        self.driver = driver


    def login(self):
        """
        login
        True
        False
        """

        print 'to login'

        driver = self.driver

        username = os.getenv('U_DUT_HTTP_USER')

        if not username:
            print 'AT_ERROR : must specified username'
            return False

        userpass = os.getenv('U_DUT_HTTP_PWD')

        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False

        driver.get(self.baseurl)

        if self.wait_id_exist(self.loc_login_usr):

            try:
                input_usr = driver.find_element_by_id(self.loc_login_usr)
                print 'AT_INFO : original username in input : ', input_usr.get_attribute('value')
                #print 'AT_INFO : username input status :', str(input_usr.is_enabled())

                #chkbox_showpwd = driver.find_element_by_id('show_password')

                #print 'AT_INFO : show_password status --', str(chkbox_showpwd.is_enabled())
                #print 'AT_INFO : show_password selected -- ', str(chkbox_showpwd.is_selected())
                #time.sleep(2)
                #print 'AT_INFO : original username in input : ',driver.find_element_by_id(self.loc_login_usr).text
                input_usr.clear()
                input_usr.send_keys(username)
                #return False

            except Exception, e:
                print 'AT_ERROR : error occured in login '
                print e
                return False


        else:
            if self.wait_id_exist('selected'):
                print 'Already logged in !'
                return True
            else:
                print 'ERROR in getting main / login page '
                return False

        if self.wait_id_exist(self.loc_login_pwd):
            try:
                input_psw = driver.find_element_by_id(self.loc_login_pwd)
                input_psw.clear()
                input_psw.send_keys(userpass)

            except:
                print 'AT_ERROR : error occured in login'
                return False
        else:
            print 'AT_ERROR : error occured in login'
            return False

        if self.wait_id_exist(self.loc_login_apply):

            input_apply = driver.find_element_by_id(self.loc_login_apply)

            input_apply.click()

            if self.wait_id_exist('selected'):
                print 'Already logged in !'
                #return True
            else:
                print 'ERROR in getting main / login page '
                return False

        else:
            print 'AT_ERROR : error occured in login'
            return False

        return True


    def logout(self):
        """
        logout 
        True
        False
        """
        self.adv_page()

        driver = self.driver

        if self.wait_id_exist(self.loc_logout_btn):

            logout_btn = driver.find_element_by_id(self.loc_logout_btn)

            logout_btn.click()

        else:
            print 'AT_ERROR : error finding logout_btn'
            return False

        return True


    def adv_page(self):
        driver = self.driver

        driver.get(self.baseurl + self.url_adv_page)


    def uti_page(self):
        driver = self.driver

        driver.get(self.baseurl + self.url_uti_page)


    def reset_page(self):
        driver = self.driver

        driver.get(self.baseurl + self.url_reset_page)


    def wan_setting_page(self):
        driver = self.driver

        driver.get(self.baseurl + self.url_wan_setting_page)


    def wan_ipv6_page(self):
        driver = self.driver
        driver.get(self.baseurl + self.url_wan_ipv6_page)


    def wanSetting(self, protocol='IPOE'):
        self.wan_setting_page()
        driver = self.driver
        current_result = True

        try:
            WebDriverWait(driver, 10).until(lambda driver: driver.find_element_by_id('isp_protocol_id'))

            print driver.current_url

            if protocol == 'IPOE':
                Select(driver.find_element_by_id("isp_protocol_id")).select_by_visible_text("IPoE")
            elif protocol == 'PPPOE':
                Select(driver.find_element_by_id("isp_protocol_id")).select_by_visible_text("PPPoE")

                driver.find_element_by_id("showpass").click()
                try:
                    WebDriverWait(driver, 10).until(
                        lambda driver: driver.find_element_by_xpath("id('tab_2')/tbody/tr[1]/td[2]/input"))
                    input_ppp_usr = driver.find_element_by_xpath("id('tab_2')/tbody/tr[1]/td[2]/input")
                    input_ppp_usr.clear()
                    input_ppp_usr.send_keys("autotest001")
                except Exception, e:
                    print 'cannot find ppp_username by id'
                    print 'ERROR ', e
                    #self.abort()
                    current_result = False

                try:
                    WebDriverWait(driver, 10).until(lambda driver: driver.find_element_by_id("ppp_password"))

                    driver.find_element_by_id("ppp_password").clear()
                    driver.find_element_by_id("ppp_password").send_keys("111111")
                except Exception, e:
                    print 'cannot find ppp_password by id'
                    print 'ERROR ', e
                    current_result = False
                    #self.abort()

            driver.find_element_by_id("apply_btn").click()

            #    wansetup.cmd

            if self.check_url(self.baseurl + '/wansetup.cmd', 60):
                if self.check_url(self.baseurl + '/advancedsetup_wanipaddress.html', 120):
                    print 'page advancedsetup_wanipaddress show up after wan setting'
                    #self.logout()
                else:
                    print 'ERROR : page advancedsetup_wanipaddress show up after wan setting'
                    #self.logout()
                    #self.abort()
                    current_result = False

            else:
                print 'ERROR : page wansetup.cmd didnt show up after apply'
                #self.logout()
                #self.abort()
                current_result = False

                #time.sleep(15)
        except Exception, e:
            print 'ERROR', e
            current_result = False
            #self.logout()
            #self.abort()

        os.environ.update({
            'current_result': str(current_result)
        })

        return current_result


    def IPV6WAN(self, v4_protocol, v6_protocol, v4_6rd, dns_type):
        """
        the setting of IPV6
        
        True
        False
        
        """

        self.wan_ipv6_page()

        driver = self.driver
        current_result = True

        id = ''

        try:
            self.wait_id_exist(self.loc_ipv6wan_enable)

            btn_enable_ipv6wan = driver.find_element_by_id(self.loc_ipv6wan_enable)

            print 'AT_INFO : btn_enable_ipv6wan status -- ' + str(btn_enable_ipv6wan.is_enabled())
            print 'AT_INFO : btn_enable_ipv6wan is selected -- ' + str(btn_enable_ipv6wan.is_selected())

            btn_enable_ipv6wan.click()

        except Exception, e:
            print 'ERROR', e
            current_result = False

        try:
            self.wait_id_exist(self.loc_ipv6_wan_type)

            select_ipv6_wan_type = Select(driver.find_element_by_id("ipv6_wan_type"))

            print 'AT_INFO : currently value of select_ipv6_wan_type :' + select_ipv6_wan_type.first_selected_option.text
            #print len(select_ipv6_wan_type.all_selected_options)

            #print '>' + select_ipv6_wan_type.all_selected_options[0].text + '<'

            #current_result=False

            if v6_protocol == '6RD':
                select_ipv6_wan_type.select_by_visible_text('6rd')

            elif v6_protocol == 'DHCP':
                select_ipv6_wan_type.select_by_visible_text('DHCPv6')
            elif v6_protocol == 'STATIC':
                select_ipv6_wan_type.select_by_visible_text('Static IPv6')
            elif v6_protocol == 'PPPOE':
                select_ipv6_wan_type.select_by_visible_text('PPPv6')

        except Exception, e:
            print 'ERROR', e
            current_result = False

        try:
            if v4_6rd == 'DHCP':
                self.wait_id_exist(self.loc_ipv6_wan_6rd_type_dhcp)
                radio_ipv6_wan_6rd_type_dhcp = driver.find_element_by_id(self.loc_ipv6_wan_6rd_type_dhcp)
                radio_ipv6_wan_6rd_type_dhcp.click()
            elif v4_6rd == 'STATIC':
                self.wait_id_exist(self.loc_ipv6_wan_6rd_type_static)
                radio_ipv6_wan_6rd_type_static = driver.find_element_by_id(self.loc_ipv6_wan_6rd_type_static)
                radio_ipv6_wan_6rd_type_static.click()
        except Exception, e:
            print 'ERROR', e
            current_result = False

        try:
            if v4_6rd == 'DHCP':
                if dns_type == 'DEF':
                    print 'AT_INFO : dns type -- default'
                    self.wait_id_exist(self.loc_ipv6_wan_dns_dhcp)
                    radio_loc_ipv6_wan_dns_dhcp = driver.find_element_by_id(self.loc_ipv6_wan_dns_dhcp)
                    radio_loc_ipv6_wan_dns_dhcp.click()
                elif dns_type == 'CUSTOM':
                    print 'AT_INFO : dns type -- static'
                    self.wait_id_exist(self.loc_ipv6_wan_dns_static)
                    radio_loc_ipv6_wan_dns_static = driver.find_element_by_id(self.loc_ipv6_wan_dns_static)
                    radio_loc_ipv6_wan_dns_static.click()

        except Exception, e:
            print 'ERROR', e
            current_result = False

        try:
            if dns_type == 'CUSTOM':
                ipv6_wan_dns1 = os.getenv('U_CUSTOM_IPV6_WAN_DNS1')
                ipv6_wan_dns2 = os.getenv('U_CUSTOM_IPV6_WAN_DNS2')

                if ipv6_wan_dns1 and ipv6_wan_dns2:
                    self.wait_id_exist(self.loc_ipv6_wan_dns1)
                    self.wait_id_exist(self.loc_ipv6_wan_dns2)

                    input_dns1 = driver.find_element_by_id(self.loc_ipv6_wan_dns1)
                    input_dns2 = driver.find_element_by_id(self.loc_ipv6_wan_dns2)

                    print 'AT_INFO : current value of DNS1:' + input_dns1.get_attribute('value')
                    print 'AT_INFO : current value of DNS2:' + input_dns2.get_attribute('value')

                    input_dns1.clear()
                    input_dns1.send_keys(ipv6_wan_dns1)

                    input_dns2.clear()
                    input_dns2.send_keys(ipv6_wan_dns2)

                #                    self.wait_link_text_exist(self.loc_ipv6_wan_apply)
                #
                #                    btn_apply = driver.find_element_by_link_text(self.loc_ipv6_wan_apply)
                #
                #                    btn_apply.click()



                else:
                    print 'AT_ERROR : must specify var : U_CUSTOM_IPV6_WAN_DNS1 U_CUSTOM_IPV6_WAN_DNS2'
                    current_result = False
                #else:
            self.wait_link_text_exist(self.loc_ipv6_wan_apply)

            btn_apply = driver.find_element_by_link_text(self.loc_ipv6_wan_apply)

            btn_apply.click()

            if self.check_url(self.baseurl + self.url_wan_ipv6_cgi, 60):
                print 'INFO : url_wan_ipv6_cgi show up after apply'
                if self.check_url(self.baseurl + self.url_wan_ipv6_page, 180):
                    print 'INFO : ipv6 setting passed'

                    current_result = True
                    #self.logout()
                else:
                    print 'ERROR : ipv6 setting failed'
                    current_result = False
                    #self.abort()
            else:
                print 'ERROR : url_wan_ipv6_cgi didnt show up'
                current_result = False

        except Exception, e:
            print 'ERROR', e
            current_result = False

        time.sleep(3)

        os.environ.update({
            'current_result': str(current_result)
        })

        return current_result

    def resetDUT(self):

        #self.uti_page()
        current_result = True

        self.reset_page()

        driver = self.driver

        restore_url = '//a[@href=\'javascript:doRestoreFactoryDefaults(4);\']'

        try:
            WebDriverWait(driver, 10).until(lambda driver: driver.find_element_by_xpath(restore_url))

            print driver.current_url
            input_adv = driver.find_element_by_xpath(restore_url)

            input_adv.click()

            driver.find_element_by_link_text("OK").click()

            #    restoreinfo.html
            #    utilities_restoredefaultsettings.html
            if self.check_url(self.baseurl + '/restoreinfo.html', 60):
                print 'INFO : restoreinfo.html show up after apply'
                if self.check_url(self.baseurl + '/utilities_restoredefaultsettings.html', 180):
                    print 'INFO : redefault passed'

                    current_result = True
                    #self.logout()
                else:
                    print 'ERROR : redefault failed'
                    current_result = False
                    #self.abort()
            else:
                print 'ERROR : restoreinfo.html didnt show up'
                current_result = False
                #self.abort()

        except:
            print 'error in find restore'
            #self.quit_drv()
            #exit(1)
            current_result = False

        os.environ.update({
            'current_result': str(current_result)
        })

        return current_result


######################################################


hash_runners = {
    'CAH001-31.30L.30': Runner_VCAH001_31_30L_30,
}

#    CAH001-31.30L.30
def_runner = 'CAH001-31.30L.30'


def getRunner():
    """
    """
    prod_ver = os.getenv('U_DUT_FW_VERSION')

    if not prod_ver:
        print 'AT_ERROR : must specified U_DUT_FW_VERSION'
        return False

    runner = None
    for (k, v) in hash_runners.items():
        if k == prod_ver:
            runner = v
            print '==', 'Find specified Runner for Version ' + prod_ver
            break
    if not runner:
        print '==', 'Not find specified Runner for Version ' + str(prod_ver)
        print '==', 'Using the default Runner for Version ' + def_runner
        runner = hash_runners[def_runner]
        #return runner(prod_ver)
    return runner
    
    
    

