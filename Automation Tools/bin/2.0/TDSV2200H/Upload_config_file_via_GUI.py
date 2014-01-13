from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.support.wait import WebDriverWait
import unittest
import subprocess, signal, select
import time
import re
import os

class Untitled(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Firefox()
        self.driver.implicitly_wait(30)
        self.base_url = 'http://' + os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1') + '/'
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_untitled(self):
        driver = self.driver
        driver.get(self.base_url)
        if self.login() :
            time.sleep(5)
            print 'Oh,login to DUT.....'
            driver.find_element_by_xpath("id('navigation')/li[5]/a").click()
            driver.find_element_by_id("Config DownUpload").click()
            #config_file_path = '/tmp/config/backupsettings.conf'
            config_file_path = self.get_config_file_path()
            driver.find_element_by_name("filename").send_keys(config_file_path)
            driver.find_element_by_css_selector("input[type=\"submit\"]").click()
            self.check_url("http://192.168.0.1/index.html", 240)
                
    def is_element_present(self, how, what):
        try: self.driver.find_element(by=how, value=what)
        except NoSuchElementException, e: return False
        return True
    
    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to_alert()
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert.text
        finally: self.accept_next_alert = True
    
    def tearDown(self):
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

#### the following function add by manual
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
                    
    def login(self):
        """
        login
        True
        False
        """
        
        print 'to login'
        
        driver = self.driver
        
        username = os.getenv('U_DUT_HTTP_USER', 'admin')
        
        if not username:
            print 'AT_ERROR : must specified username'
            return False
        
        userpass = os.getenv('U_DUT_HTTP_PWD', 'password')
        
        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False
        
#        driver.get(self.base_url)
  
        print 'Try to login : <%s>'%self.wait_id_exist('admin_user_name')
        al_login = driver.find_element_by_css_selector("#login_info > a.button1 > span")
        print 'Already login : <%s>'%al_login
        if al_login:
            try: 
                al_login.click()
            except :
                print 'Not login...'
                
#        if self.wait_id_exist('admin_user_name'):
#            driver.find_element_by_id("admin_user_name").clear()
#            driver.find_element_by_id("admin_user_name").send_keys(username)
#        if self.wait_id_exist("admin_password"):
#            driver.find_element_by_id("admin_password").clear()
#            print 'The login password is :<%s>'%userpass
#            driver.find_element_by_id("admin_password").send_keys(userpass)
#        driver.find_element_by_css_selector("a.button1 > span").click()
#        driver.find_element_by_link_text("Login").click()     
        return True

    
    def wait_id_exist(self, id, to=10):
        """
        wait till element present
        True
        False
        """
        
        print 'in function : wait_id_exist'
        driver = self.driver
        
        try:
            WebDriverWait(driver, to).until(lambda driver : driver.find_element_by_id(id))
        
            print driver.current_url
        
        except:
            print 'AT_ERROR : no such element of id exist -- %s' % (id)
            return False
        
        print 'AT_INFO : the element of id %s exists' % (id)
        return True
    
    def subproc(self, cmdss, timeout=3600) :
        """
        subprogress to run command
        0 = pass
        not 0 = fail
        """
        print 'in subproc'
        rc = None
        output = ''
    
        print '    Commands to be executed :', cmdss
    
        all_rc = 0
        all_output = ''
    
        cmds = cmdss.split(';')
    
        for cmd in cmds:
            if not cmd.strip() == '':
                print 'INFO : executing > ', cmd
                
                try :
                    #
                    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True, shell=True)
                    while_begin = time.time()
                    while True :
    
                        to = 600
                        fs = select.select([p.stdout, p.stderr], [], [], to)
    
                        if p.stdout in fs[0]:
                            tmp = p.stdout.readline()
                            if tmp :
                                output += tmp
                                print 'INFO : ', tmp
                            else :
                                while None == p.poll() : pass
                                break
                        elif p.stderr in fs[0]:
                            tmp = p.stderr.readline()
                            if tmp :
                                output += tmp
                                print 'ERROR : ', tmp
                            else :
                                while None == p.poll() : pass
                                break
                        else:
                            s = os.popen('ps -f| grep -v grep |grep sleep').read()
    
                            if len(s.strip()) :
                                continue
    
                            p.kill()
    
                            break
                        # Check the total timeout
                        dur = time.time() - while_begin
                        if dur > timeout :
                            print 'ERROR : The subprocess is timeout due to taking more time than ' , str(timeout)
                            break
                    rc = p.poll()
                    # close all fds
                    p.stdin.close()
                    p.stdout.close()
                    p.stderr.close()
    
                    print 'INFO : return value', str(rc)
    
                except Exception, e :
                    print 'ERROR :Exception', str(e)
                    rc = 1
    
            all_rc += rc
            all_output += output
    
        return all_rc, all_output

    def get_config_file_path(self):
        """
        get config file path
        """
        print 'in function : get_config_file_path'

#add for debug
#        os.environ.update({'TMP_CONFIG_FILE_DIR' : '/tmp/config'})
        
        config_file_dir = os.path.expandvars('$TMP_CONFIG_FILE_DIR')
        
        rc, out = self.subproc("ls --time ctime --format single-column " + config_file_dir + " | head -1")
        
        print 'rc     :', rc
        print 'out    :', out
        
        if not out == '':
            config_file_path = os.path.expandvars(config_file_dir + '/' + out).strip()
            print 'full latest log path : ' + config_file_path
        else:
            print 'no latest updated log file'
            return False
        return config_file_path
    

if __name__ == "__main__":
    unittest.main()

