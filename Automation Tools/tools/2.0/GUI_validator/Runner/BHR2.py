from BaseRunner import BaseRunner
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support.ui import Select
import os


class Runner_v20_19_0(BaseRunner):
    """
    """
    driver = None
    base_url = None

    def __init__(self, driver, case_id, product_type, product_version, base_url, debug):
        """
        """
        BaseRunner.__init__(self, driver, case_id, product_type, product_version, base_url, debug)

    def waiting_page(self):
        import time

        time.sleep(5)
        return True

    def restore_default(self):
        """
        try: self.assertEqual("Please wait, system is now restoring factory defaults...", driver.find_element_by_css_selector("font").text)
        except AssertionError as e: self.verificationErrors.append(str(e))
        
        css selector
        """

        driver = self.driver

        active_page_str = self.get_current_page()

        if active_page_str == 'page_home_act_vz':
            print 'on page_home_act_vz'
        else:
            print 'go to home page'
            elem_home = self.wait_elem_enabled(how='name', what='actiontec_topbar_main')
            if elem_home:
                elem_home.click()
            else:
                return False

        elem_adv = self.wait_elem_enabled(how='css selector', what="img[name=\"actiontec_topbar_adv_setup\"]")
        if elem_adv:
            elem_adv.click()
        else:
            return False

        elem_yes = self.wait_elem_enabled(how='link text', what="Yes")
        if elem_yes:
            elem_yes.click()
        else:
            return False

        elem_reset = self.wait_elem_enabled(how='link text', what="Restore Defaults")
        if elem_reset:
            elem_reset.click()
        else:
            return False

        elem_mimic = self.wait_elem_enabled(how='name', what="onclick=\"javascript:mimic_button(")
        if elem_mimic:
            elem_mimic.click()
        else:
            return False

        elem_OK = self.wait_elem_enabled(how='link text', what="OK")
        if elem_OK:
            elem_OK.click()
        else:
            return False

        import time

        time.sleep(75)

        return True

    #         pass

    def go_to_adv(self):
        """
        """
        driver = self.driver

        active_page_str = self.get_current_page()

        if active_page_str == 'page_home_act_vz':
            print 'on page_home_act_vz'
        else:
            print 'go to home page'
            elem_home = self.wait_elem_enabled(how='name', what='actiontec_topbar_main')
            if elem_home:
                elem_home.click()
            else:
                return False

        elem_adv = self.wait_elem_enabled(how='css selector', what="img[name=\"actiontec_topbar_adv_setup\"]")
        if elem_adv:
            elem_adv.click()
        else:
            return False

        elem_yes = self.wait_elem_enabled(how='link text', what="Yes")
        if elem_yes:
            elem_yes.click()
        else:
            return False

        return True


    def telnet_setting(self, params={}):
        """
        status [ disabled local remote local+remote ]

        Local Administration
        Remote Administration
        
        """

        local_console_link = 'Local Administration'
        remote_console_link = 'Remote Administration'

        driver = self.driver


        def screen_shot_apply(fn):
            self.screen_shot(fn)

            elam_apply = self.wait_elem_enabled(how='link text', what="Apply")
            if elam_apply:
                elam_apply.click()
            else:
                return False

            return True

        def setting_local(disable=False):
            self.go_to_adv()

            elem_telnet = self.wait_elem_enabled(how='link text', what=local_console_link)
            if elem_telnet:
                elem_telnet.click()
            else:
                return False

            elem_cbx = self.wait_elem_enabled(how='css selector', what="#sec_incom_telnet_pri_")
            if elem_cbx:
                if disable:
                    if elem_cbx.is_selected():
                        elem_cbx.click()
                else:
                    if not elem_cbx.is_selected():
                        elem_cbx.click()

            if not screen_shot_apply('local_telnet'):
                return False
            else:
                return True

            return True

        def setting_remote(disable=False):
            self.go_to_adv()

            elem_telnet = self.wait_elem_enabled(how='link text', what=remote_console_link)
            if elem_telnet:
                elem_telnet.click()
            else:
                return False

            elem_cbx = self.wait_elem_enabled(how='css selector', what="#is_telnet_primary_")
            if elem_cbx:
                if disable:
                    if elem_cbx.is_selected():
                        elem_cbx.click()
                else:
                    if not elem_cbx.is_selected():
                        elem_cbx.click()

            if not screen_shot_apply('remote_telnet'):
                return False
            else:
                return True

            return True

        status = params.get('status')

        if status == 'local':
            if not setting_local():
                return False
            if not setting_remote(disable=True):
                return False
            return True
        elif status == 'remote':
            if not setting_remote():
                return False
            if not setting_local(disable=True):
                return False
            return True
        elif status == 'local+remote':
            if not setting_local():
                return False
            if not setting_remote():
                return False
            return True
        elif status == 'disabled':
            if not setting_local(disable=True):
                return False
            if not setting_remote(disable=True):
                return False
            return True

            #######################################################################

        return True

    def wan_layer2_setting(self, params={}):
        return True

    def get_current_page(self):
        import re
        import urllib

        driver = self.driver

        current_url = driver.current_url
        print 'current url :%s' % (current_url)

        m_active_page = r'\&active\%5fpage\%5fstr=([^&]*)\&'

        rc = re.findall(m_active_page, current_url)
        print 'rc : %s' % (str(rc))

        if len(rc) > 0:
            return urllib.unquote(str(rc[0]))
        else:
            return 'page_home_act_vz'

    def go_to_wan_connection(self):

        active_page_str = self.get_current_page()

        if active_page_str == 'page_home_act_vz':
            print 'on page_home_act_vz'
        else:
            print 'go to home page'
            elem_home = self.wait_elem_enabled(how='name', what='actiontec_topbar_main')
            if elem_home:
                elem_home.click()
            else:
                return False

        elem_my_network = self.wait_elem_enabled(how='name', what='actiontec_topbar_HNM')
        if elem_my_network:
            elem_my_network.click()
            elem_network_connection = self.wait_elem_enabled(how='link text', what='Network Connections')
            if elem_network_connection:
                elem_network_connection.click()
            else:
                return False
        else:
            return False

        return True

    def input_static_ip(self, ip, mask, gw):
        """
        """
        ip0, ip1, ip2, ip3 = ip.split('.')

        static_ip0 = self.wait_elem_enabled(how='name', what='static_ip0')
        if static_ip0:
            static_ip0.clear()
            static_ip0.send_keys(ip0)
        else:
            return False

        static_ip1 = self.wait_elem_enabled(how='name', what='static_ip1')
        if static_ip1:
            static_ip1.clear()
            static_ip1.send_keys(ip1)
        else:
            return False

        static_ip2 = self.wait_elem_enabled(how='name', what='static_ip2')
        if static_ip2:
            static_ip2.clear()
            static_ip2.send_keys(ip2)
        else:
            return False

        static_ip3 = self.wait_elem_enabled(how='name', what='static_ip3')
        if static_ip3:
            static_ip3.clear()
            static_ip3.send_keys(ip3)
        else:
            return False
            #############################################################################
        mask0, mask1, mask2, mask3 = mask.split('.')

        static_netmask0 = self.wait_elem_enabled(how='name', what='static_netmask0')
        if static_netmask0:
            static_netmask0.clear()
            static_netmask0.send_keys(mask0)
        else:
            return False

        static_netmask1 = self.wait_elem_enabled(how='name', what='static_netmask1')
        if static_netmask1:
            static_netmask1.clear()
            static_netmask1.send_keys(mask1)
        else:
            return False

        static_netmask2 = self.wait_elem_enabled(how='name', what='static_netmask2')
        if static_netmask2:
            static_netmask2.clear()
            static_netmask2.send_keys(mask2)
        else:
            return False

        static_netmask3 = self.wait_elem_enabled(how='name', what='static_netmask3')
        if static_netmask3:
            static_netmask3.clear()
            static_netmask3.send_keys(mask3)
        else:
            return False
            #############################################################################
        gw0, gw1, gw2, gw3 = gw.split('.')

        static_gateway0 = self.wait_elem_enabled(how='name', what='static_gateway0')
        if static_gateway0:
            static_gateway0.clear()
            static_gateway0.send_keys(gw0)
        else:
            return False

        static_gateway1 = self.wait_elem_enabled(how='name', what='static_gateway1')
        if static_gateway1:
            static_gateway1.clear()
            static_gateway1.send_keys(gw1)
        else:
            return False

        static_gateway2 = self.wait_elem_enabled(how='name', what='static_gateway2')
        if static_gateway2:
            static_gateway2.clear()
            static_gateway2.send_keys(gw2)
        else:
            return False

        static_gateway3 = self.wait_elem_enabled(how='name', what='static_gateway3')
        if static_gateway3:
            static_gateway3.clear()
            static_gateway3.send_keys(gw3)
        else:
            return False

        return True

    def input_static_dns(self, dns1, dns2):
        if not dns1 == '-1':
            dns10, dns11, dns12, dns13 = dns1.split('.')

            primary_dns0 = self.wait_elem_enabled(how='name', what='primary_dns0')
            if primary_dns0:
                primary_dns0.clear()
                primary_dns0.send_keys(dns10)
            else:
                return False

            primary_dns1 = self.wait_elem_enabled(how='name', what='primary_dns1')
            if primary_dns1:
                primary_dns1.clear()
                primary_dns1.send_keys(dns11)
            else:
                return False

            primary_dns2 = self.wait_elem_enabled(how='name', what='primary_dns2')
            if primary_dns2:
                primary_dns2.clear()
                primary_dns2.send_keys(dns12)
            else:
                return False

            primary_dns3 = self.wait_elem_enabled(how='name', what='primary_dns3')
            if primary_dns3:
                primary_dns3.clear()
                primary_dns3.send_keys(dns13)
            else:
                return False
            #############################################################################
        if not dns2 == '-1':
            dns20, dns21, dns22, dns23 = dns2.split('.')

            secondary_dns0 = self.wait_elem_enabled(how='name', what='secondary_dns0')
            if secondary_dns0:
                secondary_dns0.clear()
                secondary_dns0.send_keys(dns20)
            else:
                return False

            secondary_dns1 = self.wait_elem_enabled(how='name', what='secondary_dns1')
            if secondary_dns1:
                secondary_dns1.clear()
                secondary_dns1.send_keys(dns21)
            else:
                return False

            secondary_dns2 = self.wait_elem_enabled(how='name', what='secondary_dns2')
            if secondary_dns2:
                secondary_dns2.clear()
                secondary_dns2.send_keys(dns22)
            else:
                return False

            secondary_dns3 = self.wait_elem_enabled(how='name', what='secondary_dns3')
            if secondary_dns3:
                secondary_dns3.clear()
                secondary_dns3.send_keys(dns23)
            else:
                return False

        return True

    def wan_layer3_setting(self, params={}):
        """
        isp_protocol : IPoE      PPPoE     TRANSPARENT     STATIC
        dns : 10.20.10.10,168.95.1.1
        static_ip : 192.168.55.1
        <OPTION  value="0">No IP Address</OPTION>
        <OPTION  value="2">Obtain an IP Address Automatically</OPTION>
        <OPTION  value="1">Use the Following IP Address</OPTION>
        """
        isp_protocols = {
            'IPoE': '2',
            'STATIC': '1',
        }
        isp_protocol = None
        page_uri = ''

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        param_d = params

        is_isp_given = True

        if not param_d.has_key('isp_protocol'):
            is_isp_given = False

        if self.goto(page_uri):
            self.get_current_page()
            #    Static
            if param_d.has_key('isp_protocol'):
                isp_protocol = param_d.get('isp_protocol')
            else:
                current_connection_type = driver.find_element_by_xpath(
                    "//td/table/tbody/tr[2]/td/table/tbody/tr[3]/td[3]").text
                print 'current_connection_type : %s' % (current_connection_type)
                if str(current_connection_type).lower() == 'dhcp':
                    isp_protocol = 'IPoE'
                elif str(current_connection_type).lower() == 'pppoe':
                    isp_protocol = 'PPPoE'
                elif str(current_connection_type).lower() == 'static':
                    isp_protocol = 'STATIC'
                else:
                    print 'AT_ERROR : no isp_protocol specified or detected'

            if not isp_protocol:
                print 'AT_ERROR : no isp_protocol specified or detected'
                return False

            print 'setting isp_protocol to %s' % (isp_protocol)

            if not self.go_to_wan_connection():
                return False
            #
            if isp_protocol == 'IPoE' or isp_protocol == 'STATIC':
                print 'go to PPPoE setting page first'
                element_wan_pppoe = self.wait_elem_enabled(how='link text', what='WAN PPPoE')
                if element_wan_pppoe:
                    element_wan_pppoe.click()
                    enable_disable_xpath = '/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table'
                    enable_disable_xpath += '/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]'
                    enable_disable_xpath += '/tbody/tr/td/table/tbody/tr[1]/td[2]/center/table/tbody/tr/td/span/table/tbody/tr/td/span/a'

                    elem_toggle_pppoe = self.wait_elem_enabled(how='xpath', what=enable_disable_xpath)
                    if elem_toggle_pppoe:
                        status_toggle_pppoe = elem_toggle_pppoe.text
                        print 'status_toggle_pppoe : %s' % (status_toggle_pppoe)
                        if status_toggle_pppoe == 'Disable':
                            elem_toggle_pppoe.click()

                            elem_apply_disconnect = self.wait_elem_enabled(how='link text', what='Apply')
                            if elem_apply_disconnect:
                                elem_apply_disconnect.click()
                            else:
                                print 'no confirmation appeared'
                        else:
                            print 'pppoe interface is not activated , no need to disable it'
                    else:
                        return False
                else:
                    return False

                if not self.go_to_wan_connection():
                    return False

                elem_IPoE = self.wait_elem_enabled(how='link text', what="Broadband Connection (Ethernet)")
                if elem_IPoE:
                    elem_IPoE.click()
                else:
                    return False

                elem_settings = self.wait_elem_enabled(how='link text', what="Settings")
                if elem_settings:
                    elem_settings.click()
                else:
                    return False

                if is_isp_given:
                    elem_ip_setting = self.wait_elem_enabled(how='id', what="ip_settings")
                    if elem_ip_setting:
                        Select(elem_ip_setting).select_by_value(isp_protocols.get(isp_protocol))
                    else:
                        return False

                if isp_protocol != 'STATIC':
                    dns_idx = '1'
                    if param_d.has_key('dns'):
                        print 'setting static dns for DHCP'
                        dns_idx = '0'
                    elem_dns = self.wait_elem_enabled(how='id', what="dns_option")
                    if elem_dns:
                        Select(elem_dns).select_by_value(dns_idx)

                        if dns_idx == '0':
                            dns = param_d.get('dns')
                            dns1, dns2 = dns.split(',')
                            if not self.input_static_dns(dns1, dns2):
                                return False
                    else:
                        return False
                else:
                    print 'setting static ip'

                    dns = param_d.get('dns')

                    if not is_isp_given:
                        print 'hands off ip settings'
                    else:
                        static_ip = param_d.get('static_ip')
                        static_mask = param_d.get('static_mask')
                        static_gw = param_d.get('static_gw')

                        if not self.input_static_ip(static_ip, static_mask, static_gw):
                            return False

                    dns1, dns2 = dns.split(',')
                    if not self.input_static_dns(dns1, dns2):
                        return False

                    #
            #################################################################################
            elif isp_protocol == 'PPPoE':
                ppp_usr = os.getenv('U_DUT_CUSTOM_PPP_USER', 'autotest001')
                ppp_pwd = os.getenv('U_DUT_CUSTOM_PPP_PWD', '111111')

                element_wan_pppoe = self.wait_elem_enabled(how='link text', what='WAN PPPoE')
                if element_wan_pppoe:
                    element_wan_pppoe.click()
                else:
                    return False

                elem_settings = self.wait_elem_enabled(how='link text', what="Settings")
                if elem_settings:
                    elem_settings.click()
                else:
                    return False

                ppp_username = self.wait_elem_enabled(how='name', what="ppp_username")
                if ppp_username:
                    ppp_username.clear()
                    ppp_username.send_keys(ppp_usr)
                else:
                    return False

                password1_xpath = '/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/'
                password1_xpath += 'tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr[3]/td/table/tbody/tr[3]/td[2]/input'
                password2_xpath = '/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table/tbody/'
                password2_xpath += 'tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr[3]/td/table/tbody/tr[4]/td[2]/input'

                ppp_psw1 = self.wait_elem_enabled(how='xpath', what=password1_xpath)
                if ppp_psw1:
                    ppp_psw1.clear()
                    ppp_psw1.send_keys(ppp_pwd)
                else:
                    return False

                ppp_psw2 = self.wait_elem_enabled(how='xpath', what=password2_xpath)
                if ppp_psw2:
                    ppp_psw2.clear()
                    ppp_psw2.send_keys(ppp_pwd)
                else:
                    return False

                dns_idx = '1'

                if param_d.has_key('dns'):
                    print 'setting static dns'
                    dns_idx = '0'

                elem_dns = self.wait_elem_enabled(how='id', what="dns_option")
                if elem_dns:
                    Select(elem_dns).select_by_value(dns_idx)

                    if dns_idx == '0':
                        dns = param_d.get('dns')
                        dns1, dns2 = dns.split(',')
                        if not self.input_static_dns(dns1, dns2):
                            return False
                else:
                    return False

                    ##############################################################################################

            self.screen_shot(self.get_current_page())

            elem_applybtn = self.wait_elem_enabled(how='link text', what='Apply')
            if elem_applybtn:
                elem_applybtn.click()
            else:
                return False

            if isp_protocol == 'PPPoE':
                enable_disable_xpath = '/html/body/form/table/tbody/tr[3]/td/table/tbody/tr/td[2]/table'
                enable_disable_xpath += '/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]'
                enable_disable_xpath += '/tbody/tr/td/table/tbody/tr[1]/td[2]/center/table/tbody/tr/td/span/table/tbody/tr/td/span/a'

                elem_toggle_pppoe = self.wait_elem_enabled(how='xpath', what=enable_disable_xpath)
                if elem_toggle_pppoe:
                    status_toggle_pppoe = elem_toggle_pppoe.text
                    print 'status_toggle_pppoe : %s' % (status_toggle_pppoe)
                    if status_toggle_pppoe == 'Enable':
                        elem_toggle_pppoe.click()
                    else:
                        print 'pppoe interface already activated'
                else:
                    return False

            elem_applybtn = self.wait_elem_enabled(how='link text', what='Apply')
            if elem_applybtn:
                elem_applybtn.click()
            else:
                return False

            return self.waiting_page()
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
            if not self.wan_layer2_setting(param_d):
                return False
        if param_d.has_key('isp_protocol') or param_d.has_key('dns') or param_d.has_key('static_ip'):
            print 'L3 setting is needed'
            if not self.wan_layer3_setting(param_d):
                return False
            #          pass
        return True

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

        userpass = os.getenv('U_DUT_HTTP_PWD', 'admin1')

        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False

        login_style = ''
        elem_PAGE_HEADER = self.wait_elem_enabled(how='css selector', what="span.PAGE_HEADER")

        if elem_PAGE_HEADER:
            PAGE_HEADER = str(elem_PAGE_HEADER.text).strip()
            print 'PAGE_HEADER [%s] ' % (PAGE_HEADER)

            if PAGE_HEADER == 'Login':
                login_style = 'login'
            elif PAGE_HEADER == 'Login Setup':
                login_style = 'login_setup'
        else:
            print 'no elem_PAGE_HEADER , no need to login'
            return True

        print 'login_style [%s]' % (login_style)

        if login_style == 'login':
            print 'do login '

            try:
                input_usr = self.wait_elem_enabled(how='name', what="user_name")
                if input_usr:
                    input_usr.clear()
                    input_usr.send_keys(username)
                else:
                    return False

                input_psw = self.wait_elem_enabled(how='id', what="pass2")
                if input_psw:
                    input_psw.clear()
                    input_psw.send_keys(userpass)
                else:
                    return False

            except:
                print 'AT_ERROR : error occured in login'
                return False

        elif login_style == 'login_setup':
            print 'do login setup'

            try:
                css_usr = "input[name=\"username\"]"

                input_usr = self.wait_elem_enabled(how='css selector', what=css_usr)
                if input_usr:
                    input_usr.clear()
                    input_usr.send_keys(username)
                else:
                    return False

                xpath_new_psw1 = '/html/body/form/table/tbody/tr[2]/td/table'
                xpath_new_psw1 += '/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td'
                xpath_new_psw1 += '/table/tbody/tr[2]/td[2]/table[2]/tbody/tr[5]/td[2]/input'

                xpath_new_psw2 = '/html/body/form/table/tbody/tr[2]/td/table'
                xpath_new_psw2 += '/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td'
                xpath_new_psw2 += '/table/tbody/tr[2]/td[2]/table[2]/tbody/tr[6]/td[2]/input'

                input_psw = self.wait_elem_enabled(how='xpath', what=xpath_new_psw1)
                if input_psw:
                    input_psw.clear()
                    input_psw.send_keys(userpass)
                else:
                    return False

                input_psw2 = self.wait_elem_enabled(how='xpath', what=xpath_new_psw2)
                if input_psw2:
                    input_psw2.clear()
                    input_psw2.send_keys(userpass)
                else:
                    return False

            except:
                print 'AT_ERROR : error occured in login'
                return False

        elem_OK = self.wait_elem_enabled(how='link text', what='OK')
        if elem_OK:
            elem_OK.click()
        else:
            return False

        elem_main = self.wait_elem_enabled(how='name', what='actiontec_topbar_main_lit')
        if elem_main:
            is_displayed_elem_main = elem_main.is_displayed()
            if is_displayed_elem_main:
                print 'login successful'
                return True
            else:
                print 'login failed'
                return False
        else:
            print 'error occured in login'
            return False

        return True

    def logout(self):
        """
        logout 
        True
        False
        driver.find_element_by_css_selector("a[name=\"logout\"]").click()
        """
        print 'to logout'

        self.go_to_adv()
        elem_logout = self.wait_elem_enabled(how='css selector', what="a[name=\"logout\"]")
        if elem_logout:
            elem_logout.click()
        else:
            return False

        return True


hash_runners = {
    '20.19.0': Runner_v20_19_0,
}

def_runner = '20.19.0'


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
