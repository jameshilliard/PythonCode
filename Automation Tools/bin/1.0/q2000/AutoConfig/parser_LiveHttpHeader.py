#!/usr/bin/python
"""
Parser translate raw http data catched by some tools to python structure using in Runner 
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

import re
import urllib
"""
   
REQUEST_URL
REQUEST_HEADER
REQUEST_BODY
RESPONSE_HEADER
"""

class Parser():
    """
    """
    debug = 0
    ###Temp data
    # sessions split with '-'*50
    sess_split = ''
    requests = []
    sections = ['REQUEST_URL','REQUEST_HEADER','REQUEST_BODY','RESPONSE_HEADER']
    handlers = []
    step = 0
    last_line = ""

    cfg = {
    'description' : 'no description',
    'protocol' : 'HTTP',
    'destination' : '',    
    'method' : '',
    'path' : '',
    'body_len' : 0,
    'query' : '',
    'body' : ''
    }
    
    ###Output data
    info = {
    'login' : 0,
    'logout' : 0,
    'dut' : '',
    'id' : '',
    'name' : 'No name',
    'host' : 'http://192.168.0.1',
    'username' : '',
    'password' : ''

    }
    cfgs = []
    
    def __init__(self,debug=0,sess_split='-'*32,info = {}):
        self.debug = debug
        self.sess_split = sess_split
        self.info.update(info)
        self.handlers.append(self.parseLineUrl)
        self.handlers.append(self.parseLineRequestHeader)
        self.handlers.append(self.parseLineRequestBody)
        self.handlers.append(self.parseLineResponseHeader)
        print '==Parser for LiveHttpHeaders'
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
            'description' : 'no description',
            'protocol' : 'HTTP',
            'destination' : '',            
            'method' : '',
            'path' : '',
            'body_len' : 0,
            'query' : '',
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
            self.cfg['protocol'] = proto
            self.cfg['destination'] = host
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
            print "==>"
        return True
    
    
    def parseLineRequestHeader(self,line):
        method = self.cfg['method']
        if 0==len(method):
            # such as : GET URI HTTP/1.1
            resp = line.split()
            if 3==len(resp) :
                method = resp[0]
                uri = resp[1]
                proto = resp[2]
                if 'GET'==method :
                    self.cfg['method'] = 'GET'
                    self.cfg['description'] = line
                    r = uri.split('?')
                    self.cfg['path'] = r[0]
                    if 2==len(r):
                        self.cfg['query'] = r[1]
                    # finished GET header parse
                    self.step += 1
                    return True
                elif 'POST'==method:
                    #print '==method',method
                    self.cfg['method'] = 'POST'
                    self.cfg['description'] = line
                    self.cfg['path'] = uri
        # match param list
        match = r'([^:]*):(.*)'
        resp = re.findall(match,line)
        if 1==len(resp):
            key,val = resp[0]
            self.parseLineRequestHeaderAttrib(key,val)
        return True
    
    def parseLineRequestBody(self,line):
        # body length match
        if 'GET'==self.cfg['method']:
            self.step += 1
            return True
        pd_len = self.cfg['body_len']
        """
        if pd_len==len(line):
            self.cfg['body'] = line
            # finished POST header parse
            self.step += 1
        """
        # such as "HTTP/1.1 200 OK"
        match = r'HTTP/[0-9\.]+\s+\d+\s+.+'
        res = re.match(match,line)
        if res :
            self.cfg['body'] = self.last_line
            self.last_line = ""
            self.step += 1
        else:
            if len(line) : self.last_line = line
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
        # check parse result
        if 0==len(self.cfg['method'] ):
            return False
        return True

    def parseSession(self,sess):
        rc = self.parseLines(sess.splitlines() )
        return rc
    
    def parseBuffer(self,buf):
        rc = False
        # split sessions
        buf.strip()
        sessions = buf.split(self.sess_split)
        for sess in sessions:
            self.resetCfg()
            #print 'sess : ',sess
            rc = self.parseSession(sess.strip())
            if rc:
                self.appendCfg()
            else:
                print 'bad last step :',self.step
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

http://192.168.0.1/cgi-bin/webcm?getpage=../html/confirm_real.html&var:frompage=wireless_mssid.html&var:category=&var:rule=&var:deleterule=&var:errorfound=0&var:errormessage=&var:nssid=0

POST /cgi-bin/webcm HTTP/1.1
Host: 192.168.0.1
User-Agent: Mozilla/5.0 (Windows NT 5.1; rv:2.0) Gecko/20100101 Firefox/4.0
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
Accept-Language: zh-cn,en-us;q=0.7,en;q=0.3
Accept-Encoding: gzip, deflate
Accept-Charset: GB2312,utf-8;q=0.7,*;q=0.7
Keep-Alive: 115
Connection: keep-alive
Referer: http://192.168.0.1/cgi-bin/webcm
Content-Length:1
getpage=../html/confirm_real.html&var:frompage=wireless_mssid.html&var:category=&var:rule=&var:deleterule=&var:errorfound=0&var:errormessage=&var:nssid=0


HTTP/1.1 200 OK
Content-Type: text/html; charset=ISO-8859-1
Pragma: no-cache
Cache-Control: no-cache
Expires: -1
----------------------------------------------------------




"""
def self_test():
    pp = Parser()
    pp.parseBuffer(sample)
    #pp.parseFile(r'E:\BB\AutomationTest\python\tc_PK5000\tc_pk5k_wl_ssid')
    info,cfgs = pp.GetResult()
    print info
    i = 1
    for cfg in cfgs:
        print '-'*16
        pp.p_hist('cfg',cfg)
        
    


if __name__ == "__main__":
    self_test()
