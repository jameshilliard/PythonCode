#!/usr/bin/env python
#coding=utf-8

import os, sys, re
from pprint import pprint, pformat
import subprocess, time, select
import logging

import select


def waiting_input(prompt='', timeout=10):
    if len(prompt):
        sys.stdout.write(prompt)
        sys.stdout.flush()
    to = 1
    if timeout < 0:
        timeout = sys.maxint
        print('--> %s' % timeout)
        pass
    i = 0
    while ( i < timeout):
        rd = select.select([sys.stdin], [], [], to)[0]
        if not rd:
            if i > 0:
                x = len(str(i))
                sys.stdout.write('\b' * x)
                pass
            i += 1
            sys.stdout.write(str(i))
            sys.stdout.flush()
        else:
            return raw_input()
        pass
    pass


def hasATError(msg):
    """
    """
    m = r'AT_ERROR'
    res = re.findall(m, msg, re.I)
    if len(res): return True

    return False


def hasATWarning(msg):
    """
    """
    m = r'AT_WARN'
    res = re.findall(m, msg, re.I)
    if len(res): return True

    return False


def hasATInfo(msg):
    """
    """
    m = r'AT_INFO'
    res = re.findall(m, msg, re.I)
    if len(res): return True

    return False


def subproc(cmd, timeout=-1, plogger=None, timeout_no_output=600, no_output=False):
    """
    subprogress to run command
    """
    rc = None
    output = ''
    #print('===AT_INFO:initial output id : %s' % id(output))
    if not plogger: plogger = logging.getLogger()
    #
    cmd2 = os.path.expandvars(cmd)
    plogger.info('subproc  : ' + cmd)
    plogger.info('real cmd : ' + cmd2)
    plogger.info('timout   : ' + str(timeout))
    try:
        #
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True,
                             shell=True)
        pi, po, pe = p.stdin, p.stdout, p.stderr
        while_begin = time.time()
        while True:

            to = timeout_no_output
            fs = select.select([p.stdout, p.stderr], [], [], to)
            #if p.poll() : break
            #print '==>',fs
            if p.stdout in fs[0]:
                #content = p.stdout.read()
                #for tmp in lines:
                content = p.stdout.readline()
                if content:
                    tmp = content
                    if not no_output:
                        output += tmp
                        pass
                        #print('[%d]%s'%(len(tmp),tmp))
                    if tmp.endswith('\r\n'):
                        tmp = tmp[:-2]
                        pass
                    elif tmp.endswith('\n'):
                        tmp = tmp[:-1]
                        pass
                        #plogger.debug(tmp)
                    if hasATError(tmp):
                        plogger.error(tmp)
                        pass
                    elif hasATWarning(tmp):
                        plogger.warning(tmp)
                        pass
                    elif hasATInfo(tmp):
                        plogger.info(tmp)
                        pass
                    else:
                        plogger.debug(tmp)
                        pass
                #if len(lines) == 0 :
                else:
                    #print 'end'
                    #print time.time()
                    while None == p.poll(): pass
                    break
            elif p.stderr in fs[0]:
                #print "!!!!!!!!!!!!!!!"
                #lines = p.stdout.readlines()
                #for tmp in lines:
                #content = p.stdout.read()
                content = p.stderr.readline()
                if content:
                    tmp = content.strip()
                    if not no_output:
                        output += tmp
                        pass
                        #plogger.error(tmp)
                    #plogger.debug(tmp)
                    #print('[%d]%s'%(len(tmp),tmp))
                    if tmp.endswith('\r\n'):
                        tmp = tmp[:-2]
                        pass
                    elif tmp.endswith('\n'):
                        tmp = tmp[:-1]
                        pass
                    if hasATError(tmp):
                        plogger.error(tmp)
                        pass
                    elif hasATWarning(tmp):
                        plogger.warning(tmp)
                        pass
                    elif hasATInfo(tmp):
                        plogger.info(tmp)
                        pass
                    else:
                        plogger.debug(tmp)
                        pass
                #if len(lines) == 0 :
                else:
                    #print 'end'
                    #print time.time()
                    while None == p.poll(): pass
                    break
            else:
                #print 'Timeout'
                #os.system('ps -f')
                s = os.popen('ps -eLf| grep -v grep| grep %s |grep sleep' % p.pid).read()

                if len(s.strip()):
                    plogger.info('No output in sleep : ' + s)
                    continue

                plogger.error('Timeout ' + str(to) + ' seconds without any output!')
                plogger.info(os.popen('ps -p ' + str(p.pid)).read())
                plogger.info('Dump all process in current terminal before kill : \n' + os.popen('ps T -LF ').read())
                plogger.info('Dump system info before kill : \n' + os.popen('free -m;top -b -n 1').read())

                p.kill()

                #os.kill(p.pid, signal.SIGKILL)
                break
                #timeout = timeout - (time.time() - while_begin)
            # Check the total timeout
            dur = time.time() - while_begin
            if timeout > 0 and dur > timeout:
                plogger.error('The subprocess is timeout more than ' + str(timeout))
                break
            # return
        rc = p.poll()
        # close all fds
        p.stdin.close()
        p.stdout.close()
        p.stderr.close()
        plogger.info('return value : %s' % str(rc))

    except Exception, e:
        plogger.error('Exception : ' + str(e))
        rc = False
        #print('====AT_INFO:finial output id : %s' % id(output))
    return rc, output


