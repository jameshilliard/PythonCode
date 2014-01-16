#coding=utf-8
__author__ = 'royxu'

import unittest
# 测试getSize()方法的测试用例
class WidgetSizeTestCase(unittest.TestCase):
    def runTest(self):
        widget = Widget()
        self.assertEqual(widget.getSize(), (40, 40))

        # 测试resize()方法的测试用例


class WidgetResizeTestCase(unittest.TestCase):
    def runTest(self):
        widget = Widget()
        widget.resize(100, 100)
        self.assertEqual(widget.getSize(), (100, 100))

