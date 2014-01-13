#!/usr/bin/python
import os,sys,re
import pexpect
from optparse import OptionParser
def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ('\nGet more info with command : pydoc ' + os.path.abspath(__file__) + '\n')
    parser = OptionParser(usage=usage)
    parser.add_option("-d", "--destination", dest="destination_ip_address",
                            help="target address.")
    parser.add_option("-t", "--timeout", dest="timeout",type='int',default=30,
                            help="Time out for command executed by verifyPing.py,default is 30s." )
    parser.add_option("-I", "--interface", dest="interface",
                            help="interface.")
    parser.add_option("-n", "--negative useage", dest="isNegativeTest",action="store_true",default=False,
                            help="negative useage.")
    parser.add_option("-o", "--output file",dest="log_path_name",default='ping.log',
                            help="output file to save file.")    
    parser.add_option("-l", "--Redirect stdout to the path", dest="file_path",
                            help="log file directory.")
    parser.add_option("-c", "--packet count", dest="packet_count",
                            help="specify how many packets to send.")

    parser.add_option("-k", "--verify passed continue execute", dest="isExitIfPassed",action="store_true",default=False,
                            help="verify passed continue execute.")

    (options, args) = parser.parse_args()
    if not options.destination_ip_address :
        print '==','loss destination'
        parser.print_help()
        exit(1)
    return options

parseCommandLine()

def spawnCommand(cmd,timeout,isNegativeTest=False,userExp=''):
    exp = [userExp,pexpect.TIMEOUT]
    cmdClass = pexpect.spawn(cmd,logfile=sys.stdout,timeout=float(timeout))
    index = cmdClass.expect(exp)
    print "Index is ==>%s"%index
    if not isNegativeTest:
        print '%s positive test......'%cmd
        if index == 0:
            print 'Command:%s executed succeed,positive test passed!'%cmd
            cmdResultLog = cmdClass.before + cmdClass.after 
            print cmdResultLog
            return  cmdResultLog,True
        elif index == 1:
            print 'AT ERROR: %s time out,so command executed failed!'%cmd
            cmdResultLog = cmdClass.before
            return  cmdResultLog,False           
    if isNegativeTest:
        print '%s negative test......'%cmd
        if index == 0:
            print 'AT ERROR:%s executed succeed,negative test failed!'%cmd
            cmdResultLog = cmdClass.before + cmdClass.after
            return  cmdResultLog,False
        elif index == 1:
            print 'Command:%s time out,so command negative test passed'%cmd
            cmdResultLog = cmdClass.before
            return  cmdResultLog,True

def main() :
    """
    main entry
    """
    opts = parseCommandLine()
    if opts.timeout:
        opts.timeout += 1
    if opts.isExitIfPassed:
        userExp = 'min/avg/max/mdev.*'
        opts.packet_count = int(opts.timeout)-1
    else:
        userExp = '64 bytes from .*'
    cmd = 'ping ' + opts.destination_ip_address
    if opts.interface:
        cmd += ' -I ' + opts.interface
    if opts.packet_count:
        cmd += ' -c ' + str(opts.packet_count)
    print 'Command is: %s'%cmd
    print opts.log_path_name

    cmdResult,cmdStatus = spawnCommand(cmd,opts.timeout,opts.isNegativeTest,userExp)
    print cmdStatus
    if opts.log_path_name:
        testFilePath,testFileName = os.path.split(opts.log_path_name)
        if len(testFilePath) == 0:
            testFilePath = os.getenv("G_CURRENTLOG","/tmp")
    AllFile = os.path.join(testFilePath,testFileName)
    fout = open(AllFile,'w')
    fout.write(cmdResult)
    fout.close
    if cmdStatus:
        exit(0)
    else:
        exit (1)
if __name__ == '__main__':
    """
    """
    main()
