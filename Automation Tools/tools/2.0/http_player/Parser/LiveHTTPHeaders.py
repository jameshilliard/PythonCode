#!/usr/bin/python
#       LiveHTTPHeaders.py
#       
#       Copyright 2011 rayofox <lhu@actiontec.com>
#       
#       This program is free software; you can redistribute it and/or modify
#       it under the terms of the GNU General Public License as published by
#       the Free Software Foundation; either version 2 of the License, or
#       (at your option) any later version.
#       
#       This program is distributed in the hope that it will be useful,
#       but WITHOUT ANY WARRANTY; without even the implied warranty of
#       MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#       GNU General Public License for more details.
#       
#       You should have received a copy of the GNU General Public License
#       along with this program; if not, write to the Free Software
#       Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#       MA 02110-1301, USA.
#       
#       
"""
Parser for LiveHTTPHeaders

"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "1.0"
__history__ = """
Rev 1.0 : 2011/11/02
	Initial version
"""
#------------------------------------------------------------------------------
import types
import sys, time, os
import re
from optparse import OptionParser
from pprint import pprint
from pprint import pformat
import subprocess, signal, select
import copy

#------------------------------------------------------------------------------
class Parser():
    """
    This class is the HTTP Player
    LiveHTTPHeaders sample :

    http://192.168.1.1/index.cgi

    POST /index.cgi HTTP/1.1
    Host: 192.168.1.1
    User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:7.0.1) Gecko/20100101 Firefox/7.0.1
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
    Accept-Language: zh-cn,zh;q=0.5
    Accept-Encoding: gzip, deflate
    Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7
    Connection: keep-alive
    Referer: http://192.168.1.1/index.cgi?active%5fpage=9119&active%5fpage%5fstr=page%5factiontec%5fwireless%5fstatus&req%5fmode=0&mimic%5fbutton%5ffield=sidebar%3a+actiontec%5ftopbar%5fwireless%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=actiontec%5ftopbar%5fwireless
    Cookie: rg_cookie_session_id=1538790054
    Content-Type: application/x-www-form-urlencoded
    Content-Length: 221
    active_page=9119&active_page_str=page_actiontec_wireless_status&page_title=Wireless+Status&mimic_button_field=btn_tab_goto%3A+9121..&button_value=actiontec_topbar_wireless&strip_page_top=0&tab4_selected=0&tab4_visited_0=1
    HTTP/1.1 302 Moved Temporarily
    Content-Type: text/html
    Cache-Control: public
    Pragma: cache
    Expires: Fri, 28 Oct 2011 04:03:59 GMT
    Date: Fri, 28 Oct 2011 03:33:59 GMT
    Last-Modified: Fri, 28 Oct 2011 03:33:59 GMT
    Accept-Ranges: bytes
    Connection: close
    Location: /index.cgi?active%5fpage=9121&active%5fpage%5fstr=page%5factiontec%5fwireless%5fadvanced%5fsetup&req%5fmode=0&mimic%5fbutton%5ffield=btn%5ftab%5fgoto%3a+9121%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=9121

    The common format is :
    <URL>
    <blank-line>
    <request-line>
    <request-headers>
    <request-body>
    <status-line>
    <response-headers>
    <blank-line>
    <response-body>
    <separate-line>

    """
    ###Member Variables###
    #
    # 3 : debug
    # 2 : info
    # 1 : warning
    # 0 : error
    mv_lvl = 2
    # The format of a LiveHTTPHeaders record
    mv_fmt = ['URL', 'blank-line',
              'request-line', 'request-headers', 'request-body',
              'response-line', 'response-headers', 'response-body',
              'separate-line']
    mv_dat = {
    'URL': '',
    'blank-line': '',
    'request-line': '',
    'request-headers': [],
    'request-body': '',
    'response-line': '',
    'response-headers': [],
    'response-body': None,
    'separate-line': '',
    }
    # The major information required with HTTP Request playback
    mv_req = {
    # combined elements
    'URL': '',
    'request-line': '',
    'request-body': None,
    # basic elements
    'host': '',
    'proto': '',
    'uri': '',
    'method': '',
    }
    #
    mv_section = {
    'fmt': None,
    'dat': None,
    'req': None,
    }
    #
    mv_chapter = {
    'recfile': '',
    'midfile': '',
    'sections': [],
    }
    #
    mv_recFiles = None
    mv_midFiles = None
    mv_chapters = []

    def __init__(self, loglevel=2):
        """
        """
        self.mv_lvl = loglevel
        pass

    def newChapter(self):
        """
        """
        return copy.deepcopy(self.mv_chapter)

    def newSection(self):
        """
        """
        section = copy.deepcopy(self.mv_section)
        fmt = copy.deepcopy(self.mv_fmt)
        dat = copy.deepcopy(self.mv_dat)
        req = copy.deepcopy(self.mv_req)
        section = {
        'fmt': fmt,
        'dat': dat,
        'req': req,
        }
        return section


    def debug(self, msg):
        """
        """
        #print '==DBG',str(msg)
        if self.mv_lvl > 2:
            pprint("==DBG : " + pformat(msg))
        return True

    def info(self, msg):
        """
        """
        if self.mv_lvl > 1:
            print '==INF', str(msg)
        return True

    def warning(self, msg):
        """
        """
        if self.mv_lvl > 0:
            print '==WAR', str(msg)
        return True

    def error(self, msg):
        """
        """
        print '==ERR', str(msg)
        return True


    def reset(self):
        """
        """
        self.mv_recFiles = None
        self.mv_midFiles = None
        self.mv_chapters = []

    def saveAsRecFiles(self, path):
        """
        """
        for chapter in self.mv_chapters:
            fname = chapter['recfile']
            sections = chapter['sections']
            fname = (path + '/' + fname)
            fd = open(fname, 'w')
            if fd:
                for section in sections:
                    lines = self.section2lines(section)
                    for line in lines:
                        #print '===',line
                        fd.writelines(line)
                        fd.write('\n')
                fd.close()
            else:
                self.error('can not open mid file to save : ' + fname)
        return True

    def saveAsMidFiles(self, path):
        """
        """
        for chapter in self.mv_chapters:
            fname = chapter['midfile']
            sections = chapter['sections']
            fname = (path + '/' + fname)
            fd = open(fname, 'w')
            if fd:
                fd.write('items = ')
                fd.write(pformat(chapter))
                fd.close()
            else:
                self.error('can not open mid file to save : ' + fname)
        return True


    def parseRecFiles(self, files):
        """
        """
        rc = os.popen('ls ' + files).read()
        self.debug('rec files : ' + rc)
        fns = rc.splitlines()
        for fn in fns:
            fname = os.path.abspath(fn)

            fd = open(fname)
            if fd:
                content = fd.read()
                fd.close()
                chapter = self.newChapter()
                basename = os.path.basename(fname)
                chapter['recfile'] = basename
                chapter['midfile'] = basename + '.pp'
                sections = self.parseBuffer(content)
                chapter['sections'] = sections
                self.mv_chapters.append(chapter)

        return self.mv_chapters

    def parseMidFiles(self, files):
        """
        """
        pass

    def updateSectionReq(self, section):
        """
        return value :
        0 : all elements correct
        1 : basic elements error
        2 : combined elements not match and will create new from basic elements
        """

        req = section['req']
        return self.updateReq(req)

    def updateReq(self, req):
        """
        """
        rc = 0
        # host
        if 0 == len(req['host']):
            self.error('FAIL : check host')
            return 1
        # method
        if not req['method'] in ['GET', 'POST']:
            self.error('FAIL : check method')
            return 1
        # uri
        if 0 == len(req['uri']):
            self.error('FAIL : check uri')
            return 1
        # proto
        if not req['proto'].startswith('HTTP'):
            self.error('FAIL : check proto')
            return 1
        # request-line
        reqline = req['method'] + ' ' + req['uri'] + ' ' + req['proto']
        if not req['request-line'].strip() == reqline.strip():
            self.info('request-line changed')
            rc = 2
        req['request-line'] = reqline
        # URL
        proto = 'http'
        host = req['host']
        uri = req['uri']
        m = r'(\w*)/([\w\.]*)'
        content = req['proto'].strip()
        res = re.findall(m, content)
        if res: proto, ver = res[0]
        proto = proto.lower()
        URL = proto + '://' + host + uri
        if not req['URL'].strip() == URL.strip():
            self.info('URL changed')
            rc = 2
            print '--old URL : ', req['URL']
        req['URL'] = URL
        return rc

    def updateSectionWithDat(self, section):
        """
        """
        dat = section['dat']
        req = section['req']
        # URL, request-line, request-body
        req['URL'] = dat['URL']
        req['request-line'] = dat['request-line']
        req['request-body'] = dat['request-body']

        # find host
        req['host'] = ''
        m = r'Host\s*:\s*([^\s]*)'
        for header in dat['request-headers']:
            res = re.findall(m, header)
            if len(res) > 0:
                req['host'] = res[0]
                break
            #exit(1)
        # method,uri,proto
        rc = self.matchRequestLine(req['request-line'])
        if rc:
            (req['method'], req['uri'], req['proto']) = rc
        else:
            self.error('parse request-line error')
        return True

    def updateSectionWithReq(self, section):
        """
        When req element(s) changed outside,
        call this function to update section dat with req
        """
        dat = section['dat']
        req = section['req']
        if 1 == self.updateSectionReq(section):
            exit(1)
        # combined elements
        dat['URL'] = req['URL']
        dat['request-line'] = req['request-line']
        dat['request-body'] = req['request-body']
        # host
        m = r'Host\s*:\s*([^\s]*)'
        for index, header in enumerate(dat['request-headers']):
            res = re.findall(m, header)
            if len(res) > 0:
                dat['request-headers'][index] = 'Host: ' + req['host']
        return True

    def section2str(self, section):
        """
        """
        rc = ''
        lines = self.section2lines(section)
        for line in lines:
            rc += line
        return rc

    def section2lines(self, section):
        """
        """
        fmt = section['fmt']
        dat = section['dat']
        lines = []
        for key in fmt:
            val = None
            if dat.has_key(key): val = dat[key]
            if types.ListType == type(val):
                lines += (val)
            elif types.StringType == type(val):
                lines.append(val)
            elif types.NoneType == type(val):
                self.debug('value of ' + key + ' is None')
                pass
        return lines

    def matchURL(self, line):
        """
        match http://192.168.1.1/wireless_advanced_wep.html?type=WEP&ssid=ath0
        """
        m = r'^http://'
        content = line.strip()
        res = re.findall(m, content)
        if 0 == len(res):
            self.debug('is not URL ')
        else:
            self.debug('is URL ')
            return True
        return False

    def matchRequestLine(self, line):
        """
        match :
        GET /wireless_advanced_wep.html?type=WEP&ssid=ath0 HTTP/1.1
        POST /index.cgi HTTP/1.1
        """
        m = r'(\w*)\s*([^\s]*)\s*(HTTP[^\s]*)'
        content = line.strip()
        res = re.findall(m, content)
        if 0 == len(res):
            self.debug('is not request-line ')
        else:
            (method, uri, proto) = res[0]
            if method in ['POST', 'GET']:
                self.debug('is request-line ')
                return (method, uri, proto)
            else:
                self.debug('is not request-line ')
        return False

    def matchRequestHeaders(self, line):
        """
        match :
        Host: 192.168.1.1
        User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:6.0.2) Gecko/20100101 Firefox/6.0.2
        Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
        Accept-Language: zh-cn,zh;q=0.5
        Accept-Encoding: gzip, deflate
        Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7
        Connection: keep-alive
        Referer: http://192.168.1.1/wireless_status.html
        """
        m = r'([^\s=]*)\s*:\s*(.*)'
        content = line.strip()
        res = re.findall(m, content)
        if 0 == len(res):
            self.debug('is not request-headers ')
        else:
            self.debug('is request-headers ')
            return res[0]
        return False

    def matchRequestBody(self, line):
        """
        match :
        nat=1
        active_page=9131&active_page_str=page_home_act_vz&page_title=Main
        apply_page=wireless_advanced_wep.html%3Ftype%3DWEP%26ssid%3Dath0&waiting_page=waiting_page.html
        """
        m = r'(\w*)=([^&]*)'
        content = line.strip()
        res = re.findall(m, content)
        if 0 == len(res):
            self.debug('is not request-body ')
        else:
            self.debug('is request-body ')
            return res
        return False

    def matchResponseLine(self, line):
        """
        match :
        HTTP/1.1 302 Found
        HTTP/1.1 200 OK
        """
        m = r'^(HTTP[^\s]*)\s*(\d*)\s*(.*)'
        content = line.strip()
        res = re.findall(m, content)
        if 0 == len(res):
            self.debug('is not request-body ')
        else:
            self.debug('is request-body ')
            return res[0]
        return False

    def matchResponseHeaders(self, line):
        """
        same as matchRequestHeaders
        """
        m = r'([^\s=]*)\s*:\s*(.*)'
        content = line.strip()
        res = re.findall(m, content)
        if 0 == len(res):
            self.debug('is not response-headers ')
        else:
            self.debug('is response-headers ')
            return res[0]
        return False

    def matchResponseBody(self, line):
        """
        same as match matchRequestBody
        """
        m = r'(\w*)=([^&]*)'
        content = line.strip()
        res = re.findall(m, content)
        if 0 == len(res):
            self.debug('is not response-body ')
        else:
            self.debug('is response-body ')
            return res
        return False

    def matchSeparateLine(self, line):
        """
        """
        return True

    def parseBuffer(self, buf):
        """
        """
        self.debug('== in parseBuffer')
        lines = buf.splitlines()
        sections = []
        section = None
        dat = None

        # 0 : to match URL
        # 1 : to match request-line
        # 2 : to match request-headers
        # 3 : to match request-body [optional]
        # 4 : to match response-line
        # 5 : to match response-headers
        # 6 : to match response-body[optional]
        # 7 : to match separate-line[optional]
        step = 0
        for line in lines:
            self.debug(line)
            if 0 == step:
                rc = self.matchURL(line)
                if rc:
                    step += 1
                    section = self.newSection()
                    dat = section['dat']
                    dat['URL'] = line
                else:
                    self.debug('not find URL ')
            elif 1 == step:
                rc = self.matchRequestLine(line)
                if rc:
                    step += 1
                    dat['request-line'] = line
            elif 2 == step:
                rc1 = self.matchRequestHeaders(line)
                rc2 = self.matchRequestBody(line)
                rc3 = self.matchResponseLine(line)
                if rc1:
                    dat['request-headers'].append(line)
                elif rc3:
                    dat['response-line'] = line
                    step = 5
                elif rc2:
                    dat['request-body'] = line
                    step = 4
            elif 3 == step:
                pass
            elif 4 == step:
                rc = self.matchResponseLine(line)
                if rc:
                    dat['response-line'] = line
                    step = 5
            elif 5 == step:
                rc1 = self.matchResponseHeaders(line)
                rc2 = self.matchResponseBody(line)
                rc3 = self.matchSeparateLine(line)
                if rc1:
                    dat['response-headers'].append(line)
                elif rc2:
                    dat['response-body'] = line
                    step = 7
                elif rc3:
                    dat['separate-line'] = line
                    step = 8
            elif 6 == step:
                pass
            elif 7 == step:
                rc = self.matchSeparateLine(line)
                if rc:
                    dat['separate-line'] = line
                    step = 8

            if 8 == step:
                self.info('finish parse an item')
                sections.append(section)
                self.updateSectionWithDat(section)
                #self.debug( str(item) )
                #pprint(item)
                #alines = self.item2lines(item)
                #for l in alines : print l
                step = 0

        sz = len(sections)
        self.debug('sections count :' + str(sz))

        return sections


sample = """
----------------------------------------------------------
http://192.168.1.1/index.cgi

