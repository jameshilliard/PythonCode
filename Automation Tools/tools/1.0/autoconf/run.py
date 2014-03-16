#!/usr/bin/env python
"""
This file is the entry if AutoConf tool.
"""

########################################################################
# import Zone
import sys
import getopt
import imp
import re
import os
import time
import traceback
import pprint
import types
import autoconf
#-----------------------------------------------------------------------

########################################################################
# local func Zone

def cur_file_dir():
    path = sys.path[0]
    if os.path.isdir(path):
        return path
    elif os.path.isfile(path):
        return os.path.dirname(path)


"""
val = 0, '' ,None,False are all mean Nil
"""


def isNil(val):
    t = type(val)
    if t is types.StringType:
        return 0 == len(val)
    elif t is types.BooleanType:
        return False == val
    elif t is types.IntType:
        return 0 == val
    elif t is types.NoneType:
        return True
    else:
        return False

########################################################################

help_info = """
usage: autoconf dut tc_file [option]
required parameters :
dut             : the destination-under-test product id,such as Q2000,V2000H
tc_file         : test case file path
optional parameters :
-d lvl
--debug=lvl     : define debug level(0,1)
-i inf_file
--inf=inf_file  : define the info file
-u username
--username=     : define login username(set login and logout enabled)
-p password
-password=      : define login password
-P ps
--parser=ps     : define the record parser ,default is parser_LiveHttpHead
-r
--rapid         : ignore waiting page
-o
--post_only     : POST only
--do_exception  : handle all request exception
-h
--help          : help info

NOTE: the commandline parameters will overflow those in info file
"""
#-----------------------------------------------------------------------
DUT_Runners = {
    'Q1000H': 'runner_Q1000H.py',
    'Q2000': 'runner_Q2000.py',
    'Q2K': 'runner_Q2000.py',
    'Q2KH': 'runner_Q2000.py',
    'Q1K': 'runner_Q2000.py',
    'V1K': 'runner_V1K.py',
    'SV1KH': 'runner_V1K.py',
    'V1000': 'runner_V1K.py',
    'V2000H': 'runner_V2000H.py',
    'PK5000': 'runner_Q1000H.py',
    'RaLink': 'runner_RaLink.py',
    'FGT784WN': 'runner_FGT784WN.py',
    'TV2KH': 'runner_TV2KH.py',
    'TV1KF': 'runner_TV2KH.py',
    'BHR2': 'runner_BHR2.py'
}

env = {
    'dut': None,
    'tc': None,
    'debug': 0,
    'inf': None,
    'username': None,
    'password': None,
    'parser': 'LiveHttpHeader',
    'rapid': False,
    'post_only': False,
    'no_exception': True,
    'logdir': None
}
########################################################################
# Application Envrionment Variables
AEV = {}


def loadAEV():
    for (k, v) in os.environ.items():
        if not k.find('G_'):
            AEV[k] = v
        if not k.find('U_'):
            AEV[k] = v


########################################################################
def loadInf(inf_file):
    if not os.path.exists(inf_file):
        print '\n-| FAIL: ', 'file is not exist :', inf_file
        return False
        # Load inf
    inf = imp.load_source("inf", inf_file)
    if not 'info' in dir(inf):
        print '\n-| FAIL: ', 'can not find class Runner in file :', inf_file
        return False
    print 'Not Support Now!'
    return True

#-----------------------------------------------------------------------
def printHelp():
    print '-' * 8
    print help_info
    return True

#-----------------------------------------------------------------------
def parseCfg(fn):
    lines = []
    f = open(fn)
    if f:
        lines = f.readlines()
        f.close()
    else:
        print "==open file", fn, "error"
        return False

    for line in lines:
        if not line.startswith('#'):
            res = os.popen('echo ' + line).read()
            #print res
            match = '(\w*)\s*=\s*(.*)'
            rr = re.findall(match, res)
            #print rr
            if len(rr) > 0:
                (k, v) = rr[0]
                print '==', 'import env :', k, ' = ', v
                os.environ[k] = v


def parseVerb(kv):
    match = r'(\w*)=(.*)'
    print '==', kv
    res = re.findall(match, kv)
    for (k, v) in res:
        (k, v) = res[0]
        print '==', 'import env :', k, ' = ', v
        os.environ[k] = v
        #print


def parseCmdLine(_from=3):
    # parse optional parameters
    try:
        opts, args = getopt.getopt(sys.argv[_from:], "c:d:i:l:u:v:p:P:roh", ["debug=", "inf=", 'username=',
                                                                             'password=', 'parser=', 'rapid',
                                                                             'post_only', 'help', 'do_exception'])
    except getopt.GetoptError, e:
        print "==", e
        return False
        #print 'opts = %s' %pprint.pformat(opts)
    for a, o in opts:
        if a in ('-c'):
            parseCfg(o)
        if a in ('-d', '--debug'):
            if o is None: o = 1
            env['debug'] = int(o)
        elif a in ('-i', '--inf'):
            env['inf'] = o
        elif a in ('-l'):
            env['logdir'] = o
        elif a in ('-v'):
            parseVerb(o)
        elif a in ('-u', '--username'):
            env['username'] = o
        elif a in ('-p', '--password'):
            env['password'] = o
        elif a in ('-P', '--parser'):
            env['parser'] = o
        elif a in ('-r', '--rapid'):
            env['rapid'] = True
        elif a in ('-o', '--post_only'):
            env['post_only'] = True
        elif a in ('--do_exception'):
            env['no_exception'] = False
        elif a in ('-h', '--help'):
            printHelp()
            return True
        #print 'env = %s' %pprint.pformat(env)
    #
    return True

