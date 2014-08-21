import os
import sys
import pexpect
import re
import subprocess
import time

class Wifi:

    def __init__(self):
        """"""
        self.cfg_file = '/tmp/wifi_config_file'

    def raiseError(self, Message=None):
        raise Exception, Message

    def ExcuteCMD(self, cmd):
        "Excute shell command ,return code and output"
        cmd = cmd
        print 'CMD is ### ' + cmd + ' ###'
        rc = 1
        content = ""
        # print (datetime.datetime.now())
        p = subprocess.Popen(cmd, shell=True, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

        p.wait()

        rc = p.returncode
        print 'rc is ' + str(rc)

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
        print '*'*100
        return rc, content

    def Get_Wlan_Card_Name(self):
        cmd = 'ifconfig -a |grep -o "^ *wlan[0-9][0-9]* *"|awk ' + "'{print $1}'"
        rc, result = self.ExcuteCMD(cmd)
        if rc:
            data = result.strip()
        else:
            data = None
            self.raiseError("error")
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


    def readfile(self, file, filter=''):
        filter = filter
        match_flag = False
        try:
            file = open(file, 'r')
        except Exception, e:
            print e
            return False
        for line in file:
            print line,
            if filter:
                m = re.findall(filter, line)
                if m:
                    match_flag = True
        file.close()
        return match_flag


    def Scan_SSID(self, ssid='', bssid=''):

        wlan = self.Get_Wlan_Card_Name()
        ssid=str(ssid)
        bssid=str(bssid)
        cmd = 'iw dev ' + wlan + ' scan |grep "' + ssid +'" -8' + '|grep ' + bssid

        if self.ExcuteCMD(cmd)[0]:
            return True
        else:
            print 'AT_WARNING : San_SSID RUN FAIL FAIL!'

            self.raiseError("error")

    def Start_WPASupplicant(self):
        wlan = self.Get_Wlan_Card_Name()
        os.system('killall wpa_supplicant')
        time.sleep(5)
        cmd = 'nohup wpa_supplicant -d -i '+ wlan + ' -c ' + self.cfg_file + ' 2>&1 & '
        if os.system(cmd) == 0:
            print 'AT_INFO : Start_WPASupplicant RUN SUCCESS SUCCESS!'
            return True
        else:
            print 'AT_WARNING : Start_WPASupplicant RUN FAIL FAIL!'
            self.raiseError("error")

    def Check_WPASupplicant(self):
        time.sleep(10)
        cmd = 'wpa_cli status'
        rc,result=self.ExcuteCMD(cmd)
        if rc:
            m=re.findall(r'wpa_state=COMPLETED',result)
            if m:
                print 'AT_INFO : Check_WPASuppcliant RUN SUCCESS SUCCESS! And wpa_state is COMPLETED '
                return True
            else:
                print 'AT_INFO : Check_WPASuppcliant RUN SUCCESS SUCCESS! But wpa_state is not COMPLETED '
                self.raiseError("error")

        else:
            print 'AT_WARNING : Check_WPASuppcliant RUN FAIL FAIL!'
            self.raiseError("error")



    def Generate_Config_file(self, ssid='', bssid='', type='', key=''):
        """Generate Wifi Config file for Wireless Card"""
        ssid=str(ssid)
        bssid=str(bssid)
        type=str(type)
        key=str(key)
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
        file.writelines('    ssid=\"' + ssid + '\"' + os.linesep)
        file.writelines('    bssid=' + bssid  + os.linesep)
        file.writelines('    scan_ssid=1' + os.linesep)
        file.writelines('    key_mgmt=' + type + os.linesep)
        file.writelines('    priority=5' + os.linesep)
        file.writelines('    pairwise=CCMP' + os.linesep)
        file.writelines('    proto=WPA RSN' + os.linesep)
        file.writelines('    psk=\"' + key + '\"' + os.linesep)
        file.writelines('}' + os.linesep)
        file.close()
        self.readfile(self.cfg_file)
        return True

        file.close()
        self.readfile(self.cfg_file)
        return True



    def connect_SSID(self, ssid='', bssid='', type='', key=''):
        """check Wireless Card can connect Wireless AP or not

        -Give this Keyword the 4 arguments of a AP: ssid, bssid, type and key

        -Then Case Word will scan SSID Exist or not ,and generate a Wifi config file
        If  Scan SSID Succeed  and config file is Wright, it will invoke wireless
        Tool wpa_supplicant to connect the AP and check the wireless status with
        Wireless Tool wpa_cli.

        -When wpa_state is "COMPLETED", the Keyword run succeed, otherwise it fails.


        Examples:
        | connect SSID | ssid=prince2g | bssid=10:9f:a9:70:01:03 | type=WPA-PSK   |   key=1234567890   |


        """

        ssid=str(ssid)
        bssid=str(bssid)
        type=str(type)
        key=str(key)

        if self.Up_Monitor_Interface():
            pass
        else:
               self.raiseError("error")


        if self.Generate_Config_file(ssid=ssid, bssid=bssid, type=type,  key=key):
            pass
        else:
            self.raiseError("error")

        if self.Scan_SSID(ssid=ssid, bssid=bssid):
            print "scan ssid pass"
            pass
        else:
            print "scan ssid false"
            self.raiseError("error")

        if self.Start_WPASupplicant():
            pass
        else:
            self.raiseError("error")


        if self.Check_WPASupplicant():
            pass
        else:
            self.raiseError("error")







