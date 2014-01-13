from optparse import OptionParser
from pprint import pprint
from selenium import webdriver
from timed_job import Timed_Job, do_GUI_validator_test
import os
import re
import select
import signal
import subprocess
import sys
import time
#from runner._subproc import subproc, start_async_subproc, stop_async_subporc, waiting_input
from _subproc import subproc, start_async_subproc, stop_async_subporc, waiting_input


class GUI_validator():
    def __init__(self, product_type=None, product_version=None,
                 case_id=None, browser=None,
                 base_url=None, grid_server_url=None,
                 local=False, debug=False):
        """
        """
        self.browser_support = ['chrome', 'firefox', 'internet explorer', 'safari']
        self.platform_support = ['WINDOWS', 'LINUX', 'MAC']

        if case_id:
            self.case_id = case_id
        else:
            U_CUSTOM_CURRENT_CASE_ID = os.getenv('U_CUSTOM_CURRENT_CASE_ID')
            if U_CUSTOM_CURRENT_CASE_ID:
                self.case_id = U_CUSTOM_CURRENT_CASE_ID[:8]

        if product_type:
            self.product_type = product_type
        else:
            self.product_type = os.getenv('U_DUT_TYPE')

        if product_version:
            self.product_version = product_version
        else:
            self.product_version = os.getenv('U_CUSTOM_CURRENT_FW_VER')

        if base_url:
            self.base_url = base_url
        else:
            if local:
                self.base_url = 'http://' + os.getenv('G_PROD_IP_BR0_0_0') + '/'
            else:
                self.base_url = 'http://%s:%s/' % (
                os.getenv('U_TESTBED_SSH_IP', ''), os.getenv('U_SELENIUM_SERVER_DPORT', ''))

        if local:
            self.driver = webdriver.Firefox()
            self.driver.implicitly_wait(30)
            self.driver.delete_all_cookies()
            self.driver.maximize_window()
        else:
            if grid_server_url:
                self.grid_server_url = grid_server_url
            else:
                self.grid_server_url = os.getenv('G_SELENIUM_SERVER_URL',
                                                 'http://192.168.20.106:4444/wd/hub')

            if browser:
                self.browser = browser
            else:
                self.browser = {
                    'browserName': 'firefox',
                    'platform': 'WINDOWS',
                }
                print "AT_WARNING : Not specified the browser info, use default setting browserName=firefox , platform=WINDOWS ."

            desired_capabilities = {}

            if self.browser.get('browserName'):
                if self.browser.get('browserName') in self.browser_support:
                    desired_capabilities.update({'browserName': self.browser.get('browserName').strip().lower()})
                else:
                    print "AT_ERROR : Not support browser type : <", self.browser.get('browserName'), ">"
                    print self.browser_support
            else:
                print "AT_ERROR : Not define browser name"

            if self.browser.get('platform'):
                if self.browser.get('platform') in self.platform_support:
                    desired_capabilities.update({'platform': self.browser.get('platform').strip().upper()})
                else:
                    print "AT_ERROR : Not support platform type : <", self.browser.get('platform'), ">"
                    print self.platform_support
            else:
                print "AT_ERROR : Not define browser platform>"

            if self.browser.get('version'):
                desired_capabilities.update({'version': self.browser.get('version').strip()})
            else:
                print "AT_WARNING : Not specified the browser version, use default setting version=any "
                desired_capabilities.update({'version': 'ANY'})

            desired_capabilities.update({"javascriptEnabled": True})

            self.driver = webdriver.Remote(self.grid_server_url, desired_capabilities)
            self.driver.implicitly_wait(30)
            self.driver.delete_all_cookies()
            self.driver.maximize_window()

        if self.product_type:
            cmd = 'from Runner import ' + self.product_type + ' as RUNNER'
            print cmd
            try:
                exec (cmd)
                Runner = RUNNER.getRunner(self.product_version)
                if Runner:
                    self.runner = Runner(self.driver, self.case_id, self.product_type, self.product_version,
                                         self.base_url, debug)
            except Exception, e:
                print 'Exception : ' + str(e)
                self.quit_drv()

            if not self.runner:
                self.error('Can not find Runner for ' + product_type)
                self.quit_drv()
        else:
            print 'AT_ERROR : Not specify product type'
            self.quit_drv()

    def quit_drv(self):
        """
        """
        driver = self.driver
        driver.quit()

    def login(self):
        """
        """
        try:
            if self.runner.login():
                return True
            else:
                self.quit_drv()
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            self.quit_drv()
            return False

    def tr_setting(self):
        """
        """
        try:
            self.login()
            if self.runner.tr_setting():
                self.logout()
                return True
            else:
                self.quit_drv()
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            self.quit_drv()
            return False

    def wan_setting(self, params={}):
        """
        """
        try:
            self.login()
            if self.runner.configure_wan(params=params):
                self.logout()
                return True
            else:
                self.quit_drv()
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            self.quit_drv()
            return False

    def telnet_setting(self, params={}):
        """
        """

        if not params.has_key('status'):
            params.update({
                'status': 'local'
            })

        try:
            print 'tring to login'

            self.login()
            if self.runner.telnet_setting(params=params):
                self.logout()
                return True
            else:
                self.quit_drv()
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            self.quit_drv()
            return False

    def restore_default(self):
        """
        """
        try:
            self.login()
            if self.runner.restore_default():
            #                 self.logout()
                self.quit_drv()
                return True
            else:
                self.quit_drv()
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            self.quit_drv()
            return False

    def gui_check(self):
        """
        """
        try:
            if self.runner.gui_check():
                return True
            else:
                self.quit_drv()
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            self.quit_drv()
            return False

    def goto(self, uri):
        """
        """
        try:
            if self.runner.goto(uri):
                return True
            else:
                self.quit_drv()
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            self.quit_drv()
            return False

    def logout(self):
        """
        """
        try:
            if self.runner.logout():
                self.quit_drv()
                return True
            else:
                self.quit_drv()
                return False
        except Exception, e:
            print 'Exception : ' + str(e)
            self.quit_drv()
            return False


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ('\nGet detail introduction and sample usange with command : pydoc ' + os.path.abspath(__file__) + '\n\n')

    parser = OptionParser(usage=usage)
    parser.add_option("-v", "--variableOption", dest="vos", action="append",
                      help="The environment to set, format is key=value")
    parser.add_option("-t", "--product_type", dest="product_type",
                      help="The product type ,such as CTLC2KA")
    parser.add_option("-f", "--product_version", dest="product_version",
                      help="The product version ,such as CAH004-31.30L.51N")
    parser.add_option("-c", "--case_id", dest="case_id",
                      help="The case id ,such as '00601162")
    parser.add_option("-b", "--browser", dest="browsers", action="append",
                      help="""
The browser info. This parameter can be set multiple 
times on the same line to define multiple types of browsers.
Parameters allowed for --browser: 
browserName={chrome, firefox, internet explorer, safari} 
version={browser version} platform={WINDOWS, LINUX, MAC}
eg :
--browser "browserName=firefox,version=22,platform=WINDOWS"
                            """
    )
    parser.add_option("-l", "--local", dest="local", action="store_true",
                      default=False, help="choose the local mode or remote mode")
    parser.add_option("-z", "--logout", dest="logout", action="store_true",
                      default=False, help="logout after action")
    parser.add_option("-m", "--multi", dest="multi", action="store_true",
                      default=False, help="single process mode or multiprocess mode")
    parser.add_option("-d", "--debug", dest="debug", action="store_true",
                      default=False, help="print debug message")
    parser.add_option("-g", "--grid_server_url", dest="grid_server_url",
                      help="The grid server URL,such as http://192.168.8.46:4444/wd/hub")
    parser.add_option("-u", "--base_url", dest="base_url",
                      help="The base URL,how to visit DUT from grid server")
    parser.add_option("--check_element", dest="check_element", action="store_true",
                      default=False, help="check element is valid")

    (options, args) = parser.parse_args()

    if not len(args) == 0:
        print args

    if options.vos:
        for kv in options.vos:
            parseVerb(kv)

    return args, options


