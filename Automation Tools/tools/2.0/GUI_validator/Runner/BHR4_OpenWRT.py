from BaseRunner import BaseRunner
from selenium import webdriver
from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
import os


class Runner_V01F(BaseRunner):
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

        userpass = os.getenv('U_DUT_HTTP_PWD', 'password')

        if not userpass:
            print 'AT_ERROR : must specified userpass'
            return False

        if self.wait_id_exist('login_username'):
            try:
                input_usr = driver.find_element_by_id("login_username")
                input_usr.clear()
                input_usr.send_keys(username)

                input_psw = driver.find_element_by_id('virtual_password')
                input_psw.clear()
                input_psw.send_keys(userpass)

            except:
                print 'AT_ERROR : error occured in login'
                return False
        else:
            if driver.find_element_by_link_text("Logout").is_displayed():
                print 'Already logged in !'
                return True
            else:
                print 'ERROR in getting main / login page '
                return False

        if self.wait_id_exist('login_btn'):
            input_apply = find_element_by_id("login_btn").click()
            input_apply.click()

            if driver.find_element_by_link_text("Logout").is_displayed():
                print 'Already logged in !'
                return True
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
        driver.get(self.base_url)
        al_login = driver.find_element_by_link_text("Logout")
        if al_login:
            try:
                al_login.click()
            except:
                print 'Already logout...'
        return True


hash_runners = {
    'CORTINA-BHR4-0-0-01F': Runner_V01F,
}

def_runner = 'CORTINA-BHR4-0-0-01F'


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
