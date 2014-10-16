#!/usr/bin/python -u
#       PageBase.py
#       
#       Copyright 2011 root <root@rayofox-test>
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
    The base class for Page,just overload the 2 functions :
        def fmt_repl(self,fmt) :
        def hash_repl(self,h) :

"""

import os, sys, time, re
from copy import deepcopy
import urllib
from pprint import pprint
from pprint import pformat


class PageBase():
    """
    """
    # 
    m_hashENV = {}
    m_player = None
    m_msglvl = 2
    m_queryFmts = {}
    m_bodyFmts = {}
    m_pageFmt = {
        #'name' : '',
        'keys': [],
        'vals': [],
        'hash': None,
    }
    m_isHash = True
    m_replPOST = True
    m_replGET = True

    def __init__(self, player, msglvl=2):
        """
        """
        self.m_player = player
        self.m_msglvl = msglvl
        self.m_pageFmts = {}
        self.loadEnv()


    def addStrQueryFmt(self, name, sfmt):
        """
        """
        fmt = self.m_player.newUrlQueryStr(sfmt)
        self.m_queryFmts[name] = fmt

    def addStrBodyFmt(self, name, sfmt):
        """
        """
        fmt = self.m_player.newUrlQueryStr(sfmt)
        self.m_bodyFmts[name] = fmt

    def addStrFmts(self, bodyFmts, queryFmts):
        """
        """
        # add body format
        for (k, v) in bodyFmts.items():
            self.addStrBodyFmt(k, v)
            # add query format
        for (k, v) in queryFmts.items():
            self.addStrQueryFmt(k, v)

    def loadEnv(self):
        """
        """
        for (k, v) in os.environ.items():
            if 0 == k.find('G_'):
                self.m_hashENV[k] = v
            elif 0 == k.find('U_'):
                self.m_hashENV[k] = v
            elif 0 == k.find('TMP_'):
                self.m_hashENV[k] = v

    def debug(self, msg):
        """
        """
        if self.m_msglvl > 2:
            pprint('== ' + self.__class__.__name__ + ' Debug : ' + pformat(msg))
        return True

    def info(self, msg):
        """
        """
        if self.m_msglvl > 1:
            print '== ' + self.__class__.__name__ + ' Info : ', str(msg)
        return True

    def warning(self, msg):
        """
        """
        if self.m_msglvl > 0:
            print '== ' + self.__class__.__name__ + ' Warning : ', str(msg)
        return True

    def error(self, msg):
        """
        """
        print '== ' + self.__class__.__name__ + ' Error : ', str(msg)
        return True

    def check(self, req, page_info):
        """
        """
        body = req['body-fmt']
        query = req['query-fmt']
        # check POST body 
        if self.m_replPOST and body:
            self.checkBody(body, page_info, self.m_bodyFmts)
        else:
            if not page_info['result']: page_info['result'] = 'IGNORE'
            self.info('Ignore check post body ')
            # check Get query
        if self.m_replGET and query:
            self.checkQuery(query, page_info, self.m_queryFmts)
        else:
            if not page_info['result']: page_info['result'] = 'IGNORE'
            self.info('Ignore check query ')

        return

    def checkBody(self, body, page_info, bodyFmts):
        """
        """
        self.checkFmt(body, page_info, bodyFmts)

    def checkQuery(self, query, page_info, queryFmts):
        """
        """
        self.checkFmt(query, page_info, queryFmts)

    def checkFmt(self, ofmt, page_info, fmts):
        """
        """
        hasDiff = True
        hasFmt = False

        for (name, objFmt) in fmts.items():
            z1 = deepcopy(ofmt.fmt()['keys'])
            z2 = deepcopy(objFmt.fmt()['keys'])
            q = ofmt.str()
            if q.find(name) < 0:
                continue

            hasFmt = True
            if z1 == z2:
                hasDiff = False
                #
            if hasDiff and self.m_isHash:
                z1.sort()
                z2.sort()
                if z1 == z2:
                    hasDiff = False
                else:
                    d1 = list(set(z1) - set(z2))
                    d2 = list(set(z2) - set(z1))
                    page_info['message'] = ""
                    page_info['message'] += ('have new : ' + str(d1) + '\n')
                    page_info['message'] += ('have not : ' + str(d2) + '\n')
            break

        # 
        #page_info['message'] = ""
        if not hasDiff:
            page_info['result'] = "SAME"
            #page_info['message'] = ""
        else:
            page_info['result'] = "DIFF"
            if not hasFmt:
                page_info['message'] = ('have no specified format to check\n')
                #page_info['message'] += (page_info['pagename'] + " changed")
            #
        if hasDiff:
            self.checkDetail(ofmt, page_info)

    def replace(self, req):
        """
        """
        changed = True
        body = req['body-fmt']
        query = req['query-fmt']
        changelog = []
        # repl POST
        if self.m_replPOST and body:
            q = body.str()
            if q and len(q):
                self.replBody(body)
                changelog += body.getChangeLog()
                nq = body.str()
                if q == nq:
                    changed = False
                else:
                    changed = True
                    #req['request-body'] = nq
            else:
                changed = False
        else:
            changed = False

        # repl GET
        if self.m_replGET and query:
            q = query.str()
            if q and len(q):
                self.replQuery(query)
                changelog += query.getChangeLog()
                nq = query.str()
                if q == nq:
                    #changed = False
                    pass
                else:
                    changed = True
                    #req['request-body'] = nq
                    #path,qq = urllib.splitquery(req['uri'])
                    #req['uri'] = (path + '&' + nq)
            else:
                #changed = False
                pass
        if changed:
            self.info('Dump Value changed :')
            for log in changelog:
                self.info(log)

                #self.dumpValueChanged()

        return (req, changed)

    ### Need To OverLoad ##########################


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
        # TODO : Implement your hash replacement
        return body