def start_async_subproc(cmd, plogger=None):
    """
    subprogress to run command
    """
    rc = None
    output = ''
    if not plogger: plogger = logging.getLogger()
    #
    plogger.info('start async subproc : ' + cmd)

    try:
        #
        bShell = True
        p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True,
                             shell=bShell)
        pi, po, pe = p.stdin, p.stdout, p.stderr
        rc = p
        msg = os.popen('ps | grep -v grep | grep  ' + str(p.pid)).read()
        plogger.info(msg)
        #exit(1)
    except Exception, e:
        plogger.error('Exception : ' + str(e))
        rc = False

    return rc


def stop_async_subporc(p, plogger=None):
    rc = None
    #exit(0)
    if not isinstance(p, subprocess.Popen):
        plogger.error('stop async subproc : Bad argument, expect a subprocess.Popen instance!')
        return rc
    inf = os.popen('ps aux | grep -v grep | grep ' + str(p.pid)).read()
    plogger.info('stop async subproc : ' + inf)
    try:
        p.terminate()
        #p.kill()
        #rc = p.wait()
        to = 15
        for i in range(to):
            time.sleep(1)
            rc = p.poll()
            if rc is not None:
                break


        # force to kill the progress
        if rc == None:
            plogger.info('kill async subproc : ' + inf)
            p.kill()
            for i in range(to):
                time.sleep(1)
                rc = p.poll()
                if rc is not None:
                    break
                pass
            if rc == None:
                plogger.info('kill subproc : ' + inf)
                os.system('kill ' + str(p.pid))
                pass
            else:
                plogger.info('async subproc is killed by p.kill()')
            pass
        else:
            plogger.info('async subproc is terminated')
            pass

        p.stdin.close()
        p.stdout.close()
        p.stderr.close()

        rc = p.returncode
    except Exception, e:
        plogger.error('Exception : ' + str(e))
        rc = -1
    return rc


def test():
    """
    """
    print('---> Test')

    logger = logging.getLogger("TEST")
    logger.setLevel(logging.DEBUG)
    stdhdlr = logging.StreamHandler(sys.stdout)
    #FORMAT = '[%(levelname)s] %(message)s'
    FORMAT = '%(message)s'
    stdhdlr.setFormatter(logging.Formatter(FORMAT))
    logger.addHandler(stdhdlr)

    r, o = subproc('ping 192.168.20.106 -c 3', timeout=60, plogger=logger, timeout_no_output=30)

    print('==DONE==')
    pass


if __name__ == '__main__':
    """
    """
    test()
