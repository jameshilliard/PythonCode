#!/usr/bin/python -u
# -*- coding: utf-8 -*-

from optparse import OptionParser
from pprint import pprint

import sys
import os
import time

import gobject
import dbus
import dbus.service
import dbus.mainloop.glib

import signal

sys.path.append(os.path.expandvars('../ATE_DBUS'))

import client, server


class ATE_assist():
    """
    this is a tool that will be launched by ATE to assist ATE , doing some  
    job such as reporting bug on Agile , updating testplan status on testlink ,
    [email test report] , [updating DB] (TODO)
    """

    p_arr = {}
    mainProcID = None

    def __init__(self):
        """
        """

    def start_DBUS_server(self):
        """
        to start DBUS server
        """
        Dbus_PATH = '/com/example/TestService/object/automation'
        Dbus_IFACE = 'com.example.TestService.automation'
        Dbus_NAME = 'com.example.TestService.automation'

        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

        bus = dbus.SessionBus()

        name = dbus.service.BusName(Dbus_NAME, bus)

        service = server.DbusServer(bus, Dbus_PATH)
        loop = gobject.MainLoop()
        print 'SERV : server is working...'
        loop.run()


    def load_ENV(self):
        """
        to load ATE runtime env
        """

    def import_tlopr(self):
        """
        to import tl_operator when necessary
        """

    def import_redmine(self):
        """
        to import at_redmine when necessary
        """

    def process_redmine(self):
        """
        processing Agile reporting
        """

        print 'in function process_redmine'

    def process_testlink(self):
        """
        process testlink updating
        """

        print 'in function process_testlink'

    def process_mail(self):
        """
        TODO
        """

        print 'in function process_mail'


    def sending_DBUS_msg(self):
        """
        to send a DBUS message 
        """

    def msg_dispatcher(self, msg):
        """
        to dispatch message received from DBUS
        """

        print 'in function msg_dispatcher'

        msg = msg
        if msg.has_key('type'):
            mtype = str(msg['type'])
            if mtype == 'Agile':
                self.process_redmine()
            elif mtype == 'testlink':
                self.process_testlink()
            elif mtype == 'mail':
                self.process_mail()


    def waiting_DBUS_msg(self):
        """
        to wait for message from DBUS
        supposed to be main entry
        """

        print 'RECV : in function waiting_DBUS_msg'

        client.receive_signal(receive_handle_function=self.msg_dispatcher, receive_signal_name="ATESignal")

    def emit_dbus_signal(self, msg):
        """
        """

        client.emit_signal(msg=msg)
        time.sleep(10)
        print 'done emit signal'

    def sending_msg(self):
        msgs = [{'type': 'testlink', 'ffff': 'ttt', 'eeeeee': ['hhhhhh', 'iiii']},
                {'type': 'Agile', 'ffff': 'ttt', 'eeeeee': ['hhhhhh', 'iiii']},
                {'type': 'mail', 'ffff': 'ttt', 'eeeeee': ['hhhhhh', 'iiii']}]

        for msg in msgs:
            print 'emit:'
            pprint(msg)
            self.emit_dbus_signal(msg)

    def myFork(self, plist):
        """
        """
        for p in plist:
            print 'INFO : forking ', p

            child_pid = os.fork()
            time.sleep(2)

            if child_pid == 0:
                if p == 'dbus_server':
                    print 'in child process for dbus_server'
                    self.start_DBUS_server()
                elif p == 'dbus_recv':
                    print 'in child process for dbus_recv'
                    self.waiting_DBUS_msg()
                elif p == 'dbus_emit':
                    print 'in child process for dbus_emit'
                    self.sending_msg()
            else:
                print '%s running as pid %s' % (p, str(child_pid))
                self.p_arr[p] = child_pid


    def sighandle(self, signum=0, e=0):
        """handle signal"""
        currPID = os.getppid()

        if str(currPID) == str(self.mainProcID):

            for p in self.p_arr:

                print 'killing forked subprocess %s : %s' % (p, self.p_arr[p])

                if p == 'dbus_server':
                    print 'going to kill dbus_server'
                    time.sleep(2)
                    print 'killing dbus_server'
                os.kill(self.p_arr[p], signal.SIGTERM)

        sys.exit(2)


def main():
    """
    main entry
    """

    sig_ids = [2, 4, 6, 8, 11, 15]

    mainProcID = os.getppid()
    print 'main procID:', mainProcID
    usage = "usage not ready yet \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-d", "--dbus", dest="dbus", action='store_true',
                      help="example")

    (options, args) = parser.parse_args()

    if not len(args) == 0:
        print args

    if options.dbus:
        is_dbus = True
        print is_dbus

    p_list = ['dbus_server', 'dbus_recv', 'dbus_emit']
    AA = ATE_assist()
    AA.mainProcID = mainProcID
    for sig in sig_ids:
        signal.signal(sig, AA.sighandle)

    AA.myFork(p_list)

    try:
        currProcID = os.getppid()
        if currProcID == mainProcID:
            procID, procStaus = os.waitpid(AA.p_arr['dbus_emit'], 0)

            if procStaus == 0:
                print 'process %s quit normally : %s' % (procID, procStaus)

                for p in p_list:
                    if not p == 'dbus_emit':
                        print 'killing %s of pid %s' % (p, AA.p_arr[p])
                        os.kill(AA.p_arr[p], signal.SIGTERM)
            else:
                print 'process %s quit abnormally : %s' % (procID, procStaus)

                for p in p_list:
                    if not p == 'dbus_emit':
                        print 'killing %s of pid %s' % (p, AA.p_arr[p])
                        os.kill(AA.p_arr[p], signal.SIGTERM)
    except Exception, e:
        print 'Exception :', str(e) + str(os.getppid())

        for p in p_list:
            print 'killing %s of pid %s' % (p, AA.p_arr[p])
            os.kill(AA.p_arr[p], signal.SIGTERM)


###################################################
if __name__ == '__main__':
    """
    """

    main()
