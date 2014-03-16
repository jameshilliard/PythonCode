#!/usr/bin/env python

import os, sys, re
from pprint import pprint
from pprint import pformat
from copy import deepcopy
from optparse import OptionParser
import logging


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog SRC_FILE DEST_FILE [options]\n"
    usage += ('\nGet more info with command : pydoc ' + os.path.abspath(__file__) + '\n')
    parser = OptionParser(usage=usage)

    parser.add_option("-a", "--all", dest="analyze_all", action="store_true", default=False,
                      help="analyze all cases include ncases")
    parser.add_option("-d", "--destination", dest="dest",
                      help="destination file to analyze")
    parser.add_option("-k", "--keyword", dest="keywords", action="append",
                      help="keyword(s) to classify error cases in error message")
    parser.add_option("-r", "--keyword_rules_file", dest="rules_file", #action="append",
                      help="rule file contains keyword(s) to classify error cases in error message")
    parser.add_option("-s", "--saveto", dest="saveto",
                      help="Save result to file")
    parser.add_option("-v", "--verbose", type="int", dest="verbose", default=1,
                      help="verbose level to output , default is 1 . \n0 : Summary information only.\n1 : Error details for cases without category only.\n2 : Error details for all")
    parser.add_option("-x", "--loglevel", type="int", dest="loglevel", default=30,
                      help="the log level, default is 30(WARNING)")

    (options, args) = parser.parse_args()

    if len(args) < 2:
        print '== Need 2 parameters at least!'
        parser.print_help()
        exit(1)

    return options, args


def main():
    """
    main entry
    """
    opts, args = parseCommandLine()
    [src, dst] = args
    print '=='
    print 'Source File : ', src
    if not os.path.exists(src):
        print 'File not exist :', src
        exit(1)

    print 'Destination File : ', dst
    if not os.path.exists(dst):
        print 'File not exist :', dst
        exit(1)

    #
    lines_src = open(src).readlines()
    lines_dst = open(dst).readlines()
    lines_loss = []

    for line in lines_dst:
        if not line in lines_src:
            lines_loss.append(line)

    print '\n\n'
    print '--' * 16
    print 'Total lines lost : ', str(len(lines_loss))
    for line in lines_loss:
        print line


if __name__ == '__main__':
    """
    """
    main()
    
    
    
