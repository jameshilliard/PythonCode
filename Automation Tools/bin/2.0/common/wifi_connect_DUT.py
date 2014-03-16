#!/usr/bin/python -u
from optparse import OptionParser
from pprint import pprint
import os, re, select, subprocess, time
#import verifyPing
global Capture_Flag

class NETGR_connector():

    is_neg = False
    conf_file_path = ''
    interface = ''
    wait_time = 10
    #check_status_retry = 10
    static_ip = '0'
    host_name = ''

    connect_params = {}

    down_wl_cmd = ''
    reset_wl_cmd = ''
    up_wl_cmd = ''
    auth_wl_cmd = ''
    infra_wl_cmd = ''
    wsec_wl_cmd = ''
    sup_wpa_wl_cmd = ''
    wpa_auth_wl_cmd = ''
    key_wl_cmd = ''
    bssid_wl_cmd = ''
    ssid_wl_cmd = ''
    status_wl_cmd = ''
    capture_wlan_output_log=None
    capture_mon_output_log=None
    def str2raw(self, s) :
        """
        """
        s = str(s)
        if s.startswith('"') and s.endswith('"') :
            return s[1:-1]
        if s.startswith("'") and s.endswith("'") :
            return s[1:-1]
        return s

    def load_conf_file(self):
        """

        """

        conf = os.path.expandvars(self.conf_file_path)

        if not os.path.exists(conf):
            print 'AT_ERROR : file ' + conf + ' not existed !'
            return False
        else:
            fd = open(conf, 'r')
            lines = fd.readlines()
            fd.close()

            for line in lines:
                m = r'(.*)=(.*)'
                rc = re.findall(m, line)
                if len(rc) > 0:
                    k, v = rc[0]
                    #self.connect_params[k.strip()] = self.str2raw(v.strip())
                    self.connect_params[k.strip()] = v.strip()

            print
            pprint(self.connect_params)
            print

        return True

    def wpa2wlcmd(self):
        """
        $U_PATH_TOOLS/netgear

        possible lines :

        ssid                ="$ssid"
        bssid               =$curr_bssid
        key_mgmt            =$key_mgmt
        wep_key$index       =$wep_key
        wep_tx_keyidx       =$index
        auth_alg            =$auth_alg
        proto               =WPA RSN
        pairwise            =TKIP CCMP
        psk                 =$psk
        psk                 ="$psk"
        eap                 =TLS
        identity            ="$identity"
        ca_cert             ="$ca_cert"
        client_cert         ="$cl_cert"
        private_key         ="$cl_key"
        private_key_passwd  ="$private_key_passwd"
        wep_key$index       =$wep_key
        wep_tx_keyidx       =$index
        auth_alg            =$auth_alg

WEP 64 OPEN              |WPA2 AES                |WPA2 TKIP               |WPA AES                 |WPA TKIP               |
-------------------------|------------------------|------------------------|------------------------|-----------------------|
./wl down                |./wl down               |./wl down               |./wl down               |./wl down
./wl up                  |./wl up                 |./wl up                 |./wl up                 |./wl up
./wl auth 0;             |./wl auth 0             |./wl auth 0             |./wl auth 0             |./wl auth 0
./wl infra 1;            |./wl infra 1            |./wl infra 1            |./wl infra 1            |./wl infra 1
-------------------------|------------------------|------------------------|------------------------|-----------------------|
./wl wsec 1;             |./wl wsec 4             |./wl wsec 2             |./wl wsec 4             |./wl wsec 2
./wl sup_wpa 1;          |./wl sup_wpa 1          |./wl sup_wpa 1          |./wl sup_wpa 1          |./wl sup_wpa 1
./wl wpa_auth 0;         |./wl wpa_auth 128       |./wl wpa_auth 128       |./wl wpa_auth 4         |./wl wpa_auth 4
./wl addwep 0 1234567890 |./wl set_pmk 1234567890 |./wl set_pmk 1234567890 |./wl set_pmk 1234567890 |./wl set_pmk 1234567890|
./wl ssid 8CDDE4D4;      |./wl ssid <AP NAME>     |./wl ssid <AP NAME>     |./wl ssid <AP NAME>     |./wl ssid <AP NAME>
------------------------ |----------------------- |----------------------- |----------------------- |-----------------------|
        """

        #netgear_dir = os.path.expandvars('$U_PATH_TOOLS/netgear')

        netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')

        interface = ' -i ' + self.interface + ' '

        connect_params = self.connect_params



        cmd_list = []

        down_wl_cmd = netgear_dir + '/wlx86 ' + interface + ' down'
        up_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'up'
        reset_wl_cmd = netgear_dir + '/wlx86 restart'
        #    set/get 802.11 authentication type. 0 = OpenSystem, 1= SharedKey, 2=Open/Shared OPEN, SHARED

        if connect_params.has_key('auth_alg'):
            if connect_params['auth_alg'] == 'OPEN':
                auth_mode = 'auth 0'
            elif connect_params['auth_alg'] == 'SHARED':
                auth_mode = 'auth 1'
        else:
            auth_mode = 'auth 0'
            #else:

        auth_wl_cmd = netgear_dir + '/wlx86 ' + interface + auth_mode
        infra_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'infra 1'

        # wsec
