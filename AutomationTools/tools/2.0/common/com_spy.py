#!/usr/bin/python
#coding=gb18030

import sys, threading, time;
import serial;
import binascii, encodings;
import re;
import socket;
import signal


class ReadThread:
    def __init__(self, Output=None, Port=0, Log=None, i_FirstMethod=True):
        self.l_serial = None;
        self.alive = False;
        self.waitEnd = None;
        self.bFirstMethod = i_FirstMethod;
        self.sendport = '';
        self.log = Log;
        self.output = Output;
        self.port = Port;
        self.re_num = None;

    def Output(self, msg):
        """
        """
        if not self.output is None:
            self.output.WriteText(u'to open/r/n');
        return

    def Log(self, msg):
        """
        """
        if not self.log is None:
            self.log.info(u'open');
        return

    def waiting(self):
        if not self.waitEnd is None:
            #self.waitEnd.wait();
            while True:
                rs = raw_input()

                rs += '\n'
                if len(rs) and self.l_serial.isOpen():
                    #print 'Send'
                    self.l_serial.write(rs)
                    self.l_serial.flushInput();
                    self.l_serial.flushOutput();

    def SetStopEvent(self):
        if not self.waitEnd is None:
            self.waitEnd.set();
        self.alive = False;
        self.stop();

    def start(self):
        self.l_serial = serial.Serial();
        self.l_serial.port = self.port;
        self.l_serial.baudrate = 115200;
        self.l_serial.timeout = 2;

        self.re_num = re.compile('/d');

        try:
            if not self.output is None:
                self.output.WriteText(u'to open/r/n');
            if not self.log is None:
                self.log.info(u'open');
            print '----> to open'
            self.l_serial.open();
        except Exception, ex:
            print 'except ...'
            if self.l_serial.isOpen():
                self.l_serial.close()
            self.l_serial = None

            if not self.output is None:
                self.output.WriteText(u'Error : /r/n    %s/r/n' % ex);
            if not self.log is None:
                self.log.error(u'%s' % ex);
            return False;

        if self.l_serial.isOpen():
            print 'Open success'
            if not self.output is None:
                print '111'
                self.output.WriteText('create thread to recv data/r/n');
            if not self.log is None:
                print '222'
                self.log.info('x');

            print self.l_serial
            self.waitEnd = threading.Event();
            self.alive = True;
            self.thread_read = None;
            self.thread_read = threading.Thread(target=self.FirstReader);
            self.thread_read.setDaemon(1);
            self.thread_read.start();
            return True;
        else:
            print 'Open failed'
            if not self.output is None:
                self.output.WriteText(u'Port is not opened/r/n');
            if not self.log is None:
                self.log.info(u'Port is not opened');
            return False;

    def InitHead(self):

        try:
            time.sleep(3);
            if not self.output is None:
                self.output.WriteText(u'--Reading.../r/n');
            if not self.log is None:
                self.log.info(u'--Connecting...');
            self.l_serial.flushInput();
            #self.l_serial.write('/x11');
            #data = self.l_serial.read(10);
            #print '==|',binascii.b2a_hex(data)
        except ValueError, ex:
            if not self.output is None:
                self.output.WriteText(u'Error : /r/n    %s/r/n' % ex);
            if not self.log is None:
                self.log.error(u'%s' % ex);
            self.SetStopEvent();
            return;

        if not self.output is None:
            self.output.WriteText(u'Read.../r/n');
        if not self.log is None:
            self.log.info(u'-->read');
            self.output.WriteText(u'===================================/r/n');

    def SendData(self, i_msg):
        lmsg = '';
        isOK = False;
        if isinstance(i_msg, unicode):
            lmsg = i_msg.encode('gb18030');
        else:
            lmsg = i_msg;
        try:

            pass
        except Exception, ex:
            pass;
        return isOK;

    def FirstReader(self):
        data1 = '';
        isQuanJiao = True;
        isFirstMethod = True;
        isEnd = True;
        readCount = 0;
        saveCount = 0;
        RepPos = 0;



        #read Head Infor content
        self.InitHead();
        time_last = time.time()
        while self.alive:
            try:

                data = '';
                #n = 0

                #data = data + self.l_serial.read(n);
                n = self.l_serial.inWaiting();
                #print time.time()
                #print n
                if n:
                    data = data + self.l_serial.read(n);
                    #print '--->',binascii.b2a_hex(data)
                    print data,
                    #time.sleep(3)
                tt = time.time()
                if tt - time_last > 5:
                    time_last = tt
                    print 'alive...'
            except Exception, ex:
                if not self.log is None:
                    self.log.error(u'%s' % ex);

        self.waitEnd.set();
        self.alive = False;

    def stop(self):
        self.alive = False;
        self.thread_read.join();
        if self.l_serial.isOpen():
            self.l_serial.close();
            if not self.output is None:
                self.output.WriteText(u'Close : [%s] /r/n' % self.port);
            if not self.log is None:
                self.log.info(u'Close [%s]' % self.port);

    def printHex(self, s):
        s1 = binascii.b2a_hex(s);
        print s1;

    def sighandle(self, signum=0, e=0):
        """handle signal"""
        print 'i will kill myself'
        #print 'receive signal: %d at %s' % (signum, str(time.ctime(time.time())))

        self.stop()
        #self.m_exp.kill(9)
        sys.exit(2)


class myOutput():
    """
    """

    def __init__(self):
        """
        """
        pass

    def WriteText(self, msg):
        """
        """
        print msg

    #


if __name__ == '__main__':


    rt = ReadThread();
    signal.signal(15, rt.sighandle)
    signal.signal(2, rt.sighandle)
    signal.signal(6, rt.sighandle)
    signal.signal(8, rt.sighandle)
    signal.signal(4, rt.sighandle)
    signal.signal(11, rt.sighandle)

    #f = open("sendport.cfg", "r")
    #rt.sendport = f.read()
    rt.port = '/dev/ttyUSB0'
    MOP = myOutput()
    rt.output = MOP
    #f.close()
    try:
        if rt.start():
            rt.waiting();
            rt.stop();
        else:
            pass;
    except Exception, se:
        print str(se);

    if rt.alive:
        rt.stop();

    print 'End OK .';
    del rt; 
