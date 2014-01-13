#       $FILENAME.py
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
This is a template file to create page handle file
"""
#-----------------------------------------------------------------------
import os, sys
import httplib2, urllib
import re
import types
from pprint import pprint
from copy import deepcopy

from PageBase import PageBase

#-----------------------------------------------------------------------
body_fmts = {}

# TODO : add POST body format string map to an unique string (when have multi format string ,the unique string id decided how to match)
body_fmts[
    "tr69cAcsURL"] = 'tr69cAcsURL=http%3A%2F%2Fxatechdmw.xdev.motive.com%2FcwmpWeb%2FCPEMgt&tr69cAcsUser=qwest&tr69cAcsPwd=&tr69cInformEnable=1&tr69cInformInterval=60&tr69cPeriodicInformTime=2012-02-21T02%3A43%3A58%2B00%3A00&tr69cConnReqURL=http%3A%2F%2F192.168.55.147%3A4567%2F&tr69cConnReqUser=00247B-V2000H-CVJA1141900040&tr69cConnReqPwd=&tr69cBackoffInterval=&tr69cDebugEnable=1&var%3Afrompage=tr69.html'
#body_fmts[""] = ''
#-----------------------------------------------------------------------
query_fmts = {}


class Page(PageBase):
    """
    """

    def __init__(self, player, msglvl=2):
        """
        """
        PageBase.__init__(self, player, msglvl)
        self.info('Page ' + os.path.basename(__file__))
        self.addStrFmts(body_fmts, query_fmts)

    #        tr69cAcsURL    http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt
    #        tr69cAcsUser    qwest
    #        tr69cAcsPwd
    #        tr69cInformEnable    1
    #        tr69cInformInterval    60
    #        tr69cPeriodicInformTime    2012-02-21T02:43:58+00:00
    #        tr69cConnReqURL    http://192.168.55.147:4567/
    #        tr69cConnReqUser    00247B-V2000H-CVJA1141900040
    #        tr69cConnReqPwd
    #        tr69cBackoffInterval
    #        tr69cDebugEnable    1
    #        var:frompage    tr69.html

    def checkDetail(self, fmt, page_info):
        """
        check difference detail
        """
        # TODO : check detail difference
        pass

    def replQuery(self, query):
        """
        replace query string
        """
        # TODO : Implement your replacement without hash

        pass

    def replBody(self, body):
        """
        replace body string
        """
        fmt = body.fmt()
        ACS_URL = body.value('tr69cAcsURL')
        url_reg_before = []
        url_reg_before.append('http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt')
        url_reg_before.append('http://iiothdmw13.iot.motive.com/cwmpWeb/CPEMgt')
        url_reg_done = []
        url_reg_done.append('http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt')
        url_reg_done.append('http://iiothdm13.iot.motive.com/cwmpWeb/CPEMgt')

        for index, k in enumerate(fmt['keys']):
            v = fmt['vals'][index]
            if k == 'tr69cAcsUser':
                #if 'http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt' == ACS_URL :
                #    continue
                #elif 'http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt' == ACS_URL :
                if ACS_URL in url_reg_before:
                    continue
                elif ACS_URL in url_reg_done:
                    tr69cAcsUser = os.getenv('TMP_DUT_CWMP_CONN_ACS_USERNAME')
                    if tr69cAcsUser:
                        print 'update tr69cAcsUser to ', tr69cAcsUser
                        ev = tr69cAcsUser
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue
            elif k == 'tr69cAcsPwd':
                #if 'http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt' == ACS_URL :
                if ACS_URL in url_reg_before:
                    tr69cAcsPwd = os.getenv('U_DEF_DUT_CWMP_CONN_ACS_PASSWORD')
                    if tr69cAcsPwd:
                        print 'update tr69cAcsPwd to ', tr69cAcsPwd
                        ev = tr69cAcsPwd
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue
                #elif 'http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt' == ACS_URL :
                elif ACS_URL in url_reg_done:
                    tr69cAcsPwd = os.getenv('TMP_DUT_CWMP_CONN_ACS_PASSWORD')
                    if tr69cAcsPwd:
                        print 'update tr69cAcsPwd to ', tr69cAcsPwd
                        ev = tr69cAcsPwd
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue
            elif k == 'tr69cConnReqURL':
                tr69cConnReqURL = os.getenv('TMP_DUT_CWMP_CONN_REQ_URL')
                if tr69cConnReqURL:
                    print 'update tr69cConnReqURL to ', tr69cConnReqURL
                    ev = tr69cConnReqURL
                    if ev:
                        v = ev
                    body.updateValueByIndex(index, v)
                continue
            elif k == 'tr69cConnReqUser':


                #if 'http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt' == ACS_URL :
                #    continue
                #elif 'http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt' == ACS_URL :
                if ACS_URL in url_reg_before:
                    continue
                elif ACS_URL in url_reg_done:
                    tr69cConnReqUser = os.getenv('TMP_DUT_CWMP_CONN_REQ_USERNAME')
                    if tr69cConnReqUser:
                        print 'update tr69cConnReqUser to ', tr69cConnReqUser
                        ev = tr69cConnReqUser
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue
            elif k == 'tr69cConnReqPwd':
                #if 'http://xatechdmw.xdev.motive.com/cwmpWeb/CPEMgt' == ACS_URL :
                #    continue
                #elif 'http://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt' == ACS_URL :
                if ACS_URL in url_reg_before:
                    continue
                elif ACS_URL in url_reg_done:
                    tr69cConnReqPwd = os.getenv('TMP_DUT_CWMP_CONN_REQ_PASSWORD')
                    if tr69cConnReqPwd:
                        print 'update tr69cConnReqPwd to ', tr69cConnReqPwd
                        ev = tr69cConnReqPwd
                        if ev:
                            v = ev
                        body.updateValueByIndex(index, v)
                    continue
        return body