#        1 - WEP enabled
#        2 - TKIP enabled
#        4 - AES enabled
#        8 - WSEC in software
#        0x80 - FIPS enabled
#        0x100 - WAPI enabled
        wsec = ''
        #    pairwise CCMP

        if connect_params.has_key('key_mgmt'):

            if connect_params['key_mgmt'] == 'NONE':
                print 'INFO :WEP mode '
                wsec = 'wsec 1'

            elif connect_params.has_key('pairwise'):
                print 'INFO : WPA mode'
                if connect_params['pairwise'] == 'TKIP':
                    print 'INFO : TKIP mode'
                    wsec = 'wsec 2'
                elif connect_params['pairwise'] == 'CCMP':
                    print 'INFO : CCMP mode'
                    wsec = 'wsec 4'

        wsec_wl_cmd = netgear_dir + '/wlx86 ' + interface + wsec

        #sup_wpa

        sup_wpa_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'sup_wpa 1'

        #wpa_auth
#        wpa_auth
#        Bitvector of WPA authorization modes:
#            1    WPA-NONE
#            2    WPA-802.1X/WPA-Professional
#        4    WPA-PSK/WPA-Personal
#            64    WPA2-802.1X/WPA2-Professional
#        128    WPA2-PSK/WPA2-Personal
#        0    disable WPA

        if connect_params.has_key('key_mgmt'):
            if connect_params['key_mgmt'] == 'NONE':
                wpa_auth = 'wpa_auth 0'
            elif connect_params['key_mgmt'] == 'WPA-PSK':
                if connect_params['proto'] == 'RSN' or connect_params['proto'] == 'WPA2':
                    wpa_auth = 'wpa_auth 128'
                elif connect_params['proto'] == 'WPA':
                    wpa_auth = 'wpa_auth 4'

        wpa_auth_wl_cmd = netgear_dir + '/wlx86 ' + interface + wpa_auth

        # wireless key
        #./wl addwep 0 1234567890 |./wl set_pmk 1234567890

        key_str = ''

        if connect_params.has_key('key_mgmt'):
            if connect_params['key_mgmt'] == 'NONE':
                # wep_key0=1234567890 wep_tx_keyidx=0

                key_idx = connect_params['wep_tx_keyidx']
                key_val = connect_params['wep_key' + key_idx]

                key_str = 'addwep ' + key_idx + ' ' + key_val
            elif connect_params['key_mgmt'] == 'WPA-PSK':
                key_str = 'set_pmk ' + connect_params['psk']


        key_wl_cmd = netgear_dir + '/wlx86 ' + interface + key_str

        #STATUS

        status_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'status'

        cmd_list.append(down_wl_cmd)
        cmd_list.append(reset_wl_cmd)
        cmd_list.append(up_wl_cmd)
        cmd_list.append(auth_wl_cmd)
        cmd_list.append(infra_wl_cmd)
        cmd_list.append(wsec_wl_cmd)
        cmd_list.append(sup_wpa_wl_cmd)
        cmd_list.append(wpa_auth_wl_cmd)
        cmd_list.append(key_wl_cmd)

        self.down_wl_cmd = down_wl_cmd
        self.reset_wl_cmd = reset_wl_cmd
        self.up_wl_cmd = up_wl_cmd
        self.auth_wl_cmd = auth_wl_cmd
        self.infra_wl_cmd = infra_wl_cmd
        self.wsec_wl_cmd = wsec_wl_cmd
        self.sup_wpa_wl_cmd = sup_wpa_wl_cmd
        self.wpa_auth_wl_cmd = wpa_auth_wl_cmd
        self.key_wl_cmd = key_wl_cmd


        ### BSSID
        if connect_params.has_key('bssid'):
            bssid_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'mac ' + connect_params['bssid']
            cmd_list.append(bssid_wl_cmd)
            self.bssid_wl_cmd = bssid_wl_cmd

        ### SSID
        if connect_params.has_key('ssid'):
            ssid_wl_cmd = netgear_dir + '/wlx86 ' + interface + 'ssid ' + connect_params['ssid']
            cmd_list.append(ssid_wl_cmd)
            self.ssid_wl_cmd = ssid_wl_cmd
        else:
            print 'AT_ERROR : must contain a SSID name in config file'
            cmd_list = []
            return cmd_list

        cmd_list.append(status_wl_cmd)
        self.status_wl_cmd = status_wl_cmd


        return cmd_list

    def check_status(self):
        """
        """
        rc = False

        for i in range(self.wait_time):
            time.sleep(5)
            rc, output = self.subproc(self.status_wl_cmd)

            if not output.find('Mode: Managed') > -1:
                print 'INFO : not ready yet'
            else:
                print 'INFO : wireless card is ready to GET IP'
                rc = True
                break

        if self.is_neg:
            rc = True

        return rc

    def add_def_rt(self):
        """
        to add default route
        """

        rc = False