POST /index.cgi HTTP/1.1
Host: 192.168.1.1
User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:7.0.1) Gecko/20100101 Firefox/7.0.1
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: zh-cn,zh;q=0.5
Accept-Encoding: gzip, deflate
Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7
Connection: keep-alive
Referer: http://192.168.1.1/index.cgi?active%5fpage=9119&active%5fpage%5fstr=page%5factiontec%5fwireless%5fstatus&req%5fmode=0&mimic%5fbutton%5ffield=sidebar%3a+actiontec%5ftopbar%5fwireless%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=actiontec%5ftopbar%5fwireless
Cookie: rg_cookie_session_id=1538790054
Content-Type: application/x-www-form-urlencoded
Content-Length: 221
active_page=9119&active_page_str=page_actiontec_wireless_status&page_title=Wireless+Status&mimic_button_field=btn_tab_goto%3A+9121..&button_value=actiontec_topbar_wireless&strip_page_top=0&tab4_selected=0&tab4_visited_0=1
HTTP/1.1 302 Moved Temporarily
Content-Type: text/html
Cache-Control: public
Pragma: cache
Expires: Fri, 28 Oct 2011 04:03:59 GMT
Date: Fri, 28 Oct 2011 03:33:59 GMT
Last-Modified: Fri, 28 Oct 2011 03:33:59 GMT
Accept-Ranges: bytes
Connection: close
Location: /index.cgi?active%5fpage=9121&active%5fpage%5fstr=page%5factiontec%5fwireless%5fadvanced%5fsetup&req%5fmode=0&mimic%5fbutton%5ffield=btn%5ftab%5fgoto%3a+9121%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=9121
---
"""

sample2 = """
http://192.168.1.1/waiting_page.html

