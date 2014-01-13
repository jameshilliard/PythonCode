from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import Select
from selenium.webdriver.support.wait import WebDriverWait
import os
import unittest
import time
import re

class Download(unittest.TestCase):
    def setUp(self):
        fp = self.enabled_neverAsk_saveToDisk()
        self.driver = webdriver.Firefox(firefox_profile=fp)
        self.driver.implicitly_wait(30)
        self.base_url = 'http://' + os.getenv('G_PROD_IP_BR0_0_0', '192.168.0.1') + '/'
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_download(self):
        driver = self.driver
#        driver.get(self.base_url)
#        # ERROR: Caught exception [ERROR: Unsupported command [selectFrame | realpage | ]]
#        driver.find_element_by_id("apply_btn").click()
        if self.login() :
            driver.find_element_by_link_text("Utilities").click()
            driver.find_element_by_id("double2").click()
            #driver.switch_to_frame("realpage");
            # ERROR: Caught exception [ERROR: Unsupported command [selectWindow | null | ]]
            driver.find_element_by_id("enabled").click()
            driver.find_element_by_link_text("Download").click()
        self.logout()
    
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
        """
        disabled pop window when download & upload file
        """
        self.create_config_file_dir()
        fp = webdriver.FirefoxProfile()
        fp.set_preference("browser.download.folderList", 2)
        fp.set_preference("browser.download.manager.showWhenStarting", False)
        fp.set_preference("browser.download.dir", os.getenv('TMP_CONFIG_FILE_DIR'))
        fp.set_preference("browser.helperApps.neverAsk.saveToDisk", "binary/octet-stream")
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
        
        userpass = os.getenv('U_DUT_HTTP_PWD', '9Vk5ek6j')
        
        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False
        
        driver.get(self.base_url)
        
        if self.wait_id_exist('admin_user_name'):
        
            try:
                input_usr = driver.find_element_by_id('admin_user_name')
                print 'AT_INFO : original username in input : ', input_usr.get_attribute('value')
                input_usr.clear()
                input_usr.send_keys(username)
                #return False
            
            except Exception , e:
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
        print 'to logout'
        driver = self.driver
        driver.get(self.base_url + 'modemstatus_connectionstatus.html')
        driver.switch_to_frame("realpage");
        driver.find_element_by_id("logout_btn").click()
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