def parseBrowsers(browsers):
    """
    """
    browser_list = []
    if browsers:
        for browser in browsers:
            browser_info = browser.split(',')
            if browser_info:
                browser_list.append(browser_info)

    return browser_list


def parseBrowser(browser):
    """
    """
    browserInfo = {}
    for info in browser:
        print info
        k, v = info.split('=')
        browserInfo.update({k.strip(): v.strip()})

    return browserInfo


def parseVerb(kv):
    """
    """
    match = r'(\w*)=(.*)'
    res = re.findall(match, kv)
    for (k, v) in res:
        (k, v) = res[0]
        print '==', 'import env :', k, ' = ', v
        os.environ.update({k: v})


def exportCurrentPath():
    """
    """
    import os, sys

    path = sys.path[0]
    if os.path.isdir(path):
        pass
    elif os.path.isfile(path):
        path = os.path.dirname(path)

    print '==add path :', path
    sys.path.append(path)


def add_iptables_rule():
    """
    iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 10080 -j DNAT --to 192.168.0.1:80
    iptables -t nat -A POSTROUTING -o eth1 -j SNAT --to 192.168.0.100
    """
    lan_mngmt_if = os.getenv('G_HOST_IF0_0_0', 'eth0')
    lan_active_if = os.getenv('G_HOST_IF0_1_0', 'eth1')
    dport = os.getenv('U_SELENIUM_SERVER_DPORT', '10080')
    dut_ip = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.254')
    lan_active_ip = os.getenv('G_HOST_TIP0_1_0', '192.168.1.100')

    cmd = "iptables -t nat -A PREROUTING -i %s -p tcp --dport %s -j DNAT --to %s:80" % (lan_mngmt_if, dport, dut_ip)
    rc, output = subproc(cmd)
    if not str(rc) == '0':
        print "launch command <%s> failed" % cmd
        exit(1)

    cmd = "iptables -t nat -A POSTROUTING -o %s -j SNAT --to %s" % (lan_active_if, lan_active_ip)
    rc, output = subproc(cmd)
    if not str(rc) == '0':
        print "launch command <%s> failed" % cmd
        exit(1)