GET /waiting_page.html HTTP/1.1
Host: 192.168.1.1
User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:6.0.2) Gecko/20100101 Firefox/6.0.2
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: zh-cn,zh;q=0.5
Accept-Encoding: gzip, deflate
Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7
Connection: keep-alive
Referer: http://192.168.1.1/wireless_advanced_wep.html?type=WEP&ssid=ath0

HTTP/1.1 200 OK
Connection: close
Etag: "3f9-19da-4e8fbc7e"
Last-Modified: Sat, 08 Oct 2011 02:59:10 GMT
Date: Sat, 01 Jan 2000 03:32:16 GMT
Content-Type: text/html
Content-Length: 6618
Cache-Control: private, no-cache, must-revalidate
Expires: 0
Transfer-Encoding: chunked
----------------------------------------------------------
"""


def main():
    """
    main entry
    """
    loglevel = 3 # debug
    parser = Parser(loglevel)
    parser.reset()
    chapters = parser.parseRecFiles('rec001')
    if 1 == len(chapters):
        chapter = chapters[0]
        pprint(chapter)
    #parser.debug('=='*16 + '\n1 file')
    # save to files
    #parser.saveAsRecFiles('../')
    #parser.saveAsMidFiles('../')


if __name__ == '__main__':
    """
    """
    main()


