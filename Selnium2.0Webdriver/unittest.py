#coding=utf-8
__author__ = 'royxu'

import httplib, json

#get

conn = httplib.HTTPConnection('www.baidu.com', 80)

conn.request('GET', '/')

r1 = conn.getresponse()

print r1.status, r1.reason

data = r1.read()

print data

conn.close()