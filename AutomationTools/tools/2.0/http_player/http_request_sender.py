#!/usr/bin/python -u
#       http_request_sender.py
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
    HttpRequestSender is a class for sending http request GET and POST ,
    just a wrapper of httplib2.
"""

_author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "1.0"
__history__ = """
Rev 1.0 : 2011/11/10
    Initial version
"""
#------------------------------------------------------------------------------

import sys, time, os
import re
from types import *
#from optparse import OptionParser
from pprint import pprint
from pprint import pformat

#import subprocess,signal,select
from copy import deepcopy
import httplib2, urllib, urllib2, urlparse
import traceback
import socket
import mimetypes
import datetime


def get_content_type(filename):
    """
    """
    return mimetypes.guess_type(filename)[0] or 'application/octet-stream'


def encode_multipart_formdata(fields, files):
    """
    """
    import random
    import uuid

    k = uuid.uuid4().hex
    #k = ''.join(random.sample('1234567890abcdef',random.randint(10,15) ) )
    LIMIT = '%s' % k
    CRLF = '\r\n'
    L = []
    for (key, value) in fields:
        L.append('--' + LIMIT)
        L.append('Content-Disposition: form-data; name="%s"' % key)
        L.append('')
        L.append(value)
    for (key, filename, value) in files:
        L.append('--' + LIMIT)
        L.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename))
        L.append('Content-Type: %s' % get_content_type(filename))
        L.append('')
        L.append(value)
        #L.append('zzzadf')
        #print '--> file len :',len(value)
    L.append('--' + LIMIT + '--')
    L.append('')
    body = CRLF.join(L)
    content_type = 'multipart/form-data; boundary=%s' % LIMIT

    return content_type, body


#######
#
# include the code of MultipartPostHandler
#
import urllib
import urllib2
import mimetools, mimetypes
import os, stat


class Callable:
    def __init__(self, anycallable):
        self.__call__ = anycallable

# Controls how sequences are uncoded. If true, elements may be given multiple values by
#  assigning a sequence.
doseq = 1


class MultipartPostHandler(urllib2.BaseHandler):
    handler_order = urllib2.HTTPHandler.handler_order - 10 # needs to run first

    def http_request(self, request):
        data = request.get_data()
        if data is not None and type(data) != str:
            v_files = []
            v_vars = []
            try:
                for (key, value) in data.items():
                    if type(value) == file:
                        v_files.append((key, value))
                    else:
                        v_vars.append((key, value))
            except TypeError:
                systype, value, traceback = sys.exc_info()
                raise TypeError, "not a valid non-string sequence or mapping object", traceback

            if len(v_files) == 0:
                data = urllib.urlencode(v_vars, doseq)
            else:
                boundary, data = self.multipart_encode(v_vars, v_files)
                contenttype = 'multipart/form-data; boundary=%s' % boundary
                if (request.has_header('Content-Type')
                    and request.get_header('Content-Type').find('multipart/form-data') != 0):
                    print "Replacing %s with %s" % (request.get_header('content-type'), 'multipart/form-data')
                request.add_unredirected_header('Content-Type', contenttype)
            print '==>request headers :', request.header_items()
            request.add_data(data)
        return request

    def multipart_encode(vars, files, boundary=None, buffer=None):
        """
        """

        import uuid

        k = uuid.uuid4().hex

        if boundary is None:
            #boundary = mimetools.choose_boundary()
            boundary = '--------' + k
        if buffer is None:
            buffer = ''
        for (key, value) in vars:
            buffer += '--%s\r\n' % boundary
            buffer += 'Content-Disposition: form-data; name="%s"' % key
            buffer += '\r\n\r\n' + value + '\r\n'
        for (key, fd) in files:
            file_size = os.fstat(fd.fileno())[stat.ST_SIZE]
            filename = fd.name.split('/')[-1]
            contenttype = mimetypes.guess_type(filename)[0] or 'application/octet-stream'
            buffer += '--%s\r\n' % boundary
            buffer += 'Content-Disposition: form-data; name="%s"; filename="%s"\r\n' % (key, filename)
            buffer += 'Content-Type: %s\r\n' % contenttype
            # buffer += 'Content-Length: %s\r\n' % file_size
            fd.seek(0)
            buffer += '\r\n' + fd.read() + '\r\n'
            #buffer += '--%s--\r\n\r\n' % boundary
        buffer += '--%s--\r\n' % boundary

        return boundary, buffer

    multipart_encode = Callable(multipart_encode)

    https_request = http_request


#------------------------------------------------------------------------------

def getipaddrs(hostname):
    """
    """
    try:
        result = socket.getaddrinfo(hostname, None, 0, socket.SOCK_STREAM)
        return [x[4][0] for x in result]
    except Exception, e:
        print 'getipaddrs ', hostname, ' catch exception :', e
        return None


def parseUrl4IPandPort(url):
    """
    """
    m = r'(https?)://([^/]*)'
    proto = None
    host = None
    ip = None
    port = 80
    res = re.findall(m, url)
    if len(res): (proto, host) = res[0]
    if proto and host:
        #
        if proto.lower() == 'https': port = 443
        z = host.split(':')
        ips = getipaddrs(z[0])
        if ips and len(ips): ip = ips[0]
        if len(z) > 1:
            port = z[1]

    print "ip,port : ", ip, port
    return (ip, port)


def check_server(address, port):
    """
    """
    #create a TCP socket
    #print 'product_id :',product_id
    s = socket.socket()
    print "Attempting to connect to %s on port %s" % (address, port)
    try:

        s.connect((address, port))
        print "Connected to %s on port %s" % (address, port)
        return True
    except socket.error, e:
        print "Connection to %s on port %s failed: %s" % (address, port, e)
        return False


def check_server_v2(address, port):
    """
    """
    print 'check_server_v2 port :', port
    cmd = 'nmap -sS -p ' + str(port) + ' ' + address

    nmap_retry = os.getenv('U_CUSTOM_PLAYBACK_NMAP_RETRY', '10')
    nmap_sleep = os.getenv('U_CUSTOM_PLAYBACK_NMAP_SLEEP', '10')

    nmap_retry = int(nmap_retry)
    nmap_sleep = int(nmap_sleep)
    for n_retry in range(nmap_retry):

        nmap_index = n_retry + 1
        print '== nmap for time : ', nmap_index

        lines = os.popen(cmd).read().strip()
        print cmd
        print lines
        string = str(port) + '/\w* *(\w*) *\w*'
        #m_http = r'80/\w* *open *http\n'
        m_http = string
        rc = re.findall(m_http, lines)

        if len(rc) > 0:
            port_status = rc[0]

            if port_status == 'open':
                print '== port ' + str(port) + ' status is : ' + port_status
                print '== check HTTP port passed =='
                #
                #cmd = 'curl -v -o /tmp/mainpage http://' + address + ':' + str(port)
                #cmd2 = 'curl -v -o /tmp/mainpage -k https://' + address + ':' + str(port)
                #r1 = os.system(cmd)
                #r2 = os.system(cmd2)
                #if r1 == 0 or r2 == 0 :
                #    print '== curl HTTP/HTTPS passed =='
                #    return True
                #else :
                #    print '== curl HTTP/HTTPS failed =='
                #    time.sleep(nmap_sleep)
                #    continue
                return True
            else:
                print '== port ' + str(port) + ' status is : ' + port_status
                print '== port status is not open =='

                if nmap_index == nmap_retry:
                    return False
                else:
                    print '== try nmap again'
                    time.sleep(nmap_sleep)
        else:
            if nmap_index == nmap_retry:
                print '== http port scan failed . quiting'
                return False
            else:
                print '== try nmap again'
                time.sleep(nmap_sleep)
                #return True

#------------------------------------------------------------------------------
# The major information required with HTTP Request playback
http_req = {
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


class HttpRequestSender():
    """
    """
    m_http = None
    m_timeout = 15
    m_headers = {
        'Cookie': '',
        'Content-type': 'application/x-www-form-urlencoded',
        #'User-Agent' : 'Mozilla/5.0 (X11; Linux i686; rv:7.0.1) Gecko/20100101 Firefox/7.0.1',
    }
    m_checked_http = False
    m_logfile2append = None

    def __init__(self, timeout=120):
        """
        create an httplib2.Http instance
        """
        self.m_timeout = timeout

    def checkHttpHost(self, url):
        """
        """
        if not url: return False

        if self.m_checked_http: return True
        #
        self.m_checked_http = True
        #
        ip, port = parseUrl4IPandPort(url)
        if not ip:
            print '--', 'can not parse IP from URL : ', url
            return False

        #
        rc = check_server_v2(ip, port)
        return rc


    def sendRequest(self, req):
        """
        send http request
        """
        #
        self.m_http = httplib2.Http(timeout=self.m_timeout)
        if not self.m_http:
            exit(1)

        #
        resp = None
        content = None
        url = req['URL']

        br0_ip = os.getenv('G_PROD_IP_BR0_0_0', 'NULL_NULL')
        if br0_ip != 'NULL_NULL':
            m_host = r'https*://(.*?)/'

            rc_host = re.findall(m_host, url)

            if len(rc_host) > 0:
                host_ori = rc_host[0]

                #url = ''
                url = url.replace(host_ori, br0_ip)
                #print '==url now is ', url
                #exit(0)
        method = req['method']
        headers = self.m_headers
        body = req['request-body']



        #U_DUT_TYPE = os.getenv('U_DUT_TYPE')

        #if U_DUT_TYPE != None and U_DUT_TYPE != 'PK5K1A' :
        #    http://192.168.0.1/

        print '==> Try to check HTTPd of url :', url
        rc = True
        rc = self.checkHttpHost(url)
        if not rc:
            print '--', 'AT_ERROR :', 'Check HTTP Server for (' + url + ') Failed! Maybe crashed or No Response!'
            exit(11)
            #elif U_DUT_TYPE == 'PK5K1A' :
        #    print '\n'
        #    print 'Bypassed checkHttpHost function for PK5K1A !'
        #    print '\n'
        try:
            #pprint(req)
            #self.dumpRequest(req)

            connection_type = None
            connection_type = (url.split(':')[
                                   0].lower() == 'https' ) and httplib2.HTTPSConnectionWithTimeout or httplib2.HTTPConnectionWithTimeout
            #print connection_type
            #exit(0)
            self.appendLog(method + ' : ' + url)
            resp, content = self.m_http.request(url, method, headers=headers, body=body,
                                                connection_type=connection_type)
            #resp, content = self.m_http.request(url, method, body, headers, redirections, connection_type)
            req['resp-headers'] = resp
            req['resp-content'] = content
            # auto save Cookie
            self.saveCookie(resp)
            self.dumpHTTP(req, resp, content)

        except Exception, e:
            self.dumpHTTP(req, 'Exception', e)
            print('http_request_sender.py(sendRequest) Exception : ' + str(e))
            #traceback.print_exc()
            formatted_lines = traceback.format_exc().splitlines()
            pprint(formatted_lines)
            print('Ignore exception')
            pprint(url)
            if url.find('dmz') > -1:
                print('goto HttpRequestLoop after sleep 10')
                time.sleep(10)
                try:
                    resp, content = self.m_http.request(url, method, headers=headers, body=body,
                                                        connection_type=connection_type)
                    req['resp-headers'] = resp
                    req['resp-content'] = content
                    self.saveCookie(resp)
                    self.dumpHTTP(req, resp, content)
                except Exception, e:
                    self.dumpHTTP(req, 'Exception', e)
                    print('http_request_sender.py(sendRequest) Exception : ' + str(e))
                    print('setup retry failed')

        # release
        del self.m_http
        self.m_http = None
        #
        return (resp, content)

    def dumpRequest(self, req):
        """
        """
        url = req['URL']
        method = req['method']
        headers = self.m_headers
        body = req['request-body']

        print '--headers', headers
        print '--', method, url
        if body and type(body) == StringType and len(body):
            if len(body) > 1024:
                print '-- body : ', body[:1024], '...'
            else:
                print '-- body : ', body


    def dumpRequestDetail(self, req):
        """
        """

        print '--', 'Send request : '
        pprint(req)
        print '--' * 32
        if req.has_key('body-fmt') and req['body-fmt']:
            print '--', 'body-fmt = '
            print req['body-fmt'].dump()
            print '--' * 32

        if req.has_key('query-fmt') and req['query-fmt']:
            print '--', 'query-fmt = '
            print req['query-fmt'].dump()
            print '--' * 32
            pass
        pass

    def dumpHTTP(self, req, resp, content):
        """
        [time] get url | resp content
        [time] post url query | resp content
        """
        fmt = '[%s] %s %s %s| %s %s\n'
        dt_now = datetime.datetime.now()
        str_now = dt_now.strftime('%Y-%m-%d %H:%M:%S')

        #
        url = req['URL']
        method = req['method']
        body = req['request-body']
        post_data = ''
        if body and isinstance(body, StringType) and len(body):
            post_data = body
            pass
            #print(type(resp))
        if resp and isinstance(resp, DictionaryType) and len(resp):
            resp = 'response_status : %s' % (resp.get('status', 'None'))
            content = ''
            pass

        ss = fmt % (str_now, method, url, post_data, resp, content)
        print(ss)
        #


        logfile1 = os.path.join(os.getenv('G_LOG', '/root/automation/logs'), 'current/post_file_requests.log')
        logfile2 = os.path.join(
            os.getenv('U_DEBUG_HTTP_PLAY', os.getenv('G_CUREENTLOG', '/root/automation/logs/current')),
            'post_file_requests.log')

        logfiles = []
        logfiles.append(logfile1)
        if logfile1 != logfile2:
            logfiles.append(logfile2)
            pass

        for logfile in logfiles:
            try:
                fd = open(logfile, 'a+')
                if fd:
                    fd.write(ss)
                    fd.close()
                    pass
                pass
            except Exception, e:
                print('write debug log file(%s) failed : %s' % (logfile, e))
                pass
            pass

        pass

    def saveCookie(self, resp):
        """
        save cookie from response to next request headers
        """
        #save Cookie
        if resp.has_key('set-cookie'):
            self.updateHeaders('Cookie', resp['set-cookie'])
            print '--', 'Save cookie : ', resp['set-cookie']

    def getCookie(self):
        """
        """
        return self.m_headers['Cookie']


    def updateHeaders(self, key, value):
        """
        update request headers
        """
        self.m_headers[key] = value

    def setAppendLogFile(self, filename):
        """
        """
        self.m_logfile2append = filename
        print '==' * 32
        print "AppendLogFile : ", filename

    def appendLog(self, txt):
        """
        """
        if self.m_logfile2append:
            os.system("echo '==========>[LANPC_DATE:'`date`'] : " + str(txt) + "' >> " + self.m_logfile2append)

    def uploadFileNew(self, url, fields={}, other_headers={}):
        """
        """
        import cookielib

        cookies = cookielib.CookieJar()
        opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookies), MultipartPostHandler)

        print '\n' * 3
        print 'url :', url

        headers = deepcopy(self.m_headers)
        if len(other_headers): headers.update(other_headers)
        req = urllib2.Request(url, headers=headers)
        try:
            resp = opener.open(req, fields)
            print 'uploadFile response : \n', resp.read()
        except Exception, e:
            formatted_lines = traceback.format_exc().splitlines()
            pprint(formatted_lines)
        return True


def main():
    """
    main entry
    """
    Sender = HttpRequestSender()
    test_req = {
        # combined elements
        'URL': 'http://docs.python.org/library/telnetlib.html',
        'request-line': 'GET /library/telnetlib.html HTTP/1.1',
        'request-body': None,
        # basic elements
        'host': 'ocs.python.org',
        'proto': 'HTTP/1.1',
        'uri': '/library/telnetlib.html',
        'method': 'GET',
    }

    test_req2 = {
        # combined elements
        'URL': 'http://172.16.10.229:9000/testlink-1.9.2',
        'request-line': 'GET /testlink-1.9.2 HTTP/1.1',
        'request-body': None,
        # basic elements
        'host': '172.16.10.229:9000',
        'proto': 'HTTP/1.1',
        'uri': '/testlink-1.9.2',
        'method': 'GET',
    }
    resp, content = Sender.sendRequest(test_req2)
    pprint(resp)
    pprint(content)

    # login BHR2
    return 0


if __name__ == '__main__':
    """
    """
    main()
