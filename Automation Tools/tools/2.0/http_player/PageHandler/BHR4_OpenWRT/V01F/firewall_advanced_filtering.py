#       wireless_basic.py
#       
#       Copyright 2011 rayofox <rayofox@rayofox-test>
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
body_fmts["add_edit"] = ''
body_fmts["delete"] = ''
#-----------------------------------------------------------------------
query_fmts = {}

# TODO : add query format string 
#query_fmts[''] = ''
#query_fmts[''] = ''



class Page(PageBase):
    """
    """

    def __init__(self, player, msglvl=2):
        """
        """
        PageBase.__init__(self, player, msglvl)
        self.info('Page ' + os.path.basename(__file__))
        self.addStrFmts(body_fmts, query_fmts)

        # TODO : setup replace mode 
        #self.m_isHash = True
        #self.m_replPOST = True
        #self.m_replGET = False

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
        fmt = body.fmt()
        idx = body.value('firewall_advancedfiltering_index')
        sbl_idx = os.getenv('SBL_RULE_INDEX', None)
        if str(idx) in ['-1', 'None']:
            print ''
        else:
            print 'need to update rule idx to remove'
            if sbl_idx:
                body.updateValue('firewall_advancedfiltering_index', sbl_idx)
            else:
                print 'sbl_idx is empty , DO NOT do replacement'

        return body
