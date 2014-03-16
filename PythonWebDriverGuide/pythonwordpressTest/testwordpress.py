#coding = utf-8
__author__ = 'Roy'

import unittest
from selenium import webdriver

class wordPressTestCase(unittest.TestCase):

    dr = None

    def setUp(self):
        self.dr = webdriver.Firefox()
        print "SetUp"

    def test_case_first(self):
        self.assertEqual(1, 1)

    def test_case_second(self):
        self.assertEqual(1, 1)


    def tearDown(self):

        self.dr.quit()


if __name__ == '__name__':
    unittest.main()