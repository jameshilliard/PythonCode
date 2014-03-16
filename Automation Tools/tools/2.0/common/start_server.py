#!/usr/bin/python -u
import os, select, subprocess, time, re
from optparse import OptionParser
import datetime
import clicmd


class Start_Server():
    """
    """
    protocol = ''
    current_vid = ''

    def __init__(self, vlan='', protocol=''):
        """
        """
        self.protocol = protocol
        self.current_vid = vlan
        if not self.protocol:
            print 'AT_ERROR : protocol is Null,Please define it IPOE or PPPOE with -p!'
            exit(1)
        if not self.current_vid:
            print 'AT_ERROR : vlan is Null,Please define it with -v!'
            exit(1)

        pass

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


    def cli_command(self, cmd_list, host, port, username, password, output='/tmp/cli_command.log', cli_type='ssh',
                    rest_time=None):
        """
        True False
        """

        CLI = clicmd.clicmd(has_color=False)

        res, last_error = CLI.run(cmd_list, cli_type, host, port, username, password, cli_prompt=None, mute=False,
                                  timeout=600, rest_time=rest_time)

        m_return_code = r'last_cmd_return_code:(\d)'

        if res:

            for r in res:
                rc = re.findall(m_return_code, r)
                if len(rc) > 0:
                    print 'EACH command result :', rc
                    return_code = rc[0]
                    if str(return_code) != '0':
                        all_rc = False
                        return all_rc

            CLI.saveResp2file(output)
        else:
            print 'AT_ERROR : cli command failed'
            return False

        return True

    def restart_wan_server(self):
        """
        True False
        """
        cmd_list = 'cd /root/START_SERVERS/;'
        cmd_list += 'sed -i \"s/^VLAN_LIST.*/VLAN_LIST ' + self.current_vid + '/g\" config_net.conf;'
        cmd_list += './config_net.sh'

        host = os.getenv('G_HOST_IP1')
        port = '22'
        username = os.getenv('G_HOST_USR1')
        password = os.getenv('G_HOST_PWD1')

        c_list = [cmd_list]

        line_rc = self.cli_command(c_list, host, port, username, password)

        if line_rc:
            rc = self.disable_no_use_wan_server(self.protocol)

            if rc > 0:
                print 'AT_ERROR : disable_no_use_wan_server failed'
                return False

        return line_rc


    def disable_no_use_wan_server(self, protocol):
        self.protocol = protocol
        print 'protocol :' + self.protocol

        cmd = 'bash $U_PATH_TBIN/setupWANServer.sh -e "" -d "dhcpd,pppoe-server"'

        print cmd

        rc, ouput = self.subproc(cmd)

        if self.protocol:
            self.protocol = self.protocol.upper()
            if self.protocol == 'IPOE' or self.protocol == 'STATIC':
                enable_server = 'dhcpd'
            elif self.protocol == 'PPPOE':
                enable_server = 'pppoe-server'
            elif self.protocol == 'ALL':
                enable_server = 'dhcpd,pppoe-server'
            else:
                print 'AT_WARING : can not enable WAN server <' + self.protocol + '> in this tool'
                return 0

            cmd = 'bash $U_PATH_TBIN/setupWANServer.sh -d "" -e "' + enable_server + '"'

            print cmd

            rc, ouput = self.subproc(cmd)
        else:
            print 'AT_WARNING : no WAN server need disable'
            return 0

        return rc


def main():
    """
    Entry if not imported
    """

    usage = "usage not ready yet \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-p", "--protocol", dest="protocol",
                      help="protocol , IPoE PPPoE , etc.")
    parser.add_option("-v", "--vlan", dest="vlan",
                      help="vlan")

    (options, args) = parser.parse_args()

    protocol = ''
    vlan = ''

    if not len(args) == 0:
        print args

    if options.protocol:
        protocol = options.protocol

    if options.vlan:
        vlan = options.vlan
    rc = False
    l_swap = Start_Server(vlan=vlan, protocol=protocol)
    rc = l_swap.restart_wan_server(vlan)
    return rc


if __name__ == '__main__':
    rcc = main()
    if rcc:
        exit(1)
    
