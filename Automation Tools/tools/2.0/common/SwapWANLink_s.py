#!/usr/bin/python -u
import os, select, subprocess, time, re, sys
from optparse import OptionParser
import datetime
import SetDSLAM
import clicmd
import start_server
import db_helper

aaa = os.getenv('G_SQAROOT', '/root/automation')
sys.path.append(os.path.expandvars(aaa + '/tools/2.0/GUI_validator'))

print sys.path
from GUI_validator import GUI_validator

swb_flag = os.getenv('U_CUSTOM_NO_WECB')

usage = " linemode=[ADSL|VDSL|ETH], protocol=[IPoE|PPPoE|Static], tag=<tag>, bonding=False, \n"
usage = usage + " setmode=False,vdslmode='', adslmode='',pvc='', connectport='', disconnect=False,\n"
usage = usage + " resumeconnect=False, guisetup=False, wanserversetup=False, rebootdut=False"
usage = usage + " staticIP='', staticGW='', staticMASK='', dns=''"


class SwapWANLink_s():
    """
    """
    print usage
    linemode = ''
    protocol = ''
    bonding = False
    current_vid = ''
    tag = ''
    vdslmode = 'vdsl2'
    _flag = os.getenv('U_CUSTOM_SET_DSLAM_OR_SWB', 'SWB')
    adslmode = 'adsl2+'
    pvc = os.getenv('U_DUT_DEF_VPI_VCI')
    connectport = '1'
    vlan = ''
    disconnect = False
    resumeconnect = False
    guisetup = False
    wanserversetup = False
    rebootdut = False

    testbed = os.getenv('G_TBNAME')
    layer2mode = ''
    guisetupDict = {}

    staticIP = ''
    staticGW = ''
    staticMASK = ''
    dns = ''
    backupDslam = False

    def __init__(self, linemode='', protocol='', tag='', bonding=False, checkmode=False, setmode=False,
                 reset_dslam_port=False, vdslmode='', adslmode='', pvc='', connectport='', disconnect=False,
                 resumeconnect=False, guisetup=False, wanserversetup=False, rebootdut=False, staticIP='', staticGW='',
                 staticMASK='', dns='', backupDslam=False):
        """
        """
        print 'in __init__'
        self.bonding = bonding
        self.checkmode = checkmode
        self.setmode = setmode
        self.tag = tag
        self.reset_dslam_port = reset_dslam_port
        self.backupDslam = backupDslam
        if self.backupDslam:
            os.environ.update({'TMP_DSLAM_TABLE': 't_am_def_dslam', })
        else:
            os.environ.update({'TMP_DSLAM_TABLE': 't_am_dslam', })
        if staticIP:
            self.staticIP = staticIP
            self.guisetupDict["static_ip"] = self.staticIP

        if staticGW:
            self.staticGW = staticGW
            self.guisetupDict["static_gw"] = self.staticGW

        if staticMASK:
            self.staticMASK = staticMASK
            self.guisetupDict["static_mask"] = self.staticMASK

        redns = '^(-1|[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) *, *([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|-1)$'
        if dns:
            rc = re.findall(redns, dns)
            if not rc:
                print 'AT_ERROR : dns format error!'
                exit(1)
            self.dns = dns
            self.guisetupDict["dns"] = self.dns

        if linemode:
            self.linemode = linemode
            if self.linemode != "ADSL" and self.linemode != 'VDSL' and self.linemode != 'ETH':
                print 'AT_ERROR : linemode must be ADSL,VDSL,ETH!'
                exit(1)
            wan_type = linemode
            if self.bonding:
                wan_type = linemode + '_B'
            self.guisetupDict["wan_type"] = wan_type

        if protocol:
            self.protocol = protocol
            if str(self.protocol).lower() == 'ipoe'.lower():
                self.guisetupDict["isp_protocol"] = 'IPoE'
            elif str(self.protocol).lower() == 'pppoe'.lower():
                self.guisetupDict["isp_protocol"] = 'PPPoE'
            elif str(self.protocol).lower() == 'static'.lower():
                self.guisetupDict["isp_protocol"] = 'STATIC'
            elif str(self.protocol).lower() == 'auto'.lower():
                self.guisetupDict["isp_protocol"] = 'AUTO'
            else:
                self.guisetupDict["isp_protocol"] = self.protocol

        if vdslmode:
            self.vdslmode = vdslmode
            self.guisetupDict["line_mode"] = vdslmode
        if adslmode:
            self.adslmode = adslmode
            self.guisetupDict["line_mode"] = adslmode
        if pvc:
            self.pvc = pvc
            self.guisetupDict["pvc"] = str(pvc).upper()

        if connectport:
            self.connectport = connectport

        self.disconnect = disconnect
        self.resumeconnect = resumeconnect
        self.guisetup = guisetup
        self.wanserversetup = wanserversetup
        self.rebootdut = rebootdut

        if self.bonding:
            if self.linemode == 'ADSL':
                self.layer2mode = self.linemode + '_B'
            elif self.linemode == 'VDSL':
                self.layer2mode = self.linemode + '_B'
        else:
            if self.linemode == 'ADSL':
                self.layer2mode = self.linemode + '_S'
            elif self.linemode == 'VDSL':
                self.layer2mode = self.linemode + '_S'

        if self.linemode == 'ETH':
            self.layer2mode = 'ETH'

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

    def set_dslam(self):
        """
        """
        obj = SetDSLAM.SetDSLAM(linemode=self.linemode, tag=self.tag, bonding=self.bonding, vdslmode=self.vdslmode,
                                adslmode=self.adslmode, pvc=self.pvc, connectport=self.connectport)
        rc = obj.gogo()
        return rc

    def backup_dslam(self):
        """
        ('at_sh11', 'zyxel_1', 'ADSL_S', '', '503', 'NA', '', '3', '', 'NA')
        ('at_sh11', 'zyxel_1', 'ADSL_B', '', '507', 'NA', 'tb11agroup', '9', '10', 'NA')
        ('at_sh11', 'HuaWei_1', 'VDSL_S', '', '403', '211', '', '0/1/2', '', 'NA')
        ('at_sh11', 'HuaWei_1', 'VDSL_B', '', '419', '211', '3', '0/1/20', '0/1/21', '0000-0010-0111')
        ('at_sh11', 'Huawei_1', 'VDSL_S', '201', '555', '211', '', '0/1/2', '', 'NA')
        ('at_sh11', 'Huawei_1', 'VDSL_S', '202', '666', '211', '', '0/1/2', '', 'NA')

        """
        alldslinfo = db_helper.queryTestbedDSLInfo(self.testbed)
        print alldslinfo
        num = str(alldslinfo[0])
        if num == '0':
            print 'AT_WARNING : Can\'t find data!'
            return True

        if self.linemode:
            rc = self.set_dslam()
            return rc

        for item in alldslinfo[1]:
            print item
            linemode = str(item[2]).split('_')[0]
            bonding = str(item[2]).split('_')[1]
            if bonding == 'B':
                bonding = True
            else:
                bonding = False
            tag = str(item[3])
            obj = SetDSLAM.SetDSLAM(linemode=linemode, tag=tag, bonding=bonding, vdslmode=self.vdslmode,
                                    adslmode=self.adslmode, pvc=self.pvc, connectport=self.connectport)
            rc = obj.gogo()
            if not rc:
                return False
        return True

    def gettagid(self):
        """
        """
        print 'AT_INFO : get Tag'
        retag = '^([0-9]+|[Aa][Uu][Tt][Oo])$'
        rc = re.findall(retag, self.tag)
        if len(rc) > 0:
            return True, str(self.tag).upper()
        else:
            self.tag = 'TAG'

        if not self.layer2mode:
            print 'AT_ERROR : linemode is Null!'
            return False, 'NA'
        mytuple = SetDSLAM.querydatabase(self.testbed, self.layer2mode, self.tag)
        if not mytuple:
            return False, 'NA'
        rc = re.findall(retag, str(mytuple[1][0][3]))
        if len(rc) > 0:
            return True, str(mytuple[1][0][3])
        else:
            return False, 'NA'

    def getvlanid(self):
        """
        """
        print 'AT_INFO : get VLAN'
        if not self.layer2mode:
            print 'AT_ERROR : linemode is Null!'
            return False

        mytuple = SetDSLAM.querydatabase(self.testbed, self.layer2mode, self.tag)
        if not mytuple:
            return False
        self.vlan = mytuple[1][0][4]
        print 'vlan=' + self.vlan
        return True


    def collect_info4guisetup(self):
        """
        """
        print 'collect_info4guisetup'
        if self.dns or str(self.protocol).lower() == 'static'.lower():
            if self.get_static_info():
                pass
            else:
                return False

        if self.tag:
            (rc, val) = self.gettagid()
            if rc and str(val).upper() == 'AUTO':
                self.guisetupDict["ptm_transport_mode"] = "AUTO"
            elif rc:
                self.guisetupDict["ptm_transport_mode"] = "PTM-Tagged"
                self.guisetupDict["tag"] = val
            else:
                return False

        print self.guisetupDict
        return True

    def disconnection(self):
        """
        """
        print 'Disconnect the link between DUT & SWB'
        rc, output = self.subproc('bash $U_PATH_TBIN/switch_controller.sh -alloff')
        if rc == 0:
            pass
        else:
            return False
        rc, output = self.subproc('bash $U_PATH_TBIN/switch_controller.sh -e 0')
        if rc == 0:
            pass
        else:
            return False

        return True

    def restart_wan_server(self):
        """
        True False
        """
        if self.getvlanid():
            pass
        else:
            return False
        obj = start_server.Start_Server(vlan=self.vlan, protocol=self.protocol)
        rc = obj.restart_wan_server()
        return rc

    def gui_setup(self):
        """
        """
        if self.collect_info4guisetup():
            pass
        else:
            return False
        gv = GUI_validator(product_version=os.getenv('U_CUSTOM_CURRENT_FW_VER', 'default'), local=True, debug=True)

        if gv.wan_setting(self.guisetupDict):
            pass
        else:
            return False
        return True


    def reset_swb_require_port(self):
        """
        """
        if swb_flag == '0':
            if self.linemode == 'ADSL':
                cmd = 'bash $U_PATH_TBIN/switch_controller.sh -change_line ab'
            elif self.linemode == 'ETH':
                cmd = 'bash $U_PATH_TBIN/switch_controller.sh -change_line eth'
            elif self.linemode == 'VDSL':
                cmd = 'bash $U_PATH_TBIN/switch_controller.sh -change_line vb'
            else:
                print 'get dslam count'
                type_count = db_helper.queryDslamKinds(self.testbed)
                print type_count
                count = str(type_count[0])

                print 'AT_INFO : The testbed connect to ' + count + ' dslam!'
                if count == '1':
                    cmd = 'bash $U_PATH_TBIN/switch_controller.sh -change_line ab'
                elif count == '2':
                    cmd = 'bash $U_PATH_TBIN/switch_controller.sh -change_line vb'
                else:
                    print 'AT_ERROR : The testbed connect to ' + count + ' dslam!'
                    return False

            rc, output = self.subproc(cmd)
            if rc == 0:
                pass
            else:
                return False
        return True

    def reboot_dut(self):
        """
        """
        cmd = 'bash $U_PATH_TBIN/switch_controller.sh -power 0'
        rc, output = self.subproc(cmd)
        if rc == 0:
            pass
        else:
            return False
        cmd = 'bash $U_PATH_TBIN/switch_controller.sh -power 1'
        rc, output = self.subproc(cmd)
        if rc == 0:
            pass
        else:
            return False
        print 'sleep 60s'
        time.sleep(60)
        if self.check_lan_connection():
            pass
        else:
            return False
        return True

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
            'TMP_DUT_WAN_IP': static_ip,
               'TMP_DUT_WAN_MASK': static_mask,
               'TMP_DUT_DEF_GW': static_gw,
               'TMP_DUT_WAN_DNS_1': static_dns1,
               'TMP_DUT_WAN_DNS_2': static_dns2,
            """
            static_ip = os.environ.get('U_CUSTOM_STATIC_WAN_IP', '192.168.55.1')
            static_mask = os.environ.get('U_CUSTOM_STATIC_WAN_MASK', '255.255.255.0')
            static_gw = os.environ.get('U_CUSTOM_STATIC_WAN_GW', '192.168.55.254')
            static_dns1 = os.environ.get('U_CUSTOM_STATIC_WAN_DNS_1', '168.95.1.1')
            static_dns2 = os.environ.get('U_CUSTOM_STATIC_WAN_DNS_1', '192.168.55.254')

            os.environ.update({
                'TMP_DUT_WAN_IP': static_ip,
                'TMP_DUT_WAN_MASK': static_mask,
                'TMP_DUT_DEF_GW': static_gw,
                'TMP_DUT_WAN_DNS_1': static_dns1,
                'TMP_DUT_WAN_DNS_2': static_dns2,
            })

            return True

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

        if not self.staticIP and str(self.protocol).lower() == 'static'.lower():
            rc_TMP_DUT_WAN_IP = re.findall(m_TMP_DUT_WAN_IP, ctnt)
            if len(rc_TMP_DUT_WAN_IP) > 0:
                ip_start, ip_end = rc_TMP_DUT_WAN_IP[0]
                print 'AT_INFO : ip range %s -> %s' % (ip_start, ip_end)
                static_ip_net = '.'.join(ip_start.split('.')[:-1])
                static_ip_host = str((int(ip_start.split('.')[-1]) + int(ip_end.split('.')[-1])) / 2)
                self.staticIP = static_ip_net + '.' + static_ip_host
                print 'AT_INFO : static ip :', self.staticIP
                self.guisetupDict["static_ip"] = self.staticIP
                os.environ.update({'TMP_DUT_WAN_IP': self.staticIP, })
            else:
                print 'AT_ERROR : get static ip Fail!'
                return False
        if not self.staticMASK and str(self.protocol).lower() == 'static'.lower():
            rc_TMP_DUT_WAN_MASK = re.findall(m_TMP_DUT_WAN_MASK, ctnt)
            if len(rc_TMP_DUT_WAN_MASK) > 0:
                self.staticMASK = rc_TMP_DUT_WAN_MASK[0]
                print 'AT_INFO : static mask ', self.staticMASK
                self.guisetupDict["static_mask"] = self.staticMASK
                os.environ.update({'TMP_DUT_WAN_MASK': self.staticMASK, })
            else:
                print 'AT_ERROR : get static mask Fail!'
                return False
        if not self.staticGW and str(self.protocol).lower() == 'static'.lower():
            rc_TMP_DUT_DEF_GW = re.findall(m_TMP_DUT_DEF_GW, ctnt)
            if len(rc_TMP_DUT_DEF_GW) > 0:
                self.staticGW = rc_TMP_DUT_DEF_GW[0]
                print 'AT_INFO : static_gw', self.staticGW
                self.guisetupDict["static_gw"] = self.staticGW
                os.environ.update({'TMP_DUT_DEF_GW': self.staticGW, })
            else:
                print 'AT_ERROR : get static gw Fail!'
                return False
        if self.dns or str(self.protocol).lower() == 'static'.lower():
            rc_TMP_DUT_WAN_DNS12 = re.findall(m_TMP_DUT_WAN_DNS12, ctnt)
            if len(rc_TMP_DUT_WAN_DNS12) > 0:
                def_static_dns1, def_static_dns2 = rc_TMP_DUT_WAN_DNS12[0]
            else:
                print 'AT_ERROR : get static dns Fail!'
                return False
            if self.dns:
                static_dns1 = str(self.dns).split(',')[0]
                static_dns2 = str(self.dns).split(',')[1]
                if static_dns1 == '-1':
                    static_dns1 = def_static_dns1
                if static_dns2 == '-1':
                    static_dns2 = def_static_dns2
            else:
                static_dns1 = def_static_dns1
                static_dns2 = def_static_dns2

            print 'AT_INFO : static_dns1', static_dns1
            print 'AT_INFO : static_dns2', static_dns2
            self.guisetupDict["dns"] = static_dns1 + ',' + static_dns2
            os.environ.update({'TMP_DUT_WAN_DNS_1': static_dns1, })
            os.environ.update({'TMP_DUT_WAN_DNS_2': static_dns2, })

        return True

    def swap_link(self):
        """
        """

        if self.disconnect:
            if self.disconnection():
                pass
            else:
                return False

        if self.setmode:
            if self.set_dslam():
                pass
            else:
                return False

        if self.wanserversetup:

            if self.restart_wan_server():
                pass
            else:
                return False

        if self.rebootdut:
            if self.reboot_dut():
                pass
            else:
                return False

        if self.guisetup:
            if self.gui_setup():
                pass
            else:
                return False

        if self.resumeconnect:
            if self.reset_swb_require_port():
                pass
            else:
                return False

        return True


def main():
    """
    main
    """
    usage = "python SwapWANLink_s.py [-l <ADSL|VDSL>] [-t tag] [-b]\n"
    usage = usage + "[-v <17a|12a|12b|8a|8b|8c|8d>] [-a <glite|gdmt|t1413|auto|adsl2|adsl2+>]\n"
    usage = usage + "[-p <protocol>] [-x <pvc 0/32>] [-P <port 1|2>]\n"
    usage = usage + "[-d <disconDUT_SWB>] [-s <setdslam>] [-w <setupwanserver>] [-u <rebootdut>] [-g <guisetup>] [-j <linkDUT_SW>]\n"
    usage = usage + "[ --staticIP <ip>] [ --staticGW <gw>] [ --staticMASK <mask>] [ --dns <dns>] [-k <dslamtype>]"
    parser = OptionParser(usage=usage)

    parser.add_option("-l", "--linemode", dest="linemode",
                      help="linemode , ADSL VDSL or ETH.")

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

    parser.add_option("-d", "--disconDUT_SWB", dest="disconnect", action='store_true', default=False,
                      help="disconnect the link btw DUT & SWB")
    parser.add_option("-j", "--linkDUT_SWB", dest="resumeconnect", action='store_true', default=False,
                      help="resume connection btw DUT & SWB")
    parser.add_option("-g", "--guisetup", dest="guisetup", action='store_true', default=False,
                      help="gui setup")
    parser.add_option("-w", "--wanserversetup", dest="wanserversetup", action='store_true', default=False,
                      help="wan server setup")
    parser.add_option("-u", "--rebootdut", dest="rebootdut", action='store_true', default=False,
                      help="rebootdut")
    parser.add_option("--backupDslam", dest="backupDslam", action='store_true', default=False,
                      help="backupDslam")
    parser.add_option("--staticIP", dest="staticIP",
                      help="staticIP")
    parser.add_option("--staticGW", dest="staticGW",
                      help="staticGW")
    parser.add_option("--staticMASK", dest="staticMASK",
                      help="staticMASK")
    parser.add_option("--dns", dest="dns",
                      help="dns")

    (options, args) = parser.parse_args()
    tag = ''
    protocol = ''
    vdslmode = ''
    adslmode = ''
    connectport = ''
    pvc = ''
    linemode = ''
    disconnect = False
    resumeconnect = False
    guisetup = False
    wanserversetup = False
    rebootdut = False
    backupDslam = False
    staticIP = ''
    staticGW = ''
    staticMASK = ''
    dns = ''

    if not len(args) == 0:
        print args
    if options.backupDslam:
        backupDslam = True

    if options.staticIP:
        staticIP = options.staticIP

    if options.staticGW:
        staticGW = options.staticGW

    if options.staticMASK:
        staticMASK = options.staticMASK

    if options.dns:
        dns = options.dns

    if options.rebootdut:
        rebootdut = True

    if options.wanserversetup:
        wanserversetup = True

    if options.bonding:
        bonding = True
    else:
        bonding = False

    if options.disconnect:
        disconnect = True

    if options.guisetup:
        guisetup = True

    if options.resumeconnect:
        resumeconnect = True

    if options.connectport:
        connectport = options.connectport

    if options.adslmode:
        adslmode = options.adslmode

    if options.pvc:
        pvc = options.pvc

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

    l_swap = SwapWANLink_s(linemode, protocol, tag, bonding, checkmode, setmode, reset_dslam_port, vdslmode, adslmode,
                           pvc, connectport, disconnect, resumeconnect, guisetup, wanserversetup, rebootdut, staticIP,
                           staticGW, staticMASK, dns, backupDslam)
    if backupDslam:
        rc = l_swap.backup_dslam()
    else:
        rc = l_swap.swap_link()

    return rc


if __name__ == '__main__':
    rc = main()
    if rc:
        exit(0)
    else:
        print usage
        exit(1)
