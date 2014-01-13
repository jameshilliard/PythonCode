#!/usr/bin/python -u

"""
This tool is used to Set DSLAM to ADSL,VDSL(single,bonding,8a,8b,etc)

Usage :
    python SetDSLAM_Adtran.py [-l <VDSL>] [-t tag] [-b] [-m <8A|8B|8C|12A>] [-d]
"""
__author__ = "pwang"
__version__ = "1.0"
__history__ = """
Rev 1.0 : 2013/06/27
    Initial version for Adtran DSLAM
"""
import os, sys, re
import time

from pprint import pprint
from pprint import pformat
import logging
from copy import deepcopy
import os, re, select, subprocess, time
import signal
from optparse import OptionParser
import db_helper

try:
    import pexpect
except:
    print 'Please install pexpect first'
    os.system('yum install -y pexpect')
    exit(1)


class SetDSLAM():
    """
    """
    _child = None
    _loghdlr = None
    _logger = None
    _login_ip = ''
    _login_username = ''
    _login_password = ''
    _login_port = ''
    _login_cmd = ''
    _base_prompt = 'TA5000.*#'
    _login_prompts = ['Connection closed by foreign host', 'User name:', 'Password:', _base_prompt, pexpect.EOF,
                      pexpect.TIMEOUT]
    _error_prompts = ['Invalid', 'Unrecognized']
    _testbed = ''
    _dslam_type = ''

    #    _line_profile_index = ''
    _profile_name = ''
    #    _line_template_index = ''
    #    _line_template_name = ''
    #frameid/slotid/portid
    _dslam_fsp = []
    _dslam_fs = ''
    _dslam_primary_fsp = ''
    _dslam_second_fsp = ''
    _dslam_port = []
    _dslam_primary_port = ''
    _dslam_second_port = ''
    _vlan = ''
    _bond_group_flag = ''
    _eth = ''
    _pvc = ''
    _discover_code = ''

    _linemode = ''
    _bonding = False
    _tag = '0'
    _vdslmode = '8a'
    _adslmode = 'adsl2+'
    _vpi = ''
    _vci = ''
    _using_port = ''
    _using_fsp = ''
    #    _if_prompt = ''
    #    _cf_prompt = ''
    _layer2mode = ''
    _connectport = ''
    _using_port = ''

    def __init__(self, linemode='', tag='0', bonding=False, vdslmode='', testbed='', dslamtype='', adslmode='', pvc='',
                 connectport=''):
        """
        """
        if linemode:
            self._linemode = linemode

        #        if self._linemode != 'ADSL':
        #            print 'AT_ERROR : Adtran DSLAM only support ADSL mode!'
        #            exit(1)

        self._bonding = bonding
        self._tag = tag
        if vdslmode:
            self._vdslmode = vdslmode

        if connectport:
            self._connectport = connectport

        if pvc:
            self._pvc = pvc

        if self._linemode == 'ADSL':
            if not self._pvc:
                print 'AT_ERROR : VPI/VCI is Null!'
                exit(1)

            repvc = '[0-9]+/[0-9]+'
            rc = re.findall(repvc, self._pvc)
            if not rc:
                print 'AT_ERROR : pvc ' + self._pvc + ' format Error!'
                exit(1)
            self._vpi = pvc.split('/')[0]
            self._vci = pvc.split('/')[1]

        if adslmode:
            self._adslmode = adslmode
        self._adslmode = self._adslmode.lower()

        if self._bonding:
            if self._linemode == 'ADSL':
                self._layer2mode = self._linemode + '_B_' + self._adslmode
            elif self._linemode == 'VDSL':
                self._layer2mode = self._linemode + '_B_' + self._vdslmode
        else:
            if self._linemode == 'ADSL':
                self._layer2mode = self._linemode + '_S_' + self._adslmode
            elif self._linemode == 'VDSL':
                self._layer2mode = self._linemode + '_S_' + self._vdslmode

        if testbed:
            self._testbed = testbed
        if dslamtype:
            self._dslam_type = dslamtype

        print 'The Known Info:'
        print 'testbed     :', self._testbed
        print 'dslam       :', self._dslam_type
        print 'linemode    :', self._linemode
        print 'bonding     :', self._bonding
        print 'tag         :', self._tag
        print 'adslmode    :', self._adslmode
        print 'vdslmode    :', self._vdslmode
        print 'vpi         :', self._vpi
        print 'vci         :', self._vci
        print 'pvc         :', self._pvc
        #        print 'line_profile:', self._profile_name

        if not self._dslam_type:
            print 'AT_ERROR : dslam_type Unknown,Please define it by U_DSLAM_TYPE or -k!'
            exit(1)
        if not self._testbed:
            print 'AT_ERROR : testbed Unknown,Please define it by G_TBNAME or -s!'
            exit(1)

        try:
            (self._profile_name, self._dslam_fsp, self._dslam_fs, self._dslam_primary_fsp, self._dslam_second_fsp,
             self._dslam_port, self._dslam_primary_port, self._dslam_second_port, self._vlan, self._bond_group_flag,
             self._eth, self._tag) = self.get_info_from_database()
        except Exception, e:
            print e
            exit(1)
        #
        #        self._if_prompt = 'MA5662\(config-if-vdsl-' + self._dslam_fs + '\)#'
        #        self._cf_prompt = 'MA5662\(config\)#'

        print '\nThe database Info:'
        #        print '_line_profile_index :', self._line_profile_index
        #        print '_line_template_index:', self._line_template_index
        #        print '_line_template_name :', self._line_template_name
        #        print '_dslam_fsp          :', self._dslam_fsp
        #        print '_dslam_fs           :', self._dslam_fs
        #        print '_dslam_primary_fsp  :', self._dslam_primary_fsp
        #        print '_dslam_second_fsp   :', self._dslam_second_fsp
        print 'xdsl profile       :', self._profile_name
        print 'dslam_port         :', self._dslam_port
        print 'dslam_primary_port :', self._dslam_primary_port
        print 'dslam_second_port  :', self._dslam_second_port
        print 'vlan               :', self._vlan
        print 'bond_group         :', self._bond_group_flag
        print '_tag               :', self._tag
        #        print '_discover_code      :', self._discover_code
        #        print 'pvc                :', self._pvc
        #        self.vpi = self._pvc.split('/')[0]
        #        self.vci = self._pvc.split('/')[1]
        #        print 'vpi                :', self._vpi
        #        print 'vci                :', self._vci
        #        print 'eth                :', self._eth

        if str(self._connectport) == str(2) and not self._bonding:
            self._using_port = self._dslam_second_port
            self._using_fsp = self._dslam_second_fsp
        else:
            self._using_port = self._dslam_primary_port
            self._using_fsp = self._dslam_primary_fsp

        print 'using_port           :', self._using_port
        print 'using_fsp            :', self._using_fsp

        self._logger = logging.getLogger('SetDSLAM')
        if self._loghdlr:
            self._logger.removeHandler(self._loghdlr)
            self._loghdlr.close()
            self._loghdlr = None

        if not self._loghdlr:
            G_CURRENTLOG = os.getenv('G_CURRENTLOG', '/root/automation/logs')
            print 'G_CURRENTLOG', G_CURRENTLOG
            logfile = os.path.join(G_CURRENTLOG, 'SetDSLAM.CMD')
            self._loghdlr = logging.FileHandler(logfile)
            FORMAT = '[%(asctime)-15s %(levelname)-s] %(message)s'
            self._loghdlr.setFormatter(logging.Formatter(FORMAT))
            self._logger.addHandler(self._loghdlr)
            self._logger.setLevel(11)

    def error(self, msg):
        """
        log error
        """
        msg = str(msg)
        if self._logger:
            self._logger.error('[FAIL] ' + msg)

    def info(self, msg):
        """
        log info
        """
        msg = str(msg)
        if self._logger:
            self._logger.info('[PASS] ' + msg)

    def get_info_from_database(self):
        """
         #     Column     Type     Collation     Attributes     Null     Default     Extra     Action
    1     TBNAME     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    2     DSLAMTYPE     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    3     PORT     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    4     MODE     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    5     TAG     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    6     PVC     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    7     ETHNo     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    8     VLAN     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    9     LineProfile     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    10     LineTemplate     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    11     BondGroupIndex     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    12     BondGroupMainPort     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    13     BondGrouplinkPort     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    14     DiscoverCode     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    (1L, (('at_sh1', 'Adtran', 'NA', 'VDSL_B_8B', '101', 'NA', '300', '405', '112', '120', '5', '0/1/17', '0/1/18', '0000-0000-0001'),))
        """
        print '\n' + '#' * 50 + 'Enter function get_info_from_database'
        profile_name = '';
        fsp = [];
        fs = '';
        mfsp = '';
        sfsp = '';
        port = [];
        mport = '';
        vlan = '';
        bond_group = '';
        pvc = '';
        eth = '';
        tag = '';
        query_dict = {'TBNAME': self._testbed, 'DSLAMTYPE': self._dslam_type, 'MODE': self._layer2mode,
                      'TAG': self._tag}
        if self._linemode == 'ADSL':
            query_dict = {'TBNAME': self._testbed, 'DSLAMTYPE': self._dslam_type, 'MODE': self._layer2mode}
        mytuple = db_helper.queryTBDSLAM(query_dict)
        print mytuple
        num = str(mytuple[0])
        if num == '1':
            print 'AT_INFO : Find 1 data!'
        elif num == '0':
            print 'AT_ERROR : Can\'t find data!'
            exit(1)
        else:
            print 'AT_ERROR : Find ' + num + ' data!'
            exit(1)
        profilename = mytuple[1][0][8]
        tag = mytuple[1][0][4]
        pvc = mytuple[1][0][5]
        eth = mytuple[1][0][6]
        vlan = mytuple[1][0][7]
        #        profile_index = mytuple[1][0][8]
        #        template_index = mytuple[1][0][9]
        bond_group = mytuple[1][0][10]
        #        discovercode = mytuple[1][0][13]

        #        template_name = profile_index + '_' + profilename
        #        refsp = '[0-9]/[0-9]+/[0-9]+'

        #if self._bonding:
        mfsp = mytuple[1][0][11]
        rc = re.findall(refsp, mfsp)
        if not rc:
            print 'AT_ERROR : frameid/slotid/portid ' + mfsp + ' format Error!'
            exit(1)
        sfsp = mytuple[1][0][12]
        rc = re.findall(refsp, sfsp)
        if not rc:
            print 'AT_ERROR : frameid/slotid/portid ' + sfsp + ' format Error!'
            exit(1)
        fsp = [mfsp, sfsp]
        mport = mfsp.split('/')[2]
        sport = sfsp.split('/')[2]
        port = [mport, sport]
        #        else:
        #            mfsp = mytuple[1][0][2]
        #            rc = re.findall(refsp, mfsp)
        #            if not rc:
        #                print 'AT_ERROR : frameid/slotid/portid ' + mfsp + ' format Error!'
        #                exit(1)
        #            fsp = [mfsp]
        #            mport = mfsp.split('/')[2]
        #            port = [mport]
        fs = mfsp.split('/')[0] + '/' + mfsp.split('/')[1]
        return profilename, fsp, fs, mfsp, sfsp, port, mport, sport, vlan, bond_group, eth, tag


    def set(self):
        """
        """
        print '\n' + '#' * 50 + 'Begin to Set Adtran DSLAM configuration!'
        if self.login():
            pass
        else:
            return False

        if self.check_user():
            pass
        else:
            self.logout(False)
            return False

        #        if self.check_profile(self._profile_name):
        #            pass
        #        else:
        #            self.logout(False)
        #            return False

        if self.delete_bond_group():
            pass
        else:
            self.logout(False)
            return False

        if self.disable_port():
            pass
        else:
            self.logout(False)
            return False

        if self._bonding:
            if self._linemode == 'ADSL':
                if self.enable_port_and_set_adsl_work_mode(self._dslam_primary_fsp, self._adslmode):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.enable_port_and_set_adsl_work_mode(self._dslam_second_fsp, self._adslmode):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.set_pvc(self._dslam_primary_fsp, self._pvc):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.bond_bonding_group_and_evc_profile(self._dslam_primary_fsp):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.bond_bonding_group_and_evc_profile(self._dslam_second_fsp):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.create_adsl_bonding_group():
                    pass
                else:
                    self.logout(False)
                    return False

            else:
                if self.enable_port_and_set_vdsl_work_mode(self._dslam_primary_fsp, self._vdslmode):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.enable_port_and_set_vdsl_work_mode(self._dslam_second_fsp, self._vdslmode):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.set_vdsl_profile(self._dslam_primary_fsp):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.set_vdsl_profile(self._dslam_second_fsp):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.create_vdsl_bonding_group():
                    pass
                else:
                    self.logout(False)
                    return False
                if self.bond_bonding_group_and_evc_profile(self._dslam_primary_fsp):
                    pass
                else:
                    self.logout(False)
                    return False
        else:
            if self._linemode == 'ADSL':
                if self.enable_port_and_set_adsl_work_mode(self._using_fsp, self._adslmode):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.set_pvc(self._using_fsp, self._pvc):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.bond_port_profile_adsl(self._dslam_fs, self._dslam_fsp, self._profile_name):
                    pass
                else:
                    self.logout(False)
                    return False
            else:
                if self.enable_port_and_set_vdsl_work_mode(self._using_fsp):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.set_vdsl_profile(self._using_fsp):
                    pass
                else:
                    self.logout(False)
                    return False
                if self.bond_port_profile_vdsl(self._dslam_fs, self._dslam_fsp, self._profile_name):
                    pass
                else:
                    self.logout(False)
                    return False

        self.save()
        self.logout(True)
        return True

    def remove(self):
        """
        """
        print '\n' + '#' * 50 + 'Begin to Remove Adtran DSLAM configuration!'
        if self.login():
            pass
        else:
            return False

        if self.check_user():
            pass
        else:
            self.logout(False)
            return False

        if self.backup_pvid(self._dslam_port):
            pass
        else:
            self.logout(False)
            return False

        if self.delete_pvc_port(self._dslam_port):
            pass
        else:
            self.logout(False)
            return False

        if self.delete_vlan(self._vlan):
            pass
        else:
            self.logout(False)
            return False

        if self.delete_bond_group(self._bond_group_flag):
            pass
        else:
            self.logout(False)
            return False

        if self.backup_optionmask(self._dslam_port):
            pass
        else:
            self.logout(False)
            return False

        if self.disable_port(self._dslam_port):
            pass
        else:
            self.logout(False)
            return False

        self.save()
        self.logout(True)
        return True

    def subproc(self, cmdss, timeout=3600):

        """
        subprogress to run command
        """
        rc = None
        output = ''

        print '    Commands to be executed :', cmdss

        all_rc = 0
        all_output = ''

        cmds = cmdss.split(';')

        for cmd in cmds:
            if not cmd.strip() == '':
                print 'INFO : executing > ', cmd

                try:
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

            all_rc += rc
            all_output += output

        return all_rc, all_output

    def login(self):
        """
        """
        print '\n' + '#' * 50 + 'Enter function login'
        self._login_ip = os.getenv('U_DSLAM_TELNET_IP')
        self._login_username = os.getenv('U_DSLAM_TELNET_USER')
        self._login_password = os.getenv('U_DSLAM_TELNET_PWD')
        self._login_port = os.getenv('U_DSLAM_TELNET_PORT')
        print 'U_DSLAM_TELNET_IP    :', self._login_ip
        print 'U_DSLAM_TELNET_USER  :', self._login_username
        print 'U_DSLAM_TELNET_PWD   :', self._login_password
        print 'U_DSLAM_TELNET_PORT  :', self._login_port
        if not self._login_ip:
            print 'AT_ERROR: U_DSLAM_TELNET_IP is Null!'
            return False
        if not self._login_username:
            print 'AT_ERROR: U_DSLAM_TELNET_USER is Null!'
            return False
        if not self._login_password:
            print 'AT_ERROR: U_DSLAM_TELNET_PWD is Null!'
            return False
        self._login_cmd = 'telnet ' + self._login_ip
        for j in range(30):
            i = 0
            self._child = pexpect.spawn(self._login_cmd, timeout=120)
            self._child.logfile = sys.stdout
            while i < 10:
                i = i + 1
                try:
                    index = self._child.expect(self._login_prompts)
                    if index == 0:
                        self._child.close(force=True)
                        break
                    elif index == 1:
                        self._child.sendline(self._login_username)
                    elif index == 2:
                        self._child.sendline(self._login_password)
                    elif index == 3:
                        print '\nlogin success'
                        return True
                    else:
                        return False
                except pexpect.EOF:
                    return False
                except pexpect.TIMEOUT:
                    return False
        return False

    def check_user(self):
        """
        show users login-stats local
        """
        cmd = 'show users login-stats local'
        for i in range(120):
            self._child.sendline(cmd)
            try:
                index = self._child.expect([self._base_prompt, pexpect.EOF, pexpect.TIMEOUT])
                res = self._child.before
                if index == 0:
                    (rc, result) = self.subproc('echo "' + res + '"|grep -E "' + 'telnet |web "|wc -l')
                    result = int(result)
                    print 'rc', rc
                    print 'result', result
                    if result > 1:
                        print 'AT_WARNING : User over limit!'
                        if i >= 59:
                            self.error(cmd)
                            return False
                        time.sleep(5)
                        pass
                    elif result == 1:
                        break
                    else:
                        self.error(cmd)
                        return False
                else:
                    self.error(cmd)
                    return False
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                self.error(cmd)
                return False
        self.info(cmd)
        return True

    def delete_bond_group(self):
        """
        Step1.4
        TA5000#interface efm-group 1/Slot_ID
        TA5000#no link link_ID (port ID)
        TA5000#no active-links-minimum 1
        TA5000#no shutdown
        TA5000#exit
        """
        cli = ['interface efm-group ' + self._dslam_fs, 'no link link_ID ' + self._using_port,
               'no active-links-minimum 1', 'no shutdown', 'exit']
        if self.common_method(cli=cli, fuc='delete_bond_group'):
            return True
        return False

    def disable_port(self):
        """
        Step1.5
        TA5000#configure terminal
        TA5000#interface VDSL PORT_ID
        TA5000#shutdown
        
        TA5000#exit
        TA5000#interface atm port_ID
        TA5000#shutdown
        TA5000#exit
        """
        cli = ['configure terminal', 'interface VDSL ' + self._dslam_primary_port, 'shutdown', 'exit',
               'interface atm ' + self._dslam_primary_port, 'shutdown', 'exit']
        if self.common_method(cli=cli, fuc='disable_port'):
            pass
        else:
            return False
        cli = ['configure terminal', 'interface VDSL ' + self._dslam_second_port, 'shutdown', 'exit',
               'interface atm ' + self._dslam_second_port, 'shutdown', 'exit']
        if self.common_method(cli=cli, fuc='disable_port'):
            return True
        return False

    def enable_port_and_set_adsl_work_mode(self, fsp, mode):
        """
        Step2.1-2.2
        TA5000#
        TA5000#configure terminal
        TA5000#interface vdsl 1/1/9
        TA5000#service-mode adsl2+
        TA5000#exit
        TA5000#
        TA5000#interface atm 1/1/9
        TA5000#mac limit 8
        TA5000#no shutdown
        TA5000#exit
        """
        cli = ['configure terminal', 'interface vdsl ' + fsp, 'service-mode ' + mode, 'exit', 'interface atm ' + fsp,
               'mac limit 8', 'no shutdown', 'exit']
        if self.common_method(cli=cli, fuc='enable_port_and_set_adsl_work_mode'):
            return True
        return False


    def set_pvc(self, fsp, pvc):
        """
        Step2.3
        TA5000#interface atm 1/1/9.1
        TA5000#pvc 0/32
        ATM Subinterface converted to ATM VCL
        TA5000#no shutdown
        TA5000#exit
        """
        cli = ['interface atm ' + fsp + '.1', 'pvc ' + pvc, 'encapsulation ethernet', 'no shutdown', 'exit']
        if self.common_method(cli=cli, fuc='set_pvc'):
            return True
        return False

    def bond_port_profile_adsl(self, fs, fsp, profile):
        """
        Step2.4
        TA5000#evc-map "adslb9" 1/1
        TA5000#connect uni atm 1/1/9.1
        TA5000#connect evc "v2000"
        TA5000#encapsulation ethernet
        TA5000#subscriber access dhcp mode authenticate
        TA5000#subscriber access pppoe mode authenticate
        TA5000#no shutdown
        TA5000#
        TA5000#exit
        """
        cli = ['evc-map "adslb9" ' + fs, 'connect uni atm ' + fsp + '.1', 'connect evc "' + profile + '"',
               'encapsulation ethernet',
               'subscriber access dhcp mode authenticate', 'subscriber access pppoe mode authenticate', 'no shutdown',
               'exit']
        if self.common_method(cli=cli, fuc='bond_port_profile_adsl'):
            return True
        return False

    def enable_port_and_set_vdsl_work_mode(self, fsp):
        """
        Step2.5
        TA5000#
        TA5000#interface atm 1/2/4
        TA5000#shutdown
        TA5000#exit
        TA5000#
        TA5000#interface vdsl 1/2/4
        TA5000#service-mode vdsl2
        TA5000#exit
        """
        cli = ['interface atm ' + fsp, 'shutdonw', 'exit', 'interface vdsl ' + fsp, 'service-mode vdsl2', 'exit']
        if self.common_method(cli=cli, fuc='enable_port_and_set_vdsl_work_mode'):
            return True
        return False

    def set_vdsl_profile(self, fsp):
        """
        Step2.6
        TA5000#
        TA5000#interface vdsl 1/2/4
        TA5000#$band-plan 1 band-profile 7 psd-u0 1 psd-mask 1
        VDSL config applied
        TA5000#exit
        TA5000#
        TA5000#interface efm-port 1/2/4
        TA5000#mac limit 8
        TA5000#exit
        """
        cli = ['interface vdsl ' + fsp, 'band-plan 1 band-profile 7 psd-u0 1 psd-mask 1', 'exit',
               'interface efm-port ' + fsp, 'mac limit 8', 'exit']
        if self.common_method(cli=cli, fuc='set_vdsl_profile'):
            return True
        return False

    def bond_port_profile_vdsl(self, fs, fsp, profile):
        """
        Step2.7
        TA5000#evc-map "vdslp4" 1/2
        TA5000#connect uni efm-port 1/2/4
        TA5000#match ce-vlan-id 1000
        TA5000#connect evc "v1000"
        TA5000#encapsulation ethernet
        TA5000#subscriber access pppoe mode authenticate
        TA5000#subscriber access dhcp mode authenticate
        TA5000#no shutdown
        TA5000#exit
        """
        cli = ['evc-map "vdslp4" ' + fs, 'connect uni efm-port ' + fsp, 'match ce-vlan-id 1000',
               'connect evc "' + profile + '"',
               'encapsulation ethernet', 'subscriber access pppoe mode authenticate',
               'subscriber access dhcp mode authenticate', 'no shutdown', 'exit']
        if self.common_method(cli=cli, fuc='bond_port_profile_vdsl'):
            return True
        return False


    def create_adsl_bonding_group(self):
        """
        Step2.15
        TA5000#interface atm-group 1/2/1 legacy-atm
        Created bonded group 1/2/1.
        TA5000#description "1/2/9_10"
        TA5000#link 2/9
        TA5000#link 2/10
        TA5000#no shutdown
        TA5000#exit
        """
        a = str(self._dslam_primary_fsp).split('/')[1] + str(self._dslam_primary_fsp).split('/')[2]
        b = str(self._dslam_second_fsp).split('/')[1] + str(self._dslam_second_fsp).split('/')[2]
        cli = ['interface atm-group 1/2/1 legacy-atm', 'description ' + self._bond_group_flag, 'link ' + a,
               'link ' + b, 'no shutdown', 'exit']

        if self.common_method(cli=cli, fuc='create_adsl_bonding_group'):
            return True
        return False

    def create_vdsl_bonding_group(self):
        """
        Step2.20
        TA5000#
        TA5000#inte
        TA5000#interface emf
        % Unrecognized command
        TA5000#interface emf-gr
        % Unrecognized command
        TA5000#interface emf
        % Unrecognized command
        TA5000#inter
        TA5000#interface efm
        TA5000#interface efm-gro
        TA5000#interface efm-group 1/2/15
        TA5000#alias vdslb15
        TA5000#link 2/15-16
        TA5000#acti
        TA5000#active-links-minimum 1
        TA5000#no shutdown
        TA5000#exit
        TA5000#
        """
        a = str(self._dslam_primary_fsp).split('/')[1] + str(self._dslam_primary_fsp).split('/')[2]
        b = str(self._dslam_second_fsp).split('/')[1] + str(self._dslam_second_fsp).split('/')[2]
        cli = ['interface efm-group ' + self._dslam_primary_fsp, 'alias ' + self._bond_group_flag,
               'link ' + a + '-' + self._dslam_second_port,
               'active-links-minimum 1', 'no shutdown', 'exit']

        if self.common_method(cli=cli, fuc='create_vdsl_bonding_group'):
            return True
        return False


    def bond_bonding_group_and_evc_profile(self, fsp):
        """
        Step 2.2
        TA5000#
        TA5000#evc-ma
        TA5000#evc-map vdslb15_16
        % Invalid or incomplete command
        TA5000#evc-map vdslb15_16 1/2
        TA5000#conne
        TA5000#connect uni efm
        TA5000#connect uni efm-gr
        TA5000#connect uni efm-group 1/2/15
        TA5000#enca
        TA5000#encapsulation eth
        TA5000#encapsulation ethernet
        TA5000#conn
        TA5000#connect evc "v1000"
        TA5000#encapu
        % Unrecognized command
        TA5000#enca
        TA5000#encapsulation et
        TA5000#encapsulation ethernet
        TA5000#sub
        TA5000#subscriber access
        TA5000#subscriber access dhcp
        TA5000#subscriber access dhcp mode aut
        TA5000#$scriber access dhcp mode authenticate
        TA5000#sub
        TA5000#subscriber acce
        TA5000#subscriber access pppoe
        TA5000#subscriber access pppoe mode
        TA5000#subscriber access pppoe mode aut
        TA5000#$criber access pppoe mode authenticate
        TA5000#no shu
        TA5000#no shutdown
        TA5000#eit
        % Unrecognized command
        TA5000#exit
        TA5000#exit
        TA5000#
        """

        cli = ['evc-map ' + self._profile_name + ' ' + self._dslam_fs, 'connect uni efm-group ' + fsp,
               'encapsulation ethernet',
               'scriber access dhcp mode authenticate', 'subscriber access pppoe mode authenticate', 'no shutdown',
               'exit']

        if self.common_method(cli=cli, fuc='bond_bonding_group_and_evc_profile'):
            return True
        return False


    def common_method(self, cli, fuc):

        """
        """
        function = fuc
        print '\n' + '#' * 50 + 'Enter function ' + function
        cli_cmd = cli
        for cmd in cli_cmd:
            try:
                self._child.sendline(cmd)
                self._child.expect([self._base_prompt, pexpect.EOF, pexpect.TIMEOUT])
                res = self._child.before
                for j in self._error_prompts:
                    rc = os.system('echo "' + res + '"|grep "' + str(j) + '"')
                    if rc == 0:
                        self.error(cmd)
                        return False
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                self.error(cmd)
                return False
        print '\nAT_INFO : ' + function + ' successfully!'
        return True

    def save(self):
        """
        config save
        """
        print '\n' + '#' * 50 + 'Enter function save'
        cmd = 'config save'
        self._child.sendline(cmd)
        try:
            self._child.expect(['saving configuration to flash', pexpect.EOF, pexpect.TIMEOUT])
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False

    def logout(self, rc=True):
        """
        """
        returncode = rc
        print '\n' + '#' * 50 + 'Enter function logout'
        cmd = 'exit'
        self._child.sendline(cmd)
        index = self._child.expect(['Connection closed by foreign host', pexpect.EOF, pexpect.TIMEOUT])
        self.info(cmd)
        print 'AT_INFO : ReturnCode : ', returncode
        return returncode


