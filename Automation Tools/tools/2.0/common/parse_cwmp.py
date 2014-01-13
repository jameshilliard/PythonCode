#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
#       parse_cwmp.py
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
#------------------------------------------------------------------------------
"""
This tool is to parse CWMP packages capturing by tshark

History :


"""
import os, sys, re
import time
from pprint import pprint
from pprint import pformat
import xml.dom.minidom as minidom
from copy import deepcopy
from optparse import OptionParser


CWMP_ActionKeywords = {
    'INFORM': 'Inform',
    'FAULT': 'Fault',
    'GPV': 'GetParameterValues',
    'SPV': 'SetParameterValues',
    'GPA': 'GetParameterAttribute',
    'SPA': 'SetParameterAttribute',
    'ADDOBJ': 'AddObject',
    'DELOBJ': 'DeleteObject',
    'DOWNLD': 'TransferComplete',
}


def ver_info():
    """
    """
    s = """

    HISTORY
    --------------------------------------------------------------------
    DATE    :
        Thu Dec 22 14:38:42 CST 2011

    VERISON :
        V 1.0.1
    AUTHOR  :
        rayofox(lhu@actiontec.com)
    COMMENT :
        Split Frame before do parsing, ignore the bad format frames
    --------------------------------------------------------------------
    --------------------------------------------------------------------
    DATE    :
        Sat Dec 17 14:55:45 CST 2011
    VERISON :
        V 1.0.0
    AUTHOR  :
        rayofox(lhu@actiontec.com)
    COMMENT :
        Initial Version
    --------------------------------------------------------------------
    """
    return s


