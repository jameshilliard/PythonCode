#!/usr/bin/python -u

"""
This tool is used to Set DSLAM to ADSL,VDSL(single,bonding,8a,8b,etc)

Usage :
    python SetDSLAM_HuaWei.py [-l <VDSL>] [-t tag] [-b] [-m <8A|8B|8C|12A>] [-d]
"""
__author__ = "pwang"
__version__ = "1.0"
__history__ = """
Rev 1.0 : 2013/06/27
    Initial version for HuaWei DSLAM
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


class SetDSLAM_HuaWei():
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
    _login_prompts = ['Connection closed by foreign host', 'Reenter times have reached the upper limit', '>>User name:',
                      '>>User password', 'User root has used a default password. Change the password in time',
                      "Press 'Q' to break", 'No route to host', pexpect.EOF, pexpect.TIMEOUT]
    _testbed = ''
    _dslam_type = ''

    _line_profile_index = ''
    _layer2mode = ''
    _line_template_index = ''
    _line_template_name = ''
    #frameid/slotid/portid
    _dslam_fsp = []
    _dslam_fs = ''
    _dslam_primary_fsp = ''
    _dslam_second_fsp = ''
    _dslam_port = []
    _dslam_primary_port = ''
    _dslam_second_port = ''
    _vlan = ''
    _bond_group_index = ''
    _eth = ''
    _pvc = ''
    _discover_code = ''

    _linemode = 'VDSL'
    _bonding = False
    _tag = ''
    _vdslmode = 'vdsl2'

    _connectport = ''
    _using_port = ''
    _using_fsp = ''

    _if_prompt = ''
    _cf_prompt = ''

    def __init__(self, linemode='', tag='', bonding=False, vdslmode='', testbed='', connectport='', profile_name=''):
        """
        """
        if profile_name:
            self._line_profile_index = profile_name
        else:
            print 'AT_ERROR : profile is Null!'
            exit(1)

        if linemode:
            self._linemode = linemode

        if self._linemode != 'VDSL':
            print 'AT_ERROR : HuaWei DSLAM only support VDSL mode!'
            exit(1)

        self._bonding = bonding
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

        if vdslmode:
            self._vdslmode = str(vdslmode).lower()

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
        print 'vdslmode    :', self._vdslmode
        print 'profile     :', self._line_profile_index

        #        if not self._dslam_type:
        #            print 'AT_ERROR : dslam_type Unknown,Please define it by U_DSLAM_TYPE or -k!'
        #            exit(1)

        if not self._testbed:
            print 'AT_ERROR : testbed Unknown,Please define it by G_TBNAME or -q!'
            exit(1)

        try:
            (self._line_template_index, self._line_template_name,
             self._dslam_fsp, self._dslam_fs, self._dslam_primary_fsp, self._dslam_second_fsp,
             self._dslam_port, self._dslam_primary_port, self._dslam_second_port, self._vlan, self._bond_group_index,
             self._tag, self._discover_code) = self.get_info_from_database()
        except Exception, e:
            print e
            exit(1)

        self._if_prompt = 'MA5662\(config-if-vdsl-' + self._dslam_fs + '\)#'
        self._cf_prompt = 'MA5662\(config\)#'

        print '\nThe database Info:'
        #       print '_line_profile_index :', self._line_profile_index
        print '_line_template_index:', self._line_template_index
        print '_line_template_name :', self._line_template_name
        print '_dslam_fsp          :', self._dslam_fsp
        print '_dslam_fs           :', self._dslam_fs
        print '_dslam_primary_fsp  :', self._dslam_primary_fsp
        print '_dslam_second_fsp   :', self._dslam_second_fsp
        print '_dslam_port         :', self._dslam_port
        print '_dslam_primary_port :', self._dslam_primary_port
        print '_dslam_second_port  :', self._dslam_second_port
        print '_vlan               :', self._vlan
        print '_bond_group_index   :', self._bond_group_index
        print '_tag                :', self._tag
        print '_discover_code      :', self._discover_code
        #        print '_pvc                :', self._pvc
        #       print '_eth                :', self._eth
        #
        if str(self._connectport) == str(2) and not self._bonding:
            self._using_port = self._dslam_second_port
            self._using_fsp = self._dslam_second_fsp
        else:
            self._using_port = self._dslam_primary_port
            self._using_fsp = self._dslam_primary_fsp

        print 'using_port          :', self._using_port
        print 'using_fsp           :', self._using_fsp

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
        profile_index = '';
        template_index = '';
        template_name = '';
        fsp = [];
        fs = '';
        mfsp = '';
        sfsp = '';
        port = [];
        mport = '';
        sport = '';
        vlan = '';
        bond_group = '';
        tag = '';
        pvc = '';
        eth = '';
        discovercode = '';
        mytuple = SetDSLAM.querydatabase(self._testbed, self._layer2mode, self._tag)
        if not mytuple:
            return False
        profilename = mytuple[1][0][2]
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
            #pvc = mytuple[1][0][5]
            #       eth = mytuple[1][0][6]
        vlan = mytuple[1][0][4]
        #        profile_index = mytuple[1][0][8]
        template_index = mytuple[1][0][5]
        bond_group = mytuple[1][0][6]
        discovercode = mytuple[1][0][9]

        template_name = template_index + '_' + self._line_profile_index + '_' + profilename
        refsp = '[0-9]/[0-9]+/[0-9]+'

        #if self._bonding:
        mfsp = mytuple[1][0][7]
        rc = re.findall(refsp, mfsp)
        if not rc:
            print 'AT_ERROR : frameid/slotid/portid ' + mfsp + ' format Error!'
            exit(1)
        sfsp = mytuple[1][0][8]
        sport = ''
        if sfsp:
            rc = re.findall(refsp, sfsp)
            if not rc:
                print 'AT_ERROR : frameid/slotid/portid ' + sfsp + ' format Error!'
                exit(1)
            sport = sfsp.split('/')[2]
        fsp = [mfsp, sfsp]
        mport = mfsp.split('/')[2]

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

        return template_index, template_name, fsp, fs, mfsp, sfsp, port, mport, sport, vlan, bond_group, tag, discovercode

    def set(self):
        """
        """
        print '\n' + '#' * 50 + 'Begin to Set Huawei DSLAM configuration!'
        if self.login():
            pass
        else:
            return False

        if self.check_line_profile(self._line_profile_index):
            pass
        else:
            self.logout(False)
            return False

        if self.deactive_port(self._dslam_port):
            pass
        else:
            self.logout(False)
            return False
        if self._bond_group_index:
            if self.deactive_bond_group(self._bond_group_index):
                pass
            else:
                self.logout(False)
                return False

        if self.undo_vlan_dsl(port=self._dslam_primary_fsp):
            pass
        else:
            self.logout(False)
            return False

        if self._bond_group_index:
            if self.delete_bond_group(self._bond_group_index):
                pass
            else:
                self.logout(False)
                return False
        if self._dslam_second_port:
            if self.undo_vlan_dsl(port=self._dslam_second_fsp):
                pass
            else:
                self.logout(False)
                return False
        if self._bond_group_index:
            if self.undo_vlan_dsl(bondindex=self._bond_group_index):
                pass
            else:
                self.logout(False)
                return False

            #        if self.check_bond_group(self._dslam_fsp):
            #            pass
            #        else:
            #            self.logout(False)
            #            return False
            #

        if self.modify_template(self._line_template_index, self._line_template_name, self._line_profile_index):
            pass
        else:
            self.logout(False)
            return False

        if self._bonding:
            if self.active_port(self._line_template_index, self._dslam_port):
                pass
            else:
                self.logout(False)
                return False

            if self.add_bond_group(self._bond_group_index, self._dslam_primary_fsp):
                pass
            else:
                self.logout(False)
                return False
            if self.link_bond_group(self._bond_group_index, self._dslam_second_fsp):
                pass
            else:
                self.logout(False)
                return False

            if self.active_bond_group(self._bond_group_index):
                pass
            else:
                self.logout(False)
                return False
        else:
            if self.active_port(self._line_template_index, self._using_port):
                pass
            else:
                self.logout(False)
                return False

        if self.create_vlan(self._vlan):
            pass
        else:
            self.logout(False)
            return False

        if self.bond_vlan_eth(self._vlan):
            pass
        else:
            self.logout(False)
            return False

        if self.bond_vlan_dsl(self._vlan, self._using_fsp):
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
        print '\n' + '#' * 50 + 'Begin to Remove Huawei DSLAM configuration!'
        if self.login():
            pass
        else:
            return False

        if self.check_line_profile(self._line_profile_index):
            pass
        else:
            self.logout(False)
            return False

        if self.deactive_port(self._dslam_port):
            pass
        else:
            self.logout(False)
            return False

        if self.deactive_bond_group(self._bond_group_index):
            pass
        else:
            self.logout(False)
            return False

        if self.undo_vlan_dsl(port=self._dslam_primary_fsp):
            pass
        else:
            self.logout(False)
            return False

        if self.delete_bond_group(self._bond_group_index):
            pass
        else:
            self.logout(False)
            return False

        if self.undo_vlan_dsl(port=self._dslam_second_fsp):
            pass
        else:
            self.logout(False)
            return False

        if self.undo_vlan_dsl(bondindex=self._bond_group_index):
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
        _login_prompts = ['Connection closed by foreign host','Reenter times have reached the upper limit','>>User name:', '>>User password', 'User root has used a default password. Change the password in time', "Press 'Q' to break",pexpect.EOF, pexpect.TIMEOUT]
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
        for j in range(60):
            i = 0
            print 'Try ' + str(j) + '...'
            self._child = pexpect.spawn(self._login_cmd, timeout=120)
            self._child.logfile = sys.stdout
            while i < 10:
                i = i + 1
                try:
                    index = self._child.expect(self._login_prompts)
                    if index == 0:
                        self._child.close(force=True)
                        print 'wait 10 seconds'
                        time.sleep(10)
                        break
                    elif index == 1:
                        continue
                    elif index == 2:
                        self._child.sendline(self._login_username)
                    elif index == 3:
                        self._child.sendline(self._login_password)
                    elif index == 4:
                        print '\nlogin success'
                        return True
                    elif index == 5:
                        self._child.sendline('Q')
                        return True
                    elif index == 6:
                        return False
                    else:
                        return False
                except pexpect.EOF:
                    return False
                except pexpect.TIMEOUT:
                    return False
        return False

    def display(self):
        """
        """
        print '\n' + '#' * 50 + 'Enter function display'
        self.cd_config()
        cmd = 'display vlan all'
        self._child.sendline(cmd)
        index = self._child.expect(['<cr>', pexpect.EOF, pexpect.TIMEOUT])
        if index == 0:
            self._child.sendline('')
        else:
            self._child.sendline('')
        cmd = 'display board ' + self._dslam_fs
        self._child.sendline(cmd)
        while True:
            index = self._child.expect(
                ['Press \'Q\' to break', 'Total number of unactivated ports', pexpect.EOF, pexpect.TIMEOUT])
            if index == 0:
                self._child.sendline('')
            elif index == 1:
                break
            else:
                self.error(cmd)
                return False
        return True

    def cd_config(self):
        """
        """
        self._child.sendline('')
        index = self._child.expect(
            ['MA5662>', 'MA5662#', self._cf_prompt, self._if_prompt, pexpect.EOF, pexpect.TIMEOUT])
        if index == 0:
            self._child.sendline('enable')
            index = self._child.expect(['MA5662#', pexpect.EOF, pexpect.TIMEOUT])
            if index != 0:
                self.error('enable')
                return False
            self._child.sendline('config')
            index = self._child.expect([self._cf_prompt, pexpect.EOF, pexpect.TIMEOUT])
            if index != 0:
                self.error('config')
                return False
            self.info('config')
        elif index == 1:
            self._child.sendline('config')
            index = self._child.expect([self._cf_prompt, pexpect.EOF, pexpect.TIMEOUT])
            if index != 0:
                self.error('config')
                return False
            self.info('config')
        elif index == 2:
            pass
        elif index == 3:
            self._child.sendline('quit')
            index = self._child.expect([self._cf_prompt, pexpect.EOF, pexpect.TIMEOUT])
            if index != 0:
                self.error('quit')
                return False
        else:
            pass
        return True

    def cd_config_if_vdsl(self):
        """
        """
        self.cd_config()
        cmd = 'interface vdsl ' + self._dslam_fs
        self._child.sendline(cmd)
        index = self._child.expect([self._if_prompt, pexpect.EOF, pexpect.TIMEOUT])
        if index != 0:
            self.error(cmd)
            return False
        self.info(cmd)
        return True

    def check_line_profile(self, index):
        """
        """
        print '\n' + '#' * 50 + 'Enter function check_line_profile'
        profile_index = str(index)
        envfile = os.getenv('U_CUSTOM_UPDATE_ENV_FILE', '/root/automation/logs/current/update_env')
        if os.path.exists(envfile):
            os.remove(envfile)
        self.cd_config()
        cmd = 'display vdsl line-profile ' + profile_index
        self._child.sendline(cmd)

        while True:
            index = self._child.expect(
                ['Press \'Q\' to break', 'Force framer', 'The profile does not exist', pexpect.EOF, pexpect.TIMEOUT])
            set_file = open(envfile, 'a')
            set_file.write(self._child.before)
            set_file.close()
            if index == 0:
                self._child.sendline('')
                pass
            elif index == 1:
                self._child.sendline('')
                break
            else:
                self.error(cmd)
                return False
        print '\nAT_INFO : check_line_profile Successfully!'
        (rc, downrate) = self.subproc('grep "downstream(0.02)" ' + envfile + "|awk -F: '{print $2}'")
        print 'downstream', downrate
        if not downrate:
            return False
        downrate = str(downrate).strip()
        (rc, uprate) = self.subproc('grep "upstream(0.02)" ' + envfile + "|awk -F: '{print $2}'")
        print 'upstream', uprate
        if not uprate:
            return False
        uprate = str(uprate).strip()
        set_file = open(envfile, 'w')
        set_file.write('TMP_DSLAM_DOWN_STREAM="' + downrate + '"\n')
        set_file.write('TMP_DSLAM_UP_STREAM="' + uprate + '"\n')
        set_file.close()
        self.info(cmd)
        return True


    def modify_template(self, temp_index, temp_name, prof_index):
        """
        vdsl line-template modify 120
        vdsl line-template add 120
        """
        print '\n' + '#' * 50 + 'Enter function modify_template'
        template_index = str(temp_index)
        profile_index = str(prof_index)
        template_name = str(temp_name)
        self.cd_config()
        cmd = 'vdsl line-template modify ' + template_index
        self._child.sendline(cmd)
        try:

            index = self._child.expect(
                ['Please set the line-profile index', 'The template does not exist', pexpect.EOF, pexpect.TIMEOUT])
            if index == 0:
                self._child.sendline(profile_index)
                index = self._child.expect(
                    ['Will you set channel configuration parameters', 'The profile does not exist', 'Parameter error',
                     pexpect.EOF, pexpect.TIMEOUT])
                if index == 0:
                    self._child.sendline('')
                    index = self._child.expect(
                        ['The flow for the profile to take effect is complete', pexpect.EOF, pexpect.TIMEOUT])
                    if index == 0:
                        pass
                    else:
                        self.error(cmd)
                        return False
                elif index == 1 or index == 2:
                    self._child.sendcontrol('c')
                    self._child.expect([self._cf_prompt, pexpect.EOF, pexpect.TIMEOUT])
                    self.error(cmd)
                    return False
                else:
                    self.error(cmd)
                    return False
            elif index == 1:
                cmd = 'vdsl line-template add ' + template_index
                self._child.sendline(cmd)
                index = self._child.expect(['Do you want to name the template', pexpect.EOF, pexpect.TIMEOUT])
                if index == 0:
                    self._child.sendline('y')
                    index = self._child.expect(['Please input template name', pexpect.EOF, pexpect.TIMEOUT])
                    if index == 0:
                        self._child.sendline(template_name)
                        index = self._child.expect(
                            ['Please set the line-profile index', 'The template name has existed', pexpect.EOF,
                             pexpect.TIMEOUT])

                        if index == 0:
                            self._child.sendline(profile_index)
                            index = self._child.expect(
                                ['Will you set channel configuration parameters', 'The profile does not exist',
                                 'Parameter error', pexpect.EOF, pexpect.TIMEOUT])
                            if index == 0:
                                self._child.sendline('')
                                index = self._child.expect(['successfully', pexpect.EOF, pexpect.TIMEOUT])
                                if index == 0:
                                    pass
                                else:
                                    self.error(cmd)
                                    return False
                            elif index == 1 or index == 2:
                                self._child.sendcontrol('c')
                                self._child.expect([self._cf_prompt, pexpect.EOF, pexpect.TIMEOUT])
                                self.error(cmd)
                                return False
                        else:
                            self._child.sendcontrol('c')
                            self._child.expect([self._cf_prompt, pexpect.EOF, pexpect.TIMEOUT])
                            self.error(cmd)
                            return False
                    else:
                        self.error(cmd)
                        return False
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
        print '\nAT_INFO : modify_template Successfully!'
        self.info(cmd)
        return True

    def deactive_port(self, port):
        """
        deactivate 5
        """
        print '\n' + '#' * 50 + 'Enter function deactive_port'
        port_list = port
        self.cd_config_if_vdsl()
        for p in port_list:
            if p:
                cmd = 'deactivate ' + str(p)
                self._child.sendline(cmd)
                try:
                    self._child.expect([self._if_prompt, pexpect.EOF, pexpect.TIMEOUT], timeout=5)
                except pexpect.EOF:
                    self.error(cmd)
                    return False
                except pexpect.TIMEOUT:
                    self.error(cmd)
                    return False
            self.info(cmd)
        time.sleep(2)
        for p in port_list:
            if p:
                cmd = 'display port state ' + str(p)
                self._child.sendline(cmd)
                try:
                    index = self._child.expect([str(p) + '  *Deactivated', pexpect.EOF, pexpect.TIMEOUT])
                    if index != 0:
                        print '\nAT_ERROR : deactivate ' + str(p) + ' FAILED!'
                        self.error(cmd)
                        return False
                except pexpect.EOF:
                    self.error(cmd)
                    return False
                except pexpect.TIMEOUT:
                    self.error(cmd)
                    return False
        print '\nAT_INFO : deactive port successfully!'
        return True

    def active_port(self, index, port):
        """
        activate 5 template-index 120
        """
        print '\n' + '#' * 50 + 'Enter function active_port'
        port = port
        template_index = str(index)
        self.cd_config_if_vdsl()
        if isinstance(port, list):
            for p in port:
                cmd = 'activate ' + str(p) + ' template-index ' + str(template_index)
                self._child.sendline(cmd)
                try:
                    index = self._child.expect(['Failure', 'error', pexpect.EOF, pexpect.TIMEOUT], timeout=5)
                    if index == 0 or index == 1:
                        self.error(cmd)
                        return False
                    else:
                        self.info(cmd)
                        pass
                except pexpect.EOF:
                    self.error(cmd)
                    return False
                except pexpect.TIMEOUT:
                    self.info(cmd)
                    pass
            time.sleep(2)
            for p in port:
                cmd = 'display port state ' + str(p)
                self._child.sendline(cmd)
                try:
                    index = self._child.expect([str(p) + '  *Activat.*' + template_index, pexpect.EOF, pexpect.TIMEOUT])
                    if index != 0:
                        print '\nAT_ERROR : activate ' + str(p) + ' template-index ' + template_index + ' FAILED!'
                        self.error(cmd)
                        return False
                except pexpect.EOF:
                    self.error(cmd)
                    return False
                except pexpect.TIMEOUT:
                    self.error(cmd)
                    return False
            print '\nAT_INFO : active port successfully!'
            return True
        else:
            cmd = 'activate ' + port + ' template-index ' + str(template_index)
            self._child.sendline(cmd)
            try:
                index = self._child.expect(['Failure', 'error', pexpect.EOF, pexpect.TIMEOUT], timeout=5)
                if index == 0 or index == 1:
                    self.error(cmd)
                    return False
                else:
                    self.info(cmd)
                    pass
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                self.info(cmd)
                pass

            time.sleep(2)
            cmd = 'display port state ' + port
            self._child.sendline(cmd)
            try:
                index = self._child.expect([port + '  *Activat.*' + template_index, pexpect.EOF, pexpect.TIMEOUT])
                if index != 0:
                    print '\nAT_ERROR : activate ' + port + ' template-index ' + template_index + ' FAILED!'
                    self.error(cmd)
                    return False
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                self.error(cmd)
                return False
            print '\nAT_INFO : active port successfully!'
            return True

    def create_vlan(self, vid):
        """
        vlan 405
        """
        print '\n' + '#' * 50 + 'Enter function create_vlan'
        vlan = str(vid)
        self.cd_config()
        cmd = 'vlan ' + vlan
        self._child.sendline(cmd)
        try:
            index = self._child.expect(['<cr>', 'Parameter error', 'Unknown command', pexpect.EOF, pexpect.TIMEOUT],
                                       timeout=5)
            if index == 0:
                self._child.sendline('')
                try:
                    self._child.expect(
                        ['Failure: VLAN has existed', 'VLAN list parameter error', pexpect.EOF, pexpect.TIMEOUT],
                        timeout=5)
                    if index == 0:
                        pass
                    elif index == 1:
                        self.error(cmd)
                        return False
                    else:
                        pass
                except pexpect.EOF:
                    self.error(cmd)
                    return False
                except pexpect.TIMEOUT:
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
        #        cmd = 'display vlan all'
        #        self._child.sendline(cmd)
        #        try:
        #            index = self._child.expect(['<cr>', pexpect.EOF, pexpect.TIMEOUT])
        #            if index == 0:
        #                self._child.sendline('')
        #                index = self._child.expect([' *' + vlan + '  *', pexpect.EOF, pexpect.TIMEOUT])
        #                if index != 0:
        #                    self.error(cmd)
        #                    print '\nAT_ERROR : can\'t find vlan ' + vlan
        #                    return False
        #            else:
        #                self.error(cmd)
        #                return False
        #        except pexpect.EOF:
        #            self.error(cmd)
        #            return False
        #        except pexpect.TIMEOUT:
        #            self.error(cmd)
        #            return False
        print '\nAT_INFO : Create vlan ' + vlan + ' successfully!'
        return True


    def bond_vlan_eth(self, vid):
        """
        """
        print '\n' + '#' * 50 + 'Enter function bond_vlan_eth'
        vlan = str(vid)
        self.cd_config()
        cmd = 'port vlan ' + vlan + ' 0/0 0'
        self._child.sendline(cmd)
        try:
            index = self._child.expect(
                ['The port is already in the VLAN', 'Failure: VLAN does not exist', pexpect.EOF, pexpect.TIMEOUT],
                timeout=5)
            if index == 0:
                pass
            elif index == 1:
                self.error(cmd)
                return False
            else:
                pass
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            pass
        self.info(cmd)
        return True

    def bond_vlan_dsl(self, vid, port):
        """
        service-port vlan 411 vdsl mode ptm 0/1/21 multi-service user-vlan untagged rx-cttr 6 tx-cttr 6
        """
        print '\n' + '#' * 50 + 'Enter function bond_vlan_dsl'
        vlan = str(vid)
        port = str(port)
        self.cd_config()
        i = 0
        while i < 3:
            i = i + 1
            if self._tag:
                cmd = 'service-port vlan ' + vlan + ' vdsl mode ptm ' + port + ' multi-service user-vlan ' + self._tag + ' rx-cttr 6 tx-cttr 6'
                self._child.sendline(cmd)
            else:
                cmd = 'service-port vlan ' + vlan + ' vdsl mode ptm ' + port + ' multi-service user-vlan untagged rx-cttr 6 tx-cttr 6'
                self._child.sendline(cmd)
            try:
                index = self._child.expect(['Failure: Service virtual port has existed already',
                                            'Failure: VLAN does not exist', 'Parameter error', 'Unknown command',
                                            'Failure: Cannot operate on the port because it is not the primary port of the bonding group',
                                            pexpect.EOF, pexpect.TIMEOUT], timeout=5)
                if index == 0:
                    if self.undo_vlan_dsl(port=port):
                        pass
                    else:
                        self.error(cmd)
                        return False
                elif index == 1 or index == 2 or index == 3 or index == 4:
                    print '\nAT_ERROR : service-port vlan ' + vlan + ' vdsl mode ptm ' + port + ' FAILED!'
                    self.error(cmd)
                    return False
                else:
                    break
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                break
        print '\nAT_INFO : vlan_bond_dsl Successfully!'
        self.info(cmd)
        return True

    def undo_vlan_dsl(self, port='', bondindex=''):
        """
        undo service-port vlan 405 vdsl 0/1/18
        in order to slove 'Failure: Service virtual port has existed already'
        display bonding-group 6
      ------------------------------------------------------------------------
      Bonding group primary port                  : 0/1/26
      Bonding group profile                       : -
      Bonding group scheme                        : efm
      Bonding group peer-scheme                   : efm
      Bonding group discovery-code                : 0110-0110-0110
      Bonding group description                   : 1
      Bonding group admin-status                  : deactive
    
      Link 0                                      : 0/1/26
      The port state is                           : Deactivated

          Command:
          display service-port port 0/1/17 
          Switch-Oriented Flow List
          ----------------------------------------------------------------------------
          INDEX VLAN VLAN     PORT F/ S/ P VPI  VCI   FLOW  FLOW       RX   TX   STATE
                ID   ATTR     TYPE                    TYPE  PARA            
          ----------------------------------------------------------------------------
              4  405 common   vdl  0/1 /17 -    -     vlan  untag      6    6    down
          ----------------------------------------------------------------------------
           Total : 1  (Up/Down :    0/1)

        """
        print '\n' + '#' * 50 + 'Enter function undo_vlan_dsl'

        port = str(port)
        bond_group_index = str(bondindex)
        print 'port:' + port
        print 'bond_group_index:' + bond_group_index
        self.cd_config()
        if port == '' and bond_group_index:
            cmd = 'display bonding-group ' + bond_group_index
            self._child.sendline(cmd)
            try:
                index = self._child.expect(
                    ['The port state is', 'Parameter error', 'The bonding group does not exist', pexpect.EOF,
                     pexpect.TIMEOUT])
                res = self._child.before
                if index == 0:
                    (rc, port) = self.subproc(
                        'echo "' + res + '"|grep ' + '"Bonding group primary port.*' + '"' + "|awk -F: '{print $2}'" + "|sed 's/^ *//g'" + "|sed 's/ *$//g'")
                    port = port.strip()
                    print 'port:' + port
                elif index == 1:
                    self.error(cmd)
                    return False
                elif index == 2:
                    return True
                else:
                    self.error(cmd)
                    return False
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                self.error(cmd)
                return False

        aaa = port.split('/')
        try:
            bbb = str(aaa[0] + '/' + aaa[1] + ' /' + aaa[2])
        except IndexError:
            print 'list index out of range'
            return False
        cmd = 'display service-port port ' + port
        self._child.sendline(cmd)
        try:
            index = self._child.expect(['<cr>', pexpect.EOF, pexpect.TIMEOUT])
            if index == 0:
                self._child.sendline('')
                index = self._child.expect(
                    ['Total', 'No service virtual port can be operated', pexpect.EOF, pexpect.TIMEOUT])
                res = self._child.before
                if index == 0:
                    pass
                elif index == 1:
                    return True
            else:
                self.error(cmd)
                return False
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False

        (rc, output) = self.subproc(
            'echo "' + res + '"|grep ' + '"' + bbb + '"' + "|awk '{print $2}'" + "|sed 's/^ *//g'" + "|sed 's/ *$//g'" + '|sort|uniq')
        vlanid = output.strip()
        print 'vlanid:' + vlanid
        cmd = 'undo service-port vlan ' + vlanid + ' vdsl ' + port
        self._child.sendline(cmd)
        try:
            index = self._child.expect(['Are you sure', 'Too many parameters', pexpect.EOF, pexpect.TIMEOUT])
            if index == 0:
                self._child.sendline('y')
                index = self._child.expect(['have been deleted', pexpect.EOF, pexpect.TIMEOUT])
                if index == 0:
                    pass
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
        print '\nAT_INFO : undo_vlan_dsl Successfully!'
        self.info(cmd)
        return True


    def check_bond_group(self, port):
        """
        display bonding-group all
      ------------------------------------------------------------------------------
      Group   Group   Primary  Scheme  Discovery       State      Link   
      Index   Prof    Port             Code                       Number 
      ------------------------------------------------------------------------------
          0   30      0/1/12   efm     0000-0001-000C  deactive        2
          6   -       0/1/26   efm     0110-0110-0110  deactive        2
          8   -       0/1/25   efm     0110-0110-0111  deactive        1
      ------------------------------------------------------------------------------
    display bonding-group 6
      ------------------------------------------------------------------------
      Bonding group primary port                  : 0/1/26
      Bonding group profile                       : -
      Bonding group scheme                        : efm
      Bonding group peer-scheme                   : efm
      Bonding group discovery-code                : 0110-0110-0110
      Bonding group description                   : 1
      Bonding group admin-status                  : deactive
    
      Link 0                                      : 0/1/26
      The port state is                           : Deactivated
    
      Link 1                                      : 0/1/27
      The port state is                           : Activating
      ------------------------------------------------------------------------
    
    MA5662(config)#
    
        """
        print '\n' + '#' * 50 + 'Enter function check_bond_group'
        port = port
        self.cd_config()
        self._child.sendline('display bonding-group all')
        try:
            index = self._child.expect(
                ['The bonding group does not exist', 'Total number of bonding group', 'Unknown command', pexpect.EOF,
                 pexpect.TIMEOUT])
            res = self._child.before
            if index == 0:
                return True
            elif index == 1:
                pass
            else:
                return False
        except pexpect.EOF:
            return False
        except pexpect.TIMEOUT:
            return False
        for p in port:
            cmd = 'echo "' + res + '"|grep " *' + str(p) + ' "'
            rc = os.system(cmd)
            if rc == 0:
                (rc, bdidx) = self.subproc('echo "' + res + '"|grep " *' + str(p) + ' "|head -n1|' + "awk '{print $1}'")
                if self.deactive_bond_group(bdidx):
                    pass
                else:
                    return False
                if self.delete_bond_group(bdidx):
                    pass
                else:
                    return False
            else:
                pass
        return True
        print '\nAT_INFO : check_bond_group Successfully!'

    #        (rc, output) = self.subproc('echo "' + res + '"|grep "^ *' + bond_group_index + ' *"')
    #        if rc == 0:
    #            print '\nAT_INFO : bonding-group ' + bond_group_index + ' existed!'
    #            (rc, output) = subproc('echo "' + res + '"|grep "^ *' + bond_group_index + ' *"' + "|awk '{print $3}'")
    #            primary_port = output.strip()
    #        else:
    #            return False
    #
    #        self._child.sendline('display bonding-group ' + bond_group_index)
    #        try:
    #            index = self._child.expect(['Link 1.*', 'The bonding group does not exist', pexpect.EOF, pexpect.TIMEOUT])
    #            res = self._child.after
    #            fw = open('ggg', 'w')
    #            fw.write(res)
    #            if index == 0:
    #                pass
    #            else:
    #                return False
    #        except pexpect.EOF:
    #            return False
    #        except pexpect.TIMEOUT:
    #            return False
    #        (rc, output) = self.subproc('echo "' + res + '"|grep "Link 1"' + "|awk -F: '{print $2}'" + "|sed 's/^ *//g'" + "|sed 's/ *$//g'")
    #        second_port = output.strip()
    #
    #        print 'primary_port:', primary_port
    #        print 'second_port:', second_port
    #        print 'Bonding-Group Main Port:', port
    #        if primary_port == port:
    #            return True
    #        else:
    #            print 'AT_ERROR : primary_port != Bonding-Group Main Port'
    #            return False

    def delete_bond_group(self, index):
        """
        bonding-group delete 5
        """
        print '\n' + '#' * 50 + 'Enter function delete_bond_group'
        bond_group_index = str(index)
        self.cd_config()
        i = 1
        while i < 3:
            i = i + 1
            cmd = 'bonding-group delete ' + bond_group_index
            self._child.sendline(cmd)
            try:
                index = self._child.expect(
                    ['Service virtual port has existed already', 'The bonding group does not exist', pexpect.EOF,
                     pexpect.TIMEOUT], timeout=5)
                if index == 0:
                    if self.undo_vlan_dsl(bondindex=bond_group_index):
                        pass
                    else:
                        self.error(cmd)
                        return False
                elif index == 1:
                    break
                else:
                    break
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                break
        print '\nAT_INFO : delete_bond_group Successfully!'
        self.info(cmd)
        return True

    def add_bond_group(self, index, port):

        """
        bonding-group add 6 primary-port 0/1/26 scheme efm peer-scheme efm discovery-code 0110-0110-0110 desc 1
        """
        print '\n' + '#' * 50 + 'Enter function add_bond_group'
        port = str(port)
        bond_group_index = str(index)
        self.cd_config()
        i = 0
        while i < 3:
            i = i + 1
            cmd = 'bonding-group add ' + bond_group_index + ' primary-port ' + port + ' scheme efm peer-scheme efm discovery-code ' + self._discover_code + ' desc 1'
            self._child.sendline(cmd)
            try:

                index = self._child.expect(
                    ['successfully', 'The bonding group already exists', 'Service virtual port has existed already',
                     'The port is already a member of the bonding group',
                     'The discovery code of bonding group already exists', 'Unknown command', pexpect.EOF,
                     pexpect.TIMEOUT], timeout=5)
                if index == 0:
                    break
                elif index == 1:
                    if self.delete_bond_group(bond_group_index):
                        pass
                    else:
                        self.error(cmd)
                        return False
                elif index == 2:
                    if self.undo_vlan_dsl(port=port):
                        pass
                    else:
                        self.error(cmd)
                        return False
                elif index == 3 or index == 4 or index == 5:
                    self.error(cmd)
                    return False
                else:
                    break
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                break
        print '\nAT_INFO : add_bond_group Successfully!'
        self.info(cmd)
        return True

    def link_bond_group(self, index, port):

        """
        bonding-group link add 6 0/1/27
        """
        print '\n' + '#' * 50 + 'Enter function link_bond_group'
        port = str(port)
        link_group_index = str(index)
        self.cd_config()
        i = 0
        while i < 3:
            i = i + 1
            cmd = 'bonding-group link add ' + link_group_index + ' ' + port
            self._child.sendline(cmd)
            try:
                index = self._child.expect(
                    ['The port is already a member of the bonding group', 'Service virtual port has existed already',
                     'The bonding group does not exist', 'The number of the member ports in the bonding group is full',
                     'Unknown command', pexpect.EOF, pexpect.TIMEOUT], timeout=5)
                if index == 0:
                    break
                elif index == 1:
                    if self.undo_vlan_dsl(port=port):
                        pass
                    else:
                        self.error(cmd)
                        return False
                elif index == 2 or index == 3 or index == 4:
                    self.error(cmd)
                    return False
                else:
                    break
            except pexpect.EOF:
                self.error(cmd)
                return False
            except pexpect.TIMEOUT:
                break
        print '\nAT_INFO : link_bond_group Successfully!'
        self.info(cmd)
        return True

    def active_bond_group(self, index):
        """
        active bonding-group 6 profile-index 1
        """
        print '\n' + '#' * 50 + 'Enter function active_bond_group'
        bond_group_index = str(index)
        self.cd_config()
        cmd = 'active bonding-group ' + bond_group_index + ' profile-index 1'
        self._child.sendline(cmd)
        try:
            index = self._child.expect(
                ['The bonding group is activated', 'The bonding group does not exist', 'Unknown command',
                 'Parameter error', pexpect.EOF, pexpect.TIMEOUT], timeout=5)
            if index == 0:
                pass
            elif index == 1 or index == 2 or index == 3:
                self.error(cmd)
                return False
            else:
                pass
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            pass
        self.info(cmd)
        return True

    def deactive_bond_group(self, index):

        """
        Deactived bonding-group 6
        """
        print '\n' + '#' * 50 + 'Enter function deactive_bond_group'
        bond_group_index = str(index)
        self.cd_config()
        cmd = 'Deactive bonding-group ' + bond_group_index
        self._child.sendline(cmd)
        try:
            index = self._child.expect(
                ['The bonding group is already deactivated', 'The bonding group does not exist', 'Unknown command',
                 'Parameter error', pexpect.EOF, pexpect.TIMEOUT], timeout=5)
            if index == 0 or index == 1:
                pass
            elif index == 2 or index == 3:
                self._child.sendline('')
                self.error(cmd)
                return False
            else:
                pass
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            pass
        self.info(cmd)
        return True

    def save(self):
        """
        save  configuration
        save data
        """
        print '\n' + '#' * 50 + 'Enter function logout'
        self.cd_config()
        cmd = 'save configuration'
        self._child.sendline(cmd)
        try:
            self._child.expect(['successfully', pexpect.EOF, pexpect.TIMEOUT])
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False
        self.info(cmd)
        cmd = 'save data'
        self._child.sendline(cmd)
        try:
            self._child.expect(['completely', pexpect.EOF, pexpect.TIMEOUT])
        except pexpect.EOF:
            self.error(cmd)
            return False
        except pexpect.TIMEOUT:
            self.error(cmd)
            return False
        self.info(cmd)
        return True

    def logout(self, rc=True):
        """
        """
        returncode = rc
        print '\n' + '#' * 50 + 'Enter function logout'
        self.cd_config()
        cmd = 'quit'
        self._child.sendline(cmd)
        self._child.sendline(cmd)
        index = self._child.expect(['Are you sure to log out', pexpect.EOF, pexpect.TIMEOUT])
        if index != 0:
            pass
        else:
            self._child.sendline('y')
            self._child.expect(['Connection closed by foreign host', pexpect.EOF, pexpect.TIMEOUT])
            pass
        print 'AT_INFO : return_code=' + str(returncode)
        self.info(cmd)
        return returncode


def main():
    """
    main
    """
    usage = "python SetDSLAM_HuaWei.py [-l <VDSL>] [-t tag] [-b] [-v 17a|12a|12b|8a|8b|8c|8d>] [-P <1|2>] [-d]"

    parser = OptionParser(usage=usage)

    parser.add_option("-l", "--linemode", dest="linemode",
                      help="linemode , ADSL VDSL or ETC.")
    parser.add_option("-t", "--tag", dest="tag",
                      help="tag")
    parser.add_option("-v", "--vdslmode", dest="vdslmode",
                      help="vdslmode")
    parser.add_option("-b", "--bonding", dest="bonding", action='store_true', default=False,
                      help="whether it is in bonding mode")
    parser.add_option("-d", "--remove", dest="remove", action='store_true', default=False,
                      help="remove link type")

    parser.add_option("-q", "--testbed", dest="testbed",
                      help="testbed")
    #    parser.add_option("-k", "--dslamtype", dest="dslamtype",
    #                            help="dslamtype")
    parser.add_option("-P", "--connectport", dest="connectport",
                      help="connectport")

    (options, args) = parser.parse_args()

    tag = ''
    linemode = 'VDSL'
    vdslmode = 'vdsl2'
    testbed = ''
    #dslamtype = 'HuaWei'
    connectport = '1'

    rc = False
    if not len(args) == 0:
        print args

    if options.connectport:
        connectport = options.connectport

    if options.testbed:
        testbed = options.testbed

    #    if options.dslamtype:
    #        dslamtype = options.dslamtype

    if options.linemode:
        linemode = options.linemode

    if linemode != 'VDSL':
        print 'AT_ERROR : HuaWei DSLAM only support VDSL mode!'
        return False

    if options.tag:
        tag = options.tag

    if options.bonding:
        bonding = True
    else:
        bonding = False

    if options.vdslmode:
        vdslmode = str(options.vdslmode).lower()

    if options.remove:
        remove = True
    else:
        remove = False

    if remove:
        setdslam = SetDSLAM_HuaWei(linemode, tag, bonding, vdslmode, testbed, connectport)
        rc = setdslam.remove()
    else:
        setdslam = SetDSLAM_HuaWei(linemode, tag, bonding, vdslmode, testbed, connectport)
        rc = setdslam.set()
    return rc


if __name__ == '__main__':
    rc = main()
    if not rc:
        exit(1)
