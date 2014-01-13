#!/usr/bin/python
"""
VAutomation Test Engine Class
"""

__author__ = "Rayofox"
__version__ = "$Revision: 0.1 $"
__date__ = "$Date: $"
__copyright__ = "Copyright (c) 2011 Rayofox"
__license__ = "Python"

from tcEngine import tcEngine

import os
import sys
import re
import hashlib
import time
import httplib2, urllib
import imp
import types

class Runner(tcEngine ):
    """
    """
    
    #special_type = ['login','warning','notice','error','waiting','thank_you']
#-------------------------------------------------------------------------------
    def __init__(self):
        print '==Runner for Q1K Rev.H '
        

#-------------------------------------------------------------------------------
    def parseResponse(self):
        match = r'<h1 class="thankyou">Saving Settings </h1>'
        match2 = r'<title>Thank You!</title>'        
        res = re.findall(match,self.content)
        if len(res):
            self.next_page['type'] = 'thank_you'
        

    def handleTestCaseResponse(self):
        #print 'TODO:Handle Test Case Response here'
        #print '==Next page is :' ,self.next_page['type']
        
        if not self.isNextPageSpecial():
            #print 'Next page is not a special page'
            return True
        else:
            print 'Next page is  a special page :',self.next_page['type']
            self.setLastError('Response page is a ' + self.next_page['type']+' page')
            return False
        #if self.isNextPageWarning():
        #    print 'Next page is  a special page'
        #    return False
                    
        
        return True
    
#-------------------------------------------------------------------------------

    """
    Login
    """
    def doLogin(self):
        #connect and get login page
        print '==Not support login'
        return True
#-------------------------------------------------------------------------------
    
#-------------------------------------------------------------------------------    
    def doLogout(self):
        print '==Not support logout'
        return True

#-------------------------------------------------------------------------------


def main():
    argc = len(sys.argv)
    if argc < 2:
        print 'Usage : ',sys.argv[0],' test_case_file'
        return False
    
    ###
    tc_file = sys.argv[1]
    runner = Runner()
    runner.setDebug()
    # load case info
    rc = runner.loadTestCaseFile(tc_file)

    rc = runner.run();
    if not runner.isResultPass():
      print '\n-| FAIL: ',runner.getLastError()
    else:
      print '\n-| PASS '
    
    return True
          
if __name__ == "__main__":
    main()
    """
    try:
        main()
    except Exception,e :
        print '\n-| FAIL: ',e
    """
                

        
                
