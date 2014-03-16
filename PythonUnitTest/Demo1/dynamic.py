#coding=utf-8
__author__ = 'royxu'

import unittest
# 执行测试的类
class WidgetTestCase(unittest.TestCase):
    def setUp(self):
        self.widget = Widget()

    def tearDown(self):
        self.widget.dispose()
        self.widget = None

    def testSize(self):
        self.assertEqual(self.widget.getSize(), (40, 40))

    def testResize(self):
        self.widget.resize(100, 100)
        self.assertEqual(self.widget.getSize(), (100, 100))