class CWMP_Parser():
    """
    """
    # 0 : error, 1 : warning, 2 : info , 3 : debug
    m_loglevel = 2
    #
    m_soap_envp_keys = [r'SOAP-ENV:Envelope', r'soapenv:Envelope', r'soap:Envelope']
    #
    m_faults = []
    #
    m_cwmp_sessions = {
        'seq': [],
        'sess': {},
    }
    #
    m_sess_info = {
        'xml': '',
        'id': '',
        'key': '',
        'node': None,
    }

    m_hdlrs = {}

    m_soap_envps = []
    m_frames = []

    def __init__(self, loglevel=2):
        """
        """
        if loglevel < 0: loglevel = 0
        if loglevel > 3: loglevel = 3
        self.loglevel = loglevel
        self.m_soapenvs = []
        # A little magic - Everything called cmdXXX is a command
        for k in dir(self):
            if k[:6] == 'fetch_':
                name = k[6:]
                method = getattr(self, k)
                self.m_hdlrs[name] = method
        pass

    def debug(self, msg):
        """
        """
        if self.loglevel >= 3:
            print '--DEBUG:', msg
        return

    def info(self, msg):
        """
        """
        if self.loglevel >= 2:
            print '--INFO:', msg
        return

    def warning(self, msg):
        """
        """
        if self.loglevel >= 1:
            print '--WARNING:', msg
        return

    def error(self, msg):
        """
        """
        if self.loglevel >= 0:
            print '--', 'AT_ERROR :', msg
        return

    def addSessionSeg(self, sid, seg):
        """
        """
        rc = True
        cwmp_sess = self.m_cwmp_sessions
        if not cwmp_sess['sess'].has_key(sid):
            cwmp_sess['sess'][sid] = []
            cwmp_sess['seq'].append(sid)
            # add seg
        cwmp_sess['sess'][sid].append(seg)
        self.debug("add session : " + str(sid) + ' ' + str(seg))
        return rc

    def parseFile(self, fname):
        """
        """
        rc = False
        if not os.path.exists(fname):
            print '--', 'AT_ERROR :', 'File is not found : ', fname
            return rc
            #
        fd = open(fname, 'r')
        lines = []
        if fd:
            lines = fd.readlines()
            fd.close()
        else:
            print '--', 'AT_ERROR :', 'Open File failed: ', fname
            return rc
            # Split Frames
        frames = self.splitFrames(lines)
        #
        for (fid, fr) in frames:
            self.debug("parse Frame : " + str(fid))
            self.parseSoapEnvps(fid, fr)

        self.parseCWMP()

    def splitFrames(self, lines):
        """
        """
        frames = []
        frame = []
        frame_id = None
        in_frame = False
        m = r'^Frame\s*(\d*):'
        for line in lines:
            res = re.findall(m, line)
            #print res
            if len(res):
                # add last
                if frame_id and len(frame):
                    frames.append((frame_id, frame))
                frame = []
                frame_id = res[0]
                in_frame = True
                frame.append(line)
            elif in_frame:
                frame.append(line)

        def dump():
            for (fid, fr) in frames:
                print "==" * 16
                print "\n\n"
                print "Frame ID :", fid
                print "Frame content :", fr

            #dump()
        #exit(2)
        self.m_frames = frames
        return frames

    def isSoapEnvpBegin(self, line, envp_key=None):
        """
        """
        rc = False
        s = line.strip()
        envp_keys = []
        if envp_key:
            envp_keys.append(envp_key)
        else:
            envp_keys = self.m_soap_envp_keys

        for key in envp_keys:
            k = ('<' + key)
            # ignore case
            k = k.lower()
            s = s.lower()
            #
            if s.startswith(k):
                rc = key
                return rc

        return rc

    def isSoapEnvpEnd(self, line, envp_key=None):
        """
        """
        rc = False
        s = line.strip()
        envp_keys = []
        if envp_key:
            envp_keys.append(envp_key)
        else:
            envp_keys = self.m_soap_envp_keys

        for key in envp_keys:
            k = ('</' + key)
            #
            k = k.lower()
            s = s.lower()
            if s.startswith(k):
                rc = key
                return rc

        return rc


    def parseSoapEnvps(self, frame_id, lines):
        """
        """
        in_envp = False
        envp = ''
        envps = []
        envp_key = None
        for line in lines:
            if in_envp:
                envp += line
                rc = self.isSoapEnvpEnd(line, envp_key)
                if rc:
                    #print 'end with :' ,line
                    envp_key = None
                    in_envp = False
                    envps.append(envp)
                    self.debug('add SOAP :' + str(envp))
            else:
                rc = self.isSoapEnvpBegin(line)
                if rc:
                    #print 'begin with :' ,line
                    envp_key = rc
                    in_envp = True
                    envp = line

        #
        #for envp in envps : print '==>',envp
        self.m_soap_envps += envps

    def parseCwmpFault(self, root):
        """
        """
        # <SOAP-ENV:Body>/<SOAP-ENV:Fault>/<detail>/<cwmp:Fault>
        name = root.nodeName
        z = name.split(':')
        prefix = z[0]

        body = self.findFirstChildByName(root, prefix + ':Body')
        if not body: return False
        ft = self.findFirstChildByName(body, prefix + ':Fault')
        if not ft: return False
        dd = self.findFirstChildByName(ft, 'detail')
        if not dd: return False
        node_ft = self.findFirstChildByName(dd, 'cwmp:Fault')
        if not node_ft: return False

        nfc = self.findFirstChildByName(node_ft, 'FaultCode')
        nfs = self.findFirstChildByName(node_ft, 'FaultString')
        if not nfc or not nfs: return False

        sfc = self.__getXmlTextValue(nfc)
        sfs = self.__getXmlTextValue(nfs)
        self.m_faults.append((sfc, sfs))

        return True

        #xml = root.toxml()
        #s1 = r'<FaultCode xsi:type="cwmp:FaultCodeType">9003</FaultCode>'
        #s2 = r'<FaultString xsi:type="xsd:string">Invalid arguments</FaultString>'
        #m1 = r'<FaultCode[^>]*>([^<]*)'
        #m2 = r'<FaultString[^>]*>([^<]*)'
        #r1 = re.findall(m1,xml,re.I)
        #r2 = re.findall(m2,xml,re.I)
        #fcode = None
        #fcstr = None
        #sz1 = len(r1)
        #sz2 = len(r2)
        #sz = min(sz1,sz2)
        #for i in range(sz) :
        #    fcode = r1[i]
        #    fcstr = r2[i]
        #    if fcode and fcstr :
        #        self.m_faults.append((fcode,fcstr))

    def parseCWMP(self):
        """
        """

        envps = self.m_soap_envps

        self.debug('parseCWMP :' + str(len(envps)))
        for envp in envps:
            s = envp
            dom = None
            root = None
            #self.debug( 'try parse xml : \n' + s )
            # remove all line begin with xmlns: and not end with >
            #s = ''
            #lines = envp.splitlines(True)
            #for line in lines :
            #    ss = line.strip()
            #    if ss.startswith('xmlns:') and not ss.endswith('>') :
            #        continue
            #    else :
            #        s += line
            try:
                dom = minidom.parseString(s)
                root = dom.documentElement
            except Exception, e:
                self.error('bad xml format : \n' + s)
                self.error('Except message:' + str(e))
                continue
            if root:
                self.debug('root : ' + root.nodeName)

                m = ':fault'
                res = re.findall(m, s, re.I)
                rc = False
                if len(res):
                    rc = self.parseCwmpFault(root)
                if not rc:
                    self.parseSession(root)

        #
        def dump():
            """
            """
            self.debug('---->dump start')
            for sid, sess in self.m_cwmp_sessions['sess'].items():
                for ss in sess:
                    self.debug('cwmp seg of ' + sid + ' : \n' + pformat(ss['key']))
                    self.debug('\n' * 3)
            self.debug('---->dump end')
            #dump()

    def __getXmlTextValue(self, node):
        """
        """
        val = None
        snodes = node.childNodes
        if len(snodes) == 0:
            val = ''
        elif len(snodes) == 1:
            val = snodes[0].nodeValue.strip()
        return val

    def getNodeFullName(self, node):
        """
        """
        #
        names = []
        #
        return True

    def findAttributeByName(self, node, attr_name, nocase=True):
        """
        """
        #xsi:type
        return node.getAttribute(attr_name)

    def findFirstChildByName(self, node, child_name, nocase=True):
        """
        """
        rc = False
        node_name = node.nodeName
        childs = node.childNodes
        if not childs or not len(childs):
            self.warning('Node(' + node_name + ') have no child')
            return rc
            #
            #     print '$'*10
        for child in childs:
            cname = child.nodeName
            if nocase:
                cname = cname.lower()
                child_name = child_name.lower()
            if cname == child_name:
                rc = child
                break
            #

        if not rc:
            self.warning('Node(' + node_name + ') have no child named : ' + child_name)
            return rc

        return rc

    def findFirstChildByRegex(self, node, rex, nocase=True):
        """
        """
        rc = False
        node_name = node.nodeName
        childs = node.childNodes
        if not childs or not len(childs):
            self.warning('Node(' + node_name + ') have no child')
            return rc
            #
        for child in childs:
            cname = child.nodeName
            if nocase:
                cname = cname.lower()
            if re.match(rex, cname):
                rc = child
                break
            #
        if not rc:
            self.warning('Node(' + node_name + ') have no child match : ' + rex)
            return rc
        return rc


    def parseSession(self, root):
        """
        """
        rc = False
        sid = None
        sess_info = deepcopy(self.m_sess_info)

        name = root.nodeName
        z = name.split(':')
        self.debug('parseSession :' + str(z))
        prefix = z[0]
        # soap-env:envelope/soap-env:header
        node_name = prefix + ':header'
        path = name + '/' + node_name
        node_header = self.findFirstChildByName(root, node_name)
        #node_header = root.getElementsByTagName(node_name)
        #self.debug( 'node_header : '+ str(node_header) )
        #if not node_header or not len(node_header) :
        #    self.debug( '!Node is not found : ' + path)
        #    return rc
        if not node_header: return rc
        #soap-env:envelope/soap-env:header/cwmp:id
        node_name = 'cwmp:id'
        path += ('/' + node_name)
        node_header_cwmp_id = self.findFirstChildByName(node_header, node_name)
        #node_header_cwmp_id = node_header[0].getElementsByTagName(node_name)
        #self.debug( 'node_header_cwmp_id :' + str(node_header_cwmp_id) )
        #if not node_header_cwmp_id or not len(node_header_cwmp_id) :
        #    self.debug( '!Node is not found : ' + path)
        #    return rc
        #sid = self.__getXmlTextValue(node_header_cwmp_id[0])
        if node_header_cwmp_id:
            sid = self.__getXmlTextValue(node_header_cwmp_id)
            sess_info['id'] = str(sid)
            self.debug(path + ' value: ' + sid)
        else:
            #print 'Not found : ',path
            self.warning(path + ' value: ' + str(sid))
            #soap-env:envelope/soap-env:body
        node_name = prefix + ':body'
        path = name + '/' + node_name
        #node_body = root.getElementsByTagName(node_name)

        #self.debug( 'node_body : ' + str(node_body) )
        #if not node_body or not len(node_body) :
        #    self.debug( '!Node is not found : ' + path)
        #    return rc

        node_body = self.findFirstChildByName(root, node_name)

        #soap-env:envelope/soap-env:body/cwmp:key
        m = r'^cwmp:'
        node = self.findFirstChildByRegex(node_body, m)

        #print '==>',sid,node.nodeName
        if node:
            node_name = node.nodeName
            sess_info['key'] = node_name[5:]
            sess_info['xml'] = node.toxml()
            sess_info['node'] = node

            #print '--'*32
            #print sess_info['id']
            #print sess_info['key']
            #print '--'*32
            self.addSessionSeg(str(sid), sess_info)
            return True

        #cnodes = node_body[0].childNodes
        #for node in cnodes :
        #    node_name = node.nodeName
        #    self.debug( 'sub node : ' +  str(node_name) )
        #    if node_name.startswith('cwmp:') :
        #        sess_info['key'] = node_name[5:]
        #        sess_info['xml'] = node.toxml()
        #        print sess_info
        #        self.addSessionSeg(str(sid),sess_info)
        #        return True

        #self.addSessionSeg(str(sid),seg)
        return rc

    def filterSessionsByKey(self, key, nocase=True):
        """
        """
        cwmp_sess = self.m_cwmp_sessions
        sess_matched = []
        sess = cwmp_sess['sess']
        for sid in cwmp_sess['seq']:
            sess_infos = sess[sid]
            k = sess_infos[0]['key']
            if nocase:
                k = k.lower()
                key = key.lower()
            self.debug('Expect Key : ' + key)
            self.debug('Current Key : ' + k)

            keys = [key, key + 'response']
            if k in keys:
                sess_matched.append(sess_infos)


        #
        if len(sess_matched) == 0:
            if sess.has_key('0'):
                sess_infos = sess['0']
                sess_matched.append(sess_infos)
            pass

        return sess_matched


    def fetch_INFORM(self):
        """
        """
        self.debug('Enter fetch_INFORM')
        rc = False
        keyword = CWMP_ActionKeywords['INFORM']
        key = keyword.lower()
        arr_sess = self.filterSessionsByKey(keyword)

        self.debug('INFORM sessions :\n' + pformat(arr_sess))
        for sess in arr_sess:
            req = None
            resp = None

            for seg in sess:
                xml = seg['xml']
                root = seg['node']

                #print '--seg : ',seg['xml']
                # parse request, no case sense
                k = seg['key']

                k = k.lower()

                key2 = key + 'response'

                #
                if k == key: # request ,not care
                #pass
                #elif  k == key2: # response
                    req = True
                    if req:

                        # ParameterList
                        node_pl = self.findFirstChildByName(root, 'ParameterList')

                        if not node_pl:
                            continue
                        childs = node_pl.childNodes

                        rc = []
                        for child in childs:
                            #ParameterValueStruct

                            child_name = child.nodeName.lower()

                            node_name = 'ParameterValueStruct'
                            node_name = node_name.lower()

                            if child_name == node_name:
                                #Name,Value

                                nname = self.findFirstChildByName(child, 'Name')
                                nvalue = self.findFirstChildByName(child, 'Value')
                                if nname and nvalue:
                                    ntype = self.findAttributeByName(nvalue, 'xsi:type')
                                    #print 'ntype :',ntype
                                    pname = self.__getXmlTextValue(nname)
                                    pvalue = self.__getXmlTextValue(nvalue)
                                    self.debug('ntype :' + str(ntype))
                                    if ntype == 'xsd:boolean':
                                        zz = ['1', 'true']
                                        vv = pvalue.lower()
                                        if vv in zz:
                                            pvalue = 'true'
                                        else:
                                            pvalue = 'false'
                                            #pvalue = str(bool(int(pvalue)) ).lower()
                                    if not rc: rc = []
                                    rc.append(pname + ' = ' + str(pvalue))
                        if not len(rc):
                            rc.append('@No inform found!')
                            print "==WARNING:", "no inform found!"
                            pass
                        pass
                    pass
                elif k == key2:
                    if not rc: rc = []
                    rc.append(xml)

                    break
                pass
            pass
        if rc:
            self.info('Inform : ' + pformat(rc))
        return rc

    def fetch_FAULT(self):
        """
        """
        rc = False
        for fc, fs in self.m_faults:
            if not rc: rc = []
            rc.append(str(fc) + ' : ' + str(fs))
        return rc

    def fetch_GPV(self):
        """
        """
        self.debug('Enter fetch_GPV')
        rc = False
        keyword = CWMP_ActionKeywords['GPV']
        key = keyword.lower()
        arr_sess = self.filterSessionsByKey(keyword)

        self.debug('GPV sessions :\n' + pformat(arr_sess))
        for sess in arr_sess:
            req = None
            resp = None

            for seg in sess:
                xml = seg['xml']
                root = seg['node']

                #print '--seg : ',seg['xml']
                # parse request, no case sense
                k = seg['key']

                k = k.lower()

                key2 = key + 'response'

                #
                if k == key: # request ,not care
                    pass
                elif k == key2: # response
                    req = True
                    if req:

                        # ParameterList
                        node_pl = self.findFirstChildByName(root, 'ParameterList')

                        if not node_pl:
                            continue
                        childs = node_pl.childNodes

                        rc = []
                        for child in childs:
                            #ParameterValueStruct

                            child_name = child.nodeName.lower()

                            node_name = 'ParameterValueStruct'
                            node_name = node_name.lower()

                            if child_name == node_name:
                                #Name,Value

                                nname = self.findFirstChildByName(child, 'Name')
                                nvalue = self.findFirstChildByName(child, 'Value')
                                if nname and nvalue:
                                    ntype = self.findAttributeByName(nvalue, 'xsi:type')
                                    #print 'ntype :',ntype
                                    pname = self.__getXmlTextValue(nname)
                                    pvalue = self.__getXmlTextValue(nvalue)
                                    self.debug('ntype :' + str(ntype))
                                    if ntype == 'xsd:boolean':
                                        zz = ['1', 'true']
                                        vv = pvalue.lower()
                                        if vv in zz:
                                            pvalue = 'true'
                                        else:
                                            pvalue = 'false'
                                            #pvalue = str(bool(int(pvalue)) ).lower()
                                    if not rc: rc = []
                                    rc.append(pname + ' = ' + str(pvalue))
                        if not len(rc):
                            rc.append('@GPV response is empty!')
                            print "==WARNING:", "GPV response found ,but empty!"
        if rc:
            self.info('GPV : ' + pformat(rc))
        return rc

    def fetch_SPV(self):
        """
        """
        self.debug('Enter fetch_SPV')
        rc = False
        keyword = CWMP_ActionKeywords['SPV']
        key = keyword.lower()
        arr_sess = self.filterSessionsByKey(keyword)
        self.debug('GPV sessions :\n' + pformat(arr_sess))
        for sess in arr_sess:
            req = None
            resp = None
            for seg in sess:
                xml = seg['xml']
                root = seg['node']
                #print '--seg : ',seg['xml']
                # parse request, no case sense
                k = seg['key']
                k = k.lower()

                key2 = key + 'response'
                #
                if k == key: # request
                    if not req:
                        # ParameterList
                        node_pl = self.findFirstChildByName(root, 'ParameterList')
                        if not node_pl:
                            continue
                        childs = node_pl.childNodes
                        for child in childs:
                            #ParameterValueStruct
                            child_name = child.nodeName.lower()

                            node_name = 'ParameterValueStruct'
                            node_name = node_name.lower()
                            if child_name == node_name:
                                #Name,Value
                                nname = self.findFirstChildByName(child, 'Name')
                                nvalue = self.findFirstChildByName(child, 'Value')
                                if nname and nvalue:
                                    pname = self.__getXmlTextValue(nname)
                                    pvalue = self.__getXmlTextValue(nvalue)
                                    if not req: req = []
                                    req.append(pname + ' = ' + pvalue)

                elif k == key2: # response
                    if req:
                        # status
                        node = self.findFirstChildByName(root, 'Status')
                        if not node: continue
                        v = self.__getXmlTextValue(node)
                        #self.debug()
                        if str(v) == '0':
                            resp = True
                        else:
                            self.error('Response is failure(' + str(v) + ') for request SPV : ' + str(req))
                            req = None
            if req and resp:
                if not rc: rc = []
                rc += req
            #
        if rc:
            self.info('SPV : ' + pformat(rc))

        return rc

    def fetch_DOWNLD(self):
        """
        """
        self.debug('Enter fetch_DOWNLD')
        rc = False
        keyword = CWMP_ActionKeywords['DOWNLD']
        key = keyword.lower()
        arr_sess = self.filterSessionsByKey(keyword)

        print '---' * 32
        print '\n' * 3
        self.debug('Download sessions :\n' + pformat(arr_sess))
        for sess in arr_sess:
            req = None
            resp = None
            for seg in sess:
                xml = seg['xml']
                root = seg['node']
                #print '--seg : ',seg['xml']
                # parse request, no case sense
                k = seg['key']
                k = k.lower()


                #
                if k == key: # response
                    print '----------'
                    if True:
                        # status
                        node = self.findFirstChildByName(root, 'FaultStruct')
                        if not node: continue
                        n = self.findFirstChildByName(node, 'FaultCode')
                        v = self.__getXmlTextValue(n)

                        n2 = self.findFirstChildByName(node, 'FaultString')
                        v2 = self.__getXmlTextValue(n2)
                        self.debug('FaultCode : ' + str(v) + ',FaultString : ' + str(v2))
                        #self.debug()
                        if str(v) == '0':
                            resp = True
                        else:
                            self.error('Response is failure(' + str(v2) + ') for request Download')
                            #req = None
                            resp = False

                            # InstanceNumber
                            #node = self.findFirstChildByName(root,'InstanceNumber')
                            #if not node : continue
                            #resp = self.__getXmlTextValue(node)
                            #print '===>',resp,node
            if resp:
                if not rc: rc = []
                r = resp
                rc.append(r)
            #
        if rc:
            self.info('Download : ' + pformat(rc))
        return rc

    def fetch_GPA(self):
        """
        """
        self.debug('Enter fetch_GPA')
        rc = False
        keyword = CWMP_ActionKeywords['GPA']
        key = keyword.lower()
        return rc

    def fetch_SPA(self):
        """
        """
        self.debug('Enter fetch_SPA')
        rc = False
        keyword = CWMP_ActionKeywords['SPA']
        key = keyword.lower()
        return rc

    def fetch_ADDOBJ(self):
        """
        """
        self.debug('Enter fetch_ADDOBJ')
        rc = False
        keyword = CWMP_ActionKeywords['ADDOBJ']
        key = keyword.lower()
        arr_sess = self.filterSessionsByKey(keyword)
        #print 'sess AddObj :',arr_sess
        self.debug('AddObj sessions :\n' + pformat(arr_sess))
        for sess in arr_sess:
            req = None
            resp = None
            for seg in sess:
                xml = seg['xml']
                root = seg['node']
                #print '--seg : ',seg['xml']
                # parse request, no case sense
                k = seg['key']
                k = k.lower()

                key2 = key + 'response'
                #
                if k == key: # request
                    if not req:
                        node = self.findFirstChildByName(root, 'ObjectName')
                        if not node: continue
                        req = self.__getXmlTextValue(node)
                        #print 'req : ',  req
                elif k == key2: # response
                    if req:
                        # status
                        node = self.findFirstChildByName(root, 'Status')
                        if not node: continue
                        v = self.__getXmlTextValue(node)
                        #self.debug()
                        #if str(v) == ''
                        # InstanceNumber
                        node = self.findFirstChildByName(root, 'InstanceNumber')
                        if not node: continue
                        resp = self.__getXmlTextValue(node)
                        #print '===>',resp,node
            if req and resp:
                if not rc: rc = []
                r = req + resp + '.'
                rc.append(r)
            #
        if rc:
            self.info('Object Added : ' + pformat(rc))
        return rc


    def fetch_DELOBJ(self):
        """
        """
        self.debug('Enter fetch_DELOBJ')
        rc = False
        keyword = CWMP_ActionKeywords['DELOBJ']
        key = keyword.lower()
        arr_sess = self.filterSessionsByKey(keyword)
        #print 'sess AddObj :',arr_sess
        print '---' * 32
        print '\n' * 3
        self.debug('DelObj sessions :\n' + pformat(arr_sess))
        for sess in arr_sess:
            req = None
            resp = None
            for seg in sess:
                xml = seg['xml']
                root = seg['node']
                #print '--seg : ',seg['xml']
                # parse request, no case sense
                k = seg['key']
                k = k.lower()

                key2 = key + 'response'
                #
                if k == key: # request
                    if not req:
                        node = self.findFirstChildByName(root, 'ObjectName')
                        if not node: continue
                        req = self.__getXmlTextValue(node)
                        print 'Find req : ', req
                elif k == key2: # response
                    if req:
                        # status
                        node = self.findFirstChildByName(root, 'Status')
                        if not node: continue
                        v = self.__getXmlTextValue(node)
                        #self.debug()
                        if str(v) == '0':
                            resp = True
                        else:
                            self.error('Response is failure(' + str(v) + ') for request DeleteObject : ' + req)
                            req = None
                            # InstanceNumber
                            #node = self.findFirstChildByName(root,'InstanceNumber')
                            #if not node : continue
                            #resp = self.__getXmlTextValue(node)
                            #print '===>',resp,node
            if req and resp:
                if not rc: rc = []
                r = req
                rc.append(r)
            #
        if rc:
            self.info('Object Deleted : ' + pformat(rc))
        return rc

    def fetchAll(self):
        """
        """
        rc = {}
        #
        for k, m in self.m_hdlrs.items():
            r = m()
            rc[k] = r

        #
        return rc

    def fetch(self, key):
        """
        """
        rc = {}
        k = key.upper()
        m = self.m_hdlrs.get(k, None)
        if m:
            r = m()
            rc[k] = r
        else:
            self.error('Can not found hdlr for : ' + k)
        return rc


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ('\nGet more info with command : pydoc ' + os.path.abspath(__file__) + '\n')
    parser = OptionParser(usage=usage)

    #parser.description = desc
    parser.add_option("-c", "--captureFile", dest="src", action="append",
                      help="The capture file by tshark")
    parser.add_option("-o", "--outputFile", dest="dest",
                      help="syslog file")
    parser.add_option("-v", "--ActionType", dest="atype",
                      help="The action type to fetch")
    parser.add_option("-x", "--loglevel", type="int", dest="loglevel", default=2,
                      help="the log level, 0 : error, 1 : warning, 2 : info , 3 : debug")

    (options, args) = parser.parse_args()
    # check option
    if not options.src:
        print 'AT_ERROR : ', 'No capture file specified!'
        parser.print_help()
        exit(1)

    return options
    #------------------------------------------------------------------------------