def del_iptables_rule():
    """
    iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 10080 -j DNAT --to 192.168.0.1:80
    iptables -t nat -D POSTROUTING -o eth1 -j SNAT --to 192.168.0.100
    """
    lan_mngmt_if = os.getenv('G_HOST_IF0_0_0', 'eth0')
    lan_active_if = os.getenv('G_HOST_IF0_1_0', 'eth1')
    dport = os.getenv('U_SELENIUM_SERVER_DPORT', '10080')
    dut_ip = os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.254')
    lan_active_ip = os.getenv('G_HOST_TIP0_1_0', '192.168.1.100')

    cmd = "iptables -t nat -D PREROUTING -i %s -p tcp --dport %s -j DNAT --to %s:80" % (lan_mngmt_if, dport, dut_ip)
    rc, output = subproc(cmd)
    if not str(rc) == '0':
        print "launch command <%s> failed" % cmd

    cmd = "iptables -t nat -D POSTROUTING -o %s -j SNAT --to %s" % (lan_active_if, lan_active_ip)
    rc, output = subproc(cmd)
    if not str(rc) == '0':
        print "launch command <%s> failed" % cmd


def per_action():
    """
    """
    add_iptables_rule()


def post_action():
    """
    """
    del_iptables_rule()


def multiprocess_mode(product_type, product_version, case_id, browser_list, base_url, grid_server_url, local, debug,
                      logout):
    """
    """
    idx = 1
    jobs = {}
    name = None
    for browser in browser_list:
        name = '_'.join(browser) + '_' + str(idx)
        jobs[name] = Timed_Job(target=gui_check,
                               args=(product_type, product_version,
                                     case_id, browser, base_url,
                                     grid_server_url, local,
                                     logout, debug)
        )
        jobs[name].name = name
        jobs[name].setup(interval=1, max_count=1)
        idx += 1
    return do_GUI_validator_test(jobs)


