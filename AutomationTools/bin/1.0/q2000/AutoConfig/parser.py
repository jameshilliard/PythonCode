#!/usr/bin/python
"""
Runner 
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

import re
import urllib
"""
Raw File Format:
    
REQUEST_URL
REQUEST_HEADER
REQUEST_BODY
RESPONSE_HEADER
"""

class parser():
    """
    """
    ###Temp data
    # sessions split with '-'*50
    sess_split = ''
    requests = []
    sections = ['REQUEST_URL','REQUEST_HEADER','REQUEST_BODY','RESPONSE_HEADER']
    handlers = []
    step = 0

    cfg = {
    'description' : 'None',
    'method' : '',
    'path' : '',
    'body_len' : 0,
    'body' : ''
    }
    
    ###Output data
    info = {
    'login' : 0,
    'logout' : 0,
    'dut' : '',
    'id' : '',
    'name' : 'None',
    'host' : 'http://192.168.0.1',
    'username' : '',
    'password' : ''

    }
    cfgs = []
    
    def __init__(self,sess_split='-'*50,info = {}):
        self.sess_split = sess_split
        self.info.update(info)
        self.handlers.append(self.parseLineUrl)
        self.handlers.append(self.parseLineRequestHeader)
        self.handlers.append(self.parseLineRequestBody)
        self.handlers.append(self.parseLineResponseHeader)
        return
    
    def p_hist(self,name,h):
        print name + ' = {'
        for key in sorted(h.keys()) :
            print '\'%s\' : \'%s\',' % (key, h[key])
        print '}'
    
    def description(self):
        desc = 'Parser for LiveHTTPheader' 
        return desc
    
        
    def resetCfg(self):
        self.cfg = {
            'description' : 'None',
            'method' : '',
            'path' : '',
            'Content-Length' : 0,
            'body' : ''
            }
        return True
        
    def appendCfg(self):
        self.cfgs.append(self.cfg)
        return True
    
    def parseLineUrl(self,line):
        match = r'(\w+)://([\w\.]+)(.+)'
        res = re.findall(match,line)
        protos = ['http','https']
        #print res
        if 1==len(res):
            proto,host,uri = res[0]
            proto.lower()
            if proto in protos:
                self.info['host'] = (proto + '://' + host)
                self.step += 1
                #print '-'*5,'URL Finished'
            else:
                #print 'Unknown proto',proto
                error = 'Unknown proto'
        else:
            #print 'length is not match'
            error = 'length is not match'
        return True
    def parseLineRequestHeaderAttrib(self,key,val):
        if 'Content-Length'==key:
            self.cfg['body_len'] = int(val)
            # finished POST header parse
            #print '==length have get'
            self.step += 1
        return True
    
    
    def parseLineRequestHeader(self,line):
        
        # match param list
        match = r'([^:]*):(.*)'
        resp = re.findall(match,line)
        if 1==len(resp):
            key,val = resp[0]
            self.parseLineRequestHeaderAttrib(key,val)
        else:
            # such as : GET URI HTTP/1.1
            resp = line.split()
            if 3==len(resp) :
                method = resp[0]
                uri = resp[1]
                proto = resp[2]
                if 'GET'==method :
                    self.cfg['method'] = 'GET'
                    r = uri.split('?')
                    self.cfg['path'] = r[0]
                    if 2==len(r):
                        self.cfg['query'] = r[1]
                    # finished GET header parse
                    self.step += 1
                elif 'POST'==method:
                    #print '==method',method
                    self.cfg['method'] = 'POST'
        return True
    
    def parseLineRequestBody(self,line):
        # body length match
        if 'GET'==self.cfg['method']:
            self.step += 1
            return True
        pd_len = self.cfg['body_len']
        if pd_len==len(line):
            self.cfg['body'] = line
            # finished POST header parse
            self.step += 1
        return True
    
    
    def parseLineResponseHeader(self,line):
        return True
    
    def parseLine(self,line):
        #print 'line#',line
        #print 'step',self.step
        return self.handlers[self.step](line)
    
    
    def parseLines(self,lines):
        self.step = 0
        for line in lines:
            if self.step < len(self.handlers):
                self.parseLine(line)
            else :
                break
        return True

    def parseSession(self,sess):
        rc = self.parseLines(sess.splitlines() )
        return rc
    
    def parseBuffer(self,buf):
        rc = False
        # split sessions
        sessions = buf.split(self.sess_split)
        for sess in sessions:
            self.resetCfg()
            rc = self.parseSession(sess.strip())
            if rc:
                self.appendCfg()
        return True
    
    
    def parseFile(self,fn):
        rc = False
        fd = open(fn)
        if fd:
            # read all
            buffer = fd.read()
            # close
            fd.close()
            rc = self.parseBuffer(buffer)
        return rc 

    def GetResult(self):
        return self.info,self.cfgs



sample = """

