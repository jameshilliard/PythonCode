#!/usr/bin/python -u
from optparse import OptionParser
from pprint import pprint
import os, re, select, subprocess, time
from pexpect import *
#import verifyPing
#global Capture_Flag
class NETGR_scanner():
    
    is_neg = False
    interface = ''
    ssid = ''
    capture_output_log = None
    moniface = None
    Capture_Flag = True
################################    
    scanresults_wl_cmd = ''
    
    def str2raw(self, s) :
        """
        """
        s = str(s)
        if s.startswith('"') and s.endswith('"') :
            return s[1:-1]
        if s.startswith("'") and s.endswith("'") :
            return s[1:-1]
        return s
    
    def check_scan(self):
        """
        """
        if self.Capture_Flag == True:
            self.start_mon_capture()
            pass
        else:
            print 'No need capture'

        rc = False
        
        scan_cmd = []
        
        netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')
        
        interface = ' -i ' + self.interface + ' '
        
        if not self.is_neg:
            scan_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'scan -s ' + self.ssid
        else:
            scan_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'scan'
            
        scanresults_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'scanresults'
        
        scan_cmd.append(scan_wl_cmd)
        scan_cmd.append(scanresults_wl_cmd)
        
        scan_time = 40
        
        count = 0
        
        for scan_t in range(scan_time):
            ''
            #if not self.is_neg:
            #    print 'INFO : positive test , supposed to be able to scan add to 5 times'
            for s_cmd in scan_cmd:
                print '===================' * 5
                
                if s_cmd == scanresults_wl_cmd:
                    print 'INFO : count -', count
                    
                print 'INFO : wait 10 sec'
                
                time.sleep(10)
                rc, output = self.subproc(s_cmd)
                time.sleep(5)
                if rc != 0:
                    print 'AT_WARNING : error occurred in scanning'
                    count = 0
                else:
                    if s_cmd == scanresults_wl_cmd:
                        if not self.is_neg:
                            #positive
                            if len(output) == 0:
                                print 'AT_WARNING : failed to scan this time'
                                count = 0
                            else:
                                count += 1
                        else:
                            r_neg = r'SSID: \"' + self.ssid + '\"'
                            #negative
                            rc_neg = re.findall(r_neg, output)
                            if len(rc_neg) > 0:
                                print 'AT_WARNING : failed to scan this time'
                                pprint(rc_neg)
                                count = 0
                            else:
                                count += 1
                    else:
                        if len(output) > 0:
                            print 'AT_WARNING : error occurred in scanning'
                            count = 0
                            
            if count == 5:
                print 'INFO : count -', count
                rc = True
                break
            print '===================' * 5
            
        return rc
    
        
    def scan(self):
        """
        """
        
        print 'INFO : try to scan AP'
        netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')
            
        interface = ' -i ' + self.interface + ' '

        cmd_list = []
        #kill_wpa_cmd='wpa_cli term'
        del_mon_cmd = netgear_dir + '/wlx86 ' + 'monitor 0'
        down_wl_cmd = netgear_dir + '/wlx86 ' + interface + ' down'
        up_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'up'
        reset_wl_cmd = netgear_dir + '/wlx86 restart'
        
        ###############################
        #cmd_list.append(kill_wpa_cmd)
        cmd_list.append(del_mon_cmd)
        cmd_list.append(down_wl_cmd)
        cmd_list.append(reset_wl_cmd)
        cmd_list.append(up_wl_cmd)
        
                        
        #############################
        
        for cmd in cmd_list:
            #print 'INFO : >>>subproc start time :',time.asctime()
            rc, output = self.subproc(cmd)
            #print 'INFO : <<<subproc end time :',time.asctime()
            
            print 'INFO : wait 5 sec'
            time.sleep(5)
            
            if not rc == 0:
                return False
            else:
                output = output.strip()
                if len(output) > 0:
                    return False
                
        if not self.check_scan():
            return False
                
        return True
    
    

    def subproc(self, cmd, timeout=3600) :
        """
        subprogress to run command
        """
        rc = None
        output = ''
            
        print '    cmd :', cmd
        
        try :
            #
            p = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, close_fds=True, shell=True)
            while_begin = time.time()
            while True :
                
                to = 600
                fs = select.select([p.stdout, p.stderr], [], [], to)
                
                if p.stdout in fs[0]:
                    tmp = p.stdout.readline()
                    if tmp :
                        output += tmp
                        print 'INFO : ', tmp
                    else :
                        while None == p.poll() : pass
                        break
                elif p.stderr in fs[0]:
                    tmp = p.stderr.readline()
                    if tmp :
                        output += tmp
                        print 'ERROR : ', tmp
                    else :
                        while None == p.poll() : pass
                        break
                else:
                    s = os.popen('ps -f| grep -v grep |grep sleep').read()
                    
                    if len(s.strip()) :
                        continue
                        
                    p.kill()
                    
                    break
                # Check the total timeout 
                dur = time.time() - while_begin
                if dur > timeout :
                    print 'ERROR : The subprocess is timeout due to taking more time than ' , str(timeout)
                    break
            rc = p.poll()
            # close all fds
            p.stdin.close()
            p.stdout.close()
            p.stderr.close()
            
            print 'INFO : return value', str(rc)
        
        except Exception, e :
            print 'ERROR :Exception', str(e)
            rc = 1
        
            
        return rc, output

    def start_mon_capture(self):
        print 'Entry start_capture'
        i = 0
        sleep_time = 5
        while i < 3:
            i += 1
            print 'Try ' + str(i) + ' Times...'
            exit_status = False
            netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')
            
            (rc1, output_ifconfig) = self.subproc('ifconfig ' + self.interface + ' up')
            time.sleep(sleep_time)
            
            #(rc2,output_mon0)=self.subproc(netgear_dir + '/wlx86 monitor 0')
            #time.sleep(sleep_time)
            
            (rc3, output_mon0) = self.subproc(netgear_dir + '/wlx86 monitor 1')
            time.sleep(sleep_time)
            
            (rc, self.moniface) = self.subproc('ifconfig |grep -o "^ *prism[0-9][0-9]*"')
            self.moniface = str(self.moniface).strip()
            time.sleep(sleep_time)
            if self.moniface:
                cur_time = time.strftime("%m_%d_%H_%M_%S")
                print cur_time
                self.capture_output_log = 'lan_' + self.moniface + '_' + cur_time + '.cap'
                print 'capture_output_log : ' + self.capture_output_log
                
                start_capture_cmd = 'bash $U_PATH_TBIN/raw_capture.sh --local -i ' + self.moniface + ' -o ' + self.capture_output_log + ' -t 3600 --begin'
                (rcc, capture_output) = self.subproc(start_capture_cmd)
                if rcc == 0:
                    exit_status = True
                    (rccc, iface) = self.subproc('ifconfig;route -n')
                    break
                else:
                    print 'Start capture Fail!'
            else:
                print 'Monitor interface not exist!'
                (rccc, iface) = self.subproc('ifconfig;route -n')
            
        return exit_status
        
        
    def stop_mon_capture(self):
        print 'Entry stop_capture'
        exit_status = False
        sleep_time = 5
        netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')
        
        stop_capture_cmd = 'bash $U_PATH_TBIN/raw_capture.sh --local -i ' + self.moniface + ' -o ' + self.capture_output_log + ' --stop'
        (rcc, capture_output) = self.subproc(stop_capture_cmd)
        time.sleep(sleep_time)
        print netgear_dir + '/wlx86 monitor 0'
        (rc2, output_mon0) = self.subproc(netgear_dir + '/wlx86 monitor 0')
        time.sleep(sleep_time)
        (rccc, iface) = self.subproc('ifconfig;route -n')
        if rc2 == 0:
            exit_status = True
        return exit_status

