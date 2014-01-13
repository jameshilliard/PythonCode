#! /usr/bin/env python
"""
This file is a tool to send http request
"""

from optparse import OptionParser
##############################################################################
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
    'logdir': None,
}
##############################################################################

def main():
    """
    the main entry, parse the commandline
    """
    usage = "usage: %prog [options]"
    parser = OptionParser(usage)
    parser.add_option("-d", "--dest", dest="dut",
                      help="the dut request send to,default is no dut, but a common request")
    parser.add_option("-f", "--file", dest="filename",
                      help="read data from FILENAME")
    parser.add_option("-e", "--send_request", dest="req",
                      help="send request ")
    parser.add_option("-v", action="append", dest="env",
                      help="import envrionment variable like U_TEST_NAME=root")
    parser.add_option("-x", "--loglevel", type="int", dest="loglevel",
                      help="set the log level,default is 0")
    parser.add_option("-q", "--quick", action="store_false", dest="quick",
                      help="quick mode igore all waiting pages")
    parser.add_option("--imp_env_cfg", action="append", dest="env_cfg",
                      help="import envrionment variables from file(s) ")
    parser.add_option("--repl_cfg", action="append", dest="repl_cfg",
                      help="set the common replacement config file")
    (options, args) = parser.parse_args()
    print args
    if len(args) != 1:
        parser.error("incorrect number of arguments")
        parser.print_usage()
    if options.req:
        print options.req


if __name__ == "__main__":
    main()
