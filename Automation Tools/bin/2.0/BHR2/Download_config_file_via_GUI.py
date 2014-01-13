from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
import time
import unittest
import os

class Download(unittest.TestCase):
    def setUp(self):
        fp = self.enabled_neverAsk_saveToDisk()
        self.driver = webdriver.Firefox(firefox_profile=fp)
        self.driver.implicitly_wait(30)
        self.base_url = 'http://' + os.getenv('G_PROD_IP_BR0_0_0', '192.168.1.1') + '/'
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_download(self):
        driver = self.driver
        driver.get(self.base_url)
#        driver.find_element_by_xpath('/html/body/form/table/tbody/tr[2]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[1]/td[2]/input[2]').clear()
#        driver.find_element_by_xpath('/html/body/form/table/tbody/tr[2]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[1]/td[2]/input[2]').send_keys("admin")
#        driver.find_element_by_id("pass2").clear()
#        driver.find_element_by_id("pass2").send_keys("admin1")
#        driver.find_element_by_link_text("OK").click()
        if self.login() :
            driver.find_element_by_name("actiontec_topbar_adv_setup").click()
            driver.find_element_by_link_text("Yes").click()
            driver.find_element_by_link_text("Configuration File").click()
            driver.find_element_by_link_text("Save Configuration File").click()
            driver.find_element_by_link_text("Logout").click()
            print 'Already logged out'
    
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
    def enabled_neverAsk_saveToDisk(self):
        self.create_config_file_dir()
        fp = webdriver.FirefoxProfile()
        fp.set_preference("browser.download.folderList", 2)
        fp.set_preference("browser.download.manager.showWhenStarting", False)
        fp.set_preference("browser.download.dir", os.getenv('TMP_CONFIG_FILE_DIR'))
        fp.set_preference("browser.helperApps.neverAsk.saveToDisk", "text/plain")
        
        return fp
    
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
        
        userpass = os.getenv('U_DUT_HTTP_PWD', 'admin1')
        
        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False
        
        driver.get(self.base_url)

        if self.wait_id_exist('pass2'):
            try:
                input_usr = driver.find_element_by_xpath('/html/body/form/table/tbody/tr[2]/td/table/tbody/tr/td[2]/table/tbody/tr[2]/td[2]/table/tbody/tr/td/table/tbody/tr[2]/td[2]/table[2]/tbody/tr/td/table/tbody/tr[1]/td[2]/input[2]')
                input_usr.clear()
                input_usr.send_keys(username)
                
                input_psw = driver.find_element_by_id('pass2')
                input_psw.clear()
                input_psw.send_keys(userpass)
                
            except:
                print 'AT_ERROR : error occured in login'
                return False
        else:
            #http://192.168.1.1/index.cgi?active_page=9128&active_page_str=page_home_act_vz&req_mode=0&mimic_button_field=submit_button_login_submit%3a+..&strip_page_top=0&button_value=.
            if self.match_url('page%5fhome%5fact%5fvz'):
                print 'Already logged in !'
                return True
            else:
                print 'ERROR in getting main / login page '
                return False
    
        
            
        if self.wait_link_text_exist('OK'):
            input_apply = driver.find_element_by_link_text('OK')
            input_apply.click()
            
            if self.match_url('page%5fhome%5fact%5fvz',):
                print 'Already logged in !'
                #return True
            else:
                print 'ERROR in getting main / login page '
                return False
        
        else:
            print 'AT_ERROR : error occured in login'
            return False
        
        return True
    
    def wait_link_text_exist(self, id, to=10):
        """
        wait till element present
        True
        False
        """
        
        #print 'in function : wait_id_exist'
        driver = self.driver
        
        try:
            WebDriverWait(driver, to).until(lambda driver : driver.find_element_by_link_text(id))
        
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
            WebDriverWait(driver, to).until(lambda driver : driver.find_element_by_id(id))
        
            print driver.current_url
        
        except:
            print 'AT_ERROR : no such element of id exist -- %s' % (id)
            return False
        
        print 'AT_INFO : the element of id %s exists' % (id)
        return True
    
    def match_url(self, url, tmo=10):
        print ' dest url :', url
        driver = self.driver
        
        waited = 0

        check_interval = 2
        check_retry = int(tmo) / check_interval
        
        for i in range(check_retry):
            cur_url = driver.current_url
            print ' current url : ', cur_url
            if cur_url.find(url) > -1:
                print 'match url passed'
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
            
    def create_config_file_dir(self):
        """
        create config file dir
        True
        False
        """
        print 'to create config file dir'
        
        log_path = os.getenv('G_CURRENTLOG')
        if not log_path :
            log_path = '/tmp'
        
        if os.path.exists(log_path) :
            try:
                os.mkdir(log_path + '/config')
            except Exception, e:
                print str(e)
            os.environ.update({'TMP_CONFIG_FILE_DIR' : log_path + '/config'})
            fname = os.getenv('U_CUSTOM_UPDATE_ENV_FILE', None)
            if fname:
                fname = os.path.expandvars(fname)
                file = open(fname, 'a')
                file.write('-v TMP_CONFIG_FILE_DIR=' + log_path + '/config' + '\n')
                file.close()
        else :
            print 'AT_ERROR : no such directory : <' + log_path + '>'
            return False
        
        return True

if __name__ == "__main__":
    unittest.main()
