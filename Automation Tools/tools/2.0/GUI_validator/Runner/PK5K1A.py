from BaseRunner import BaseRunner
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support.ui import Select
import os


class Runner_VCAP001_10_0_0k(BaseRunner):
    """
    """
    driver = None
    base_url = None

    def __init__(self, driver, case_id, product_type, product_version, base_url, debug):
        """
        """
        BaseRunner.__init__(self, driver, case_id, product_type, product_version, base_url, debug)

    def waiting_page(self, what, how='id', to=20):
        """
        id('pleasewait_reboot')       -reset
        id('thankyou')                -reboot
        id('pleasewait')              -apply
        elem_main.is_displayed()
        """

        if self.wait_elem_appear(how=how, what=what):
            if self.wait_elem_appear(how=how, what=what, to=to, disappear=True):
                return True
            else:
                print 'waiting page did not disappear'
                return False
        else:
            print 'waiting page did not show up'
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

            elem_reset = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Restore')])[6]")
            if elem_reset:
                elem_reset.click()
            else:
                return False

            elem_ok = self.wait_elem_enabled(how='link text', what="OK")
            if elem_ok:
                elem_ok.click()
            else:
                return False

            return self.waiting_page(what='pleasewait_reboot', how='id', to=180)
            #######################################################################
        else:
            return False
        pass

    def tr_setting(self):
        """
        driver.find_element_by_css_selector("#admin_user_name").clear()
        driver.find_element_by_css_selector("#admin_user_name").send_keys("CenturyL1nk")
        driver.find_element_by_css_selector("#admin_password").clear()
        driver.find_element_by_css_selector("#admin_password").send_keys("CTLsupport12")
        driver.find_element_by_css_selector("#apply_btn").click()
        driver.find_element_by_css_selector("#side_link3").click()
        
        driver.find_element_by_css_selector("#acs_url_txt").clear()
        driver.find_element_by_css_selector("#acs_url_txt").send_keys("http://192.168.55.254:1234/acs")
        
        driver.find_element_by_css_selector("#acs_username_txt").clear()
        driver.find_element_by_css_selector("#acs_username_txt").send_keys("actiontec")
        driver.find_element_by_css_selector("#acs_passwd_txt").clear()
        driver.find_element_by_css_selector("#acs_passwd_txt").send_keys("actiontec")
        
        driver.find_element_by_css_selector("a.btn.apply_btn").click()
        try: self.assertEqual("PLEASE WAIT", driver.find_element_by_css_selector("#thankyou").text)
        except AssertionError as e: self.verificationErrors.append(str(e))
        """

        page_uri = 'supportconsole'

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        if self.goto(page_uri):
            elem_usr = self.wait_elem_enabled(how='css selector', what="#admin_user_name")
            if elem_usr:
                elem_usr.clear()
                elem_usr.send_keys("CenturyL1nk")
            else:
                return False

            elem_pwd = self.wait_elem_enabled(how='css selector', what="#admin_password")
            if elem_pwd:
                elem_pwd.clear()
                elem_pwd.send_keys("CTLsupport12")
            else:
                return False

            elem_login = self.wait_elem_enabled(how='css selector', what="#apply_btn")
            if elem_login:
                elem_login.click()
            else:
                return False

            elem_tr69 = self.wait_elem_enabled(how='css selector', what="#side_link3")
            if elem_tr69:
                elem_tr69.click()
            else:
                return False
                #######################################################################################################
            elem_acsusr = self.wait_elem_enabled(how='css selector', what="#acs_username_txt")
            if elem_acsusr:
                elem_acsusr.clear()
                elem_acsusr.send_keys("actiontec")
            else:
                return False

            elem_acspwd = self.wait_elem_enabled(how='css selector', what="#acs_passwd_txt")
            if elem_acspwd:
                elem_acspwd.clear()
                elem_acspwd.send_keys("actiontec")
            else:
                return False

            ##########################################################################################################
            elem_acsurl = self.wait_elem_enabled(how='css selector', what="#acs_url_txt")
            if elem_acsurl:
                elem_acsurl.clear()
                elem_acsurl.send_keys("http://192.168.55.254:1234/acs")
            else:
                return False
                #########################################################################    driver.find_element_by_css_selector("span")
            #    <input id="periodic_inform_interval" type="text" size="25" value="">
            elem_periodic = self.wait_elem_enabled(how='id', what="periodic_inform_interval")
            if elem_periodic:
                elem_periodic.clear()
                elem_periodic.send_keys("1")
            else:
                return False

            self.screen_shot('tr69settings')

            elem_apply = self.wait_elem_enabled(how='css selector', what="a.btn.apply_btn")
            if elem_apply:
                elem_apply.click()
            else:
                return False

            return self.waiting_page(what='thankyou', how='id', to=50)
        else:
            return False

        return True

    def telnet_setting(self, params={}):
        """
        status [ disabled local remote local+remote ]
        
        <select id="remote_console_tel" onchange="configState();" name="remote_console_tel">
            <option value="0">Disabled</option>
            <option value="1">Telnet Enabled</option>
        </select>
        
        <select id="remote_management_timeout" name="remote_management_timeout">
            <option value="0">Disabled</option>
            <option value="15">15 Minutes</option>
            <option value="30">30 Minutes</option>
            <option value="60">1 Hour</option>
            <option value="360">6 Hours</option>
            <option value="720">12 Hours</option>
            <option value="1440">1 Day</option>
            <option value="4320">3 Days</option>
            <option value="10080">7 Days</option>
        </select>
        """

        status_val = {
            'disabled': '0',
            'local': '1',
            'remote': '1',
            'local+remote': '1',
        }

        idle_times = {
            '0': '0',
            '15m': '15',
            '30m': '30',
            '1h': '60',
            '6h': '360',
            '12h': '720',
            '1d': '1440',
            '3d': '4320',
            '7d': '10080',
        }

        page_uri = 'advancedsetup_remotetelnet.html'

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        if self.goto(page_uri):
            print 'on page %s now' % (page_uri)

            param_d = params

            if param_d.has_key('status'):
                status = param_d.get('status')
                print 'setting status to %s' % (status)

                elem_status = self.wait_elem_enabled(how='id', what='remote_console_tel')
                if elem_status:
                    Select(elem_status).select_by_value(status_val.get(status))
                else:
                    return False

                if not status == 'disabled':
                    print 'going to set username & password'

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

                    if param_d.has_key('idle_time'):
                        idle_time = param_d.get('idle_time')
                        print 'setting idle_time to %s' % (idle_time)

                        elem_idle_time = self.wait_elem_enabled(how='id', what='remote_management_timeout')
                        if elem_idle_time:
                            Select(elem_idle_time).select_by_value(idle_times.get(idle_time))
                        else:
                            return False
                    else:
                        print 'setting idle_time to 0'

                        elem_idle_time = self.wait_elem_enabled(how='id', what='remote_management_timeout')
                        if elem_idle_time:
                            Select(elem_idle_time).select_by_value(idle_times.get('0'))
                        else:
                            return False

            self.screen_shot('telnet')

            elem_apply = self.wait_elem_enabled(how='id', what="apply_btn")
            if elem_apply:
                elem_apply.click()
            else:
                return False

            if not status == 'disabled':
                elem_ok = self.wait_elem_enabled(how='link text', what="OK")
                if elem_ok:
                    elem_ok.click()
                else:
                    return False

            return self.waiting_page(what='pleasewait', how='id', to=50)
            #######################################################################
        else:
            return False

        return True

    def wan_layer2_setting(self, params={}):
        """
        wan_type : ADSL     VDSL     ADSL_B     VDSL_B     ETH
        line_mode : 8a     adsl2+
        tag :     201
        pvc :     8/35
        
        """
        wan_type = None
        line_mode = None
        pvc = None
        #    Auto Select
        wan_types = {
            #                    'VDSL':'VDSL2',
            #                    'VDSL_B':'VDSL2 Bonding',
            'ADSL': 'ADSL-ADSL2+',
            #                    'ADSL_B':'ADSL-ADSL2+ Bonding',
            #                    'ETH':'WAN Ethernet Port 5',
        }
        """
        <select id="atm_line_mode" onchange="Click_LineMode(this.selectedIndex);" name="Mode">
        <option value="0">Auto Select</option>
        <option value="1">T1.413 </option>
        <option value="3">G.DMT </option>
        <option value="2">G.Lite </option>
        <option value="4">ADSL2 </option>
        <option value="5">ADSL2Plus </option>
        <option value="5">ADSL2Plus with AnnexM </option>
        """
        line_modes = {
            "auto": "Auto Select",

            "t1413": "T1.413 ",
            "gdmt": "G.DMT ",
            "glite": "G.Lite ",
            "adsl2": "ADSL2 ",
            "adsl2+": "ADSL2Plus ",
            "Annexm": "ADSL2Plus with AnnexM ",
        }

        page_uri = 'advancedsetup_broadbandsettings.html'

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        if self.goto(page_uri):
            print 'on page %s now' % (page_uri)

            param_d = params

            if param_d.has_key('wan_type'):
                wan_type = param_d.get('wan_type')
                print 'setting WAN type to %s' % (wan_type)
                print 'warning : PK5K1A only adsl supported'

            ##################################################################################
            if param_d.has_key('line_mode'):
                line_mode = param_d.get('line_mode')
                line_mode_v = line_modes.get(line_mode)
                print 'setting line_mode to %s : %s ' % (line_mode, line_mode_v)

                elem_linemode = self.wait_elem_enabled(how='id', what='atm_line_mode')
                if elem_linemode:
                    Select(elem_linemode).select_by_visible_text(line_mode_v)
                else:
                    return False
                    ##################################################################################
                #             if param_d.has_key('tag') :
                #                 tag = param_d.get('tag')
                # #                 id('eth_transport_mode')    id('adsl_transport_mode')    id('ptm_transport_mode')
                #                 print 'setting vlan tag ID to %s ' % (tag)
                #
                #                 elem_tag = self.wait_elem_enabled(how='id', what='atm_line_mode')
                #                 if elem_linemode:
                #                     Select(elem_linemode).select_by_value(line_mode_v)
                #                 else:
                #                     elem_linemode = self.wait_elem_enabled(how='id', what='ptm_line_mode')
                #                     if elem_linemode:
                #                         Select(elem_linemode).select_by_value(line_mode_v)
                #                     else:
                #                         return False
                #################################################################################
            if param_d.has_key('pvc'):
                pvc = param_d.get('pvc')
                print 'setting pvc to %s' % (pvc)
                vpi, vci = pvc.split('/')

                elem_vpi = self.wait_elem_enabled(how='id', what='atm_paramenters_vpi')
                if elem_vpi:
                    elem_vpi.clear()
                    elem_vpi.send_keys(vpi)
                else:
                    return False

                elem_vci = self.wait_elem_enabled(how='id', what='atm_paramenters_vci')
                if elem_vci:
                    elem_vci.clear()
                    elem_vci.send_keys(vci)
                else:
                    return False
                #     applyBtn
            self.screen_shot(driver.title)
            #############################################################################
            elem_applybtn = self.wait_elem_enabled(how='id', what='apply_btn')
            if elem_applybtn:
                elem_applybtn.click()
            else:
                return False

            return self.waiting_page(what='pleasewait', how='id', to=50)
            #######################################################################
        else:
            return False
        pass

    def wan_layer3_setting(self, params={}):
        """
        isp_protocol : IPoE      PPPoE     TRANSPARENT     STATIC
        dns : 10.20.10.10,168.95.1.1
        static_ip : 192.168.55.1
        id('isp_protocol_id')
        ppp_usr=id('subrf3')
        ppp_pwd1=id('subrf5')
        id('cf_subrf5')
        
    """
        isp_protocols = {
            'AUTO': 'auto',
            'IPoE': 'dhcpc',
            'PPPoE': 'pppoe',
            'TRANSPARENT': 'bridge',
            'STATIC': 'static',
            'PPPoA': 'asis',
            'TRANSPARENT_032': 'bridge_0/32',
            'TRANSPARENT_035': 'bridge_0/35',
            'TRANSPARENT_835': 'bridge_8/35',
            'TRANSPARENT_0': 'bridge_0',
            'TRANSPARENT_U': 'bridge_-1',
        }

        page_uri = 'advancedsetup_wanipaddress.html'

        print 'navigating to page %s' % (page_uri)

        driver = self.driver

        if self.goto(page_uri):
            print 'on page %s now' % (page_uri)

            param_d = params

            driver.switch_to_frame("realpage")

            if param_d.has_key('isp_protocol'):
                isp_protocol = param_d.get('isp_protocol')
                print 'setting isp_protocol to %s' % (isp_protocol)

                elem_isp = self.wait_elem_enabled(how='id', what="isp_protocol_id")
                if elem_isp:
                    Select(elem_isp).select_by_value(isp_protocols.get(isp_protocol))

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

                        elem_ppp_pwd2 = self.wait_elem_enabled(how='id', what='cf_subrf5')
                        if elem_ppp_pwd2:
                            elem_ppp_pwd2.clear()
                            elem_ppp_pwd2.send_keys(ppp_pwd)
                        else:
                            return False
                    elif isp_protocol == 'STATIC':
                        static_ip = param_d.get('static_ip')
                        static_mask = param_d.get('static_mask')
                        static_gw = param_d.get('static_gw')

                        elem_static_ip = self.wait_elem_enabled(how='id', what='ipadd')
                        if elem_static_ip:
                            elem_static_ip.clear()
                            elem_static_ip.send_keys(static_ip)
                        else:
                            return False

                        elem_static_mask = self.wait_elem_enabled(how='id', what='submask')
                        if elem_static_mask:
                            elem_static_mask.clear()
                            elem_static_mask.send_keys(static_mask)
                        else:
                            return False

                        elem_static_gw = self.wait_elem_enabled(how='id', what='gateadd')
                        if elem_static_gw:
                            elem_static_gw.clear()
                            elem_static_gw.send_keys(static_gw)
                        else:
                            return False
                else:
                    return False
                #################################################

            xpath_dyn_dns = "/html/body/div/div[3]/div[2]/div/form/div[4]/div[5]/div[2]/table/tbody/tr/td[2]/input"
            xpath_cus_dns = "/html/body/div/div[3]/div[2]/div/form/div[4]/div[5]/div[2]/table/tbody/tr/td[2]/input[2]"

            if param_d.has_key('dns'):
                elem_static_dns = self.wait_elem_enabled(how='xpath', what=xpath_cus_dns)
                if elem_static_dns:
                    elem_static_dns.click()
                    dns1, dns2 = param_d.get('dns').split(',')

                    if not dns1 == '-1':
                        elem_static_dns1 = self.wait_elem_enabled(how='name', what='primarydns')
                        if elem_static_dns1:
                            elem_static_dns1.clear()
                            elem_static_dns1.send_keys(dns1)
                        else:
                            return False

                    if not dns2 == '-1':
                        elem_static_dns2 = self.wait_elem_enabled(how='name', what='secdns')
                        if elem_static_dns2:
                            elem_static_dns2.clear()
                            elem_static_dns2.send_keys(dns2)
                        else:
                            return False
                else:
                    return False
            else:
                elem_dyna_dns = self.wait_elem_enabled(how='xpath', what=xpath_dyn_dns)
                if elem_dyna_dns:
                    elem_dyna_dns.click()
                else:
                    return False
                ################################################
            #     applyBtn
            self.screen_shot(driver.title)

            elem_applybtn = self.wait_elem_enabled(how='id', what='apply_btn')
            if elem_applybtn:
                elem_applybtn.click()
            else:
                return False

            return self.waiting_page(what='pleasewait', how='id', to=50)
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

        userpass = os.getenv('U_DUT_HTTP_PWD', '9Vk5ek6j')

        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False

        if self.wait_id_exist('admin_user_name'):

            try:
                input_usr = driver.find_element_by_id('admin_user_name')
                print 'AT_INFO : original username in input : ', input_usr.get_attribute('value')
                input_usr.clear()
                input_usr.send_keys(username)
                # return False

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

        if self.wait_id_exist('admin_password'):
            try:
                input_psw = driver.find_element_by_id('admin_password')
                input_psw.clear()
                input_psw.send_keys(userpass)

            except:
                print 'AT_ERROR : error occured in login'
                return False
        else:
            print 'AT_ERROR : error occured in login'
            return False

        if self.wait_id_exist('apply_btn'):

            input_apply = driver.find_element_by_id('apply_btn')

            input_apply.click()

            if self.wait_id_exist('selected'):
                print 'Already logged in !'
                # return True
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
        print 'to logout'
        driver = self.driver
        driver.get(self.base_url + 'modemstatus_connectionstatus.html')
        driver.switch_to_frame("realpage");
        driver.find_element_by_id("logout_btn").click()
        return True


hash_runners = {
    'CAP001-10.0.0k': Runner_VCAP001_10_0_0k,
}

def_runner = 'CAP001-10.0.0k'


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