#-----------------------------------------------------------------------
def main():
    fp, pn, desc = imp.find_module('autoconf')
    #print fp
    #print pn
    #print desc
    pn, fn = os.path.split(pn)
    print '==add path :', pn
    sys.path.append(pn)

    argc = len(sys.argv)
    if argc < 3:
        printHelp()
        return False
        # required parameters
    env['dut'] = sys.argv[1]
    env['tc'] = sys.argv[2]
    # DUT
    #if not DUT_Runners.has_key(env['dut']) :
    #    print '\n-| FAIL: ','no runner for ',env['dut']
    #    return False
    # tc file
    if not os.path.exists(env['tc']):
        print '\n-| FAIL: ', 'tc file is not exist :', env['tc']
        return False
        # optional parameters
    rc = parseCmdLine()
    if not rc: return False
    # do job
    print '\n-| BEGIN_TIME ', time.asctime()
    t = time.time()
    #dojob()
    #"""
    try:
        dojob()
    except Exception, e:
        print '\n-| FAIL: ', e
        traceback.print_exc()
        time.sleep(2)
        #"""
    print '\n-| END_TIME ', time.asctime()
    print '\n-| SPEND_TIME ', time.time() - t

    return True

#-----------------------------------------------------------------------
"""
def loadParser(info) :
    # _parser
    psf = 'parser_' + env['parser'] + '.py'
    #print psf
    if not os.path.exists(psf):
        print '\n-| FAIL: ','Parser file is not exist :',psf
        return False
    M_parser = imp.load_source("Parser", psf)
    if not 'Parser' in dir(M_parser):
        print '\n-| FAIL: ','can not find class Parser in file :',psf
        return False
    from env['parser'] import Parser
    _parser = M_parser.Parser(info=info,debug=0)
    return _parser
 """


def loadParser(info):
    _parser = None
    psf = env['parser']
    exec ('from parser.' + psf + ' import Parser')
    _parser = Parser(info=info, debug=0)

    return _parser

#-----------------------------------------------------------------------
#-----------------------------------------------------------------------


#-----------------------------------------------------------------------
"""
def loadRunner() :
    #
    dut = env['dut']
    rf = DUT_Runners[dut]
    #print rf
    if not os.path.exists(rf):
        print '\n-| FAIL: ','Runner file is not exist :',rf
        return False
    M_Runner = imp.load_source("Runner", rf)
    if not 'Runner' in dir(M_Runner):
        print '\n-| FAIL: ','can not find class Runner in file :',rf
        return False
    _runner = M_Runner.Runner()
    #
    debug = env['debug']
    if debug > 0 : _runner.setDebug()
    if env['post_only'] : _runner.includeMethod('POST')
    return _runner
 """


def loadRunner():
    dut = env['dut']
    exec ('from runner. ' + dut + ' import Runner')
    #from runner.runner_Q2000 import Runner
    _runner = Runner()
    #print _runner
    #
    debug = env['debug']
    if debug > 0: _runner.setDebug()
    if env['post_only']: _runner.includeMethod('POST')
    return _runner

#-----------------------------------------------------------------------

#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
def dojob():
    # set testcase info
    tc_info = {
        'debug': env['debug'],
        'login': isNil(env['username']),
        'logout': isNil(env['username']),
        'dut': env['dut'],
        'id': '',
        'name': env['tc'],
        'host': '',
        'username': env['username'],
        'password': env['password'],
        'do_waiting_page': (not env['rapid'] ),
        'no_exception': env['no_exception'],
        'logdir': env['logdir'],
    }
    _parser = loadParser(tc_info)
    if not _parser:
        print "==E:", "Can not load parser"
        return False
    _runner = loadRunner()
    if not _runner: return _runner
    #return False
    # parser tcfile
    _parser.parseFile(env['tc'])
    info, reqs = _parser.GetResult()
    if 0 == len(reqs):
        print '==W:', 'request is empty'
        return True
        #print info
    #print len(cfg),reqs
    rc = _runner.loadTestCaseInfo(info, reqs)
    # Run
    rc = _runner.run();

    #Output result
    if not _runner.isResultPass():
        print '\n-| FAIL: ', _runner.getLastError()
        return False
    else:
        print '\n-| PASS '
        return True
    return True

#-----------------------------------------------------------------------
if __name__ == "__main__":
    main()