#    route del default;route add default gw $G_PROD_IP_BR0_0_0  dev ${interface}
#
        rt_cmd = 'route del default;route add default gw $G_PROD_IP_BR0_0_0  dev ' + self.interface

        rcc, output = self.subproc(rt_cmd)
        if rcc == 0:
            rc = True
        return rc

    def configure_IP(self):
        """
        configure IP staticly
        """
        rc = False

        kill_dhc_cmd = 'killall -9 dhclient'

        self.subproc(kill_dhc_cmd)

        ip_cmd = 'ip link set ' + self.interface + ' up;' + 'ip -4 addr flush dev ' + self.interface + ';ip addr add ' + self.static_ip + '/24 dev ' + self.interface

        rcc, output = self.subproc(ip_cmd)

        if rcc == 0:
            if  self.add_def_rt():
                #'to ping'
                ping_cmd = 'python $U_PATH_TBIN/verifyPing.py -d $TMP_DUT_DEF_GW'
                rcc, output = self.subproc(ping_cmd)

                if rcc == 0:
                    if not self.is_neg:
                        print 'INFO : positive test passed'
                        rc = True
                    else:
                        print 'AT_ERROR : negative test failed'
                        rc = False
                else:
                    if not self.is_neg:
                        print 'AT_ERROR : positive test failed'
                        rc = False
                    else:
                        print 'INFO : negative test passed'
                        rc = True
            else:
                print 'AT_ERROR : failed to add default route to wireless NIC'
                rc = False

        return rc

    def fetch_IP(self):
        """
        get IP via DHclient
        """
        rc = False
        
        kill_dhc_cmd = 'killall -9 dhclient'
        delete_pidfile='rm -f /tmp/' + self.interface + '.pid'
        if self.host_name == '':
            ip_cmd = 'dhclient -v ' + self.interface + ' -pf /tmp/' + self.interface + '.pid'
        else:
            ip_cmd = 'dhclient -v ' + self.interface + ' -H ' + self.host_name + ' -pf /tmp/' + self.interface + '.pid'
            
        self.subproc(delete_pidfile)    
        self.subproc(kill_dhc_cmd)
        
        rcc, output = self.subproc(ip_cmd)

        if rcc == 0:
            self.subproc(kill_dhc_cmd)

            m_ip = r'bound to (.*) -- renewal in \d* seconds.'
            rc_ip = re.findall(m_ip, output)

            if len(rc_ip) > 0:
                got_ip = rc_ip[0]

                if not self.is_neg:
                    print 'INFO : positive test , should be able to get IP'
                    print 'INFO : successfully got IP %s from AP %s' % (got_ip, self.connect_params['ssid'])
                    rc = True
                else:
                    print 'AT_ERROR : negative test , should NOT be able to get IP'
                    print 'AT_ERROR : successfully got IP %s from AP %s' % (got_ip, self.connect_params['ssid'])
                    rc = False
            else:
                if not self.is_neg:
                    print 'AT_ERROR : positive test , should be able to get IP'
                    print 'AT_ERROR : failed to get IP from AP %s' % (self.connect_params['ssid'])
                    rc = False
                else:
                    print 'INFO : negative test , should NOT be able to get IP'
                    print 'INFO : didn\'t get IP from AP %s as expected' % (self.connect_params['ssid'])
                    rc = True
        else:
            print 'AT_ERROR : failed to get IP from AP'
            self.subproc(kill_dhc_cmd)
            return False

        return rc

    def is_in_same_net(self, ip1, ip2):
        """
        return True if two ip in same net
        """

        if '-'.join(ip1.split('.')[:-1]) == '-'.join(ip2.split('.')[:-1]):
            rc = True
        else:
            rc = False

        return rc

    def flush_all_br0_net(self):
        """
        disable all NIC in same net with $G_PROD_GW_BR0_0_0
        """

        rc = True

        rcc, output = self.subproc('ifconfig -a')
        if rcc != 0:
            return False

        m_iface_ip = r'([\w.]*) *Link *encap:.* *HWaddr *.*\n *inet *addr:([0-9.]*)'

        rcc = re.findall(m_iface_ip, output)

        if len(rcc) > 0:
            for rccc in rcc:
                iface, ifcip = rccc
                print 'INFO : %s -> %s' % (iface, ifcip)

                if self.is_in_same_net(ifcip, os.getenv('G_PROD_GW_BR0_0_0')):
                    flush_cmd = 'ip -4 addr flush dev ' + iface + ';ip link set ' + iface + ' down'
                    rc_flush, output = self.subproc(flush_cmd)

                    if not rc_flush == 0:
                        print 'AT_ERROR : flush ip failed'
                        rc = False
                        break
        return rc

    def connect(self):
        """
        """

        if not self.flush_all_br0_net():
            return False

        print 'INFO : try to connect to AP'
        if not self.load_conf_file():
            print 'AT_ERROR : error loading wireless config file'
            return False
        else:
            cmd_list = self.wpa2wlcmd()

            if len(cmd_list) == 0:
                print 'AT_ERROR : error converting from wpa conf to netgear command'
                return False

            for cmd in cmd_list:
                #print 'INFO : >>>subproc start time :',time.asctime()
                rc, output = self.subproc(cmd)
                #print 'INFO : <<<subproc end time :',time.asctime()

                print 'INFO : wait 3 sec'
                time.sleep(3)

                if not rc == 0:
                    return False
                else:
                    output = output.strip()
                    if len(output) > 0:
                        #output=''
                        if  cmd == self.status_wl_cmd or cmd == self.ssid_wl_cmd:
                            pass
                        else:
                            return False
        #
        if not self.check_status():
            return False
        #begin capture
        self.start_wlan_capture()
        if self.static_ip == '0':
            if not self.fetch_IP():
                return False
        else:
            if not self.configure_IP():
                return False

        return True

    def subproc(self, cmdss, timeout=3600) :
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

            all_rc += rc
            all_output += output

        return all_rc, all_output

    def start_mon_capture(self):
        print 'Entry start_mon_capture'
        i=0
        sleep_time=3
        while i<3:
            i+=1
            print 'Try '+str(i)+' Times...'
            exit_status=False
            netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')
            
            (rc1,output_ifconfig)=self.subproc('ifconfig '+self.interface+' up')
            time.sleep(sleep_time)
            
            (rc2,output_mon0)=self.subproc(netgear_dir + '/wlx86 monitor 0')
            time.sleep(sleep_time)
            
            (rc3,output_mon0)=self.subproc(netgear_dir + '/wlx86 monitor 1')
            time.sleep(sleep_time)
            
            (rc,self.moniface)=self.subproc('ifconfig |grep -o "^ *prism[0-9][0-9]*"')
            self.moniface=str(self.moniface).strip()
            time.sleep(sleep_time)
            if self.moniface:
                cur_time=time.strftime("%m%d%H%M%S")
                print cur_time
                self.capture_mon_output_log='lan_'+self.moniface+'_'+cur_time+'.cap'
                print 'capture_mon_output_log : '+self.capture_mon_output_log
                
                start_capture_cmd='bash $U_PATH_TBIN/raw_capture.sh --local -i '+self.moniface+' -o '+ self.capture_mon_output_log+' -t 3600 --begin'
                (rcc,capture_output)=self.subproc(start_capture_cmd)
                if rcc==0:
                    exit_status=True
                    (rccc,iface)=self.subproc('ifconfig;route -n')
                    break
                else:
                    print 'Start capture Fail!'
            else:
                print 'Monitor interface not exist!'
                (rccc,iface)=self.subproc('ifconfig;route -n')
            
        return exit_status
        
    def start_wlan_capture(self):
        print 'Entry start_wlan_capture'
        i=0
        sleep_time=3
        while i<1:
            i+=1
            print 'Try '+str(i)+' Times...'
            exit_status=False
            netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')
            
            (rc1,pid2kill)=self.subproc('ps aux|grep -v grep|grep tshark|grep "i  *'+self.interface+"\"|awk '{print $2}'")
            time.sleep(sleep_time)
            pid2kill=str(pid2kill).strip()
            print pid2kill
            if pid2kill:
                self.subproc('kill -9 '+pid2kill)
            time.sleep(sleep_time)
            #os.system('ifconfig '+self.interface+' up')
            cur_time=time.strftime("%m%d%H%M%S")
            print cur_time
            self.capture_wlan_output_log='lan_'+self.interface+'_'+cur_time+'.cap'
            print 'capture_wlan_output_log : '+self.capture_wlan_output_log
            
            start_capture_cmd='bash $U_PATH_TBIN/raw_capture.sh --local -i '+self.interface+' -o '+ self.capture_wlan_output_log+' -t 3600 --begin'
            (rcc,capture_output)=self.subproc(start_capture_cmd)
            print 'U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE : '
            
            (rtcode,pid2killaftercase)=self.subproc('ps aux|grep -v grep|grep tshark|grep "i  *'+self.interface+"\"|awk '{print $2}'")
            pid2killaftercase=str(pid2killaftercase).strip()
            file1_path=os.getenv('G_CURRENTLOG')+'/kill_tshark_'+str(self.interface)+'_'+str(cur_time)
            print 'file1_path : '+file1_path
            tshark_file=open(file1_path,'w')
            tshark_file.write('kill -9 '+pid2killaftercase)
            tshark_file.close()
            
            print 'U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE : '+os.getenv('U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE')
            os.environ['U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE']=os.getenv('G_CURRENTLOG')+'/jobs_after_case'
            print 'U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE : '+os.getenv('U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE')
            
            file2_path=os.getenv('U_CUSTOM_FILE_JOBS_AFTER_EACH_CASE')
            print 'file2_path : '+file2_path
            after_case_file=open(file2_path,'a')
            after_case_file.write(file1_path+'\n')
            after_case_file.close()
            
            if rcc==0:
                print '--------------------------------------'
                exit_status=True
                (rccc,iface)=self.subproc('ifconfig;route -n')
                break
            else:
                print 'Start capture Fail!'

        return exit_status
    def stop_mon_capture(self):
        print 'Entry stop_capture'
        exit_status=False
        sleep_time=5
        netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')
        
        stop_capture_cmd='bash $U_PATH_TBIN/raw_capture.sh --local -i '+self.moniface+' -o '+ self.capture_mon_output_log+' --stop'
        (rcc,capture_output)=self.subproc(stop_capture_cmd)
        time.sleep(sleep_time)
        print netgear_dir + '/wlx86 monitor 0'
        (rc2,output_mon0)=self.subproc(netgear_dir + '/wlx86 monitor 0')
        (rccc,iface)=self.subproc('ifconfig;route -n')
        if rc2==0:
            exit_status=True
        return exit_status


