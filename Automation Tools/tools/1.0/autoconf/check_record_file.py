#!/usr/bin/python
#       check_record_file.py
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

"""
Usage : check_record_file DUT_TYPE FILE_PATH
"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "0.1"
#__license__ = "GGPL"
__history__ = """
Rev 0.1 : 2011/10/25
    Initial version
"""

import sys, time, os
import re
from optparse import OptionParser
from pprint import pprint
from http_repl import http_repl


stats = {
    'file_changed': [],
    'page_changed': [],
    'change_info': [],
}


def unique_arr(arr):
    """
    """
    rc = {}.fromkeys(arr).keys()
    return rc


def loadParser():
    _parser = None
    psf = "LiveHttpHeader" #env['parser']
    exec ('from parser.' + psf + ' import Parser')
    _parser = Parser(debug=0)

    return _parser


def check_files(info):
    """
    """
    parser = loadParser()
    dut_type = info['dut_type']
    print "++", info['record_files']
    for rec_file in info['record_files']:
        parser.parseFile(rec_file)
        info, reqs = parser.GetResult()
        print "--" * 16
        print "==check file:", rec_file
        for req in reqs:

            rc = http_repl.check_request(dut_type, req)
            if len(rc['page_changed']):
                stats['file_changed'].append(rec_file)
                stats['page_changed'] += rc['page_changed']
                stats['change_info'] += rc['change_info']
    # unique
    stats['file_changed'] = unique_arr(stats['file_changed'])
    stats['page_changed'] = unique_arr(stats['page_changed'])
    stats['change_info'] = unique_arr(stats['change_info'])
    # print the total results
    print '\n' * 3
    print '--' * 16
    pprint(stats)
    return


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog DUT_TYPE FILE_PATH\n"
    parser = OptionParser(usage=usage)

    (options, args) = parser.parse_args()
    # check option
    if len(args) < 2:
        parser.print_usage()
        exit(1)
    # set variables
    info = {}
    info['dut_type'] = args[0]
    rec_path = args[1]
    cmd = 'ls ' + rec_path
    resp = os.popen(cmd).read()
    info['record_files'] = resp.split()
    #print info
    if len(info['record_files']):
        check_files(info)
    else:
        print "==", "files to check is empty!"
    return True


def main():
    """
    """
    parseCommandLine()
    exit(0)


if __name__ == "__main__":
    main()
