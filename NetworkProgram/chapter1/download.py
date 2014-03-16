#coding=utf-8
# __author__ = 'royxu'

import urllib
import sys

f = urllib.urlopen(sys.argv[1])
while 1:
    buf = f.read(2048)
    if not len(buf):
        break
    sys.stdout.write(buf)