def main() :
    """
    arguments list:
    -n -f -i -t -a -H
    """
    print 'now we are in python ...'
    usage = "usage: %prog -n/--negative -f/--file config file  -i/--interface iface -t/--waittime waittime -a/--ipaddr ip address -H/--hostname hostname\n"

    usage += "Arguments :\n"
    usage += "-n/--negative              : negative test mode \n"
    usage += "-f/--file                  : wireless connection config file \n"
    usage += "-i/--interface             : wireless interface \n"
    usage += "-t/--waittime              : wait time \n"
    usage += "-a/--ipaddr                : ip addr in static ip mode \n"
    usage += "-H/--hostname              : host name if needed \n"

    ######################

    parser = OptionParser(usage=usage)
    parser.add_option("-w", "--capture", dest="capture_flag", help="capture or not")
    parser.add_option("-n", "--negative", dest="is_neg", action="store_true", help="set true if negative test")
    parser.add_option("-f", "--file", dest="wifi_conf_file", help="file path of wireless connection config file")
    parser.add_option("-i", "--interface", dest="interface", help="wireless NIC interface")
    parser.add_option("-t", "--waittime", dest="wait_time", help="wait time")
    parser.add_option("-a", "--ipaddr", dest="static_ip", help="static ip used in static mode")
    parser.add_option("-H", "--hostname", dest="host_name", help="host name if defined")

    (options, args) = parser.parse_args()

    #########################

    nc = NETGR_connector()
    Capture_Flag=True
    if options.capture_flag==str(0):
        Capture_Flag=False
    print 'capture : '+str(Capture_Flag)
    if options.is_neg:
        nc.is_neg = True
    if options.wifi_conf_file:
        nc.conf_file_path = options.wifi_conf_file
    if options.interface:
        nc.interface = options.interface
    if options.wait_time:
        nc.wait_time = int(options.wait_time)
    if options.static_ip:
        nc.static_ip = options.static_ip
    if options.host_name:
        nc.host_name = options.host_name

    ##############################

    whole_again_chance = 3
    whole_rc = False
    if Capture_Flag==True:
        #nc.start_mon_capture()
        pass
    for i in range(whole_again_chance):
        print 'INFO : connecting attempt %s ' % str(i + 1)
        
        

        if not nc.connect():

            print 'AT_ERROR : connecting to AP failed'
            
            netgear_dir = os.path.expandvars(os.getenv('U_PATH_TOOLS') + '/netgear')
            
            reload_mod_cmd = 'rmmod ' + netgear_dir + '/wl.ko;rmmod ' + netgear_dir + '/bcm_usbshim.ko;' + 'insmod ' + netgear_dir + '/bcm_usbshim.ko;insmod ' + netgear_dir + '/wl.ko'
            
            nc.subproc(reload_mod_cmd)
            #exit(1)
            time.sleep(30)
        else:
            print 'AT_INFO : connecting to AP passed'
            #exit(0)
            whole_rc = True


            print 'AT_NOTICE : passed on attempt %s' % (str(i + 1))
            break
    if Capture_Flag==True:
        #nc.stop_mon_capture()
        pass
    if not whole_rc:
        exit(1)
    else:
        exit(0)

# ENTRY
if __name__ == '__main__':
    """
    """

    main()
