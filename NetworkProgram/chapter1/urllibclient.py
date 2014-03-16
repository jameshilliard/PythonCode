#coding=utf-8
# __author__ = 'royxu'
## High-Level urllib client -Chapter 1 - urllibclient.py

import urllib, sys

host = sys.argv[1]
filename = sys.argv[2]

f = urllib.urlopen('gopher://%s%s' % (host, file))

for line in f.readline():
    sys.stdout.write(line)