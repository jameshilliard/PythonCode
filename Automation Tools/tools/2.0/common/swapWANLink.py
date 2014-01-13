#!/usr/bin/python -u
import os, select, subprocess, time, re
from optparse import OptionParser
import datetime
import SetDSLAM
import SetDSLAM_HuaWei
import SetDSLAM_Zyxel
import clicmd


class Link_Swap():
    """
    """
    is_config_load = False
    check_static = False
    l3only = False
    doreplace = True
    linemode = ''
    protocol = ''
    bonding = False
    checkmode = False
    setmode = False
    current_vid = ''
    tag = '0'
    post_file_loc = os.path.expandvars(
        '$SQAROOT/platform/$G_PFVERSION/$U_DUT_TYPE/config/$U_DUT_FW_VERSION/Precondition/NO-DETECT')

    TMP_DUT_WAN_LINK = ''
    TMP_DUT_WAN_ISP_PROTO = ''
    TMP_CUSTOM_WANINF = ''
    static_ip = ''
    static_mask = ''
    static_gw = ''
    static_dns1 = ''
    static_dns2 = ''
    # switch
    first_setting = ''
    second_setting = ''
    setting_idx = ''

    vb_involved = False
    dslam_bonding_bad = False
    in_route = False
    in_route_added = False

    reset_dslam_port = False
    vdslmode = '8a'
    _flag = os.getenv('U_CUSTOM_SET_DSLAM_OR_SWB', 'SWB')
    adslmode = 'adsl2+'
    pvc = os.getenv('U_DUT_DEF_VPI_VCI')
    connectport = '1'

    def __init__(self, linemode='', protocol='', tag='', bonding=False, checkmode=False, setmode=False,
                 reset_dslam_port=False, vdslmode='', adslmode='', pvc='', connectport=''):
        """
        """
        print 'in __init__'
        self.linemode = linemode
        self.protocol = protocol
        self.bonding = bonding
        self.checkmode = checkmode
        self.setmode = setmode
        self.tag = tag
        self.reset_dslam_port = reset_dslam_port
        if vdslmode:
            self.vdslmode = vdslmode
        if adslmode:
            self.adslmode = adslmode
        if pvc:
            self.pvc = pvc

        #if not self.pvc:
        #    print 'AT_ERROR : VPI/VCI is Null!'
        #    #exit(1)

        if connectport:
            self.connectport = connectport

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
        print 'in cli_command'

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

    def set_dslam(self):
        """
        """
        obj = SetDSLAM.SetDSLAM(linemode=self.linemode, tag=self.tag, bonding=self.bonding, vdslmode=self.vdslmode,
                                adslmode=self.adslmode, pvc=self.pvc, connectport=self.connectport)
        rc = obj.gogo()
        return rc

    def set_physical_line(self, linemode):
        """
        -d $U_CUSTOM_WECB_IP
        -p 22
        -u $U_CUSTOM_WECB_USR
        -p $U_CUSTOM_WECB_PSW

        True False
        """

        # U_CUSTOM_TESTCLASS = "performance-ixia"
        U_CUSTOM_TESTCLASS = os.getenv('U_CUSTOM_TESTCLASS', 'None')

        if U_CUSTOM_TESTCLASS == 'performance-ixia' or U_CUSTOM_TESTCLASS == 'performance-veriwave':
            print 'INFO : doing performance test'
            if linemode != 'reboot':
                print 'INFO : skip phyx line setting in performance testing'
                return True

        cmdlist = []
        host = os.getenv('U_CUSTOM_WECB_IP')
        if host == '':
            print 'AT_ERROR : U_CUSTOM_WECB_IP must be specified'
            return False

        #   , cli_type='ssh'


        port = '22'
        cli_type = 'ssh'

        wecb_version = os.getenv('U_CUSTOM_WECB_VER', '1.0')

        if wecb_version == '2.0':
            print 'AT_INFO : set port to 23 , set cli_type to telnet'
            port = '23'
            cli_type = 'telnet'

        username = os.getenv('U_CUSTOM_WECB_USR')
        if username == '':
            username = 'root'
        password = os.getenv('U_CUSTOM_WECB_PSW')
        if password == '':
            password = 'admin'

        all_rc = True

        if linemode == 'ADSL':
            if self.bonding:
                if self.tag == '0':
                    linemode = 'ab'
                else:
                    linemode = 'abt'
            else:
                if self.tag == '0':
                    linemode = 'as'
                else:
                    linemode = 'ast'
        elif linemode == 'VDSL':
            if self.bonding:
                if self.tag == '0':
                    linemode = 'vb'
                else:
                    linemode = 'vbt'
            else:
                if self.tag == '0':
                    linemode = 'vs'
                else:
                    linemode = 'vst'
        elif linemode == 'ETH':
            linemode = 'eth'

        #

        if linemode == 'off':
            print 'AT_INFO : shutting all wan link down'
            cmdlist.append('switch_controller -n')
            cmdlist.append('switch_controller -e 0')

        elif linemode == 'reboot':
            print 'AT_INFO : down and up DUT\'s power supply'
            cmdlist.append('switch_controller -p 0')
            cmdlist.append('switch_controller -p 0')
            cmdlist.append('switch_controller -p 0')
            cmdlist.append('switch_controller -p 1')
            cmdlist.append('switch_controller -p 1')
            cmdlist.append('switch_controller -p 1')
        elif linemode == 'as':
            cmdlist.append('switch_controller -e 0')
            cmdlist.append('switch_controller -m ADSL -B 0 -l 1')
        elif linemode == 'ab':
            cmdlist.append('switch_controller -e 0')
            cmdlist.append('switch_controller -m ADSL -B 1')
        elif linemode == 'vs':
            cmdlist.append('switch_controller -e 0')
            cmdlist.append('switch_controller -m VDSL -B 0 -l 1')
        elif linemode == 'vb':
            cmdlist.append('switch_controller -e 0')
            cmdlist.append('switch_controller -m VDSL -B 1')
        elif linemode == 'ast':
            U_CUSTOM_ALIAS_AST = os.getenv('U_CUSTOM_ALIAS_AST')
            if U_CUSTOM_ALIAS_AST:
                cmdlist.append('switch_controller -e 0')
                cmdlist.append('switch_controller -m ' + U_CUSTOM_ALIAS_AST)
            else:
                print 'AT_ERROR : must specify var : %s' % (U_CUSTOM_ALIAS_AST)
                return False
        elif linemode == 'abt':
            U_CUSTOM_ALIAS_ABT = os.getenv('U_CUSTOM_ALIAS_ABT')
            if U_CUSTOM_ALIAS_ABT:
                cmdlist.append('switch_controller -e 0')
                cmdlist.append('switch_controller -m ' + U_CUSTOM_ALIAS_ABT)
            else:
                print 'AT_ERROR : must specify var : %s' % (U_CUSTOM_ALIAS_ABT)
                return False
        elif linemode == 'vst':
            U_CUSTOM_ALIAS_VST = os.getenv('U_CUSTOM_ALIAS_VST')
            if U_CUSTOM_ALIAS_VST:
                cmdlist.append('switch_controller -e 0')
                cmdlist.append('switch_controller -m ' + U_CUSTOM_ALIAS_VST)
            else:
                print 'AT_ERROR : must specify var : %s' % (U_CUSTOM_ALIAS_VST)
                return False
        elif linemode == 'vbt':
            U_CUSTOM_ALIAS_VBT = os.getenv('U_CUSTOM_ALIAS_VBT')
            if U_CUSTOM_ALIAS_VBT:
                cmdlist.append('switch_controller -e 0')
                cmdlist.append('switch_controller -m ' + U_CUSTOM_ALIAS_VBT)
            else:
                print 'AT_ERROR : must specify var : %s' % (U_CUSTOM_ALIAS_VBT)
                return False
        elif linemode == 'eth':
            cmdlist.append('switch_controller -n')
            cmdlist.append('switch_controller -e 1')

        line_rc = self.cli_command(cmdlist, host, port, username, password, cli_type=cli_type)

        print 'line_rc', line_rc

        return line_rc

    def get_static_info(self):
        """
        subnet 172.19.109.0 netmask 255.255.255.0 {
        option routers                172.19.109.254;
        option subnet-mask            255.255.255.0;
        option domain-name-servers    172.19.109.254,192.168.55.254;
        option time-offset            -18000;
        range dynamic-bootp          172.19.109.1 172.19.109.253;
        default-lease-time            21600;
        max-lease-time                43200;
        }
        """

        print 'in get_static_info'

        ctnt = ''
        test_class = os.getenv('testClass')

        if not test_class:
            dhcp_cfg = '$U_PATH_TOOLS/START_SERVERS/dhcpd/dhcpd.conf'
        else:
            """
            'TMP_DUT_WAN_IP': self.static_ip,
               'TMP_DUT_WAN_MASK': self.static_mask,
               'TMP_DUT_DEF_GW': self.static_gw,
               'TMP_DUT_WAN_DNS_1': self.static_dns1,
               'TMP_DUT_WAN_DNS_2': self.static_dns2,
            """
            self.static_ip = os.environ.get('U_CUSTOM_STATIC_WAN_IP', '192.168.55.1')
            self.static_mask = os.environ.get('U_CUSTOM_STATIC_WAN_MASK', '255.255.255.0')
            self.static_gw = os.environ.get('U_CUSTOM_STATIC_WAN_GW', '192.168.55.254')
            self.static_dns1 = os.environ.get('U_CUSTOM_STATIC_WAN_DNS_1', '168.95.1.1')
            self.static_dns2 = os.environ.get('U_CUSTOM_STATIC_WAN_DNS_1', '192.168.55.254')

            os.environ.update({
                'TMP_DUT_WAN_IP': self.static_ip,
                'TMP_DUT_WAN_MASK': self.static_mask,
                'TMP_DUT_DEF_GW': self.static_gw,
                'TMP_DUT_WAN_DNS_1': self.static_dns1,
                'TMP_DUT_WAN_DNS_2': self.static_dns2,
            })

            return True
        #             dhcp_cfg = '/root/dhcpd.conf'
        # dhcp_cfg=

        fd = open(os.path.expandvars(dhcp_cfg), 'r')
        lines = fd.readlines()
        fd.close()

        for line in lines:
            line = line.strip()
            ctnt += line + '\n'

        print ctnt

        m_TMP_DUT_WAN_IP = r'range *dynamic\-bootp *([0-9.]*) *([0-9.]*)\;'
        m_TMP_DUT_WAN_MASK = r'netmask *(.*) *\{'
        m_TMP_DUT_DEF_GW = r'option *routers *(.*)\;'
        m_TMP_DUT_WAN_DNS12 = r'option *domain\-name\-servers *([0-9.]*)\,([0-9.]*)\;'

        rc_TMP_DUT_WAN_IP = re.findall(m_TMP_DUT_WAN_IP, ctnt)
        if len(rc_TMP_DUT_WAN_IP) > 0:
            ip_start, ip_end = rc_TMP_DUT_WAN_IP[0]
            print 'AT_INFO : ip range %s -> %s' % (ip_start, ip_end)
            static_ip_net = '.'.join(ip_start.split('.')[:-1])
            static_ip_host = str((int(ip_start.split('.')[-1]) + int(ip_end.split('.')[-1])) / 2)
            self.static_ip = static_ip_net + '.' + static_ip_host
            print 'AT_INFO : static ip :', self.static_ip

        rc_TMP_DUT_WAN_MASK = re.findall(m_TMP_DUT_WAN_MASK, ctnt)
        if len(rc_TMP_DUT_WAN_MASK) > 0:
            self.static_mask = rc_TMP_DUT_WAN_MASK[0]
            print 'AT_INFO : static mask ', self.static_mask

        rc_TMP_DUT_DEF_GW = re.findall(m_TMP_DUT_DEF_GW, ctnt)
        if len(rc_TMP_DUT_DEF_GW) > 0:
            self.static_gw = rc_TMP_DUT_DEF_GW[0]
            print 'AT_INFO : static_gw', self.static_gw

        rc_TMP_DUT_WAN_DNS12 = re.findall(m_TMP_DUT_WAN_DNS12, ctnt)
        if len(rc_TMP_DUT_WAN_DNS12) > 0:
            self.static_dns1, self.static_dns2 = rc_TMP_DUT_WAN_DNS12[0]
            print 'AT_INFO : static_dns1', self.static_dns1
            print 'AT_INFO : static_dns2', self.static_dns2

        os.environ.update(
            {
                'TMP_DUT_WAN_IP': self.static_ip,
                'TMP_DUT_WAN_MASK': self.static_mask,
                'TMP_DUT_DEF_GW': self.static_gw,
                'TMP_DUT_WAN_DNS_1': self.static_dns1,
                'TMP_DUT_WAN_DNS_2': self.static_dns2,
            }
        )

    def add_wan_route(self):
        """
        """

        #         if self.in_route_added:
        #             print 'already added route'
        #             return True
        #         else:
        print 'INFO : add_wan_route() : to add a route on WAN PC before ping WAN host from LAN PC'

        wan_link_chance = 10
        add_wan_route = False
        desti_protocol = self.protocol.lower()

        if desti_protocol == 'static':
            desti_protocol = 'ipoe'

        for i in range(wan_link_chance):
            rc_wan_link = self.get_wan_link()
            if rc_wan_link:
                print 'add_wan_route > desti_protocol : %s TMP_DUT_WAN_ISP_PROTO %s' % (
                desti_protocol, self.TMP_DUT_WAN_ISP_PROTO)
                if desti_protocol == str(self.TMP_DUT_WAN_ISP_PROTO).lower():
                    add_wan_route = True
                    break
                else:
                    print 'AT_INFO : wait 15 and try again'
                    if i == wan_link_chance - 1:
                        print 'AT_ERROR : get wan link failed'
                        # return False
        if add_wan_route:
            print 'AT_INFO : to add a route for traffic in case only'
            self.export_wan_info()
            rt_cmd = 'bash $U_PATH_TBIN/addRemoteRoute.sh -i $G_HOST_IF0_1_0 -gw ' + os.getenv('TMP_DUT_WAN_IP')
            rc_rt, out_rt = self.subproc(rt_cmd)
            if rc_rt == 0:
                print 'AT_INFO : add route pass'
                self.in_route_added = True
                # return True
            else:
                print 'AT_INFO : add route failed'

    def wan_setting(self):
        """
        True False
        ev = os.getenv('TMP_DUT_WAN_IP')
        ev = os.getenv('TMP_DUT_WAN_MASK')
        ev = os.getenv('TMP_DUT_DEF_GW')
        """
        print 'in wan_setting'

        print 'AT_INFO : add route ? %s' % (str(self.in_route))

        print 'U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE=', str(os.getenv('U_CUSTOM_IS_MANUAL_SET_PHYSICAL_LINE'))

        if self.linemode == '':
            print 'no linemode given'
            rcc = self.get_wan_link()
            if not rcc:
                print 'AT_ERROR : wan setting failed'
                return False
            self.linemode = self.TMP_DUT_WAN_LINK

        if self.validateL2():
            if self.in_route:
                self.add_wan_route()

            rc_wan_link = self.check_wan_connection('180')
            rcc = self.get_wan_link()
            if rc_wan_link:
                if self.TMP_DUT_WAN_ISP_PROTO == self.protocol:
                    print 'AT_INFO : the destination protocol %s is ready' % (self.TMP_DUT_WAN_ISP_PROTO)
                    # return True
            if not rcc:
                print 'AT_ERROR : wan setting failed after validateL2'
                return False

            if self.protocol == 'STATIC':
                self.get_static_info()
                # self.linemode = 'IPOE'
                self.check_static = True

            if not self.bonding:
                print 'AT_INFO : setting single line mode'
                if self.tag != '0':
                    print 'AT_INFO : tagged mode'
                    post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
                    post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-' + self.linemode + '-TAGGED-' + self.protocol + '-NO-DETECT $U_AUTO_CONF_PARAM'
                else:
                    print 'AT_INFO : untagged mode'
                    post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
                    post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-' + self.linemode + '-' + self.protocol + '-NO-DETECT $U_AUTO_CONF_PARAM'
            else:
                print 'AT_INFO : setting bonding line mode'
                if self.tag != '0':
                    print 'AT_INFO : tagged mode'
                    post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
                    post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-' + self.linemode + '-BONDING-TAGGED-' + self.protocol + '-NO-DETECT $U_AUTO_CONF_PARAM'
                else:
                    print 'AT_INFO : untagged mode'
                    post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
                    post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-' + self.linemode + '-BONDING-' + self.protocol + '-NO-DETECT $U_AUTO_CONF_PARAM'

            rc, out = self.subproc(post_cmd)

            if rc == 0:
                print 'AT_INFO : wan setting passed'

                # wan_link_chance = 10
                if self.in_route:
                    self.add_wan_route()
                    print 'AT_INFO : add wan route done !'
                    return True
                else:
                    return True

            else:
                print 'AT_ERROR : wan setting failed'
                return False
        else:
            print 'AT_ERROR : line status not ready'
            return False


    def restart_WAN_server(self, server_only=False):
        """
        True False
        """
        cmd_list = 'cd /root/START_SERVERS/;'

        if not server_only:
            linemode = self.linemode
            if linemode == 'ADSL' and self.bonding == False:
                self.current_vid = os.getenv('U_CUSTOM_VLANAS')
            elif linemode == 'ADSL' and self.bonding == True:
                self.current_vid = os.getenv('U_CUSTOM_VLANAB')
            elif linemode == 'VDSL' and self.bonding == False:
                self.current_vid = os.getenv('U_CUSTOM_VLANVS')
            elif linemode == 'VDSL' and self.bonding == True:
                self.current_vid = os.getenv('U_CUSTOM_VLANVB')
            elif linemode == 'ADSL' and self.bonding == False and self.tag != '0':
                self.current_vid = os.getenv('U_CUSTOM_VLANAST')
            elif linemode == 'ADSL' and self.bonding == True and self.tag != '0':
                self.current_vid = os.getenv('U_CUSTOM_VLANABT')
            elif linemode == 'VDSL' and self.bonding == False and self.tag != '0':
                self.current_vid = os.getenv('U_CUSTOM_VLANVST')
            elif linemode == 'VDSL' and self.bonding == True and self.tag != '0':
                self.current_vid = os.getenv('U_CUSTOM_VLANVBT')
            elif linemode == 'ETH':
                eth_vid = os.getenv('U_CUSTOM_VLANETH', '')
                if not eth_vid == '':
                    self.current_vid = eth_vid
                else:
                    self.current_vid = 'no'

            print 'in restart_WAN_server'

            if self.current_vid == '':
                print 'AT_WARNING : vlan id cannot be empty'
                # return False
            else:
                cmd_list += 'sed -i \"s/^VLAN_LIST.*/VLAN_LIST ' + self.current_vid + '/g\" config_net.conf;'
            cmd_list += './config_net.sh'

        test_class = os.getenv('testClass')

        if test_class:
            #     dhcp_cfg = '$U_PATH_TOOLS/START_SERVERS/dhcpd/dhcpd.conf'
            cmd_subproc = 'sed -i \"s/^VLAN_LIST.*/VLAN_LIST ' + self.current_vid + '/g\" ' + ' $U_PATH_TOOLS/START_SERVERS/dhcpd/dhcpd.conf'

            int_rc, out = self.subproc(cmd_subproc)
            if str(int_rc) == '0':
                print 'AT_INFO :change vlan id passed'
                return True
            else:
                print 'AT_ERROR :change vlan id failed'
                return False
            return True

        host = os.getenv('G_HOST_IP1')
        port = '22'
        username = os.getenv('G_HOST_USR1')
        password = os.getenv('G_HOST_PWD1')

        c_list = [cmd_list]

        line_rc = self.cli_command(c_list, host, port, username, password)

        if line_rc:
            #   disable_no_use_wan_server(protocol)
            rc = self.disable_no_use_wan_server(self.protocol)

            if rc > 0:
                print 'AT_ERROR : disable_no_use_wan_server failed'
                return False

        return line_rc


    def reset_DSLAM_port(self):
        """
            Reset DSLAM Port
        """

        test_class = os.getenv('testClass')

        if test_class:
            return True

        print 'Entry reset_DSLAM_port'
        linemode = self.linemode
        current_vlan_id = ''
        print 'linemode : ' + linemode
        print 'bonding : ' + str(self.bonding)
        if linemode == 'ADSL' and self.bonding == False:
            current_vlan_id = os.getenv('U_CUSTOM_VLANAS')
        elif linemode == 'ADSL' and self.bonding == True:
            current_vlan_id = os.getenv('U_CUSTOM_VLANAB')
        elif linemode == 'VDSL' and self.bonding == False:
            current_vlan_id = os.getenv('U_CUSTOM_VLANVS')
        elif linemode == 'VDSL' and self.bonding == True:
            current_vlan_id = os.getenv('U_CUSTOM_VLANVB')
        elif linemode == 'ADSL' and self.bonding == False and self.tag != '0':
            current_vlan_id = os.getenv('U_CUSTOM_VLANAST')
        elif linemode == 'ADSL' and self.bonding == True and self.tag != '0':
            current_vlan_id = os.getenv('U_CUSTOM_VLANABT')
        elif linemode == 'VDSL' and self.bonding == False and self.tag != '0':
            current_vlan_id = os.getenv('U_CUSTOM_VLANVST')
        elif linemode == 'VDSL' and self.bonding == True and self.tag != '0':
            current_vlan_id = os.getenv('U_CUSTOM_VLANVBT')
        elif linemode == 'ETH':
            eth_vid = os.getenv('U_CUSTOM_VLANETH', '')
            if not eth_vid == '':
                current_vlan_id = eth_vid
            else:
                current_vlan_id = 'no'
        else:
            current_vlan_id = 'no'
        print 'current_vlan_id : ', current_vlan_id
        if current_vlan_id == 'no' or current_vlan_id == '':
            print 'AT_INFO : NO VLAN ,NO need reset DSLAM'
            return True
        dslam_vlan_port_tb = os.path.expandvars('$SQAROOT/tools/$G_TOOLSVERSION/common/DSLAM_VLAN_PORT.TAB')
        if not os.path.exists(dslam_vlan_port_tb):
            print 'AT_ERROR : ' + dslam_vlan_port_tb + ' NOT EXIST!'
            return False
        re_current_vlan_id = '^ *' + current_vlan_id + ' *:.*'
        fa = open(dslam_vlan_port_tb, 'r')
        alines = fa.readlines()
        fa.close()
        ac_arr = []
        vlan_match_flag = False
        for line in alines:
            ac_count = re.findall(re_current_vlan_id, line)
            if ac_count:
                vlan_match_flag = True
                tem_ac_str = ac_count[0]
                tem_ac_list = tem_ac_str.split(':')
                ac_arr.append(tem_ac_list[1])
        print 'DSL Port : ' + str(ac_arr)

        if vlan_match_flag == False:
            print 'AT_INFO : Can\'t find ' + current_vlan_id + ' in ' + dslam_vlan_port_tb + ' ,NO need Reset DSLAM Port!'
            return True
        if not ac_arr:
            print 'AT_ERROR : VLAN ' + current_vlan_id + ' Port is NULL!'
            return False

        CLI_Para = ''
        command_lst = []

        dslam_type = os.getenv('U_DSLAM_TYPE', 'None')
        if dslam_type == 'CALIX':
            print 'DSLAM TYPE : CALIX'
            for item in ac_arr:
                Item_Para = ' -v "vdsl disable ' + str(item) + '"' + ' -v "vdsl enable ' + str(item) + '"'
                command_lst.append('vdsl disable ' + str(item))
                command_lst.append('vdsl enable ' + str(item))
                CLI_Para = CLI_Para + Item_Para
        else:
            print 'AT_INFO : NO Need Reset DSLAM Port!'
            return True
        print 'CLI Paramaters : ' + CLI_Para

        mycmd = '$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/telnet_reset_dslam_port.log  -y telnet -u $U_DSLAM_TELNET_USER -p $U_DSLAM_TELNET_PWD -d $U_DSLAM_TELNET_IP ' + CLI_Para
        print 'CLI Command : ' + mycmd

        host = os.path.expandvars('$U_DSLAM_TELNET_IP')
        username = os.path.expandvars('$U_DSLAM_TELNET_USER')
        password = os.path.expandvars('$U_DSLAM_TELNET_PWD')
        port = '23'
        cli_type = 'telnet'

        output = '/tmp/clicmd.log'

        command_rc = self.cli_command(command_lst, host, port, username, password, output, cli_type, rest_time='5')
        if command_rc:
            print 'AT_INFO : Rest DSLAM PORT Success!'
            return True
        else:
            print 'AT_ERROR : Rest DSLAM PORT FAIL!'
            return False

        #          return_code, return_output = self.subproc(mycmd)
        #          if return_code == 0:
        #              print 'AT_INFO : Rest DSLAM PORT Success!'
        #              return True
        #          else:
        #              print 'AT_ERROR : Rest DSLAM PORT FAIL!'
        #              return False


    def get_wan_link(self):
        """
        True False
        """
        print 'in get_wan_link'

        cli_dut_cmd = 'bash $U_PATH_TBIN/cli_dut.sh -v wan.link -o $G_CURRENTLOG/wan_link.log'

        m_link = r'TMP_DUT_WAN_LINK *=(.*)'
        m_proto = r'TMP_DUT_WAN_ISP_PROTO *=(.*)'
        m_l3ifc = r'TMP_CUSTOM_WANINF *=(.*)'

        get_wan_retry = 3

        for i in range(get_wan_retry):
            print 'AT_INFO : try getting WAN info attempt :', str(i + 1)

            rc, out = self.subproc(cli_dut_cmd)

            if rc == 0:
                print 'AT_INFO : get wan link pass'

                wan_link_log = ''

                fd = open(os.path.expandvars('$G_CURRENTLOG/wan_link.log'), 'r')
                lines = fd.readlines()
                fd.close()

                for line in lines:
                    wan_link_log += line + '\n'

                rc_link = re.findall(m_link, wan_link_log)

                if len(rc_link) > 0:
                    print 'AT_INFO : TMP_DUT_WAN_LINK:', rc_link[0]
                    self.TMP_DUT_WAN_LINK = rc_link[0]

                    #################################

                rc_proto = re.findall(m_proto, wan_link_log)

                if len(rc_proto) > 0:
                    print 'AT_INFO : TMP_DUT_WAN_ISP_PROTO:', rc_proto[0]
                    self.TMP_DUT_WAN_ISP_PROTO = rc_proto[0]

                    #################################

                rc_l3ifc = re.findall(m_l3ifc, wan_link_log)

                if len(rc_l3ifc) > 0:
                    print 'AT_INFO : TMP_CUSTOM_WANINF:', rc_l3ifc[0]
                    self.TMP_CUSTOM_WANINF = rc_l3ifc[0]

                return True

                #################################
            else:
                print 'AT_ERROR : get wan link failed'

                if i == get_wan_retry - 1:
                    return False
                else:
                    time.sleep(20)
                    print 'AT_INFO : try getting wan info again'


    def check_wan_link(self):
        """
        """

        print 'in check_wan_link'

        get_wan_link_retry = 3
        for i in range(get_wan_link_retry):
            print 'AT_INFO : try to get wan link info ', str(i + 1)

            rcc = self.get_wan_link()
            if not rcc or self.TMP_DUT_WAN_ISP_PROTO == 'Unknown':
                print 'AT_ERROR : check wan link failed'
                # return False
                if i == get_wan_link_retry - 1:
                    print 'AT_ERROR : check wan link failed '
                    return False
                time.sleep(20)

            else:
                break

        if not self.check_static:
            print 'AT_INFO : current wan isp :', self.TMP_DUT_WAN_ISP_PROTO
            print 'AT_INFO : dest wan isp :', self.protocol

            if self.TMP_DUT_WAN_ISP_PROTO == self.protocol or self.protocol == "NONE":
                print 'AT_INFO : check wan link passed'
                return True
            else:
                print 'AT_ERROR : check wan link failed'
                return False
        else:
            print 'AT_INFO : checking static ip'
            if self.TMP_DUT_WAN_ISP_PROTO == 'IPOE':
                cli_dut_cmd = 'bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/wan_info.log'

                rc, out = self.subproc(cli_dut_cmd)

                if rc == 0:
                    m_ip = r'dut_wan_ip *= *([0-9.]*)'
                    rc_ip = re.findall(m_ip, out)
                    if len(rc_ip) > 0:
                        current_ip = rc_ip[0]
                        print 'AT_INFO : current ip ', current_ip
                        if current_ip == self.static_ip:
                            print 'AT_INFO : check static ip passed'
                            return True
                        else:
                            print 'AT_ERROR : check static ip failed'
                            return False
                    else:
                        print 'AT_ERROR : no IP matched'
                        return False
                else:
                    print 'AT_ERROR : proto is not IPOE'
                    return False

                #

    def export_wan_info(self):
        """
        """

        print 'in export_wan_info'

        U_CUSTOM_UPDATE_ENV_FILE = os.getenv('U_CUSTOM_UPDATE_ENV_FILE')

        if U_CUSTOM_UPDATE_ENV_FILE:
            output = U_CUSTOM_UPDATE_ENV_FILE
        else:
            output = os.path.expandvars('$G_CURRENTLOG/setDutWANLinkEx.log')

        cli_dut_cmd = 'bash $U_PATH_TBIN/cli_dut.sh -v wan.info -o $G_CURRENTLOG/wan_info.log'

        rc, out = self.subproc(cli_dut_cmd)

        if rc == 0:
            tmp_cmd = 'cat  $G_CURRENTLOG/wan_info.log | dos2unix | tee ' + output
            self.subproc(tmp_cmd)

        cli_dut_cmd = 'bash $U_PATH_TBIN/cli_dut.sh -v wan.dns -o $G_CURRENTLOG/wan_dns.log'

        rc, out = self.subproc(cli_dut_cmd)

        if rc == 0:
            tmp_cmd = 'cat  $G_CURRENTLOG/wan_dns.log | dos2unix | tee -a ' + output
            self.subproc(tmp_cmd)

        if os.path.exists(output):
            U_CUSTOM_CURRENT_WAN_TYPE_LINEMODE = self.linemode
            if self.bonding:
                U_CUSTOM_CURRENT_WAN_TYPE_ISBONDING = '1'
            else:
                U_CUSTOM_CURRENT_WAN_TYPE_ISBONDING = '0'
            U_CUSTOM_CURRENT_WAN_TYPE_ISTAGGED = self.tag
            U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL = self.protocol

            try:
                append_env_f = open(output, 'a')
                append_env_f.write(
                    '%s=%s\n' % ('U_CUSTOM_CURRENT_WAN_TYPE_LINEMODE', U_CUSTOM_CURRENT_WAN_TYPE_LINEMODE))
                append_env_f.write(
                    '%s=%s\n' % ('U_CUSTOM_CURRENT_WAN_TYPE_ISBONDING', U_CUSTOM_CURRENT_WAN_TYPE_ISBONDING))
                append_env_f.write(
                    '%s=%s\n' % ('U_CUSTOM_CURRENT_WAN_TYPE_ISTAGGED', U_CUSTOM_CURRENT_WAN_TYPE_ISTAGGED))
                append_env_f.write(
                    '%s=%s\n' % ('U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL', U_CUSTOM_CURRENT_WAN_TYPE_PROTOCOL))
                append_env_f.close()
            except Exception, e:
                print(str(e))

            print 'AT_INFO : to update runtime ENV from file : %s' % (output)
            update_env_f = open(output, 'r')

            lines = update_env_f.readlines()
            update_env_f.close()

            m_k_v = r'(.*)=(.*)'
            for line in lines:
                rc_kv = re.findall(m_k_v, line.strip())
                if len(rc_kv) > 0:
                    k, v = rc_kv[0]
                    print 'AT_INFO : updating env : %s = %s' % (k, v)
                    os.environ.update({
                        k: v
                    })


    def dsl_bonding_setting(self):
        """
        B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-BONDING-NO-DETECT
        B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-SINGLE-NO-DETECT

        """

        if str(os.getenv('U_DUT_TYPE')) == 'TV2KH':
            print 'AT_INFO : do bonding setting for TV2KH'
            post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
            if self.bonding:
                post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-BONDING-NO-DETECT $U_AUTO_CONF_PARAM'
            else:
                post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-BONDING-SETTING-SINGLE-NO-DETECT $U_AUTO_CONF_PARAM'

            rc, out = self.subproc(post_cmd)

            if rc == 0:
                print 'AT_INFO : bonding setting passed'
                # return True
            else:
                print 'AT_ERROR : bonding setting failed'
                return False

            # time.sleep(seconds)

            rc_lan = self.check_lan_connection()
            if rc_lan:
                print 'AT_INFO : ping DUT after bonding setting passed'
                # return True
            else:
                print 'AT_ERROR : ping DUT after  bonding setting failed'
                return False

            rc_l2 = self.validateL2()

            if not rc_l2:
                print 'AT_ERROR : validate L2 after bonding setting failed !'
                return False
            else:
                print 'AT_INFO : validate L2 after bonding setting passed !'
                return True
        else:

            print 'skip bonding setting'
            return True


    def broadband_setting(self):
        """
        True False
        """
        print 'in broadband_setting'

        if not self.vb_involved:
            if self.validateL2():
                rcc = self.get_wan_link()
                if not rcc:
                    print 'AT_ERROR : wan setting failed after validateL2'
                    return False

        if not self.bonding:
            print 'AT_INFO : setting single line mode'
            if self.tag != '0':
                print 'AT_INFO : tagged mode'
                post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
                post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-' + self.linemode + '-SINGLE-TAGGED-NO-DETECT $U_AUTO_CONF_PARAM'
            else:
                print 'AT_INFO : untagged mode'
                post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
                post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-' + self.linemode + '-SINGLE-UNTAGGED-NO-DETECT $U_AUTO_CONF_PARAM'
        else:
            print 'AT_INFO : setting bonding line mode'
            if self.tag != '0':
                print 'AT_INFO : tagged mode'
                post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
                post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-' + self.linemode + '-BONDING-TAGGED-NO-DETECT $U_AUTO_CONF_PARAM'
            else:
                print 'AT_INFO : untagged mode'
                post_cmd = '$U_AUTO_CONF_BIN $U_DUT_TYPE ' + self.post_file_loc
                post_cmd += '/B-GEN-ENV.PRE-DUT.WANCONF-BROADBAND-SETTING-' + self.linemode + '-BONDING-UNTAGGED-NO-DETECT $U_AUTO_CONF_PARAM'

        rc, out = self.subproc(post_cmd)

        if rc == 0:
            print 'AT_INFO : broadband setting passed'
            return True
        else:
            print 'AT_ERROR : broadband setting failed'
            return False


    def check_wan_connection(self, timeout='1200'):
        """
        """

        eth1 = os.getenv('G_HOST_IF0_1_0', 'eth1')

        retry_count = 10
        seperated_to = str(int(timeout) / retry_count)

        wan_conn_cmd = 'python $U_PATH_TBIN/verifyPing.py -d $U_CUSTOM_WAN_HOST -I ' + eth1 + ' -t ' + seperated_to + ' -l $G_CURRENTLOG'

        for i in range(retry_count):
            rc, out = self.subproc(wan_conn_cmd)

            if rc != 0:
                print 'AT_WARNING : ping wan host failed'
                if i == retry_count - 1:
                    print 'AT_ERROR : ping wan host failed'
                    return False
                else:
                    print 'AT_INFO : sleep 15s and try again'
                    time.sleep(15)
            else:
                print 'AT_INFO : ping wan host passed'
                return True
        return False

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

    #   bash cli_dut.sh -v layer2.stats -o /tmp/haha
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
                        print 'AT_INFO : wait 60 second and check again'
                        time.sleep(60)

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


    def checkL2L3(self):
        """
        """
        result_rc = False

        linemode = self.linemode
        proto = self.protocol
        bonding = self.bonding
        dest_L2 = linemode

        # rcc = self.cli_command(cmd_list, host, port, username, password, output='/tmp/cli_command.log', cli_type='telnet')
        m_status = r'' + dest_L2 + '=Up'

        m_bonding = ''

        if not linemode == 'ETH':
            m_bonding = r'' + linemode + '_BONDING'
        if bonding:
            m_status2 = r'' + dest_L2 + '2=Up'
            m_bonding += '=1'
        else:
            m_bonding += '=0'

        cli_dut_cmd = 'bash $U_PATH_TBIN/cli_dut.sh -v layer2.stats -o /tmp/l2stats.log'
        rc_cli, output_cli = self.subproc(cli_dut_cmd)

        if rc_cli == 0:
            output = ''

            fn = open('/tmp/l2stats.log', 'r')
            lines = fn.readlines()
            fn.close()

            for line in lines:
                line = line.strip()
                output += line + '\n'

            if not linemode == 'ETH':
                rc_bonding = re.findall(m_bonding, output)
                if len(rc_bonding) > 0:
                    print rc_bonding[0]
                    print 'AT_INFO : bonding status ok'
                    if bonding:
                        rc_line1 = re.findall(m_status, output)
                        if len(rc_line1) > 0:
                            print 'AT_INFO : line status ok'
                            rc_line2 = re.findall(m_status2, output)
                            if len(rc_line2) > 0:
                                print 'AT_INFO : line 2 status ok'
                                rc_wanLine = self.get_wan_link()
                                if rc_wanLine:
                                    if self.TMP_DUT_WAN_ISP_PROTO == proto:
                                        rc_checkwan = self.check_wan_connection()
                                        if rc_checkwan:
                                            print 'AT_INFO : protocol is right and ping wan host passed'
                                            return True
                                        else:
                                            print 'AT_ERROR : protocol is right but ping wan host failed'
                                            return False
                                    else:
                                        print 'AT_ERROR : protocol not correct'
                                        return False
                                else:
                                    print 'AT_ERROR : get wan link Failed'
                                    return False
                            else:
                                print 'AT_ERROR : line 2 status not correct'
                                return False
                        else:
                            print 'AT_ERROR : line 1 status not correct'
                            return False
                    else:
                        rc_line1 = re.findall(m_status, output)
                        if len(rc_line1) > 0:
                            print 'AT_INFO : line status ok'

                            rc_wanLine = self.get_wan_link()
                            if rc_wanLine:
                                if self.TMP_DUT_WAN_ISP_PROTO == proto:
                                    rc_checkwan = self.check_wan_connection()
                                    if rc_checkwan:
                                        print 'AT_INFO : protocol is right and ping wan host passed'
                                        return True
                                    else:
                                        print 'AT_ERROR : protocol is right but ping wan host failed'
                                        return False
                                else:
                                    print 'AT_ERROR : protocol not correct'
                                    return False
                            else:
                                print 'AT_ERROR : get wan link Failed'
                                return False
                        else:
                            print 'AT_ERROR : line 1 status not correct'
                            return False
                else:
                    print 'AT_ERROR : bonding status not correct'
                    return False
            else:
                rc_line1 = re.findall(m_status, output)
                if len(rc_line1) > 0:
                    print 'AT_INFO : line status ok'

                    rc_wanLine = self.get_wan_link()
                    if rc_wanLine:
                        if self.TMP_DUT_WAN_ISP_PROTO == proto:
                            rc_checkwan = self.check_wan_connection()
                            if rc_checkwan:
                                print 'AT_INFO : protocol is right and ping wan host passed'
                                return True
                            else:
                                print 'AT_ERROR : protocol is right but ping wan host failed'
                                return False
                        else:
                            print 'AT_ERROR : protocol not correct'
                            return False
                    else:
                        print 'AT_ERROR : get wan link Failed'
                        return False
                else:
                    print 'AT_ERROR : line 1 status not correct'
                    return False
                    #                    status_ready = True
        else:
            result_rc = False

        return result_rc


    def load_config(self, idx):
        """
        No-36455__WPA_802.1x_with_AES_for_Primary.xml:ADSL BONDING TAGGED IPOE -> VDSL SINGLE UNTAGGED IPOE
        """

        print 'AT_INFO : setting of index ', idx

        config_load_path = os.path.expandvars('$SQAROOT/testsuites/$G_PFVERSION/$U_DUT_TYPE/cfg/CONFIG_LOAD_WAN_SWAP')
        if not config_load_path:
            print 'AT_ERROR : must specify U_CUSTOM_CONFIG_LOAD'
            return False
        else:
            config_load_path = os.path.expandvars(config_load_path)

            if not os.path.exists(config_load_path):
                print 'AT_ERROR : config load file %s not exists' % (config_load_path)
                return False
            else:
                G_CURRENTLOG = os.getenv('G_CURRENTLOG')
                casename = '__'.join(os.path.basename(G_CURRENTLOG).split('__')[1:])
                print 'AT_INFO : current case name : ', casename

                fd = open(config_load_path, 'r')
                lines = fd.readlines()
                fd.close()

                rule = ''

                for line in lines:
                    if not line.startswith('#'):
                        if line.startswith(casename):
                            print 'found rule ,', line
                            rule = line
                            break

                if rule == '':
                    print 'AT_ERROR : rule for case %s is not defined' % (casename)
                    return False

                rule = ':'.join(rule.split(':')[1:]).strip()

                settings = rule.split('->')

                bfr = settings[0].split()
                aftr = settings[1].split()

                if len(bfr) == 4:
                    bfrs = '-'.join(bfr[:-1])
                    aftrs = '-'.join(aftr[:-1])
                    if bfrs == aftrs:
                        self.l3only = True
                        self.doreplace = False
                        print 'AT_INFO : only do lay3 setting'
                    else:
                        self.doreplace = True
                else:
                    self.doreplace = False

                linemode = settings[int(idx) - 1].split()

                firstLineMode = settings[0].split()
                secondLineMode = settings[1].split()

                if len(firstLineMode) == 4:
                    self.first_setting = '-'.join(firstLineMode[:2])
                else:
                    self.first_setting = firstLineMode[0]

                if len(secondLineMode) == 4:
                    self.second_setting = '-'.join(secondLineMode[:2])
                else:
                    self.second_setting = secondLineMode[0]

                print 'AT_INFO : first line mode : %s , second line mode : %s' % (
                self.first_setting, self.second_setting)

                # print linemode
                if len(linemode) == 4:
                    #   ADSL BONDING TAGGED IPOE

                    # self.first_setting='-'.join(linemode[:2])

                    self.linemode = linemode[0]
                    if linemode[2] == 'UNTAGGED':
                        self.tag = '0'
                    else:
                        self.tag = os.getenv('U_CUSTOM_TAGGED_ID')
                    self.protocol = linemode[3]
                    if linemode[1] == 'BONDING':
                        self.bonding = True
                    else:
                        self.bonding = False
                elif len(linemode) == 1:
                    self.protocol = linemode[0]
                    self.bonding = False
                    self.tag = '0'

        return True

    def disable_no_use_wan_server(self, protocol):
        print 'AT_INFO : in disable_no_use_wan_server function'
        print 'protocol :' + protocol

        cmd = 'bash $U_PATH_TBIN/setupWANServer.sh -e "" -d "dhcpd,pppoe-server"'

        print cmd

        rc, ouput = self.subproc(cmd)

        if protocol:
            protocol = protocol.upper()
            if protocol == 'IPOE' or protocol == 'STATIC':
                enable_server = 'dhcpd'
            elif protocol == 'PPPOE':
                enable_server = 'pppoe-server'
            else:
                print 'AT_WARING : can not enable WAN server <' + protocol + '> in this tool'
                return 0

            cmd = 'bash $U_PATH_TBIN/setupWANServer.sh -d "" -e "' + enable_server + '"'

            print cmd

            rc, ouput = self.subproc(cmd)
        else:
            print 'AT_WARNING : no WAN server need disable'
            return 0

        return rc


    def swap_link(self):
        """
        linemode = ''
        protocol = ''
        bonding = False
        checkmode = False
        setmode = False
        """
        rc = 0

        if self.linemode == '' or self.l3only == True:
            print 'AT_INFO : no changing pyhx line'

            #            rcc = self.set_physical_line('reboot')
            #            if not rcc:
            #                rc = 1
            #                print 'AT_ERROR : setting phyx line failed'
            #                return rc
            #
            #
            if self.reset_dslam_port and self._flag != 'DSLAM':
                self.reset_DSLAM_port()
            rcc = self.restart_WAN_server()
            if not rcc:
                rc = 1
                print 'AT_ERROR : restart_WAN_server failed'
                return rc
            #
            #            rcc = self.check_lan_connection()
            #            if not rcc:
            #                rc = 1
            #                print 'AT_ERROR : check_lan_connection failed'
            #                return rc

            rcc = self.wan_setting()

            if not rcc:
                print 'AT_ERROR : wan setting failed !'
                rc = 1
                return rc

        else:
            print 'AT_INFO : changing pyhx line'

            if self.linemode == 'off':
                rcc = self.set_physical_line('off')
                if not rcc:
                    rc = 1
                    print 'AT_ERROR : setting phyx line off failed'
                    return rc
                else:
                    return 0

            rcc = self.set_physical_line('off')
            if not rcc:
                rc = 1
                print 'AT_ERROR : setting phyx line failed'
                return rc

            # time.sleep(60)
            if self.reset_dslam_port and self._flag != 'DSLAM':
                self.reset_DSLAM_port()

            rcc = self.restart_WAN_server()
            if not rcc:
                rc = 1
                print 'AT_ERROR : restart_WAN_server failed'
                return rc

            do_setting = False

            if self.first_setting == 'VDSL-BONDING':
                print 'AT_INFO : vdsl bonding mode , going to set broadband setting and wan setting'
                do_setting = True
                self.vb_involved = True
            else:
                if self.second_setting == 'VDSL-BONDING' and self.setting_idx == '2':
                    print 'AT_INFO : vdsl bonding mode , going to set broadband setting and wan setting'
                    do_setting = True
                    self.vb_involved = True
            if self.linemode == 'VDSL' and self.bonding:
                do_setting = True
                self.vb_involved = True

            rcc = self.set_physical_line('reboot')
            if not rcc:
                rc = 1
                print 'AT_ERROR : setting phyx line failed'
                return rc

            if self._flag == 'DSLAM' and (self.linemode == 'ADSL' or self.linemode == 'VDSL'):
                rcc = self.set_dslam()
            else:
                rcc = self.set_physical_line(self.linemode)
            if not rcc:
                rc = 1
                print 'AT_ERROR : setting phyx line failed'
                return rc

            rcc = self.check_lan_connection()
            if not rcc:
                rc = 1
                print 'AT_ERROR : check_lan_connection failed'
                return rc

            # time.sleep(60)

            if self.dslam_bonding_bad:
                if do_setting:
                    rc_bonding = self.dsl_bonding_setting()
                    if not rc_bonding:
                        print 'AT_INFO : bonding setting failed'
                        return False

                    rcc = self.broadband_setting()
                    if not rcc:
                        rc = 1
                        print 'AT_ERROR : broadband_setting failed'
                        return rc
                    else:
                        time.sleep(20)

            rcc = self.wan_setting()
            if not rcc:
                rc = 1
                print 'AT_ERROR : wan_setting failed'
                return rc

        if self.protocol != 'NONE':
            rcc = self.check_wan_connection()
            if not rcc:
                rc = 1
                print 'AT_ERROR : check wan connection after wan setting failed'
                return rc

        rcc = self.check_wan_link()
        if not rcc and self._flag == 'DSLAM' and (self.linemode == 'ADSL' or self.linemode == 'VDSL'):
            res = self.set_dslam()
            if res:
                rcc = self.check_wan_link()
            else:
                rc = 1
                print 'AT_ERROR : set dslam failed'
                return rc

        if not rcc:
            rc = 1
            print 'AT_ERROR : check_wan_link failed'
            return rc

        self.export_wan_info()

        print 'returning in swap_link() : %s' % (rc)
        return rc


