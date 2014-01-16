import unittest
import urllib


class TestUrlHttpcode(unittest.TestCase):
    def setUp(self):
        urlinfo = ['http://www.baidu.com', 'http://www.163.com', 'http://www.sohu.com', 'http://www.cnpythoner.com']
        self.checkurl = urlinfo

    def test_ok(self):
        for m in self.checkurl:
            httpcode = urllib.urlopen(m).getcode()
            self.assertEqual(httpcode, 200)


if __name__ == '__main__':
    unittest.main()