from BaseRunner import BaseRunner
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support.ui import Select
import os


class Runner_V33_120L_01C(BaseRunner):
    """
    """
    driver = None
    base_url = None

    def __init__(self, driver, case_id, product_type, product_version, base_url, debug):
        """
        """
        BaseRunner.__init__(self, driver, case_id, product_type, product_version, base_url, debug)

    def login(self):
        """
        login
        True
        False
        """

        print 'to login'

        driver = self.driver
        driver.get(self.base_url)

        username = os.getenv('U_DUT_HTTP_USER', 'admin')

        if not username:
            print 'AT_ERROR : must specified username'
            return False

        userpass = os.getenv('U_DUT_HTTP_PWD', '1')

        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False

        print 'Try to login : <%s>' % self.wait_id_exist('admin_user_name')
        al_login = driver.find_element_by_css_selector("#login_info > a.button1 > span")
        if al_login.is_displayed():
            print "AT_INFO : already log in"
        else:
            if self.wait_id_exist('admin_user_name'):
                driver.find_element_by_id("admin_user_name").clear()
                driver.find_element_by_id("admin_user_name").send_keys(username)
            if self.wait_id_exist("admin_password"):
                driver.find_element_by_id("admin_password").clear()
                print 'The login password is :<%s>' % userpass
                driver.find_element_by_id("admin_password").send_keys(userpass)
            #            if self.wait_id_exist("confirm_password"):
            #                driver.find_element_by_id("confirm_password").clear()
            #                print 'The login confirm_password is :<%s>'%userpass
            #                driver.find_element_by_id("confirm_password").send_keys(userpass)
            driver.find_element_by_css_selector("a.button1 > span").click()

        return True

    def tr_setting(self):
        """
        """

        page_uri = '1sp_tr69.html'

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        if self.goto(page_uri):
            elem_acsusr = self.wait_elem_enabled(how='css selector', what="input[name=\"ACSUSERNAME\"]")
            if elem_acsusr:
                elem_acsusr.clear()
                elem_acsusr.send_keys("actiontec")
            else:
                return False

            elem_acspwd = self.wait_elem_enabled(how='css selector', what="input[name=\"ACSPASSWORD\"]")
            if elem_acspwd:
                elem_acspwd.clear()
                elem_acspwd.send_keys("actiontec")
            else:
                return False
                ####################################################################################################
            elem_acsrequsr = self.wait_elem_enabled(how='css selector',
                                                    what="input[name=\"ACS_ConnectionRequestUsername\"]")
            if elem_acsrequsr:
                elem_acsrequsr.clear()
                elem_acsrequsr.send_keys("actiontec")
            else:
                return False

            elem_acsreqpwd = self.wait_elem_enabled(how='css selector',
                                                    what="input[name=\"ACS_ConnectionRequestPassword\"]")
            if elem_acsreqpwd:
                elem_acsreqpwd.clear()
                elem_acsreqpwd.send_keys("actiontec")
            else:
                return False
                ################################################################################################
            elem_acspriodic = self.wait_elem_enabled(how='css selector',
                                                     what="input[name=\"ACS_PeriodicInformInterval\"]")
            if elem_acspriodic:
                elem_acspriodic.clear()
                elem_acspriodic.send_keys("60")
            else:
                return False
                ##########################################################################################################
            elem_acsurl = self.wait_elem_enabled(how='css selector', what="input[name=\"ACSURL\"]")
            if elem_acsurl:
                elem_acsurl.clear()
                elem_acsurl.send_keys("http://192.168.55.254:1234/acs")
            else:
                return False
                #########################################################################
            elem_enable = self.wait_elem_enabled(how='xpath',
                                                 what="/html/body/div/div[2]/div[2]/form/div/table[2]/tbody/tr/td[2]/input")
            if elem_enable:
                elem_enable.click()
            else:
                return False

            self.screen_shot('tr69settings')

            elem_apply = self.wait_elem_enabled(how='css selector', what="span")
            if elem_apply:
                elem_apply.click()
            else:
                return False

                #    <title>Advanced Setup - TR-069</title>    <title>Thank you.</title>
            #             return self.waiting_page('Thank you.', 'Advanced Setup - TR-069')
            import time

            time.sleep(10)
        else:
            return False

        return True

    def telnet_setting(self, params={}):
        """
        status [ disabled local remote local+remote ]
        
        id="remote_management_enabled"    id="remote_management_disabled"
        id="local_telnet_enabled"        id="local_telnet_disabled"
        id="admin_user_name"    id="admin_password"
        
        <select id="remote_management_timeout" name="remote_management_timeout">
            <option value="0">No Idle Disconnect</option>
            <option value="1800">30 Minutes</option>
            <option value="43200">12 Hours</option>
            <option value="86400">1 Day</option>
            <option value="604800">7 Days</option>
        </select>
        
        /html/body/div/div[4]/div[2]/form/p[11]/a/span
        """

        idle_times = {
            '0': '0',
            #                       '15m':'900',
            '30m': '1800',
            #                       '1h':'3600',
            #                       '6h':'21600',
            '12h': '43200',
            '1d': '86400',
            #                       '3d':'259200',
            '7d': '604800',
        }

        page_uri = '1sp_remotetelnet.html'

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        if self.goto(page_uri):
            print 'on page %s now' % (page_uri)

            param_d = params

            if param_d.has_key('status'):
                status = param_d.get('status')
                print 'setting status to %s' % (status)

                if not status == 'disabled':
                    print 'going to set username & password'

                    if status == 'local':
                        print 'enabling local'
                        elem_enable_local = self.wait_elem_enabled(how='id', what='local_telnet_enabled')
                        if elem_enable_local:
                            elem_enable_local.click()
                        else:
                            return False

                        print 'disabling remote'
                        elem_disable_remote = self.wait_elem_enabled(how='id', what='remote_management_disabled')
                        if elem_disable_remote:
                            elem_disable_remote.click()
                        else:
                            return False

                    if status == 'remote':
                        print 'enabling remote'
                        elem_enable_remote = self.wait_elem_enabled(how='id', what='remote_management_enabled')
                        if elem_enable_remote:
                            elem_enable_remote.click()
                        else:
                            return False

                        print 'disabling local'
                        elem_disable_local = self.wait_elem_enabled(how='id', what='local_telnet_disabled')
                        if elem_disable_local:
                            elem_disable_local.click()
                        else:
                            return False

                    if status == 'local+remote':
                        print 'enabling remote'
                        elem_enable_remote = self.wait_elem_enabled(how='id', what='remote_management_enabled')
                        if elem_enable_remote:
                            elem_enable_remote.click()
                        else:
                            return False

                        print 'enabling local'
                        elem_enable_local = self.wait_elem_enabled(how='id', what='local_telnet_enabled')
                        if elem_enable_local:
                            elem_enable_local.click()
                        else:
                            return False

                    U_DUT_TELNET_USER = os.getenv('U_DUT_TELNET_USER', 'admin')
                    U_DUT_TELNET_PWD = os.getenv('U_DUT_TELNET_PWD', '1')

                    elem_usr = self.wait_elem_enabled(how='id', what='admin_user_name')
                    if elem_usr:
                        elem_usr.clear()
                        elem_usr.send_keys(U_DUT_TELNET_USER)
                    else:
                        return False

                    elem_pwd = self.wait_elem_enabled(how='id', what='admin_password')
                    if elem_pwd:
                        elem_pwd.clear()
                        elem_pwd.send_keys(U_DUT_TELNET_PWD)
                    else:
                        return False
                else:
                    print 'disabling remote'
                    elem_disable_remote = self.wait_elem_enabled(how='id', what='remote_management_disabled')
                    if elem_disable_remote:
                        elem_disable_remote.click()
                    else:
                        return False

                    print 'disabling local'
                    elem_disable_local = self.wait_elem_enabled(how='id', what='local_telnet_disabled')
                    if elem_disable_local:
                        elem_disable_local.click()
                    else:
                        return False

            if param_d.has_key('idle_time'):
                idle_time = param_d.get('idle_time')
                print 'setting idle_time to %s' % (idle_time)

                elem_idle_time = self.wait_elem_enabled(how='id', what='remote_management_timeout')
                if elem_idle_time:
                    Select(elem_idle_time).select_by_value(idle_times.get(idle_time))
                else:
                    return False
            else:
                if not status == 'disabled':
                    print 'setting idle_time to 7d'

                    elem_idle_time = self.wait_elem_enabled(how='id', what='remote_management_timeout')
                    if elem_idle_time:
                        Select(elem_idle_time).select_by_value(idle_times.get('0'))
                    else:
                        return False

            self.screen_shot('telnet')

            elem_apply = self.wait_elem_enabled(how='css selector', what="span")
            if elem_apply:
                elem_apply.click()
            else:
                return False

            return self.waiting_page('Thank You.', 'Advanced Setup - Remote Management - Remote Telnet')
            #######################################################################
        else:
            return False

        return True

    def restore_default(self):
        """
        """

        page_uri = 'utilities_restoredefaultsettings.html'

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        if self.goto(page_uri):
            print 'on page %s now' % (page_uri)
            #    driver.find_element_by_xpath("//div[@id='content_right_contentarea']/table/tbody/tr[5]/td[2]/a/span").click()
            elem_reset = self.wait_elem_enabled(how='xpath',
                                                what="//div[@id='content_right_contentarea']/table/tbody/tr[4]/td[2]/a/span")
            if elem_reset:
                elem_reset.click()
            else:
                return False

            #             self.assertEqual("Restoring the modem to default settings will remove all custom user configurations. Click OK to restore factory default settings.", self.close_alert_and_get_its_text())
            #             import time
            #             time.sleep(3)
            try:
                self.close_alert_and_get_its_text()
            except Exception, e:
                print str(e)

            return self.waiting_page('Reboot Info', 'Home')
            #######################################################################
        else:
            return False
        pass

    def waiting_page(self, first_title, second_title):
        if self.check_title(first_title, 60):
            if self.check_title(second_title, 120):
                print 'page %s show up ' % (second_title)
                return True
            else:
                print 'ERROR : page %s didnt show up ' % (second_title)
                return False
        else:
            print 'ERROR : page %s didnt show up ' % (first_title)
            return False
        pass

    def wan_layer3_setting(self, params={}):
        """
        isp_protocol : IPoE      PPPoE     TRANSPARENT     STATIC
        dns : 10.20.10.10,168.95.1.1
        static_ip : 192.168.55.1
        
        <title>Advanced Setup - IP Addressing - WAN IP Address</title>
        advancedsetup_wanipaddress.html
        """
        isp_protocols = {
            'IPoE': 'rfc_1483_dhcp',
            'PPPoE': 'PPPoE',
            'TRANSPARENT': 'rfc_1483_transparent_bridging',
            'STATIC': 'rfc_1483_static_ip',
        }
        print '--------------------------------------'
        print 'subrf3 : pppoe username'
        print 'subrf5 : pppoe password'
        print 'ipadd   :  static ip addr'
        print 'submask : static submask'
        print 'gateadd : static gate addr'
        print 'subrf24 : static dns'
        print 'subrf27 : static dns1'
        print 'subrf29 : static dns2'
        print 'subrf22 : dynamic dns'
        print isp_protocols
        print '---------------------------------------'
        page_uri = 'advancedsetup_wanipaddress.html'

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        if self.goto(page_uri):
            print 'on page %s now' % (page_uri)

            param_d = params

            if param_d.has_key('isp_protocol'):
                isp_protocol = param_d.get('isp_protocol')
                print 'setting isp_protocol to %s' % (isp_protocol)

                elem_isp = self.wait_elem_enabled(how='id', what=isp_protocols.get(isp_protocol))
                if elem_isp:
                    elem_isp.click()
                    if isp_protocol == 'PPPoE':
                        ppp_usr = os.getenv('U_DUT_CUSTOM_PPP_USER', 'autotest001')
                        ppp_pwd = os.getenv('U_DUT_CUSTOM_PPP_PWD', '111111')

                        elem_ppp_usr = self.wait_elem_enabled(how='id', what='subrf3')
                        if elem_ppp_usr:
                            elem_ppp_usr.clear()
                            elem_ppp_usr.send_keys(ppp_usr)
                        else:
                            return False

                        elem_ppp_pwd = self.wait_elem_enabled(how='id', what='subrf5')
                        if elem_ppp_pwd:
                            elem_ppp_pwd.clear()
                            elem_ppp_pwd.send_keys(ppp_pwd)
                        else:
                            return False
                    elif isp_protocol == 'STATIC':
                        static_ip = param_d.get('static_ip')
                        static_mask = param_d.get('static_mask')
                        static_gw = param_d.get('static_gw')

                        elem_static_ip = self.wait_elem_enabled(how='name', what='ipadd')
                        if elem_static_ip:
                            elem_static_ip.clear()
                            elem_static_ip.send_keys(static_ip)
                        else:
                            return False

                        elem_static_mask = self.wait_elem_enabled(how='name', what='submask')
                        if elem_static_mask:
                            elem_static_mask.clear()
                            elem_static_mask.send_keys(static_mask)
                        else:
                            return False

                        elem_static_gw = self.wait_elem_enabled(how='name', what='gateadd')
                        if elem_static_gw:
                            elem_static_gw.clear()
                            elem_static_gw.send_keys(static_gw)
                        else:
                            return False
                else:
                    return False
                #################################################
            if param_d.has_key('dns'):
                #     dynamic -- id('subrf22')   || static --  id('subrf24')
                elem_static_dns = self.wait_elem_enabled(how='id', what='subrf24')
                if elem_static_dns:
                    elem_static_dns.click()
                    dns1, dns2 = param_d.get('dns').split(',')

                    if not dns1 == '-1':
                        elem_static_dns1 = self.wait_elem_enabled(how='id', what='subrf27')
                        if elem_static_dns1:
                            elem_static_dns1.clear()
                            elem_static_dns1.send_keys(dns1)
                        else:
                            return False

                    if not dns2 == '-1':
                        elem_static_dns2 = self.wait_elem_enabled(how='id', what='subrf29')
                        if elem_static_dns2:
                            elem_static_dns2.clear()
                            elem_static_dns2.send_keys(dns2)
                        else:
                            return False
                else:
                    return False
            else:
                elem_dyna_dns = self.wait_elem_enabled(how='id', what='subrf22')
                if elem_dyna_dns:
                    elem_dyna_dns.click()
                else:
                    return False
                ################################################
            #     applyBtn
            self.screen_shot(driver.title)

            driver.find_element_by_css_selector("a.button1 > span").click()

            return self.waiting_page('Thank you', 'Advanced Setup - IP Addressing - WAN IP address')
            #######################################################################
        else:
            return False
        pass

    def configure_wan(self, params={}):
        """
        """
        param_d = params

        if param_d.has_key('wan_type') or param_d.has_key('line_mode') or param_d.has_key('vpi_vci') or param_d.has_key(
                'tag'):
            print 'L2 setting is needed'
            print 'AT_INFO : BAR1KH no broadband setting page,No need set it!'
            pass
        #            if not  self.wan_layer2_setting(param_d):
        #                return False
        if param_d.has_key('isp_protocol') or param_d.has_key('dns') or param_d.has_key('static_ip'):
            print 'L3 setting is needed'
            if not self.wan_layer3_setting(param_d):
                return False
            #          pass
        return True

    def logout(self):
        """
        logout 
        True
        False
        """
        print 'to logout'
        driver = self.driver
        driver.get(self.base_url)
        al_login = driver.find_element_by_css_selector("#login_info > a.button1 > span")
        #        print 'Already login : <%s>'%al_login
        if al_login:
            try:
                al_login.click()
            except:
                print 'Already logout...'
        return True


hash_runners = {
    '33.120L.01c': Runner_V33_120L_01C,
}

def_runner = '33.120L.01c'


def getRunner(product_version=None):
    """
    """
    if not product_version:
        if os.getenv('U_CUSTOM_CURRENT_FW_VER'):
            product_version = os.getenv('U_CUSTOM_CURRENT_FW_VER')
        else:
            print 'AT_ERROR : must specified U_CUSTOM_CURRENT_FW_VER'
            return False

    runner = None
    for (k, v) in hash_runners.items():
        if k == product_version:
            runner = v
            print '==', 'Find specified Runner for Version ' + product_version
            break
    if not runner:
        print '==', 'Not find specified Runner for Version ' + str(product_version)
        print '==', 'Using the default Runner for Version ' + def_runner
        runner = hash_runners[def_runner]
    return runner
