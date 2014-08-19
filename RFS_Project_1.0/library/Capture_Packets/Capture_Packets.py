import os
import sys
import re
import time
import subprocess
import datetime
class Capture_Packets():
    
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

    
    def Stop_Capture_On_Lan(self, raw="/tmp/capture_packets.pcap"):
        ""
        print 'Stop_Capture_On_Lan'
        # self.ExcuteCMD(cmd="ps aux|grep -v grep|grep tshark")
        
        rc, result = self.ExcuteCMD(cmd='ps aux|grep -v grep|grep tshark|grep "' + raw + '"|' + "awk '{print $2}' ")
        if rc:
            try:
                for i in result.split():
                    if i:
                        # print '>>>' + str(i).strip() + '<<<'
                        kill_cmd = 'kill -9 ' + str(i).strip()
                        if self.ExcuteCMD(cmd=kill_cmd)[0]:
                            pass
                        else:
                            print 'AT_ERROR : Stop Capture FAIL FAIL!'
                            f.close()
                            return False
            except Exception, e:
                print e
                return False
        else:
            print 'AT_INFO : Not Exist releated tshark program!'
            return True
        # self.ExcuteCMD(cmd="ps aux|grep -v grep|grep tshark")
        print 'AT_INFO : Stop Capture PASS PASS!'
        return True
    
    
    def Start_Capture_On_Lan(self, interface="", output="/tmp/capture_packets.pcap", filter="", duration=""):
        ""
        interface = str(interface)
        output = str(output)
        filter = str(filter)
        duration = str(duration)
        
        # stop capture
        self.Stop_Capture_On_Lan(output)
        
        # remove file
        try:
            if os.path.exists(output):
                self.ExcuteCMD(cmd='rm -f ' + output)
        except Exception, e:
            print e
            return False
        
        # Up Monitor interface
        if filter.lower() == 'beacon':
            rc, mon = self.Up_Monitor_Interface()
            if rc and mon:
                interface = mon
                self.ExcuteCMD(cmd='ifconfig')
                self.ExcuteCMD('route -n')
            else:
                return False
        else:
            # check interface
            if not self.ExcuteCMD('ifconfig -a | grep "^' + interface + ' "')[0]:
                print 'AT_ERROR : ' + interface + ' NOT Exist!'
                return False
        
        if not interface:
            print 'AT_ERROR : No interface defined!'
            return False
        
        # run tshark
        print 
        print 'Start_Capture_On_Lan'
        try:
            cmd = "nohup tshark -i " + interface
            if duration:
                cmd += " -a duration:" + duration
            if filter:
                if filter.lower() == 'beacon':
                    cmd += " -f 'wlan[0] == 0x80'"
                else:
                    cmd += ' -f "' + filter + '"'
            cmd += ' -w ' + output + ' >/dev/null 2>&1 &'
        except Exception, e:
            print e
            return False
        rc, f = self.ExcuteCMD(cmd)
        
        # view all tshark command
        time.sleep(2)
        print 'ALl tshark process as below:'
        self.ExcuteCMD(cmd="ps aux|grep -v grep|grep tshark")
        print '-' * 100
        
        # check tshark
        if rc:
            print 'Current tshark process as below:'
            check_cmd = "ps aux|grep -v grep|grep tshark|grep " + interface + "|grep -w " + output
            if self.ExcuteCMD(check_cmd)[0]:
                print 'AT_INFO : tshark command run PASS PASS!'
                return True
            else:
                print 'AT_ERROR : ' + str(cmd) + ' run FAIL FAIL!'
                return False
        else:
            print 'AT_ERROR : ' + str(cmd) + ' run FAIL FAIL!'
            print 'AT_ERROR : tshark command run FAIL FAIL!'
            return False
    
    def Start_Capture_On_Remote(self):
        pass
    
    def Parse_Packets(self, filter='', raw='/tmp/capture_packets.pcap', output='/tmp/parse_capture_packets.log', negtive=False):
        
        print 'Parse_Packets'
        filter = str(filter)
        raw = str(raw)
        output = str(output)
        print filter
        print raw
        print output
        
        if not filter:
            print 'AT_WARNING : No Filter!'
            
        if not raw:
            print 'AT_ERROR : No Packets Files!'
            return False
        
        if not os.path.exists(raw):
            print 'AT_ERROR : ' + raw + ' NOT Exist!'
            return False
        try:
            if filter:
                print 'filter'
                filter=filter.replace('"','\\"')
                print filter
                cmd = 'tshark -r ' + raw + ' -R "' + filter + '" > ' + output
            else:
                cmd = 'tshark -r ' + raw + ' > ' + output
            if self.ExcuteCMD(cmd)[0]:
                pass
            else:
                print 'AT_ERROR : Parse Packets FAIL FAIL!'
                return False
        except Exception, e:
            print e
            return False
        
        rc, data = self.ExcuteCMD(cmd='cat ' + output + ' |wc -l')
        
        print str(data) + ' packets captured!'
        try:
            data = int(data)
        except Exception, e:
            print e
            return False
        if data > 0:
            if negtive:
                print 'AT_ERROR : Negtive Test,Parse Packets FAIL FAIL!'
                return False
            else:
                print 'AT_INFO : Positive Test,Parse Packets PASS PASS!'
                return True
        else:
            if negtive:
                print 'AT_INFO : Negtive Test,Parse Packets PASS PASS!'
                return True
            else:
                print 'AT_ERROR : Positive Test,Parse Packets FAIL FAIL!'
                return False
        return data

# 
# output = '/tmp/123'
# obj = Capture_Packets()
# obj.Start_Capture_On_Lan(interface='eth1', output=output, duration=360, filter='beacon') 
# time.sleep(10)
# obj.Stop_Capture_On_Lan(raw=output)
# obj.Parse_Packets(filter="wlan.bssid== 00:26:62:9f:4f:6f and wlan_mgt.ds.current_channel == 1",raw=output)