http://192.168.1.1/index.cgi

POST /index.cgi HTTP/1.1
Host: 192.168.1.1
User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:2.0) Gecko/20100101 Firefox/4.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: zh-cn,en-us;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7
Keep-Alive: 115
Connection: keep-alive
Referer: http://192.168.1.1/index.cgi?active%5fpage=9119&active%5fpage%5fstr=page%5factiontec%5fwireless%5fstatus&req%5fmode=0&mimic%5fbutton%5ffield=sidebar%3a+actiontec%5ftopbar%5fwireless%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=actiontec%5ftopbar%5fwireless
Cookie: lte6368=2; actiontec=alkydmapsoot; auth52370=1302590079; permission=1; ACTSessionID=899238493; rg_cookie_session_id=1043678582
Content-Type: application/x-www-form-urlencoded
Content-Length: 235
active_page=9119&active_page_str=page_actiontec_wireless_status&page_title=Wireless+Status&mimic_button_field=sidebar%3A+actiontec_topbar_status..&button_value=actiontec_topbar_wireless&strip_page_top=0&tab4_selected=0&tab4_visited_0=1
HTTP/1.1 302 Moved Temporarily
Content-Type: text/html
Cache-Control: public
Pragma: cache
Expires: Sat, 15 Dec 2007 00:37:06 GMT
Date: Sat, 15 Dec 2007 00:07:06 GMT
Last-Modified: Sat, 15 Dec 2007 00:07:06 GMT
Accept-Ranges: bytes
Connection: close
Location: /index.cgi?active%5fpage=9090&active%5fpage%5fstr=page%5fmon%5frg%5fstatus&req%5fmode=0&mimic%5fbutton%5ffield=sidebar%3a+actiontec%5ftopbar%5fstatus%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=actiontec%5ftopbar%5fstatus
----------------------------------------------------------
http://192.168.1.1/index.cgi?active%5fpage=9090&active%5fpage%5fstr=page%5fmon%5frg%5fstatus&req%5fmode=0&mimic%5fbutton%5ffield=sidebar%3a+actiontec%5ftopbar%5fstatus%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=actiontec%5ftopbar%5fstatus

GET /index.cgi?active%5fpage=9090&active%5fpage%5fstr=page%5fmon%5frg%5fstatus&req%5fmode=0&mimic%5fbutton%5ffield=sidebar%3a+actiontec%5ftopbar%5fstatus%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=actiontec%5ftopbar%5fstatus HTTP/1.1
Host: 192.168.1.1
User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:2.0) Gecko/20100101 Firefox/4.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: zh-cn,en-us;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7
Keep-Alive: 115
Connection: keep-alive
Referer: http://192.168.1.1/index.cgi?active%5fpage=9119&active%5fpage%5fstr=page%5factiontec%5fwireless%5fstatus&req%5fmode=0&mimic%5fbutton%5ffield=sidebar%3a+actiontec%5ftopbar%5fwireless%2e%2e&strip%5fpage%5ftop=0&button%5fvalue=actiontec%5ftopbar%5fwireless
Cookie: lte6368=2; actiontec=alkydmapsoot; auth52370=1302590079; permission=1; ACTSessionID=899238493; rg_cookie_session_id=1043678582

HTTP/1.1 200 OK
Content-Type: text/html
Cache-Control: no-cache,no-store
Pragma: no-cache
Expires: Sat, 15 Dec 2007 00:07:06 GMT
Date: Sat, 15 Dec 2007 00:07:06 GMT
Accept-Ranges: bytes
Connection: close
----------------------------------------------------------



"""
def self_test():
    pp = parser()
    pp.parseBuffer(sample)
    info,cfgs = pp.GetResult()
    print info
    i = 1
    for cfg in cfgs:
        
        print cfg
    
self_test()