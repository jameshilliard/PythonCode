from BaseRunner import BaseRunner
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support.ui import Select
import os, time


class Runner_VCAC001_31_30L_00B(BaseRunner):
    """
    """
    driver = None
    base_url = None

    def __init__(self, driver, case_id, product_type, product_version, base_url, debug):
        """
        """
        BaseRunner.__init__(self, driver, case_id, product_type, product_version, base_url, debug)

    def waiting_page(self):
        """
        # <frame src="cmdthankyou_real.html" name="realpage" ></frame>
#         <frame src="cmdthankyou_hide.html" name="hidepage"></frame>
        """
        driver = self.driver

        for i in range(15):
        #             driver.refresh()
            if self.wait_elem_exist(how='name', what='realpage') and self.wait_elem_exist(how='name', what='hidepage'):
                print 'waiting page appeared!'
                break
            else:
                print 'waiting for waiting page'
                time.sleep(1)

        for i in range(120):
        #             driver.refresh()
            if self.wait_elem_exist(how='name', what='realpage') or self.wait_elem_exist(how='name', what='hidepage'):
                print 'waiting page still on'
                time.sleep(1)
            else:
                break
        print 'waiting pass'
        return True

    def tr_setting(self):
        """
        """

        page_uri = 'tr69.html'

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
                ################################################################################################################
            elem_acsurl = self.wait_elem_enabled(how='css selector', what="input[name=\"ACSURL\"]")
            if elem_acsurl:
                elem_acsurl.clear()
                elem_acsurl.send_keys("http://192.168.55.254:1234/acs")
            else:
                return False
                ###################################################################################################################

            elem_period = self.wait_elem_enabled(how='css selector', what="input[name=\"ACS_PeriodicInformInterval\"]")
            if elem_period:
                elem_period.clear()
                elem_period.send_keys("60")
            else:
                return False
                #driver.find_element_by_css_selector("input[name=\"ACS_Debug\"]").click()
            #########################################################################    driver.find_element_by_css_selector("span")
            elem_enable = self.wait_elem_enabled(how='xpath',
                                                 what="/html/body/div/div[4]/div[2]/form/div/div[2]/table[2]/tbody/tr/td[2]/input")
            if elem_enable:
                elem_enable.click()
            else:
                return False

            self.screen_shot('tr69settings')

            elem_apply = self.wait_elem_enabled(how='css selector', what="a.btn.apply_btn")
            if elem_apply:
                elem_apply.click()
            else:
                return False

            #    <title>Advanced Setup - TR-069</title>    <title>Thank you.</title>
            time.sleep(10)
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

            elem_reset = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Restore')])[6]")
            if elem_reset:
                elem_reset.click()
            else:
                elem_reset = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Restore')])[5]")
                if elem_reset:
                    elem_reset.click()
                else:
                    return False
                #                 return False

            elem_ok = self.wait_elem_enabled(how='link text', what="OK")
            if elem_ok:
                elem_ok.click()
            else:
                return False

            return self.waiting_page()
            #######################################################################
        else:
            return False
        pass

    def telnet_setting(self, params={}):
        """
        status [ disabled local remote local+remote ]
        
        <select id="remote_management" onchange="selectMode(this.options[this.selectedIndex].value);" name="remote_management">
            <option value="0">Disabled</option>
            <option value="1">Telnet Enabled</option>
        </select>
        
        <select id="remote_management_timeout" name="remote_management_timeout">
            <option value="0">Disabled</option>
            <option value="900">15 Minutes</option>
            <option value="1800">30 Minutes</option>
            <option value="3600">1 Hour</option>
            <option value="21600">6 Hours</option>
            <option value="43200">12 Hours</option>
            <option value="86400">1 Day</option>
            <option value="259200">3 Days</option>
            <option value="604800">7 Days</option>
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
            '15m': '900',
            '30m': '1800',
            '1h': '3600',
            '6h': '21600',
            '12h': '43200',
            '1d': '86400',
            '3d': '259200',
            '7d': '604800',
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

                elem_status = self.wait_elem_enabled(how='id', what='remote_management')
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

                    elem_pwd2 = self.wait_elem_enabled(how='id', what='confirmPass')
                    if elem_pwd2:
                        elem_pwd2.clear()
                        elem_pwd2.send_keys(U_DUT_TELNET_PWD)
                    else:
                        return False
                    #                 else:

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

            elem_apply = self.wait_elem_enabled(how='css selector', what="a.btn.apply_btn")
            if elem_apply:
                elem_apply.click()
            else:
                return False

            time.sleep(15)
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
            'VDSL': 'VDSL2',
            'VDSL_B': 'VDSL2 Bonding',
            'ADSL': 'ADSL-ADSL2+',
            'ADSL_B': 'ADSL-ADSL2+ Bonding',
            'ETH': 'WAN Ethernet Port 5',
        }

        line_modes = {
            "auto": "ADSL_Modulation_All",

            "8a": "8A",
            "8b": "8B",
            "8c": "8C",
            "8d": "8D",
            "12a": "12A",
            "12b": "12B",
            "17a": "17A",
            "30a": "30A",

            "t1413": "ADSL_ANSI_T1.413",
            "gdmt": "ADSL_G.dmt",
            "glite": "ADSL_G.lite",
            "adsl2": "ADSL_G.dmt.bis",
            "adsl2+": "ADSL_2plus",
            "Annexm": "AnnexM",
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

                elem_wan_type = self.wait_elem_enabled(how='id', what='wan_type')
                if elem_wan_type:
                    Select(elem_wan_type).select_by_visible_text(wan_types.get(wan_type))
                else:
                    return False
                ##################################################################################
            if param_d.has_key('line_mode'):
                line_mode = param_d.get('line_mode')
                line_mode_v = line_modes.get(line_mode)
            else:
                line_mode_v = 'ADSL_Modulation_All'
            print 'setting line_mode to ', line_mode_v

            if wan_type == 'ADSL' or wan_type == 'ADSL_B':
                elem_linemode = self.wait_elem_enabled(how='id', what='atm_line_mode')
                if elem_linemode:
                    Select(elem_linemode).select_by_value(line_mode_v)
                else:
                    return False
            elif wan_type == 'VDSL' or wan_type == 'VDSL_B':
                elem_linemode = self.wait_elem_enabled(how='id', what='ptm_line_mode')
                if elem_linemode:
                    Select(elem_linemode).select_by_value(line_mode_v)
                else:
                    return False
                ##################################################################################
            if param_d.has_key('tag'):
                tag = param_d.get('tag')
                print 'setting vlan tag ID to %s ' % (tag)
                if str(tag).lower() == 'auto':
                    ptm_transport_mode = 'Auto'
                    elem_transportmode = self.wait_elem_enabled(how='id', what='ptm_transport_mode')
                    if elem_transportmode:
                        Select(elem_transportmode).select_by_value(ptm_transport_mode)
                    else:
                        return False
                else:
                    ptm_transport_mode = 'PTM-Tagged'
                    elem_transportmode = self.wait_elem_enabled(how='id', what='ptm_transport_mode')
                    if elem_transportmode:
                        Select(elem_transportmode).select_by_value(ptm_transport_mode)
                    else:
                        return False
                    elem_tag = self.wait_elem_enabled(how='id', what='vlanMuxId')
                    if elem_tag:
                        elem_tag.clear()
                        elem_tag.send_keys(tag)
                    else:
                        return False

            #################################################################################
            # id('atm_setting')    id('atm_paramenters_vpi')    id('atm_paramenters_vci')    id('apply_btn')
            if param_d.has_key('pvc'):
                pvc = param_d.get('pvc')
                print 'setting pvc to %s' % (pvc)
                elem_transportmode = self.wait_elem_enabled(how='id', what='adsl_transport_mode')
                if elem_transportmode:
                    Select(elem_transportmode).select_by_visible_text('ATM-LLC Bridged')
                else:
                    return False
                if str(pvc).lower() == 'auto':
                    elem_atm_setting = self.wait_elem_enabled(how='id', what='atm_setting')
                    if elem_atm_setting:
                        Select(elem_atm_setting).select_by_value('auto')
                    else:
                        return False
                else:
                    vpi, vci = pvc.split('/')

                    elem_atm_setting = self.wait_elem_enabled(how='id', what='atm_setting')

                    if elem_atm_setting:
                        Select(elem_atm_setting).select_by_value('manual')

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
                    else:
                        return False
                #     applyBtn
            self.screen_shot(driver.title)
            #############################################################################
            if self.wait_elem_appear(how='id', what='apply_btn', to=5):
                elem_applybtn = self.wait_elem_enabled(how='id', what='apply_btn')
                if elem_applybtn:
                    elem_applybtn.click()
                else:
                    return False
            elif self.wait_elem_appear(how='xpath', what="(//a[contains(text(),'Apply')])[3]", to=5):
                elem_applybtn = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Apply')])[3]")
                if elem_applybtn:
                    elem_applybtn.click()
                else:
                    return False
            elif self.wait_elem_appear(how='xpath', what="(//a[contains(text(),'Apply')])[2]", to=5):
                elem_applybtn = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Apply')])[2]")
                if elem_applybtn:
                    elem_applybtn.click()
                else:
                    return False
            elif self.wait_elem_appear(how='xpath', what="(//a[contains(text(),'Apply')])[5]", to=5):
                elem_applybtn = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Apply')])[5]")
                if elem_applybtn:
                    elem_applybtn.click()
                else:
                    return False
            elif self.wait_elem_appear(how='xpath', what="(//a[contains(text(),'Apply')])[6]", to=5):
                elem_applybtn = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Apply')])[6]")
                if elem_applybtn:
                    elem_applybtn.click()
                else:
                    return False
            elif self.wait_elem_appear(how='xpath', what="(//a[contains(text(),'Apply')])[4]", to=5):
                elem_applybtn = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Apply')])[4]")
                if elem_applybtn:
                    elem_applybtn.click()
                else:
                    return False
            elif self.wait_elem_appear(how='xpath', what="(//a[contains(text(),'Apply')])[1]", to=5):
                elem_applybtn = self.wait_elem_enabled(how='xpath', what="(//a[contains(text(),'Apply')])[1]")
                if elem_applybtn:
                    elem_applybtn.click()
                else:
                    return False
            else:
                return False

            return self.waiting_page()
            #######################################################################
        else:
            return False
        pass

    def wan_layer3_setting(self, params={}):
        """
        isp_protocol : IPoE      PPPoE     TRANSPARENT     STATIC
        dns : 10.20.10.10,168.95.1.1
        static_ip : 192.168.55.1
        
        <title>Advanced Setup - IP Addressing - WAN IP Address</title>
        advancedsetup_wanipaddress.html    id('isp_protocol_id')
        
        
        ("Auto Select","auto",true,true);
        ("PPPoE","pppoe",true,true);
        ("PPPoA","asis",false,false);
        ("DHCP","dhcpc",false,false);
        ("Static IP","static",false,false);
        ("Transparent Bridging","bridge",false,false);
        
        ("Transparent Bridging 0/32","bridge_0/32",false,false);
        ("Transparent Bridging 0/35","bridge_0/35",false,false);
        ("Transparent Bridging 8/35","bridge_8/35",false,false);
    
        ("Transparent Bridging Tagged-0","bridge_0",false,false);
        ("Transparent Bridging Untagged","bridge_-1",false,false);
    }
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

            if param_d.has_key('isp_protocol'):
                isp_protocol = param_d.get('isp_protocol')
                print 'setting isp_protocol to %s' % (isp_protocol)

                elem_isp = self.wait_elem_enabled(how='id', what='isp_protocol_id')

                if elem_isp:
                    Select(elem_isp).select_by_value(isp_protocols.get(isp_protocol))

                    if isp_protocol == 'PPPoE':
                        ppp_usr = os.getenv('U_DUT_CUSTOM_PPP_USER', 'autotest001')
                        ppp_pwd = os.getenv('U_DUT_CUSTOM_PPP_PWD', '111111')

                        elem_ppp_usr = self.wait_elem_enabled(how='name', what='ppp_username')
                        if elem_ppp_usr:
                            elem_ppp_usr.clear()
                            elem_ppp_usr.send_keys(ppp_usr)
                        else:
                            return False

                        elem_ppp_pwd = self.wait_elem_enabled(how='id', what='ppp_password')
                        if elem_ppp_pwd:
                            elem_ppp_pwd.clear()
                            elem_ppp_pwd.send_keys(ppp_pwd)
                        else:
                            return False

                        elem_ppp_pwd2 = self.wait_elem_enabled(how='id', what='ppp_password_cfm')
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
            if param_d.has_key('dns'):
                elem_static_dns = self.wait_elem_enabled(how='xpath', what="(//input[@name='dnstyp'])[2]")
                if elem_static_dns:
                    elem_static_dns.click()
                    dns1, dns2 = param_d.get('dns').split(',')

                    if not dns1 == '-1':
                        elem_static_dns1 = self.wait_elem_enabled(how='id', what='primarydns')
                        if elem_static_dns1:
                            elem_static_dns1.clear()
                            elem_static_dns1.send_keys(dns1)
                        else:
                            return False

                    if not dns2 == '-1':
                        elem_static_dns2 = self.wait_elem_enabled(how='id', what='secdns')
                        if elem_static_dns2:
                            elem_static_dns2.clear()
                            elem_static_dns2.send_keys(dns2)
                        else:
                            return False
                else:
                    return False
            else:
                elem_dyna_dns = self.wait_elem_enabled(how='name', what='dnstyp')
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

        userpass = os.getenv('U_DUT_HTTP_PWD', '1')

        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False

        if self.wait_id_exist('admin_user_name'):
            try:
                input_usr = driver.find_element_by_id('admin_user_name')
                print 'AT_INFO : original username in input : ', input_usr.get_attribute('value')
                input_usr.clear()
                input_usr.send_keys(username)
                input_psw = driver.find_element_by_id('admin_password')
                input_psw.clear()
                input_psw.send_keys(userpass)
                input_apply = driver.find_element_by_id('apply_btn')
                input_apply.click()

            except Exception, e:
                print 'AT_ERROR : error occured in login '
                print e
                return False

        else:
            if self.wait_id_exist('selected'):
                print 'AT_INFO :Already logged in !'
                return True
            else:
                print 'AT_ERROR in getting main / login page '
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
        driver.get(self.base_url + 'modemstatus_home.html')
        driver.find_element_by_id("logout_btn").click()
        return True


hash_runners = {
    'CAC001-31.30L.00B': Runner_VCAC001_31_30L_00B,
}

def_runner = 'CAC001-31.30L.00B'


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
