#       http_parser.py
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
Http_Parser is a class to parse HTTP request record files to python data struct
1. parse record file
2. saveas record file after python data struct do some changing

}


"""
__author__ = "Rayofox (lhu@actiontec.com)"
__copyright__ = "Copyright 2011, Rayofox"
__version__ = "1.0"
__history__ = """
Rev 1.0 : 2011/11/10
	Initial version
"""
#------------------------------------------------------------------------------
from types import *
import sys, time, os
import re
from optparse import OptionParser
from pprint import pprint
from pprint import pformat
import subprocess, signal, select
from copy import deepcopy

from Parser.LiveHTTPHeaders import Parser
from url_query_str import url_query_str
import urllib


class Http_Parser(Parser):
    """
    """
    mv_parser = None

    def __init__(self, loglevel=2):
        """
        Init ,create a parser
        """
        Parser.__init__(self, loglevel)

    #self.mv_parser = Parser(loglevel)

    def parseRecordFile(self, filename):
        """
        Parse Record file
        """
        #self.mv_parser.parseRecFiles(filename)
        self.mv_chapters = []
        self.parseRecFiles(filename)

    def getSections(self):
        """
        Get all parsed sections
        """
        #rc = self.mv_parser.mv_chapters[0]['sections']
        #print '===',self.mv_chapters[0],len(self.mv_chapters)
        rc = self.mv_chapters[0]['sections']
        return rc

    def getResult(self):
        """
        Get all parsed req for http_player to play
        """
        sections = self.getSections()
        Reqs = []
        for section in sections:
            req = section['req']
            req['body-fmt'] = None
            req['query-fmt'] = None
            # post body
            body = req['request-body']
            if body and len(body):
                req['body-fmt'] = url_query_str(body)
            # get query
            path, query = urllib.splitquery(req['uri'])
            if query and len(query):
                req['query-fmt'] = url_query_str(query)
            #
            Reqs.append(req)
        return Reqs

    def updateReqByBodyAndQuery(self, req):
        """
        """
        body = req['body-fmt']
        query = req['query-fmt']

        if body and body.isChanged():
            req['request-body'] = body.str()
        if query and query.isChanged():
            path, q = urllib.splitquery(req['uri'])
            if q and len(q):
                req['uri'] = (path + '?' + query.str() )

    def dumpReq(self, req):
        """
        """
        body = req['body-fmt']
        query = req['query-fmt']
        s = ''
        s += '\n\n'
        s += 'req = '
        s += pformat(req)
        s += '\n\n'
        if body:
            s += ('body = \n')
            s += (body.dump() )
            s += ('\n\n')
        if query:
            s += ('query = \n')
            s += (query.dump() )
            s += ('\n\n')
        return s


    def saveAs(self, fname):
        """
        save as record file
        """
        sections = self.getSections()
        fd = open(fname, 'w')
        if fd:
            for section in sections:
                #self.mv_parser.updateSectionWithReq(section)
                #lines = self.mv_parser.section2lines(section)
                self.updateSectionWithReq(section)
                lines = self.section2lines(section)
                for line in lines:
                    #print '===',line
                    fd.writelines(line)
                    fd.write('\n')
            fd.close()
        else:
            self.error('can not open mid file to save : ' + fname)
            return False
        return True


def main():
    """
    main entry
    """
    HP = Http_Parser(2)
    # parse record file
    HP.parseRecordFile('./rec001')
    # get all inf
    rc = HP.getResult()
    pprint(rc)
    # change some inf
    item = rc[0]
    item['host'] = '172.16.1.254'
    # print origin sections
    print '\n' * 4
    rc = HP.getSections()
    pprint(rc)
    # update change
    # HP.updateChange()
    # print changed sections
    print '\n' * 4
    rc = HP.getSections()
    pprint(rc)
    # save changed record file
    HP.saveAs('./rec001.new')
    return 0


if __name__ == '__main__':
    """
    """
    main()


