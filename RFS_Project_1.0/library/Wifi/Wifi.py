import os
import sys
import pexpect
import re

class Wifi:

    def __init__(self):
        """"""
        print 'wan_ip:'
        print self.wan_ip

    def ExcuteCMD(self, cmd):
        "Excute shell command ,return code and output"
        cmd = cmd
        # print cmd
        rc = 1
        content = ""
        # print (datetime.datetime.now())
        p = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        p.wait()
        rc = p.returncode
        content = p.stdout.read().strip()
        if content:
            print ">" + content + "<"

        if p.returncode == 0:
            # print 'AT_INFO : "' + cmd + '" Excute SUCESS!'
            rc = True
        else:
            print 'return code :' + str(rc)
            print 'AT_WARNING : "' + cmd + '" Excute FAIL!'
            rc = False
        p.stdout.close()
        return rc, content

    def Get_Wlan_Card_Name(self):
        cmd = 'ifconfig -a |grep -o "^ *wlan[0-9][0-9]* *"|awk ' + "'{print $1}'"
        rc, result = self.ExcuteCMD(cmd)
        if rc:
            data = result.strip()
        else:
            data = None
        return data

    def Up_Monitor_Interface(self):
        wlan = self.Get_Wlan_Card_Name()
        mon = 'mon_' + str(wlan)
        if wlan:

            if self.ExcuteCMD(cmd='ifconfig |grep "^ *' + wlan + '"')[0]:
                pass
            else:
                if self.ExcuteCMD(cmd='ifconfig ' + wlan + ' up')[0]:
                    pass
                else:
                    print 'AT_ERROR : ' + 'ifconfig ' + wlan + ' up' + ' FAIL FAIL!'
                    return False, None

            if self.ExcuteCMD(cmd='ifconfig |grep ' + mon)[0]:
                print 'AT_INFO : Monitor Interface is already Up PASS PASS!'
                return True, mon
            elif self.ExcuteCMD(cmd='ifconfig -a|grep ' + mon)[0]:
                print 'AT_INFO : Monitor Interface is exist,but NOT UP!'
                if self.ExcuteCMD(cmd='ifconfig ' + mon + ' up')[0]:
                    print 'AT_INFO : Monitor Interface is already Up PASS PASS!'
                    return True, mon
                else:
                    print 'AT_ERROR : Monitor Interface Up FAIL FAIL!'
                    return False, None
            else:
                if self.ExcuteCMD(cmd='iw dev ' + wlan + ' interface add ' + mon + ' type monitor')[0]:
                    if self.ExcuteCMD(cmd='ifconfig |grep ' + mon)[0]:
                        print 'AT_INFO : Monitor Interface is already Up PASS PASS!'
                        return True, mon
                    elif self.ExcuteCMD(cmd='ifconfig -a|grep ' + mon)[0]:
                        if self.ExcuteCMD(cmd='ifconfig ' + mon + ' up')[0]:
                            print 'AT_INFO : Monitor Interface Up PASS PASS!'
                            return True, mon
                        else:
                            print 'AT_ERROR : Monitor Interface Up FAIL FAIL!'
                            return False, None
                else:
                    print 'AT_ERROR : Monitor Interface Add FAIL FAIL!'
                    return False, mon
        else:
            print 'AT_ERROR : NO Exist WLAN Card!'
            return False, None



    def Generate_Config_file(self, ssid='', bssid='',key='', type='WPAWPA2-Both'):

        ssid=str(ssid)
        bssid=str(bssid)
        key_mgmt=str(key_mgmt)
        key=str(psk)


        try:
            file = open(self.cfg_file, 'w')
        except Exception, e:
            print e
            return False

        file.writelines('ctrl_interface=/var/run/wpa_supplicant' + os.linesep)
        file.writelines('eapol_version=1' + os.linesep)
        file.writelines('ap_scan=1' + os.linesep)
        file.writelines('fast_reauth=1' + os.linesep)
        file.writelines('network={' + os.linesep)
        file.writelines('    ssid=\"ssid\"' + os.linesep)
        file.writelines('    bssid=bssid' + os.linesep)
        file.writelines('    scan_ssid=1' + os.linesep)
        file.writelines('    key_mgmt=\"key_mgmt\"' + os.linesep)
        file.writelines('    priority=5' + os.linesep)
        file.writelines('    pairwise=pairwise' + os.linesep)
        file.writelines('    proto=proto' + os.linesep)
        file.writelines('    psk=\"psk\"' + os.linesep)
        file.writelines('}' + os.linesep)
        file.close()
        self.readfile(self.cfg_file)
        return True


        file.close()
        self.readfile(self.cfg_file)
        return True



    def connect_SSID(self, ssid='', bssid='',key='', type='WPAWPA2-Both'):
        """check Wireless Card can connect Wireless AP"""

        cmd=""

        self.Get_Wlan_Card_Name()

        self.Generate_Config_file()

        self.ExcuteCMD(self, cmd)


