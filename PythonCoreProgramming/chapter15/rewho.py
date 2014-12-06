#!/usr/bin/env python
# coding=utf-8
__author__ = 'root'

from os import popen
from re import split

f = popen('who', 'r')

for eachLine in f.readline():
    print split('\s\s+/\t', eachLine.strip())
    f.close()

