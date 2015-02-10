__author__ = 'roy'
#coding=utf-8
import urllib
import re
def getHtml(url):
    page = urllib.urlopen(url)
    html = page.read()
    return html



def getImg(html):
    reg = r'src="(.+?\.jpg)" pic_ext'
    imgre = re.compile(reg)
    imglist = re.findall(imgre,html)
    return imglist

html = getHtml("http://tieba.baidu.com/p/2738151262")

print html

print getImg(html)