#coding=utf-8
__author__ = 'royxu'
import unittest
# 执行测试的类
class WidgetTestCase(unittest.TestCase):
    def runTest(self):
        widget = Widget()
        self.assertEqual(widget.getSize(), (40, 40))