def singleprocess_mode(product_type, product_version, case_id, browser_list, base_url, grid_server_url, local, debug,
                       logout):
    """
    """
    rc = 0
    idx = 1
    name = None
    for browser in browser_list:
        name = ' '.join(browser) + ' ' + str(idx)
        if gui_check(product_type, product_version, case_id, browser, base_url, grid_server_url, local, debug, logout):
            print "AT_INFO : <%s> check GUI is Successful" % name
        else:
            print "AT_ERROR : <%s> check GUI is failed" % name
            rc = 1
    return rc


def gui_check(product_type, product_version, case_id, browser, base_url, grid_server_url, local, debug, logout):
    """
    """
    browserInfo = parseBrowser(browser)
    gv = GUI_validator(product_type, product_version, case_id, browserInfo, base_url, grid_server_url, local, debug)
    if gv.login():
        if gv.gui_check():
            if logout:
                gv.logout()
                return True
        else:
            if logout:
                gv.logout()
    gv.quit_drv()
    return False


def main():
    args, opts = parseCommandLine()

    exportCurrentPath()

    browser_list = []
    if opts.browsers:
        browser_list = parseBrowsers(opts.browsers)
    elif os.getenv('U_CUSTOM_GUI_CHECK_BROWSERS_INFO'):
        browser_list = parseBrowsers(os.getenv('U_CUSTOM_GUI_CHECK_BROWSERS_INFO'))
    else:
        browser_list.append(['browserName=firefox', 'platform=WINDOWS'])
        browser_list.append(['browserName=chrome', 'platform=WINDOWS'])
        browser_list.append(['browserName=internet explorer', 'platform=WINDOWS'])
    #        browser_list.append(['browserName=safari', 'platform=MAC'])

    if opts.product_type:
        product_type = opts.product_type
    else:
        product_type = os.getenv('U_DUT_TYPE')

    if opts.product_version:
        product_version = opts.product_version
    else:
        product_version = os.getenv('U_CUSTOM_CURRENT_FW_VER')

    if not opts.check_element:
        if opts.case_id:
            case_id = opts.case_id
        else:
            case_id = os.getenv('U_CUSTOM_CURRENT_CASE_ID')[:8]
    else:
        case_id = None

    if opts.base_url:
        base_url = opts.base_url
    else:
        if opts.local:
            base_url = 'http://' + os.getenv('G_PROD_IP_BR0_0_0', '') + '/'
        else:
            base_url = 'http://%s:%s/' % (os.getenv('U_TESTBED_SSH_IP', ''), os.getenv('U_SELENIUM_SERVER_DPORT', ''))

    if opts.grid_server_url:
        grid_server_url = opts.grid_server_url
    else:
        grid_server_url = os.getenv('G_SELENIUM_SERVER_URL',
                                    'http://192.168.20.106:4444/wd/hub')

    per_action()

    rc = 0
    try:
        if opts.check_element:
            rc = check_element(product_type, product_version,
                               case_id, browser_list, base_url,
                               grid_server_url, opts.local,
                               opts.debug, opts.logout)
            pass
        else:
            if opts.multi:
                rc = multiprocess_mode(product_type, product_version,
                                       case_id, browser_list, base_url,
                                       grid_server_url, opts.local,
                                       opts.debug, opts.logout)
            else:
                rc = singleprocess_mode(product_type, product_version,
                                        case_id, browser_list, base_url,
                                        grid_server_url, opts.local,
                                        opts.debug, opts.logout)
    except Exception, e:
        post_action()

    post_action()

    exit(rc)


if __name__ == '__main__':
    """
    """
    main()
