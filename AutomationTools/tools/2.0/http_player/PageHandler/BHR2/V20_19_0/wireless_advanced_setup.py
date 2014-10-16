#       template.py
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

# TODO : add your keyword-format into map
body_fmts[
    "active_page"] = 'active_page=9121&active_page_str=page_actiontec_wireless_advanced_setup&page_title=Advanced+Security+Settings&mimic_button_field=submit_button_wireless_next%3A+..&button_value=9121&strip_page_top=0&tab4_selected=2&tab4_visited_2=1&wireless_advanced=3'
#body_fmts["wpa"] = ''
#-----------------------------------------------------------------------
query_fmts = {}
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


    def checkDetail(self, fmt, page_info):
        """
        TODO : check detail difference
        """
        pass

    def replQuery(self, query):
        """
        """
        # TODO : Implement your replacement without hash

        pass

    def replBody(self, body):
        """
        """
        # TODO : Implement your hash replacement
        return body

	
	
	
	