def main() :
    """
    arguments list:
        i)
        s)
        n)
    """
    print 'now we are in python ...'
    usage = "usage: %prog -n/--negative  -i/--interface iface  -s/--ssid ssid name\n"
    
    usage += "Arguments :\n"
    usage += "-n/--negative              : negative test mode \n"
    usage += "-i/--interface             : wireless interface \n"
    usage += "-s/--ssid                  : the ssid to be scanned \n"
    
    ######################       
    
    parser = OptionParser(usage=usage)
    parser.add_option("-w", "--capture", dest="capture_flag", help="capture or not")
    parser.add_option("-n", "--negative", dest="is_neg", action="store_true", help="set true if negative test")
    parser.add_option("-i", "--interface", dest="interface", help="wireless NIC interface")
    parser.add_option("-s", "--ssid", dest="ssid", help="the ssid to be scanned")

    (options, args) = parser.parse_args()
    
    #########################
    os.system('wpa_cli term')
    nc = NETGR_scanner()
    #Capture_Flag=True
    if options.capture_flag == str(0):
        nc.Capture_Flag = False
    print 'capture : ' + str(nc.Capture_Flag)
    if options.is_neg:
        nc.is_neg = True
    if options.interface:
        nc.interface = options.interface
    if options.ssid:
        nc.ssid = options.ssid
    
    ##############################
    #if Capture_Flag==True:
    #    #nc.start_mon_capture()
    #    pass
    if not nc.scan():
        print 'AT_ERROR : scanning  failed'
        if nc.Capture_Flag == True:
            nc.stop_mon_capture()
            pass
        exit(1)
    else:
        print 'AT_INFO : scanning  passed'
        if nc.Capture_Flag == True:
            nc.stop_mon_capture()
            pass
        exit(0)
        
# ENTRY    
if __name__ == '__main__':
    """
    """
    
    main()
