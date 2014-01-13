#!/usr/bin/python -u
import os, sys, re
import time, datetime

from pprint import pprint
from pprint import pformat
import logging
from copy import deepcopy

import signal
from optparse import OptionParser

import pexpect


def backup_db(username, password, dbname, bk_dir, filename):
    """
    """
    #bk_dir = 'var/log/mysql'
    filefullname = os.path.join(bk_dir, filename)
    # 1. remove the file whatever it exists or not
    print('== 1 : remove the file whatever it exists or not (%s)' % filefullname)
    os.system('rm -rf "%s"' % (filefullname))

    cmd = 'find -P "%s" -maxdepth 1 -mtime +%d  -type f |grep "%s" |sort' % (bk_dir, 60, filename)
    print(cmd)
    rr = os.popen(cmd).read()
    print(rr)
    cmd += ' | xargs -i rm -rf {}'
    print(cmd)
    os.system(cmd)

    # 2. do backup
    print('== 2 : do mysqldump for db(%s)' % (dbname))
    cmd = 'mysqldump -u%s -p %s ' % (username, dbname)
    print(cmd)
    exp = pexpect.spawn(cmd)
    #exp.logfile = sys.stdout
    idx = exp.expect(['Enter password:', pexpect.TIMEOUT, pexpect.EOF])
    if idx == 0:
        exp.sendline(password)
        pass
    else:
        print('== AT_Error : %s' % (str(exp)))
        pass

    idx = exp.expect(['-- Dump completed on', pexpect.TIMEOUT, pexpect.EOF])
    dump_info = exp.before
    fd = open(filefullname, 'w+')
    if fd:
        fd.write(dump_info)
        fd.close
        pass



    # 3. zip file
    print('== 3 : zip the file')
    dt = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    cmd = 'cd %s ;tar -zcvf %s_%s.tgz %s' % (bk_dir, filename, dt, filename)
    print(cmd)
    os.system(cmd)

    pass


def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: [options]\n"
    usage += ('\nGet detail introduction and sample usange with command : pydoc ' + os.path.abspath(__file__) + '\n\n')

    parser = OptionParser(usage=usage)
    # save response
    parser.add_option("-o", "--Output_file", dest="outfile",
                      help="output the command(s) response to file")

    (options, args) = parser.parse_args()
    # output the options list
    print '==' * 32
    print 'Options :'
    excludes = ['read_file', 'read_module', 'ensure_value']
    for k in dir(options):
        if k.startswith('_') or k in excludes:
            continue
            #
        v = getattr(options, k)
        print k, ':', v
        # exit(1)
    print '==' * 32
    print ''
    return args, options
    #--------------------------


def main():
    """
    main entry
    """
    exit_code = 0
    #args, opts = parseCommandLine()
    backup_db('root', '123qaz', 'automation_test', '/var/log/mysql', 'automation_test.bk')
    exit(exit_code)


if __name__ == '__main__':
    """
    """

    main()
