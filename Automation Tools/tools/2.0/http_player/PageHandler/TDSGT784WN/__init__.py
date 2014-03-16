#       __init__.py
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
	The dispatcher for specified version
"""

import sys, time, os
import re

#-----------------------------------------------------------------------
# TODO : add the map from version to folder name
hash_pageHdlrs = {
    '1.1L.0a-gt784wn': 'V1_1L_0A_GT784WN',
}
# TODO : set the default page handler 
def_pageHdlr = '1.1L.0a-gt784wn'
#-----------------------------------------------------------------------

def getPageHandler(prod_ver, player):
    """
    Dispatcher for Version
    """
    pageHdlr = None
    for (k, v) in hash_pageHdlrs.items():
        if k == prod_ver:
            pageHdlr = v
            print '==', 'Find specified PageHandler for Version ' + prod_ver
            break
    if not pageHdlr:
        print '==', 'Not find specified PageHandler for Version ' + str(prod_ver)
        print '==', 'Using the default PageHandler for Version ' + def_pageHdlr
        pageHdlr = hash_pageHdlrs[def_pageHdlr]
    cmd = 'from ' + pageHdlr + ' import PageHandler'
    exec (cmd)
    hdlr = PageHandler(player)
    return hdlr