def main():
    """
    Entry if not imported
    """

    usage = "usage not ready yet \n"

    parser = OptionParser(usage=usage)

    parser.add_option("-l", "--linemode", dest="linemode",
                      help="linemode , ADSL VDSL or ETC.")

    parser.add_option("-p", "--protocol", dest="protocol",
                      help="protocol , IPoE PPPoE , etc.")

    parser.add_option("-t", "--tag", dest="tag",
                      help="tag")

    parser.add_option("-b", "--bonding", dest="bonding", action='store_true', default=False,
                      help="whether it is in bonding mode")

    parser.add_option("-c", "--check", dest="checkmode", action='store_true', default=False,
                      help="check link type")

    parser.add_option("-s", "--set", dest="setmode", action='store_true', default=False,
                      help="set link type")

    parser.add_option("-i", "--config_load", dest="config_load",
                      help="load setting information from config load file")

    parser.add_option("-r", "--in_route", dest="in_route", action='store_true', default=False,
                      help="add a route on WAN PC for traffic in")
    parser.add_option("-R", "--reset_dslam_port", dest="reset_dslam_port", action='store_true', default=True,
                      help="Reset DSLAM PORT")
    parser.add_option("-v", "--vdslmode", dest="vdslmode",
                      help="vdslmode")

    parser.add_option("-a", "--adslmode", dest="adslmode",
                      help="adslmode")

    parser.add_option("-x", "--pvc", dest="pvc",
                      help="pvc")

    parser.add_option("-P", "--connectport", dest="connectport",
                      help="connectport")

    (options, args) = parser.parse_args()

    tag = '0'
    protocol = ''
    vdslmode = '8a'
    adslmode = 'adsl2+'
    connectport = '1'
    pvc = os.getenv('U_DUT_DEF_VPI_VCI')

    if not len(args) == 0:
        print args

    if options.connectport:
        connectport = options.connectport

    if options.adslmode:
        adslmode = options.adslmode

    if options.pvc:
        pvc = options.pvc

    #if not pvc:
    #    print 'AT_ERROR : U_DUT_DEF_VPI_VCI is Null!'
    #    #exit(1)

    if options.linemode:
        linemode = options.linemode

    if options.protocol:
        protocol = options.protocol

    if options.in_route:
        in_route = True
    else:
        in_route = False

    if options.tag:
        tag = options.tag

    if options.bonding:
        bonding = True
        vdslmode = '8a'
    else:
        bonding = False
        vdslmode = '8a'

    if options.vdslmode:
        vdslmode = options.vdslmode

    if options.checkmode:
        checkmode = True
    else:
        checkmode = False

    if options.setmode:
        setmode = True
    else:
        setmode = False

    if options.reset_dslam_port:
        reset_dslam_port = True
    else:
        reset_dslam_port = False
        ############################



    if options.config_load:

        l_swap = Link_Swap(reset_dslam_port=reset_dslam_port)
        l_swap.in_route = in_route
        l_swap.is_config_load = True
        l_swap.setting_idx = options.config_load
        rc_load = l_swap.load_config(options.config_load)
        if not rc_load:
            print 'AT_ERROR : loading config load failed'
            exit(1)
        print 'linemode  :', l_swap.linemode
        print 'bonding   :', l_swap.bonding
        print 'protocol  :', l_swap.protocol
        print 'tag     :', l_swap.tag

        rc = l_swap.swap_link()
    elif checkmode:
        l_swap = Link_Swap(linemode, protocol, tag, bonding, checkmode, setmode, reset_dslam_port, vdslmode, adslmode,
                           pvc, connectport)
        check_rc = l_swap.checkL2L3()
        if check_rc:
            print 'AT_INFO : check WAN connection link status passed !'
            rc = 0
        else:
            print 'AT_ERROR : check WAN connection link status failed !'
            rc = 1
    elif setmode:
        l_swap = Link_Swap(linemode, protocol, tag, bonding, checkmode, setmode, reset_dslam_port, vdslmode, adslmode,
                           pvc, connectport)
        rc = 0
        rc_res_serv = l_swap.restart_WAN_server()
        if not rc_res_serv:
            rc = 1
            # else
        rc_line = l_swap.set_physical_line(linemode)
        if not rc_line:
            rc = 1
    else:
        l_swap = Link_Swap(linemode, protocol, tag, bonding, checkmode, setmode, reset_dslam_port, vdslmode, adslmode,
                           pvc, connectport)

        rc = l_swap.swap_link()
        #


    exit(rc)

#############################################################################################

if __name__ == '__main__':
    main()
