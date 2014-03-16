#!/usr/bin/python 
"""
This tool is to execute command with input environment variables
    ./run_with_env.py -v X_TEST=okay -e 'cat "$X_TEST"'
the output is : okey
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

#exec_cmd = None
_opts = {
    'debug': False,
    'exec_cmd': None
}
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
                #if _opts['debug'] : print '==','putenv ',k,'=',v
                os.putenv(k, v)
                #s = (k + '=' + v)
                #rc += s
                #rc += ' '
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
        if _opts['debug']: print '==Error:', 'Can not open file ', fn
    return rc

#------------------------------------------------------------------------------
def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-c", "--configfile", dest="cfgfile",
                      help="The environment config file to set")
    parser.add_option("-v", "--VariableOption", dest="env", action="append",
                      help="The env to set, format is key=val")
    parser.add_option("-e", "--execute", dest="execute",
                      help="The command to execute with os.system()")
    parser.add_option("-d", "--Debug",
                      action="store_true", dest="debug", default=False,
                      help="print debug messages to stdout")

    (options, args) = parser.parse_args()
    #print options.filename,options.verbose

    #print dir(options)
    if options.debug:
        #print '!!!'
        _opts['debug'] = True
    if options.cfgfile:
        res = parse_cfgfile(options.cfgfile)
    if options.execute:
        global exec_cmd
        #print '==!','Exec:',exec_cmd
        _opts['exec_cmd'] = options.execute
    if options.env:
        #print options.env
        for item in options.env:
            #print '==!',item
            match = r'(\w*)\s*=\s*(.*)'
            az = re.findall(match, item)
            sz = len(az)
            if sz > 0:
                (key, val) = az[0]
                if key:
                    if not val: val = ''
                    #print _opts['debug'] 
                    if _opts['debug']: print '==', 'putenv ', key, '=', val
                    os.putenv(key, val)
                    #------------------------------------------------------------------------------


def main():
    """
    main entry
    """
    parseCommandLine()
    if _opts['exec_cmd']:
        # 
        if _opts['debug']: print '==', 'Exec:', _opts['exec_cmd']
        os.system(_opts['exec_cmd'])
        #os.fork(str(exec_cmd) )

#------------------------------------------------------------------------------
if __name__ == '__main__':
    main()
    exit(0)
