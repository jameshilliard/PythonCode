#coding=utf-8
__author__ = 'royxu'

import unittest
import myclass


class mytest(unittest.TestCase):
    def setUp(self):
        self.tclass = myclass.myclass()
        pass

    def tearDown(self):
        pass

    def testsum(self):
        self.assertEqual(self.tclass.sum(1, 2), 3, 'test sum fail')

    def testsub(self):
        self.assertEqual(self.tclass.sub(2, 1), 1, 'test sub fail')


if __name__ == '__main__':
    unittest.main()