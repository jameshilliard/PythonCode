#!/usr/bin/python
import os,sys,re,time
from optparse import OptionParser
from pexpect import run
def parseCommandLine():
    """
    parse command line
    """
    usage = "usage: %prog [options]\n"
    usage += ('\nGet more info with command : pydoc ' + os.path.abspath(__file__) + '\n')
    parser = OptionParser(usage=usage)
    parser.add_option("-t", "--dut type", dest="dut_type",
                            help="Specify current DUT type.")
    parser.add_option("-w", "--dut ipv6 WAN type", dest="wan_type",
                            help="Specify the DUT ipv6 WAN type." )
    parser.add_option("-l", "--dut ipv6 LAN type", dest="client_type",
                            help="Specify ipv6 LAN type:stateless or stateful.")
    parser.add_option("-n", "--negative useage", dest="isNegativeTest",action="store_true",default=False,
                            help="negative useage.")
    parser.add_option("-d","--debug",dest="isDebug",action="store_true",default=False,
                            help="Specify debug mode.")
    parser.add_option("-o", "--output file",dest="log_name",default='DUT_ipv6_Setup.log',
                            help="Output file to save file.")
    parser.add_option("-r", "--log path", dest="file_path",
                            help="Redirect log file directory.")
    parser.add_option("-f", "--CLI files", dest="cli_files_list",action="append",
                            help="Specify the CLI commands files.")
    (options, args) = parser.parse_args()

    if not options.wan_type and not options.client_type and  options.cli_files_list is None:
        print 'AT_ERROR : ==> Not specified any  cli command to execute,please get more information for help'
        parser.print_help()
        exit(1)
    if not options.wan_type or not options.client_type and  options.cli_files_list is not None:
        print 'AT_warning : ==>','Not specified DUT WAN or LAN ipv6 settings...,use command files that -f option assigned.'
        parser.print_help()
    if not options.dut_type:
        print 'AT_warning : ==>','Not specified current DUT type,use environment value U_DUT_TYPE...'
        options.dut_type=os.getenv('U_DUT_TYPE')

    if not options.cli_files_list:
        print 'Not specified any CLI file...'
    if options.isDebug:
        print '==>%s'%options.cli_files_list

    return options

def read_cmd_files(filename,dut_type,debug=False):
    all_cmd=''
    filepath='/root/automation/testsuites/2.0/' + dut_type +'/cfg/ipv6/'
    cmd_file=filepath+filename
    if debug:print 'So will execute the %s commands.'%cmd_file
    fd = open(cmd_file, 'r')
    lines = fd.readlines()
    fd.close()
    for line in lines:
        line = line.strip()
        m = r'\$.*'
        n = r'[^\$].*'
        rc = re.search(m, line)
        if  rc is not None and len(rc.group().split(',')) >= 1:
            if debug:print   'line======>%s'%line
            for var in rc.group().split(','):
                if debug:print   'var is ====>%s'%var
                env_var = re.search(n,var).group()
                if debug:print env_var
                env_val = os.getenv(env_var)
                if not env_val :
                    if debug:print 'Please specify the $%s in ~/cfg/tst.cfg'%env_var
                    sys.exit(1)
                else :
                    line = line.replace(var,env_val)
                    if debug:print line
        all_cmd += '-v "' + line + '" '
    return all_cmd

def main():
    all_cmd = ''
    opts = parseCommandLine()

    if opts.dut_type == 'BHR2':
        all_cmd = "-v 'system' -v 'shell' "  

    if opts.isDebug:
        print "options is ==>:%s"%opts
        print "DUT current flatform is %s."%opts.dut_type
        print "DUT ipv6 WAN type is %s..."%opts.wan_type
        print "DUT ipv6 LAN type is %s..."%opts.client_type
    if opts.wan_type:
        print 'Add DUT WAN settings cli commands to all cmd...'
        all_cmd +=  read_cmd_files(opts.wan_type,opts.dut_type,opts.isDebug)
    if opts.client_type:
        print 'Add DUT LAN settings cli commands to all cmd...'
        all_cmd += read_cmd_files(opts.client_type,opts.dut_type,opts.isDebug)
    if opts.cli_files_list is not None :
        print 'The cli file list is ==><%s>'%opts.cli_files_list
        print 'Add DUT IPv6 settings cli commands use option \"-f\" specified to all cmd...'
        for commands in opts.cli_files_list:
            all_cmd += read_cmd_files(commands,opts.dut_type,opts.isDebug)
    all_cmd += ' -v "cli -f  InternetGatewayDevice"'
    print 'The command <%s> will execute...'%all_cmd
    print 'Current time is==>:<%s>'%time.ctime()
    execute_cmd_vars= '$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/telnet_clicmd.log  -y  telnet -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0  -v "sh" '
    begintimes = 0
    execute_cmd = os.path.expandvars(execute_cmd_vars) + all_cmd
    waitingTime = 15
    rts = 6
    while 1:
        cmd_result, cmd_status = run(execute_cmd, withexitstatus=True, timeout=1200, logfile=sys.stdout)
        if cmd_status:
            begintimes += 1
            if opts.isDebug:
                print 'The cmd executed failed at <%s> times...,will retry it after <%s> seconds' % (begintimes, waitingTime)
            time.sleep(waitingTime)
            if begintimes == rts:
                print 'Failed executed the cmd after retry %s times!' % (rts)
                break
            else:
                continue
        else:
            print 'The cmd executed pass at %s times!' % (begintimes)
            break

    sys.exit(cmd_status)



if __name__ == '__main__':
    """
    """
    main()
