def main():
    """
    main
    """
    usage = "python SetDSLAM_Adtran.py [-l <ADSL|VDSL>] [-t tag] [-b] [-a <adsl2+|adsl2|gdmt|glite|t1413|annexm>] [-v <17a|12a|12b|8a|8b|8c|8d>] [-x <pvc 0/32>] [-P <1|2>] [-d]"

    parser = OptionParser(usage=usage)

    parser.add_option("-l", "--linemode", dest="linemode",
                      help="linemode , ADSL VDSL or ETC.")
    parser.add_option("-t", "--tag", dest="tag",
                      help="tag")
    parser.add_option("-v", "--vdslmode", dest="vdslmode",
                      help="vdslmode")
    parser.add_option("-a", "--adslmode", dest="adslmode",
                      help="adslmode")
    parser.add_option("-b", "--bonding", dest="bonding", action='store_true', default=False,
                      help="whether it is in bonding mode")
    parser.add_option("-d", "--remove", dest="remove", action='store_true', default=False,
                      help="remove link type")

    parser.add_option("-s", "--testbed", dest="testbed",
                      help="testbed")
    parser.add_option("-k", "--dslamtype", dest="dslamtype",
                      help="dslamtype")

    parser.add_option("-x", "--pvc", dest="pvc",
                      help="pvc")

    parser.add_option("-P", "--connectport", dest="connectport",
                      help="connectport")

    (options, args) = parser.parse_args()

    tag = '0'
    linemode = ''
    vdslmode = '8a'
    adslmode = 'adsl2+'
    testbed = os.getenv('G_TBNAME')
    dslamtype = 'Adtran'
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

    if not pvc:
        print 'AT_ERROR : VPI/VCI is Null!'
        exit(1)

    if options.testbed:
        testbed = options.testbed

    if options.dslamtype:
        dslamtype = options.dslamtype

    if options.linemode:
        linemode = options.linemode
    #    if linemode != 'ADSL':
    #        print 'AT_ERROR : Adtran DSLAM only support ADSL mode!'
    #        exit(1)

    if options.tag:
        tag = options.tag

    if options.bonding:
        bonding = True
    else:
        bonding = False

    if options.vdslmode:
        vdslmode = options.vdslmode

    if options.remove:
        remove = True
    else:
        remove = False

    rc = False
    if remove:
        setdslam = SetDSLAM(linemode, tag, bonding, vdslmode, testbed, dslamtype, adslmode, pvc, connectport)
        rc = setdslam.remove()
    else:
        setdslam = SetDSLAM(linemode, tag, bonding, vdslmode, testbed, dslamtype, adslmode, pvc, connectport)
        rc = setdslam.set()
    return rc


if __name__ == '__main__':
    rc = main()
    if not rc:
        exit(1)
