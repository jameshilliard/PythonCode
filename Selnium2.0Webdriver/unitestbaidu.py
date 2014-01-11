#coding=utf-8
__author__ = 'royxu'

import unittest, httplib, urllib


class ApiTestCase(unittest, TestCase):
    def setUp(self):
        self.conn1 = httplib.HTTPConnection("www.baidu.com", 80)

    def tearDown(self):
        if self.conn1 is not None:
            self.conn1.close()


    def get(self, path='/'):
        self.conn1.request('GET', path)
        return self.conn.getresponse()

    def post(self, path='/', params={}):
        params = urllib.urlencode(params)
        headers = {"Content-type": "application/x-wwww-form-urlencoded", "Accept": "applciation/json"}
        self.conn1.request('POST', path, params, headers)
        return self.conn.getresponse()

    def test_baidu(self):
        res = self.get('/')
        self.assertEqual(res.status, 200)
        data = res.read()
        self.aasertEqual(data, u'知道')


if __name__ == "__main__":
    unittest.main()