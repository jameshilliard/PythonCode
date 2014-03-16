#!/usr/bin/python 
"""
This tool is to export config file to getenv format 
"""
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "1.0"
__license__ = "MIT"
__history__ = """
Rev 1.0 : Initial version at 2011/08/31
"""
#------------------------------------------------------------------------------
import sys, time, os
import re
from optparse import OptionParser
#file_lines = []
#------------------------------------------------------------------------------
def parse_lines(lines):
    """
    parse config file lines, and combine to getenv format
    """
    rc = ''
    for line in lines:
        if not line.startswith('#'):
            res = os.popen('echo ' + line).read()
            #print res
            match = '([^=\s]*)\s*=\s*(.*)'
            rr = re.findall(match, res)
            #print rr
            if len(rr) > 0:
                (k, v) = rr[0]
                s = (k + '=' + v)
                rc += s
                rc += ' '
    return rc

#------------------------------------------------------------------------------
def parse_cfgfile(fn):
    """
    parse config file
    """
    rc = ''
    fd = open(fn, 'r')
    if fd:
        lines = fd.readlines()
        rc = parse_lines(lines)
        fd.close()
    else:
        print '==Error:', 'Can not open file ', fn
    return rc

#------------------------------------------------------------------------------
def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-c", "--configfile", dest="cfgfile",
                      help="The config file to getenv")

    (options, args) = parser.parse_args()
    #print options.filename,options.verbose

    #print dir(options)
    if options.cfgfile:
        res = parse_cfgfile(options.cfgfile)
        print '==>Result:'
        print res
    else:
        print '==Error:', 'cfgfile MUST specified'
        exit(-1)

#------------------------------------------------------------------------------
def main():
    """
    main entry
    """
    parseCommandLine()

#------------------------------------------------------------------------------
if __name__ == '__main__':
    main()
    exit(0)
