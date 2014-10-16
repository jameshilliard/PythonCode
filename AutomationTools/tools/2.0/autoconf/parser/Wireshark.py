#!/usr/bin/env python -u
"""
Parser translate raw http data catched by Wireshark 

Wireshark filter for Q2000: 
    ip.dst == 192.168.0.1 and http and 
    !(http.request.method==M-SEARCH) and !(http.request.method==NOTIFY) and 
    !(http.request.uri contains connect_left_refresh.html) and 
    !(http.request.uri contains .css) and 
    !(http.request.uri contains .js)  and 
    !(http.request.uri contains .gif)  and 
    !(http.request.uri contains .bmp)  and 
    !(http.request.uri contains .png)
    
    ip.dst == 192.168.0.1 : destination ip is DUT
    http : http package only
    !(http.request.method==M-SEARCH) and !(http.request.method==NOTIFY) : filter SSDP
    !(http.request.uri contains connect_left_refresh.html) : filter auto refresh request
    
    (!(http.request.uri contains .css) and 
    !(http.request.uri contains .js)  and 
    !(http.request.uri contains .gif)  and 
    !(http.request.uri contains .bmp)  and 
    !(http.request.uri contains .png) ) : filter all resource request
    
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

import re, time
import urllib
from pprint import pprint
from pprint import pformat


class Parser():
    """
    """
    debug = 0
    request = {
        'protocol': '',
        'destination': '',
        'description': 'no description',
        'method': '',
        'path': '',
        'body_len': 0,
        'query': '',
        'body': '',
        'URI': ''
    }

    ###Output data
    info = {
        'login': 0,
        'logout': 0,
        'dut': '',
        'id': '',
        'name': 'No name',
        'host': 'http://192.168.0.1',
        'username': '',
        'password': ''

    }
    requests = []

    # init
    def __init__(self, debug=0, info={}):
        self.debug = debug
        self.info.update(info)
        print '==Parser for Wireshark'
        return

        #
    def resetRequest(self):
        self.request = {
            'description': 'no description',
            'protocol': 'HTTP',
            'destination': '',
            'method': '',
            'path': '',
            'body_len': 0,
            'query': '',
            'body': '',
            'URI': ''
        }
        return True

        # add cfg
    def appendRequest(self):
        self.requests.append(self.request)
        return True

    # self test
    def self_test(self):
        return

    # parse file
    def parseFile(self, fname):
        rc = False
        fd = open(fname)
        if fd:
            buf = fd.read()
            rc = self.parseBuffer(buf)
            fd.close()
            return rc
        return rc

    # parse buffer
    def parseBuffer(self, buf):
        rc = False
        # split buffer to sessions
        buf = buf.strip()
        match = r'No\.\s+Time\s+Source\s+Destination\s+Protocol\ Info\s+'
        res = re.findall(match, buf)
        if self.debug: print '[split sessions]', len(res)
        if 0 == len(res): return False
        res = re.split(match, buf)
        #print res
        i = 0
        while (i < len(res)):
            sess = res[i]
            rc = self.parseSess(sess)
            i += 1
        return rc

    # parse session
    def parseSess(self, sess):
        rc = False
        sess = sess.strip()
        if self.debug: print 'sess =(%d) %s' % (len(sess), sess)
        # empty is ignore
        if 0 == len(sess):
            return rc
            # reset cfg
        self.resetRequest()
        # parse summary
        rc = self.parseSummary(sess)
        if not rc:
            return False
            #if self.debug : print '\n'*3;print 'request = %s' %pformat(self.request)
        # GET request parse summary only
        if 'GET' == self.request['method']:
            if self.debug: print '\n' * 3;print 'request = %s' % pformat(self.request)
            self.appendRequest()
            return True
            # POST request data
        rc = self.parsePostData(sess)
        if self.debug: print '\n' * 3;print 'request = %s' % pformat(self.request)
        if rc and 'POST' == self.request['method']:
            self.appendRequest()
        return rc

    # parse summary
    def parseSummary(self, sess):
        rc = False
        summary = {}
        summary_title = ['No.', 'Time', 'Source', 'Destination', 'Protocol', 'Method', 'URI', 'Version']
        lines = sess.splitlines()
        summary_data = lines[0]
        if self.debug: print 'summay data = %s' % pformat(summary_data)
        # remove [TCP Retransmission]
        match = r'(\[[^\]]+])'
        summary_data = re.sub(match, '', summary_data)
        # split to words
        words = summary_data.split()
        if self.debug: print 'words = %s' % pformat(words)
        i = 0
        while i < len(summary_title) and i < len(words):
            key = summary_title[i]
            val = words[i]
            if self.debug: print 'key = %s' % pformat(key)
            if self.debug: print 'val = %s' % pformat(val)
            summary[key] = val
            i += 1
        if self.debug: print '*' * 32;print 'summay = %s' % pformat(summary)
        # set info value
        #self.info['host'] = summary['Protocol'] + '://' + summary['Destination']
        # set cfg value
        req = self.request
        req['method'] = summary['Method']
        req['destination'] = summary['Destination']
        req['URI'] = summary['URI']
        req['protocol'] = summary['Protocol']
        req['path'] = summary['URI']
        req['description'] = req['method'] + ' ' + req['URI'] + ' ' + summary['Version']

        method = req['method']
        # input GET query
        if 'GET' == method:
            res = req['URI'].split('?')
            req['path'] = res[0]
            if 2 == len(res):
                req['query'] = res[1]
        rc = True
        return rc

    # parse POST data
    def parsePostData(self, sess):
        rc = False
        req = self.request
        # get HTTP data zone
        match = r'Hypertext Transfer Protocol'
        res = re.split(match, sess)
        if 2 > len(res):
            print '---bad http locate'
            return rc
        d = res[1]
        if self.debug: print 'HTTP data : ', d
        # Content type and length
        match = r'Content\-(\S+)\s*:\s*(\S+)'
        res = re.findall(match, d)
        for (key, val) in res:
            if 'Type' == key:
                pass
            elif 'Length' == key:
                req['body_len'] = val
                #print '-----body_len',val
            #print res
        lines = d.splitlines()
        isData = False
        for line in lines:
            match = r'Line-based text data'
            #print 'line :',line
            if line.startswith(match):
                #print '###'
                isData = True
                continue
            if isData:
                #print '@@@'
                req['body'] = line.strip()
                rc = True
                break
        return rc

        # get result
    def GetResult(self):
        return self.info, self.requests


tbuf = """
No.     Time        Source                Destination           Protocol Info
     44 11.989266   192.168.1.100         192.168.1.1           HTTP     GET /connect_left_refresh.html HTTP/1.1

