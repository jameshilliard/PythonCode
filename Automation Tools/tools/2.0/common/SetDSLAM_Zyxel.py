#!/usr/bin/python -u

"""
This tool is used to Set DSLAM to ADSL,VDSL(single,bonding,8a,8b,etc)

Usage :
    python SetDSLAM_Zyxel.py [-l <VDSL>] [-t tag] [-b] [-m <8A|8B|8C|12A>] [-d]
"""
__author__ = "pwang"
__version__ = "1.0"
__history__ = """
Rev 1.0 : 2013/06/27
    Initial version for Zyxel DSLAM
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
import SetDSLAM

try:
    import pexpect
except:
    print 'Please install pexpect first'
    os.system('yum install -y pexpect')
    exit(1)


class SetDSLAM_Zyxel():
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
    _login_prompts = ['Connection closed by foreign host', 'User name:', 'Password:', 'ras>', pexpect.EOF,
                      pexpect.TIMEOUT]
    _testbed = ''
    _dslam_type = ''

    #    _line_profile_index = ''
    _profile_name = ''
    #    _line_template_index = ''
    #    _line_template_name = ''
    #frameid/slotid/portid
    #    _dslam_fsp = []
    #    _dslam_fs = ''
    #    _dslam_primary_fsp = ''
    #    _dslam_second_fsp = ''
    _dslam_port = []
    _dslam_primary_port = ''
    _dslam_second_port = ''
    _vlan = ''
    _bond_group_flag = ''
    _eth = ''
    _pvc = os.getenv('U_DUT_DEF_VPI_VCI')
    _discover_code = ''

    _linemode = 'ADSL'
    _bonding = False
    _tag = ''
    _vdslmode = '8a'
    _adslmode = 'adsl2+'
    _vpi = ''
    _vci = ''
    #    _if_prompt = ''
    #    _cf_prompt = ''
    _layer2mode = ''
    _connectport = ''
    _using_port = ''

    def __init__(self, linemode='', tag='', bonding=False, vdslmode='', testbed='', adslmode='', pvc='', connectport='',
                 profile_name=''):
        """
        """

        if profile_name:
            self._profile_name = profile_name
        else:
            print 'AT_ERROR : profile is Null!'
            exit(1)

        if linemode:
            self._linemode = linemode

        if self._linemode != 'ADSL':
            print 'AT_ERROR : Zyxel DSLAM only support ADSL mode!'
            exit(1)

        self._bonding = bonding
        self._tag = tag
        self._tag = tag
        if self._tag:
            retag = '^[0-9]+$'
            rc = re.findall(retag, self._tag)
            if len(rc) > 0:
                pass
            else:
                self._tag = 'TAG'

        self._vdslmode = vdslmode

        if connectport:
            self._connectport = connectport

        if pvc:
            self._pvc = pvc

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
            self._layer2mode = self._linemode + '_B'
        else:
            self._layer2mode = self._linemode + '_S'

        if testbed:
            self._testbed = testbed
        #        if dslamtype:
        #            self._dslam_type = dslamtype

        print 'The Known Info:'
        print 'testbed     :', self._testbed
        #        print 'dslam       :', self._dslam_type
        print 'linemode    :', self._linemode
        print 'bonding     :', self._bonding
        print 'tag         :', self._tag
        print 'adslmode    :', self._adslmode
        print 'vpi         :', self._vpi
        print 'vci         :', self._vci
        print 'pvc         :', self._pvc
        print 'profile     :', self._profile_name

        #        if not self._dslam_type:
        #            print 'AT_ERROR : dslam_type Unknown,Please define it by U_DSLAM_TYPE or -k!'
        #            exit(1)

        if not self._testbed:
            print 'AT_ERROR : testbed Unknown,Please define it by G_TBNAME or -s!'
            exit(1)

        try:
            (self._dslam_port, self._dslam_primary_port, self._dslam_second_port, self._vlan,
             self._bond_group_flag, self._tag) = self.get_info_from_database()
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
        #        print 'xdsl profile       :', self._profile_name
        print 'dslam_port         :', self._dslam_port
        print 'dslam_primary_port :', self._dslam_primary_port
        print 'dslam_second_port  :', self._dslam_second_port
        print 'vlan               :', self._vlan
        print 'bond_group         :', self._bond_group_flag
        #        print '_tag                :', self._tag
        #        print '_discover_code      :', self._discover_code
        #        print 'pvc                :', self._pvc
        #        self.vpi = self._pvc.split('/')[0]
        #        self.vci = self._pvc.split('/')[1]
        #        print 'vpi                :', self._vpi
        #        print 'vci                :', self._vci
        #        print 'eth                :', self._eth

        if str(self._connectport) == str(2) and not self._bonding:
            self._using_port = self._dslam_second_port
        else:
            self._using_port = self._dslam_primary_port

        print 'main_port          :', self._using_port

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
        1     TBNAME     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    2     DslamName     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    3     MODE     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    4     TAG     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    5     VLAN     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    6     LineTemplate     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    7     BondGroupIndex     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    8     BondGroupMainPort     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    9     BondGrouplinkPort     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
    10     DiscoverCode     varchar(255)     utf8_general_ci         No     None         Change Change     Drop Drop     More Show more actions
        """
        print '\n' + '#' * 50 + 'Enter function get_info_from_database'
        profile_name = '';
        port = [];
        mport = '';
        sport = '';
        vlan = '';
        bond_group = '';
        pvc = '';
        eth = '';
        tag = '';
        mytuple = SetDSLAM.querydatabase(self._testbed, self._layer2mode, self._tag)
        if not mytuple:
            return False

        if self._tag:
            if self._tag == 'TAG':
                tag = mytuple[1][0][3]
                retag = '^[0-9]+$'
                rc = re.findall(retag, tag)
                if len(rc) > 0:
                    pass
                else:
                    print 'AT_ERROR : tag ' + tag + 'format error!'
                    return False
            else:
                tag = self._tag
        else:
            tag = ''

        #        profilename = mytuple[1][0][8]
        #pvc = mytuple[1][0][5]
        #eth = mytuple[1][0][6]
        vlan = mytuple[1][0][4]
        #        profile_index = mytuple[1][0][8]
        #        template_index = mytuple[1][0][9]
        bond_group = mytuple[1][0][6]
        #        discovercode = mytuple[1][0][13]

        #        template_name = profile_index + '_' + profilename
        #        refsp = '[0-9]/[0-9]+/[0-9]+'

        #if self._bonding:
        mport = mytuple[1][0][7]
        sport = mytuple[1][0][8]
        #        rc = re.findall(refsp, mfsp)
        #        if not rc:
        #            print 'AT_ERROR : frameid/slotid/portid ' + mfsp + ' format Error!'
        #            exit(1)
        #        sfsp = mytuple[1][0][12]
        #        rc = re.findall(refsp, sfsp)
        #        if not rc:
        #            print 'AT_ERROR : frameid/slotid/portid ' + sfsp + ' format Error!'
        #            exit(1)
        #        fsp = [mfsp, sfsp]
        #        mport = mfsp.split('/')[2]
        #        sport = sfsp.split('/')[2]
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
        #        fs = mfsp.split('/')[0] + '/' + mfsp.split('/')[1]

        return port, mport, sport, vlan, bond_group, tag

    def set(self):
        """
        """
        print '\n' + '#' * 50 + 'Begin to Set Zyxel DSLAM configuration!'
        if self.login():
            pass
        else:
            return False

        if self.check_user():
            pass
        else:
            self.logout(False)
            return False

        if self.check_profile(self._profile_name):
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

        if self.disable_annexm(self._dslam_port):
            pass
        else:
            self.logout(False)
            return False

        if self.disable_port(self._dslam_port):
            pass
        else:
            self.logout(False)
            return False

        if self._bonding:
            if self.enable_port(self._dslam_port):
                pass
            else:
                self.logout(False)
                return False

            if self.add_bond_group(self._bond_group_flag, self._dslam_primary_port, self._dslam_second_port):
                pass
            else:
                self.logout(False)
                return False
        else:
            if self.enable_port(self._using_port):
                pass
            else:
                self.logout(False)
                return False

        if self.bond_vlan_eth(self._vlan):
            pass
        else:
            self.logout(False)
            return False

        if self.bond_vlan_dsl(self._vlan, self._using_port):
            pass
        else:
            self.logout(False)
            return False

        if self.bond_pvc_port(self._using_port, self._vpi, self._vci, self._vlan):
            pass
        else:
            self.logout(False)
            return False
        if self._bonding:
            if self.set_work_mode(self._dslam_primary_port, self._profile_name, self._adslmode):
                pass
            else:
                self.logout(False)
                return False
            if self.set_work_mode(self._dslam_second_port, self._profile_name, self._adslmode):
                pass
            else:
                self.logout(False)
                return False
        else:
            if self.set_work_mode(self._using_port, self._profile_name, self._adslmode):
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
        print '\n' + '#' * 50 + 'Begin to Remove Zyxel DSLAM configuration!'
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

        if self.disable_annexm(self._dslam_port):
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
         _login_prompts = ['Connection closed by foreign host', 'User name:', 'Password:', 'ras>', pexpect.EOF, pexpect.TIMEOUT]
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
        sys user online
        """
        cmd = 'sys user online'
        for i in range(20):
            self._child.sendline(cmd)
            try:
                index = self._child.expect(['ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                res = self._child.before

                if index == 0:
                    (rc, result) = self.subproc('echo "' + res + '"|grep -E "' + 'telnet |web "|wc -l')
                    result = int(result)
                    print 'rc', rc
                    print 'result', result
                    if result > 1:
                        print 'AT_WARNING : User over limit!'
                        print 'logout and wait 60 seconds'
                        self.logout(True)
                        time.sleep(60)
                        if not self.login():
                            return False
                    elif result == 1:
                        self.info(cmd)
                        return True
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
        self.error(cmd)
        return False


    def check_profile(self, name):
        """
        """
        print '\n' + '#' * 50 + 'Enter function check_profile'
        profile_name = str(name)
        cmd = 'adsl profile show ' + profile_name
        self._child.sendline(cmd)
        try:
            index = self._child.expect(
                ['invalid command.*\r\nras> *$', 'not exist.*\r\nras> *$', 'down shift margin.*\r\nras> *$',
                 pexpect.EOF, pexpect.TIMEOUT])
            res = self._child.before
            (rc, result) = self.subproc('echo "' + res + '"|grep ' + '"max rate.*"')
            if index == 0:
                self.error(cmd)
                return False
            elif index == 1:
            #                cmd = 'adsl profile set ' + profile_name + ' interleave 512 2048 6 0 31 32 6 0 31 64 3 9 3 9 '
            #                self._child.sendline(cmd)
            #                index = self._child.expect([':', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
            #                if index == 1:
            #                    pass
            #                else:
            #                    self.error(cmd)
            #                    return False
                self.error(cmd)
                return False
            elif index == 2:
                pass
            else:
                self.error(cmd)
                return False
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False
        print '\nAT_INFO : check_profile Successfully!'
        self.info(cmd)
        result = str(result).strip()
        (rc, uprate) = self.subproc('echo "' + result + '"|awk -F: ' + "'{print $2}'|" + "awk '{print $1}'")
        (rc, downrate) = self.subproc('echo "' + result + '"|awk -F: ' + "'{print $2}'|" + "awk '{print $2}'")
        uprate = str(uprate).strip()
        downrate = str(downrate).strip()
        envfile = os.getenv('U_CUSTOM_UPDATE_ENV_FILE', '/root/automation/logs/current/update_env')
        set_file = open(envfile, 'w')
        set_file.write('TMP_DSLAM_DOWN_STREAM="' + downrate + ' kbps"\n')
        set_file.write('TMP_DSLAM_UP_STREAM="' + uprate + ' kbps"\n')
        set_file.close()
        return True

    def backup_pvid(self, port):
        """
        switch vlan pvid 11 1
        """
        print '\n' + '#' * 50 + 'Enter function backup_pvid'
        port = port
        if isinstance(port, list):
            for p in port:
                if p:
                    cmd = 'switch vlan pvid ' + str(p) + ' 1'
                    self._child.sendline(cmd)
                    try:
                        index = self._child.expect([': ', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                        if index == 1:
                            pass
                        else:
                            self.error(cmd)
                            return False
                    except pexpect.EOF:
                        self.error(cmd)
                        return False
                    except pexpect.TIMEOUT:
                        self.error(cmd)
                        return False
        else:
            cmd = 'switch vlan pvid ' + port + ' 1'
            self._child.sendline(cmd)
            try:
                index = self._child.expect([': ', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                if index == 1:
                    pass
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
        print '\nAT_INFO : backup_pvid Successfully!'
        return True

    def disable_port(self, port):
        """
        adsl disable 11
        """
        print '\n' + '#' * 50 + 'Enter function disable_port'
        port_list = port
        for p in port_list:
            if p:
                cmd = 'adsl disable ' + str(p)
                self._child.sendline(cmd)
                try:
                    index = self._child.expect([':', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                    if index == 1:
                        pass
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
        print '\nAT_INFO : disable port successfully!'
        return True

    def enable_port(self, port):
        """
        adsl enable 11
        """
        print '\n' + '#' * 50 + 'Enter function enable_port'
        port = port
        if isinstance(port, list):
            for p in port:
                cmd = 'adsl enable ' + str(p)
                self._child.sendline(cmd)
                try:
                    index = self._child.expect([':', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                    if index == 1:
                        pass
                    else:
                        self.error(cmd)
                        return False
                except pexpect.EOF:
                    self.error(cmd)
                    return False
                except pexpect.TIMEOUT:
                    self.error(cmd)
                    return False
        else:
            cmd = 'adsl enable ' + str(port)
            self._child.sendline(cmd)
            try:
                index = self._child.expect([':', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                if index == 1:
                    pass
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
        #        time.sleep(2)
        #        for p in port_list:
        #            cmd = 'adsl show ' + str(p)
        #            self._child.sendline(cmd)
        #            try:
        #                index = self._child.expect(['ras>', pexpect.EOF, pexpect.TIMEOUT])
        #                res = self._child.before
        #                (rc, result) = self.subproc('echo "' + res + '"|grep "' + str(p) + '  *V"')
        #                result = result.strip()
        #                print 'rc', rc
        #                print 'result', result
        #                if str(rc) == str(0):
        #                    pass
        #                else:
        #                    print '\nAT_ERROR : adsl enable ' + str(p) + ' FAILED!'
        #                    self.error(cmd)
        #                    return False
        #            except pexpect.EOF:
        #                self.error(cmd)
        #                return False
        #            except pexpect.TIMEOUT:
        #                self.error(cmd)
        #                return False
        print '\nAT_INFO : enable_port successfully!'
        return True

    def delete_vlan(self, vid):
        """
        switch vlan delete 332
        """
        print '\n' + '#' * 50 + 'Enter function delete_vlan'
        vlan = str(vid)
        while True:
            cmd = 'switch vlan delete ' + vlan
            self._child.sendline(cmd)
            try:
                index = self._child.expect(
                    ['not exists.*\r\nras> *$', 'number format.*\r\nras> *$', '1\.\.4094.*\r\nras> *$',
                     'referenced by PVCs/PVID\r\n *ras> *$', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                if index == 0:
                    break
                elif index == 1 or index == 2:
                    self.error(cmd)
                    return False
                elif index == 3:
                    cmd = 'adsl pvc show'
                    self._child.sendline(cmd)
                    index = self._child.expect(['ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                    res = self._child.before
                    #                print('output(%d) L [[%s]]' % (len(res),res))
                    if index == 0:
                        (rc, result) = self.subproc(
                            'echo "' + res + '"|grep ' + vlan + "|head -n1|awk '{print $1 " + '" ' + '" $2 "' + ' " $3}' + "'")
                        result = result.strip()
                        reresult = '[0-9]+  *[0-9]+  *[0-9]+'
                        rc = re.findall(reresult, result)
                        if rc:
                            cmd = 'adsl pvc delete ' + result
                            self._child.sendline(cmd)
                            index = self._child.expect(
                                ['invalid command', 'usage:', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                            if index == 2:
                                pass
                            else:
                                self.error(cmd)
                                return False
                        else:
                            print 'AT_ERROR : Can\'t find the vlan referenced by PVCs/PVID'
                            self.error(cmd)
                            return False
                    else:
                        self.error(cmd)
                        return False
                elif index == 4:
                    break
                else:
                    self.error(cmd)
                    return False
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                self.error(cmd)
                return False
        print '\nAT_INFO : delete_vlan Successfully!'
        self.info(cmd)
        return True


    def bond_vlan_eth(self, vid):
        """
        """
        print '\n' + '#' * 50 + 'Enter function bond_vlan_eth'
        vlan = str(vid)
        cmd = 'switch vlan set ' + vlan + ' enet1,enet2:FT'
        self._child.sendline(cmd)
        try:
            index = self._child.expect([': ', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
            if index == 1:
                pass
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
        print '\nAT_INFO : bond_vlan_eth Successfully!'
        return True

    def bond_vlan_dsl(self, vid, port):
        """
        switch vlan set 504 11:FU
        """
        print '\n' + '#' * 50 + 'Enter function bond_vlan_dsl'
        vlan = str(vid)
        port = str(port)
        cmd = 'switch vlan set ' + vlan + ' ' + port + ':FU'
        self._child.sendline(cmd)
        try:
            index = self._child.expect([': ', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
            if index == 1:
                pass
            else:
                self.error(cmd)
                return False
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False
        print '\nAT_INFO : bond_vlan_dsl Successfully!'
        self.info(cmd)
        return True

    def delete_pvc_port(self, port):
        """
        adsl pvc delete 11 0 35
        """
        print '\n' + '#' * 50 + 'Enter function delete_pvc_port'
        port_list = port
        cmd = 'adsl pvc show'
        self._child.sendline(cmd)
        try:
            index = self._child.expect(['ras> *$', pexpect.EOF, pexpect.TIMEOUT])
            res = self._child.before
            if index == 0:
                pass
            else:
                self.error(cmd)
                return False
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False
        for p in port_list:
            if p:
                (rcc, resultt) = self.subproc('echo "' + res + '"|grep ' + '"^ *' + str(p) + '  *"')
                if str(rcc) == str(0):
                    (rc, result) = self.subproc('echo "' + res + '"|grep ' + '"^ *' + str(
                        p) + '  *"' + "|head -n1|awk '{print $1 " + '" ' + '" $2 "' + ' " $3}' + "'")
                    result = result.strip()
                    print 'result', result
                    reresult = '[0-9]+  *[0-9]+  *[0-9]+'
                    rc = re.findall(reresult, result)
                    if rc:
                        cmd = 'adsl pvc delete ' + result
                        self._child.sendline(cmd)
                        try:
                            index = self._child.expect(
                                ['invalid command', 'usage:', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                            if index == 2:
                                pass
                            else:
                                self.error(cmd)
                                return False
                        except pexpect.EOF:
                            self.error(cmd)
                            return False
                        except pexpect.TIMEOUT:
                            self.error(cmd)
                            return False
                    else:
                        print 'AT_ERROR : adsl pvc show format error'
                        self.error(cmd)
                        return False
                else:
                    print 'AT_INFO : Port ' + str(p) + ' was not referenced by PVCs/PVID'

        print '\nAT_INFO : delete_pvc_port Successfully!'
        self.info(cmd)
        return True

    #    def delete_pvc_port(self, port, vpi, vci):
    #        """
    #        adsl pvc delete 11 0 35
    #        """
    #        print '\n' + '#' * 50 + 'Enter function delete_pvc_port'
    #        port = str(port)
    #        vpi = str(vpi)
    #        vci = str(vci)
    #        cmd = 'adsl pvc delete ' + port + ' ' + vpi + ' ' + vci
    #        self._child.sendline(cmd)
    #        try:
    #            index = self._child.expect(['no such channel.*\r\nras> *$', 'invalid command', 'usage:', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
    #            print self._child
    #            if index == 0 or index == 3:
    #                pass
    #            else:
    #                self.error(cmd)
    #                return False
    #        except pexpect.EOF:
    #            self.error(cmd)
    #            return False
    #        except pexpect.TIMEOUT:
    #            self.error(cmd)
    #            return False
    #        print '\nAT_INFO : delete_pvc_port Successfully!'
    #        self.info(cmd)
    #        return True

    def bond_pvc_port(self, port, vpi, vci, vid):
        """
        adsl pvc set 11 0 35 vlan 504 0 DEFVAL
        """
        print '\n' + '#' * 50 + 'Enter function bond_pvc_port'
        vlan = str(vid)
        port = str(port)
        vpi = str(vpi)
        vci = str(vci)
        cmd = 'adsl pvc set ' + port + ' ' + vpi + ' ' + vci + ' ' + vlan + ' 0 DEFVAL'
        self._child.sendline(cmd)
        try:
            index = self._child.expect([':', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
            if index == 1:
                pass
            else:
                self.error(cmd)
                return False
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False
        print '\nAT_INFO : bond_pvc_port successfully!'
        self.info(cmd)
        return True

    def delete_bond_group(self, name):
        """
        adsl gbond delete bg7
        """
        print '\n' + '#' * 50 + 'Enter function delete_bond_group'
        bond_group_name = str(name)
        cmd = 'adsl gbond delete ' + bond_group_name
        self._child.sendline(cmd)
        try:
            index = self._child.expect(
                ['no such bonding group.*\r\nras> *$', 'invalid', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
            print self._child
            if index == 0 or index == 2:
                pass
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
        print '\nAT_INFO : delete_bond_group Successfully!'

        return True

    def add_bond_group(self, name, mport, sport):

        """
        adsl gbond set bg7 11,12
        adsl gbond show
        name                            port list
        ------------------------------- ---------
        1                                     5,6
        bg7                                 11,12

        """
        print '\n' + '#' * 50 + 'Enter function add_bond_group'
        bond_group_name = str(name)
        mport = str(mport)
        sport = str(sport)
        while True:
            cmd = 'adsl gbond set ' + bond_group_name + ' ' + mport + ',' + sport
            self._child.sendline(cmd)
            try:
                index = self._child.expect(['ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                print self._child
                res = self._child.before
                command1 = 'echo "' + res + '"|grep "' + "group member is referenced by other group" + '"'
                command2 = 'echo "' + res + '"|grep "' + ':"'
                rc1 = os.system(command1)
                rc2 = os.system(command2)
                print 'rc1', rc1
                print 'rc2', rc2
                if rc1 == 0:
                    print 'rc1==0'
                    cmd = 'adsl gbond show'
                    self._child.sendline(cmd)
                    index = self._child.expect(['ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                    res = self._child.before
                    command = 'echo "' + res + '"|grep "' + mport + ',' + sport + '"' + "|awk '{print $1}'"
                    (rc, bondname) = self.subproc(command)
                    if str(rc) == str(0):
                        if self.delete_bond_group(bondname):
                            pass
                        else:
                            self.error(cmd)
                            return False
                    else:
                        self.error(cmd)
                        return False
                elif rc1 != 0 and rc2 == 0:
                    print 'rc1 != 0 and rc2 == 0'
                    self.error(cmd)
                    return False
                else:
                    break
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                self.error(cmd)
                return False

        time.sleep(2)
        cmd = 'adsl gbond show'
        self._child.sendline(cmd)
        try:
            index = self._child.expect(['ras>', pexpect.EOF, pexpect.TIMEOUT])
            res = self._child.before
            (rc, result) = self.subproc(
                'echo "' + res + '"|grep "^ *' + bond_group_name + '  *' + mport + ',' + sport + '"')
            result = result.strip()
            print 'rc', rc
            print 'result', result
            if str(rc) == str(0):
                pass
            else:
                self.error(cmd)
                return False
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False
        print '\nAT_INFO : add_bond_group Successfully!'
        self.info(cmd)
        return True

    def disable_annexm(self, port):
        """
        adsl annexm disable 11
        """
        print '\n' + '#' * 50 + 'Enter function disable_annexm'
        port_list = port
        for p in port_list:
            if p:
                cmd = 'adsl annexm disable ' + str(p)
                self._child.sendline(cmd)
                try:
                    index = self._child.expect([':', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
                    if index == 1:
                        pass
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
        print '\nAT_INFO : disable_annexm successfully!'
        return True

    def enable_annexm(self, port):
        """
        adsl annexm enable 11
        """
        print '\n' + '#' * 50 + 'Enter function enable_annexm'
        port = str(port)
        cmd = 'adsl annexm enable ' + port
        self._child.sendline(cmd)
        try:
            index = self._child.expect([':', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
            if index == 1:
                pass
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
        print '\nAT_INFO : enable_annexm successfully!'
        return True

    def set_work_mode(self, port, profile, module):
        """
        adsl profile map 19 ben111 adsl2 
        """
        print '\n' + '#' * 50 + 'Enter function set_work_mode'
        port = str(port)
        dslprofile = str(profile)
        amoduler = str(module)
        if str(module) == 'annexm':
            amoduler = 'adsl2+'
        cmd = 'adsl profile map ' + port + ' ' + dslprofile + ' ' + amoduler
        self._child.sendline(cmd)
        try:
            index = self._child.expect([':', 'ras> *$', pexpect.EOF, pexpect.TIMEOUT])
            if index == 1:
                pass
            else:
                self.error(cmd)
                return False
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False

        if str(module) == 'annexm':
            if self.enable_annexm(port):
                pass
            else:
                self.error(cmd)
                return False
        print '\nAT_INFO : set_work_mode successfully!'
        self.info(cmd)
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
    usage = "python SetDSLAM_Zyxel.py [-l <ADSL>] [-t tag] [-b] [-a <glite|gdmt|t1413|auto|adsl2|adsl2+|annexm>] [-x <pvc 0/32>] [-P <1|2>] [-d]"

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

    parser.add_option("-q", "--testbed", dest="testbed",
                      help="testbed")
    #    parser.add_option("-k", "--dslamtype", dest="dslamtype",
    #                            help="dslamtype")

    parser.add_option("-x", "--pvc", dest="pvc",
                      help="pvc")

    parser.add_option("-P", "--connectport", dest="connectport",
                      help="connectport")

    (options, args) = parser.parse_args()

    tag = ''
    linemode = 'ADSL'
    vdslmode = 'DEF'
    adslmode = 'adsl2+'
    testbed = os.getenv('G_TBNAME')
    #    dslamtype = 'zyxel'
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

    #    if options.dslamtype:
    #        dslamtype = options.dslamtype

    if options.linemode:
        linemode = options.linemode
    if linemode != 'ADSL':
        print 'AT_ERROR : Zyxel DSLAM only support ADSL mode!'
        exit(1)

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
        setdslam = SetDSLAM_Zyxel(linemode, tag, bonding, vdslmode, testbed, adslmode, pvc, connectport)
        rc = setdslam.remove()
    else:
        setdslam = SetDSLAM_Zyxel(linemode, tag, bonding, vdslmode, testbed, adslmode, pvc, connectport)
        rc = setdslam.set()
    return rc


if __name__ == '__main__':
    rc = main()
    if not rc:
        exit(1)
