#!/bin/env python

"""
This script would check if AT still works after browser or webDriver updated.
"""
from selenium import webdriver
#from selenium.common.excetpions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
from optparse import OptionParser
from pexpect import run
import os
import sys
import re

element_dict = {'find_element_by_id': 'coolestWidgetEvah',
                'find_element_by_class_name': 'cheese',
                'find_element_by_tag_name': 'iframe',
                'find_element_by_name': 'example',
                'find_element_by_link_text': 'cheese',
                'find_element_by_partial_link_text': 'cheese',
                'find_element_by_css_selector': '#food span.dairy.aged',
                'find_element_by_xpath': '//input'
}


class BrowserOrWebDriverCheck():
    """
    Specify the check point to make sure browser or web driver
    still work with selenium if them version upgraded. 
    """

    def __init__(self, browser_name, base_url=None, debug=False):
        self.browser_name = browser_name.capitalize()
        self.base_url = base_url
        self.driver = None
        self.debug = debug

    def driver_init(self):
        browser_name = self.browser_name
        base_url = self.base_url

        self.driver = eval('webdriver.%s()' % browser_name)
        self.driver.get(base_url)
        if self.driver:
            return self.driver
        else:
            return False

    def driver_quit(self):
        driver = self.driver
        driver.quit()
        return True

    def dirver_test(self):

        element = []
        function = []
        driver = self.driver_init()
        if not driver:
            return False
        func_list = dir(eval('webdriver.%s' % self.browser_name))
        #        if self.debug:
        #            print func_list
        #        for i in func_list:
        #            if i.startswith('find_element_'):
        #                function.append(i)
        #        print  function
        for k, v in element_dict.items():
            if self.debug:
                print k, v
            try:
                find = getattr(driver, k)
                em = find(v)
            #                print type(find_cmd),find_cmd
            #                element = eval(find_cmd)
            except Exception, e:
                print '===><%s>' % str(e)
                self.driver_quit()
            if em:
                expect_value = self.checkResult()
                p_text = expect_value.get(k).get("text")
                p_color = expect_value.get(k).get("color")
                c_text = em.text
                c_color = em.value_of_css_property('color')
                if self.debug:
                    print
                    print 'Text====><%s>' % em.text
                    print 'Color===><%s>' % em.value_of_css_property('color')
                    print
                if not c_text == p_text:
                    print "AT_ERROR : Element method <%s> text property check failed..." % k
                    return False
                else:
                    if self.debug:
                        print "Element method <%s> text property check passed..." % k
                if not c_color == p_color:
                    print "AT_Waring :Element method <%s> color property check failed..." % k
                    return False
                else:
                    if self.debug:
                        print "Element method <%s> color property check passed..." % k
            else:
                return False

        return True

    def checkResult(self):

        expect_value = {"find_element_by_id": {"text": "python", "color": "rgba(0, 255, 0, 1)"},
                        "find_element_by_class_name": {"text": "Test", "color": "rgba(255, 0, 255, 1)"},
                        "find_element_by_tag_name": {"text": "Iframe", "color": "rgba(204, 232, 207, 1)"},
                        "find_element_by_name": {"text": "", "color": "rgba(0, 0, 255, 1)"},
                        "find_element_by_link_text": {"text": "cheese", "color": "rgba(0, 0, 238, 1)"},
                        "find_element_by_partial_link_text": {"text": "cheese", "color": "rgba(0, 0, 238, 1)"},
                        "find_element_by_css_selector": {"text": "World", "color": "rgba(255, 0, 0, 1)"},
                        "find_element_by_xpath": {"text": "", "color": "rgba(255, 255, 0, 1)"}
        }
        return expect_value


def setupHttpdServerOnLAN():
    """
    Setup httpd server on LAN PC
    """
    from shutil import copyfile

    src_file_dir = "/root/automation/tools/2.0/START_SERVERS/httpd/"
    src_file = ["index.html", "selenium_feature_test.html", "eg_landscape.jpg"]
    dst_dir = "/var/www/html/"
    if not os.path.isdir(dst_dir):
        os.makedirs(dst_dir)

    for i in src_file:
        full_src_file = os.path.join(src_file_dir, i)
        full_dst_file = os.path.join(dst_dir, i)
        if os.path.exists(full_src_file):
            copyfile(full_src_file, full_dst_file)
        else:
            print "AT_ERROR : File %s isn\'t exists!" % full_src_file
            return False

    s_log, k_result = run("service httpd restart", withexitstatus=True, timeout=60)
    if not k_result:
        print "Service httpd is ready for test..."
        return True
    return False


def stopHttpdServerOnLAN():
    """
    Stop httpd server on lan pc
    """
    p_log, p_result = run("service httpd stop", withexitstatus=True, timeout=60)

    if not p_result:
        print "Service httpd stoped..."
        return True
    else:
        print "Stop httpd service error,try to force kill it\'s process..."
        k_log, k_result = run("killall -9 httpd", withexitstatus=True, timeout=60)
        if not k_result:
            return True
        else:
            return False


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ("\nGet more info with command : pydoc " + os.path.abspath(__file__) + "\n")
    parser = OptionParser(usage=usage)

    parser.add_option("-U", "--base_url", dest="url", default="http://127.0.0.1/selenium_feature_test.html",
                      help="Destination http url to check.")

    parser.add_option("-d", "--debug", dest="isDebug", action="store_true", default=True,
                      help="If debug mode on,will print the debug information")

    parser.add_option("-b", "--browser_name", dest="browser_name", default="firefox", type='choice',
                      action="store",
                      choices=['chrome', 'firefox', 'internet explorer', 'safari'],
                      help="Choice the browser name you want to check,default is firefox.")

    (options, args) = parser.parse_args()

    return options


def test():
    """
    Test code
    """
    opts = parseCommandLine()
    print "URL======><%s>" % opts.url
    print "Browser==><%s>" % opts.browser_name

    firefox_test = BrowserOrWebDriverCheck(opts.browser_name, opts.url, opts.isDebug)
    try:
        firefox_test.dirver_test()
    except Exception, e:
        print str(e)
        firefox_test.driver_quit()
    firefox_test.driver_quit()


def testServer():
    a = setupHttpdServerOnLAN()
    b = stopHttpdServerOnLAN()
    print a, b


if __name__ == '__main__':
    """
    Main function
    """
    setupHttpdServerOnLAN()
    test()
    stopHttpdServerOnLAN()        
      
        
        
        
        
        
    
