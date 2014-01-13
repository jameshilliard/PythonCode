#!/usr/bin/python -u
import os, select, subprocess, time, re
from optparse import OptionParser
import datetime


class CheckLayer2():
    """
    """
    linemode = ''
    bonding = False

    def __init__(self, linemode='', bonding=False):
        """
        """
        self.linemode = linemode
        self.bonding = bonding
        if not self.linemode:
            print 'AT_ERROR : linemode is Null,Please define it with ADSL,VDSL,ETH!'
            exit(1)


    def validateL2(self):
        """
        True False
        """

        #        if os.getenv('U_DUT_TYPE') == 'PK5K1A':
        #            print 'AT_INFO : not do l2 checking on PK5K1A'
        #            return True

        dest_L2 = self.linemode
        print 'dest_L2 : ', dest_L2

        validate_retry = 30
        # m_status_up = r'Config\.Status=Up'
        m_status = r'' + dest_L2 + '=Up'

        m_bonding = ''

        if not self.linemode == 'ETH':
            m_bonding = r'' + dest_L2 + '_BONDING'

        if self.bonding:
            if os.getenv('U_DUT_TYPE') == 'TDSV2200H':
                print 'AT_INFO m_bonding for tdsv2200h is ', m_bonding
            else:
                m_bonding += '=1'
            m_status_2 = r'' + dest_L2 + '2=Up'
        else:
            if os.getenv('U_DUT_TYPE') == 'TDSV2200H':
                print 'AT_INFO m_bonding for tdsv2200h is ', m_bonding
            else:
                m_bonding += '=0'

        status_ready = False

        # added by rayofox 2013-05-20 : timeout 1 hours to training Layer2
        dtstart = datetime.datetime.now()

        for i in range(validate_retry):
            print 'AT_INFO : validating line status tempt : %s' % (str(i + 1))
            dtnow = datetime.datetime.now()
            if (dtnow - dtstart).total_seconds() > 3600:
                print('AT_WARNING : Timeout to training Layer2 than 1 hours')
                break

            cli_dut_cmd = 'bash $U_PATH_TBIN/cli_dut.sh -v layer2.stats -o /tmp/l2stats.log'
            rc_cli, output_cli = self.subproc(cli_dut_cmd)
            # rcc = self.cli_command(cmd_list, host, port, username, password, output='/tmp/cli_command.log', cli_type='telnet')
            if rc_cli == 0:
                output = ''

                fn = open('/tmp/l2stats.log', 'r')
                lines = fn.readlines()
                fn.close()

                for line in lines:
                    line = line.strip()
                    output += line + '\n'

                if not self.linemode == 'ETH':

                    rc_bonding = re.findall(m_bonding, output)
                    if len(rc_bonding) > 0:
                        print rc_bonding[0]
                        print 'AT_INFO : bonding status ok'
                        #                    status_ready = True
                        #                    break
                        rc_status = re.findall(m_status, output)

                        if len(rc_status) > 0:
                            print rc_status[0]
                            print 'AT_INFO : line status ready.'
                            if self.bonding:
                                rc_status_2 = re.findall(m_status_2, output)
                                if len(rc_status_2) > 0:
                                    print rc_status_2[0]
                                    print 'AT_INFO : line 2 status ready'
                                    status_ready = True
                                    break
                                else:
                                    print 'AT_INFO : line 2 status not ready'
                                    print 'AT_INFO : wait 30 second and check again'
                                    time.sleep(30)

                            else:
                                if os.getenv('U_DUT_TYPE') == 'TDSV2200H':
                                    #   ADSL2=NoSignal
                                    m_status_2 = r'' + dest_L2 + '2=Disabled' + '|' + dest_L2 + '2=NoSignal'
                                    rc_status_2 = re.findall(m_status_2, output)

                                    if len(rc_status_2) > 0:
                                        print rc_status_2[0]
                                        print 'AT_INFO : line 2 status ready'
                                        status_ready = True
                                        break
                                    else:
                                        print 'AT_INFO : line 2 status not ready'
                                        print 'AT_INFO : wait 30 second and check again'
                                        time.sleep(30)
                                else:
                                    print 'AT_INFO : line status ok'
                                    status_ready = True
                                    break

                        else:
                            print 'AT_INFO : line status not ready.'
                            # print output
                            print 'AT_INFO : wait 30 second and check again'
                            time.sleep(30)

                    else:
                        print 'AT_INFO : bonding status not ready'
                        print 'AT_INFO : wait 30 second and check again'
                        time.sleep(30)

                else:
                    rc_status = re.findall(m_status, output)

                    if len(rc_status) > 0:
                        print rc_status[0]
                        print 'AT_INFO : line status ready.'
                        if self.bonding:
                            rc_status_2 = re.findall(m_status_2, output)
                            if len(rc_status_2) > 0:
                                print rc_status_2[0]
                                print 'AT_INFO : line 2 status ready'
                                status_ready = True
                                break
                            else:
                                print 'AT_INFO : line 2 status not ready'
                                print 'AT_INFO : wait 30 second and check again'
                                time.sleep(30)

                        else:
                            print 'AT_INFO : line status ok'
                            status_ready = True
                            break

                    else:
                        print 'AT_INFO : line status not ready.'
                        # print output
                        print 'AT_INFO : wait 30 second and check again'
                        time.sleep(30)

            else:
                print 'AT_ERROR : cli command failed'
                rc_ping = self.check_lan_connection()

                if not rc_ping:
                    print 'AT_WARNING : DUT br0 not reachable !'
                    print 'AT_INFO : wait 30 second and check again'
                    time.sleep(30)
                else:
                    print 'AT_INFO : wait 30 second and check again'
                    time.sleep(30)

        return status_ready

    def check_lan_connection(self):
        """
        """

        eth1 = os.getenv('G_HOST_IF0_1_0', 'eth1')

        wan_conn_cmd = 'python $U_PATH_TBIN/verifyPing.py -d $G_PROD_IP_BR0_0_0 -I ' + eth1 + ' -t ' + '1200' + ' -l $G_CURRENTLOG'
        rc, out = self.subproc(wan_conn_cmd)

        if rc != 0:
            print 'AT_ERROR : ping br0 failed'
            return False
        else:
            print 'AT_INFO : ping br0 passed'
            return True

    def subproc(self, cmdss, timeout=3600):
        """
        subprogress to run command
        0 = pass
        not 0 = fail
        """
        print 'in subproc'
        rc = None
        output = ''

        print ' Commands to be executed :', cmdss

        all_rc = 0
        all_output = ''

        cmds = cmdss.split(';')

        for cmd in cmds:
            if not cmd.strip() == '':
                print 'INFO : executing > ', cmd

                try:
                    #
                    p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                                         close_fds=True, shell=True)
                    while_begin = time.time()
                    while True:

                        to = 600
                        fs = select.select([p.stdout, p.stderr], [], [], to)

                        if p.stdout in fs[0]:
                            tmp = p.stdout.readline()
                            if tmp:
                                output += tmp
                                print 'INFO : ', tmp
                            else:
                                while None == p.poll(): pass
                                break
                        elif p.stderr in fs[0]:
                            tmp = p.stderr.readline()
                            if tmp:
                                output += tmp
                                print 'ERROR : ', tmp
                            else:
                                while None == p.poll(): pass
                                break
                        else:
                            s = os.popen('ps -f| grep -v grep |grep sleep').read()

                            if len(s.strip()):
                                continue

                            p.kill()

                            break
                            # Check the total timeout
                        dur = time.time() - while_begin
                        if dur > timeout:
                            print 'ERROR : The subprocess is timeout due to taking more time than ', str(timeout)
                            break
                    rc = p.poll()
                    # close all fds
                    p.stdin.close()
                    p.stdout.close()
                    p.stderr.close()

                    print 'INFO : return value', str(rc)

                except Exception, e:
                    print 'ERROR :Exception', str(e)
                    rc = 1

            if not rc:
                rc = 0

            all_rc += rc
            all_output += output

        return all_rc, all_output


def main():
    """
    Entry if not imported
    """

    usage = "usage not ready yet \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-l", "--linemode", dest="linemode",
                      help="linemode , ADSL VDSL or ETH.")
    parser.add_option("-b", "--bonding", dest="bonding", action='store_true', default=False,
                      help="whether it is in bonding mode")
    (options, args) = parser.parse_args()
    linemode = ''
    bonding = False

    if not len(args) == 0:
        print args
    if options.linemode:
        linemode = options.linemode
    if options.bonding:
        bonding = True
    rc = False
    clayer2 = CheckLayer2(linemode=linemode, bonding=bonding)
    rc = clayer2.validateL2()
    return rc


if __name__ == '__main__':
    rc = main()
    if rc:
        exit(0)
    else:
        exit(1)
    