def main():
    """
    main entry
    """
    opts = parseCommandLine()
    #
    _res = 0
    rc = {}
    for fn in opts.src:
        if not os.path.exists(fn):
            print '--', 'AT_ERROR :', 'File not found :', fn
            continue
        CWMPP = None
        CWMPP = CWMP_Parser(opts.loglevel)
        CWMPP.parseFile(fn)
        if opts.atype:
            t = opts.atype.upper()
            if not rc.has_key(t): rc[t] = []
            res = rc[t]
            r = CWMPP.fetch(opts.atype)
            if r.has_key(t):
                rr = r[t]
                if rr: res += rr
        else:
            r = CWMPP.fetchAll()
            for k, v in r.items():
                if not rc.has_key(k):
                    if v: rc[k] = v
                else:
                    if v: rc[k] += v


    #
    res_lines = []
    if opts.atype:
        t = opts.atype.upper()

        res = rc.get(t, None)

        if not res:
            line = ('!not found response for ' + t + '\n')
            print '--', 'AT_ERROR :', line
            _res = 11
            res_lines.append(line)
        else:
            for item in res:
                line = (str(item) + '\n' )
                res_lines.append(line)
    else:
        pass

    if opts.dest:
        fd = open(opts.dest, 'w')
        if fd:
            fd.writelines(res_lines)
            fd.close()
        else:
            print '--', 'AT_ERROR :', 'Open file failed :', opts.dest
            exit(1)
    else:
        print '\n\n'
        print '--' * 32
        print 'rc = \n', rc
        print '\n\n'
    print "--> res", _res
    exit(_res)


if __name__ == '__main__':
    """
    """
    print ver_info()
    main()