Frame 44 (484 bytes on wire, 484 bytes captured)
    Arrival Time: May  4, 2011 10:59:06.372851000
    [Time delta from previous captured frame: 0.000992000 seconds]
    [Time delta from previous displayed frame: 2.998376000 seconds]
    [Time since reference or first frame: 11.989266000 seconds]
    Frame Number: 44
    Frame Length: 484 bytes
    Capture Length: 484 bytes
    [Frame is marked: False]
    [Protocols in frame: eth:ip:tcp:http]
    [Coloring Rule Name: HTTP]
    [Coloring Rule String: http || tcp.port == 80]
Ethernet II, Src: 00:ee:ee:01:ab:22 (00:ee:ee:01:ab:22), Dst: Actionte_fa:7b:68 (00:15:05:fa:7b:68)
    Destination: Actionte_fa:7b:68 (00:15:05:fa:7b:68)
    Source: 00:ee:ee:01:ab:22 (00:ee:ee:01:ab:22)
    Type: IP (0x0800)
Internet Protocol, Src: 192.168.1.100 (192.168.1.100), Dst: 192.168.1.1 (192.168.1.1)
Transmission Control Protocol, Src Port: ddi-tcp-1 (8888), Dst Port: http (80), Seq: 1, Ack: 1, Len: 430
Hypertext Transfer Protocol
    GET /connect_left_refresh.html HTTP/1.1\r\n
        Request Method: GET
        Request URI: /connect_left_refresh.html
        Request Version: HTTP/1.1
    Host: 192.168.1.1\r\n
    User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:2.0.1) Gecko/20100101 Firefox/4.0.1\r\n
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n
    Accept-Language: zh-cn,en-us;q=0.7,en;q=0.3\r\n
    Accept-Encoding: gzip, deflate\r\n
    Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7\r\n
    Keep-Alive: 115\r\n
    Connection: keep-alive\r\n
    Referer: http://192.168.1.1/advancedsetup_nat.html\r\n
    \r\n

No.     Time        Source                Destination           Protocol Info
     55 13.062181   192.168.1.100         192.168.1.1           HTTP     POST /natcfg.cmd HTTP/1.1 (application/x-www-form-urlencoded)

Frame 55 (584 bytes on wire, 584 bytes captured)
    Arrival Time: May  4, 2011 10:59:07.445766000
    [Time delta from previous captured frame: 0.029147000 seconds]
    [Time delta from previous displayed frame: 1.072915000 seconds]
    [Time since reference or first frame: 13.062181000 seconds]
    Frame Number: 55
    Frame Length: 584 bytes
    Capture Length: 584 bytes
    [Frame is marked: False]
    [Protocols in frame: eth:ip:tcp:http:data-text-lines]
    [Coloring Rule Name: HTTP]
    [Coloring Rule String: http || tcp.port == 80]
Ethernet II, Src: 00:ee:ee:01:ab:22 (00:ee:ee:01:ab:22), Dst: Actionte_fa:7b:68 (00:15:05:fa:7b:68)
    Destination: Actionte_fa:7b:68 (00:15:05:fa:7b:68)
    Source: 00:ee:ee:01:ab:22 (00:ee:ee:01:ab:22)
    Type: IP (0x0800)
Internet Protocol, Src: 192.168.1.100 (192.168.1.100), Dst: 192.168.1.1 (192.168.1.1)
Transmission Control Protocol, Src Port: ddi-tcp-2 (8889), Dst Port: http (80), Seq: 1, Ack: 1, Len: 530
Hypertext Transfer Protocol
    POST /natcfg.cmd HTTP/1.1\r\n
        Request Method: POST
        Request URI: /natcfg.cmd
        Request Version: HTTP/1.1
    Host: 192.168.1.1\r\n
    User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:2.0.1) Gecko/20100101 Firefox/4.0.1\r\n
    Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r\n
    Accept-Language: zh-cn,en-us;q=0.7,en;q=0.3\r\n
    Accept-Encoding: gzip, deflate\r\n
    Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7\r\n
    Keep-Alive: 115\r\n
    Connection: keep-alive\r\n
    Referer: http://192.168.1.1/advancedsetup_nat.html\r\n
    Content-Type: application/x-www-form-urlencoded\r\n
    Content-Length: 45
    \r\n
Line-based text data: application/x-www-form-urlencoded
    enblNat=0&needthankyou=advancedsetup_nat.html

"""
if __name__ == "__main__":
    t = time.time()
    parser = Parser(debug=1)
    parser.parseFile('record')
    #parser.parseBuffer(tbuf)
    info, reqs = parser.GetResult()
    print '=' * 50
    print 'info = %s' % pformat(info)
    print 'reqs = %d,%s' % (len(reqs), pformat(reqs))
    print 'SPAN TIME : ', time.time() - t
