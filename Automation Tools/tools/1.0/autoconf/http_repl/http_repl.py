#       http_repl.py
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
#
#
#

"""
This tool support functions :
1. Check http request files change 
2. Replace http request files variables

"""

__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "0.1"
#__license__ = "GGPL"
__history__ = """
Rev 0.1 : 2011/10/20
    Initial version
"""

import sys, time, os
import re
from pprint import pprint
from pprint import pformat

tot_results = {
    'page_changed': [],
    'page_same': [],
    'page_unknown': [],
    'change_info': [],
}


def unique_arr(arr):
    """
    """
    rc = {}.fromkeys(arr).keys()
    return rc


def check_request(dut_type, req):
    """
    """
    cmd = 'from ' + dut_type + ' import hdlr_check_request'
    exec (cmd)
    dut_hdlr = hdlr_check_request
    if not dut_hdlr:
        print "==!", "no handler function hdlr_check_request for ", dut_type
        exit(1)
    page_info = dut_hdlr(req)
    if page_info['result']:
        pprint(page_info)
        if page_info['result'] == "DIFF":
            tot_results['page_changed'].append(page_info['pagename'])
            tot_results['change_info'].append(page_info['message'])
        elif page_info['result'] == "SAME":
            tot_results['page_same'].append(page_info['pagename'])
    else:
        tot_results['page_unknown'].append(page_info['pagename'])
    #
    tot_results['page_changed'] = unique_arr(tot_results['page_changed'])
    tot_results['page_same'] = unique_arr(tot_results['page_same'])
    tot_results['page_unknown'] = unique_arr(tot_results['page_unknown'])
    return tot_results


def repl_request(dut_type, req):
    """
    """
    exec ('from ' + dut_type + ' import hdlr_repl_request')
    dut_hdlr = hdlr_check_request
    if not dut_hdlr:
        print "==!", "no handler function hdlr_repl_request for ", dut_type
        exit(1)
    dut_hdlr(req)
    return True


def main():
    """
    """
    pass


if __name__ == '__main__':
    main()
