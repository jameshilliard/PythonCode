#coding=utf-8
from selenium import webdriver
#from selenium.webdriver.common.by import By
#from selenium.webdriver.common.keys import Keys
#from selenium.webdriver.support.ui import Select
#from selenium.webdriver.support.ui import WebDriverWait
#from selenium.common.exceptions import NoSuchElementException
from selenium.webdriver.common.action_chains import ActionChains
import unittest, time, re
import login
import quit


class Rename(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Firefox()
        self.driver.implicitly_wait(30)
        self.base_url = "http://passport.kuaibo.com"
        self.verificationErrors = []
        self.accept_next_alert = True

    #去除重复操作用例
    def test_rename(self):
        u"""智能重命名"""
        driver = self.driver
        driver.get(self.base_url + "/login/?referrer=http%3A%2F%2Fwebcloud.kuaibo.com%2F")


        #调用登录模块
        login.login(self)


        #新功能引导
        driver.find_element_by_class_name("guide-ok-btn").click()
        time.sleep(3)


        #智能重命名
        element = driver.find_element_by_class_name("more-fe")
        ActionChains(driver).move_to_element(element).perform()
        time.sleep(2)

        lis = driver.find_elements_by_tag_name('li')
        for li in lis:
            if li.get_attribute('data-action') == 'renameAll':
                li.click() #点击重命名选项
        time.sleep(2)
        #确定重命名
        driver.find_element_by_class_name("msg-box-panel").find_element_by_xpath(
            "/html/body/div[8]/div[2]/div[2]/div").click()


        #退出
        driver.find_element_by_class_name("Usertool").click()
        time.sleep(2)
        driver.find_element_by_link_text("退出").click()
        time.sleep(2)

        print "ok"

    def tearDown(self):
    #   self.driver.quit()
    # self.assertEqual([], self.verificationErrors)
        quit.quit(self)


if __name__ == "__main__":
    unittest.main()






