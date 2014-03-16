#!/usr/bin/env python -u
"""
Runner 
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

Runners = {
'Q1000H' : 'runner_Q1000H.py',
'Q2000' : 'runner_Q2000.py',
'V1000' : 'runner_V1000.py',
'PK5000' : 'runner_Q1000H.py',
'BHR1' : 'runner_BHR1.py',
'RaLink' : 'runner_RaLink.py'
}
import imp
import sys
import re
import os
import time
import traceback

from  parser_LiveHttpHeader import Parser
#from  parser_Wireshark import Parser
from pprint import pprint
from pprint import pformat

#-------------------------------------------------------------------------------
def cur_file_dir():
    path = sys.path[0]
    if os.path.isdir(path):
        return path
    elif os.path.isfile(path):
        return os.path.dirname(path)


#-------------------------------------------------------------------------------
def main():
    argc = len(sys.argv)
    debug = False
    info = None
    #argc MUST be 3
    if argc < 2:
        print '\nUsage : ',sys.argv[0],' product_id test_case_file ["info={}"] ["info_file=file_full_path"] '
        print '\nSuch as : run.py Q1000H tc_sample'
        print '\n        : run.py BHR2 tc_sample info={\'usename\':\'account\',\'password\':\'passwd\'}'
        print '\n        : run.py BHR2 tc_sample info_file=info_bhr2'
        print '\n-| FAIL: ','Bad Arguments'
        return False
    
    ###Get Runner file
    product = sys.argv[1]
    tc_file = sys.argv[2]
    
    # set default info
    default_info = {
    'login' : 0,
    'logout' : 0,
    'dut' : product,
    'id' : tc_file,
    'name' : tc_file,
    'host' : '192.168.1.1',
    'username' : 'admin',
    'password' : 'admin1',
    'do_waiting_page' : True
    }
    info_file = None
    for i in range(3,argc):
        exec(sys.argv[i])
    
    if info:
        default_info.update(info)
        
    if info_file :
        execfile(info_file)
        
        
    if not Runners.has_key(product):
        print '\n-| FAIL: ','no runner for product',product
        return False
    runner_fn = Runners[product]
    if not os.path.exists(tc_file):
        print '\n-| FAIL: ','file is not exist :',tc_file
        return False
    #Load Runner module
    R = imp.load_source("Runner", runner_fn)
    if not 'Runner' in dir(R):
        print '\n-| FAIL: ','can not find class Runner in file :',tc_file
        return False
        
    #instnace a runner
    runner = R.Runner()
    if debug:
        runner.setDebug()
    
    #Load case info, parse custom format setting into python data struct
    #parser = parser2()
    #info,cfg = parser.parseFile(tc_file)
    
    #print dir(parser_LiveHttpHeader)
    
    ps = Parser(info=default_info)
    ps.parseFile(tc_file)
    info,reqs = ps.GetResult()
    #print info
    #print len(cfg),reqs
    rc = runner.loadTestCaseInfo(info,reqs)

    # Set Filter
    #runner.excludeMethod('GET')
    #runner.includeMethod('POST')
    #runner.excludePostContent('thankyou')
    #runner.excludeURL('thankyou')
    #Run 
    rc = runner.run();
    
    #wait 
    #runner.wait4cfg(15)
    
    #Output result
    if not runner.isResultPass():
        print '\n-| FAIL: ',runner.getLastError()
        return False
    else:
        print '\n-| PASS '
        return True
          
if __name__ == "__main__":
    #p = parser4Q1K()
    #p.test()
    print '\n-| BEGIN_TIME ',time.asctime()
    t = time.time()

    #main()
    #"""
    try:
        main()
    except Exception,e :
        print '\n-| FAIL: ',e
        traceback.print_exc()
        time.sleep(2)
    #"""
    print '\n-| END_TIME ',time.asctime()
    print '\n-| SPEND_TIME ',time.time()-t
