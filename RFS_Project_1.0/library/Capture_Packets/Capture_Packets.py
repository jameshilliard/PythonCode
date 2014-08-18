import os
import sys
import re
import time

class Capture_Packets():
    
    def Get_Wlan_Card_Name(self):
        cmd = 'ifconfig -a |grep -o "^ *wlan[0-9][0-9]* *"|awk ' + "'{print $1}'"
        f = os.popen(cmd)
        data = f.readline().strip()
        if not data:
            data = None
        f.close()
        print data
        return data
    
    def Excute_CMD(self, cmd):
        print cmd
        rc = os.system(cmd)
        if str(rc) == str(0):
            return True
        else:
            return False
        
    def Up_Monitor_Interface(self):
        wlan = self.Get_Wlan_Card_Name()
        mon = 'mon_' + str(wlan)
        if wlan:
            
            if self.Excute_CMD(cmd='ifconfig |grep "^ *' + wlan + '"'):
                pass
            else:
                if self.Excute_CMD(cmd='ifconfig ' + wlan + ' up'):
                    pass
                else:
                    print 'AT_ERROR : ' + 'ifconfig ' + wlan + ' up' + ' FAIL FAIL!'
                    return False, None
                
            if self.Excute_CMD(cmd='ifconfig |grep ' + mon):
                print 'AT_INFO : Monitor Interface is already Up PASS PASS!'
                return True, mon
            elif self.Excute_CMD(cmd='ifconfig -a|grep ' + mon):
                print 'AT_INFO : Monitor Interface is exist,but NOT UP!'
                if self.Excute_CMD(cmd='ifconfig ' + mon + ' up'):
                    print 'AT_INFO : Monitor Interface is already Up PASS PASS!'
                    return True, mon
                else:
                    print 'AT_ERROR : Monitor Interface Up FAIL FAIL!'
                    return False, None
            else:
                if self.Excute_CMD(cmd='iw dev ' + wlan + ' interface add ' + mon + ' type monitor'):
                    if self.Excute_CMD(cmd='ifconfig |grep ' + mon):
                        print 'AT_INFO : Monitor Interface is already Up PASS PASS!'
                        return True, mon
                    elif self.Excute_CMD(cmd='ifconfig -a|grep ' + mon):
                        print 'AT_INFO : Monitor Interface is exist,but NOT UP!'
                        if self.Excute_CMD(cmd='ifconfig ' + mon + ' up'):
                            print 'AT_INFO : Monitor Interface is already Up PASS PASS!'
                            return True, mon
                        else:
                            print 'AT_ERROR : Monitor Interface Up FAIL FAIL!'
                            return False, None
                else:
                    print 'AT_ERROR : Monitor Interface Add FAIL FAIL!'
                    return True, mon
        else:
            print 'AT_ERROR : NO Exist WLAN Card!'
            return False, None

    
    def Stop_Capture_On_Lan(self, output="/tmp/capture_packets.pcap"):
        ""
        print 'Stop_Capture_On_Lan'
        cmd = 'ps aux|grep -v grep|grep tshark'
        f = os.popen(cmd)
        for i in f:
            print i,
        f.close()
        
        cmd = 'ps aux|grep -v grep|grep tshark|grep "' + output + '"|' + "awk '{print $2}' "
        f = os.popen(cmd)
        try:
            for i in f:
                print '>>>' + str(i).strip() + '<<<'
                kill_cmd = 'kill -9 ' + str(i).strip()
                if self.Excute_CMD(kill_cmd):
                    pass
                else:
                    print 'AT_ERROR : Stop Capture FAIL FAIL!'
                    f.close()
                    return False
        except Exception, e:
            print e
            return False
        f.close()
        print 'AT_INFO : Stop Capture PASS PASS!'
        return True
    
    
    def Start_Capture_On_Lan(self, interface="", output="/tmp/capture_packets.pcap", filter="", duration=""):
        ""
        print 'Start_Capture_On_Lan'
        interface = str(interface)
        output = str(output)
        filter = str(filter)
        duration = str(duration)
        
        if interface.lower() == 'monitor':
            rc, mon = self.Up_Monitor_Interface()
            if rc and mon:
                interface = mon
            else:
                return False
        
        if not interface:
            print 'AT_ERROR : No interface defined!'
            return False
        self.Stop_Capture_On_Lan(output)

        try:
            if os.path.exists(output):
                os.remove(output)
        except Exception, e:
            print e
            return False
        
        try:
            cmd = "nohup tshark -i " + interface
            if duration:
                cmd += " -a duration:" + duration
            if filter:
                cmd += ' -f "' + filter + '"'
            cmd += ' -w ' + output + ' >/dev/null 2>&1 &'
        except Exception, e:
            print e
            return False
        rc = self.Excute_CMD(cmd)
        print '-' * 100
        print 'ALl tshark process as below:'
        view_cmd = "ps aux|grep -v grep|grep tshark"
        f = os.popen(view_cmd)
        for i in f:
            print i,
        f.close()
        print '-' * 100
        if rc:
            print 'Current tshark process as below:'
            check_cmd = "ps aux|grep -v grep|grep tshark|grep -w " + output
            if self.Excute_CMD(check_cmd):
                print 'AT_INFO : tshark command run PASS PASS!'
                return True
            else:
                print 'AT_ERROR : ' + str(cmd) + ' run FAIL FAIL!'
                return False
        else:
            print 'AT_ERROR : ' + str(cmd) + ' run FAIL FAIL!'
            print 'AT_ERROR : tshark command run FAIL FAIL!'
            return False
        pass
    
    def Start_Capture_On_Remote(self):
        pass
    
    def Parse_Packets(self, filter, raw='', output='/tmp/parse_capture_packets.log', negtive=False):
        filter = str(filter)
        raw = str(raw)
        output = str(output)
        print filter
        print raw
        print output
        
        if not filter:
            print 'AT_ERROR : No Filter!'
            return False
        if not raw:
            print 'AT_ERROR : No Packets Files!'
            return False
        
        if not os.path.exists(raw):
            print 'AT_ERROR : ' + raw + ' NOT Exist!'
            return False
        try:
            cmd = 'tshark -r ' + raw + ' -R "' + filter + '" > ' + output
            if self.Excute_CMD(cmd):
                pass
            else:
                print 'AT_ERROR : Parse Packets FAIL FAIL!'
                return False
        except Exception, e:
            print e
            return False
        cmd = 'cat ' + output + ' |wc -l'
        f = os.popen(cmd)
        data = f.readline().strip()
        f.close()
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
            
# obj = Capture_Packets()
# obj.Start_Capture_On_Lan(interface='eth1', output="./123", duration=60) 
# # obj.Up_Monitor_Interface()
# time.sleep(10)
# obj.Stop_Capture_On_Lan(output='./123')
# obj.Parse_Packets(raw='./123', filter='http')
