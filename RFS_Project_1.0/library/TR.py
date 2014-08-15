import os
import sys
import pexpect
import re

class TR:
    nodes = None
    wan_ip = None
    wan_user = None
    wan_pwd = None
    acs_url = None
    acs_user = None
    acs_pwd = None
    prompt = None
    cfg_file = None
    output = None
    
    def __init__(self):
        self.wan_ip = os.getenv('G_HOST_IP1')
        print 'wan_ip:'
        print self.wan_ip
        self.wan_user = os.getenv('user', 'root')
        self.wan_pwd = os.getenv('pwd', '123qaz')
        self.acs_url = os.getenv('ACS_ConnectionRequestURL')
        print 'acs connection request url'
        print self.acs_url
        self.acs_user = os.getenv('acs_user', 'actiontec')
        self.acs_pwd = os.getenv('acs_pwd', 'actiontec')
        self.prompt = ['\]$', '\]# ', 'Permission denied,', pexpect.EOF, pexpect.TIMEOUT]
        self.cfg_file = '/tmp/jacs_config_file'
        self.output = '/tmp/jacs_output'
    
    def do_gpv(self, *nkw):
        self.__init__()
        print '=' * 100
        print "Begin GPV"
        print nkw
        output = self.output
        
        self.nodes = list(nkw)
        gpv_node = []
        check_dict = {}
        gpv_format1 = r'^ *[\w\.]+ *$'
        gpv_format2 = r'^ *([\w\.]+) *= *([\w\.\,/]+) *$'
        
        # (u'InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID', u'output=/tmp/1')
        for key in self.nodes:
            print key
            m1 = re.match(gpv_format1, key)
            m2 = re.match(gpv_format2, key)
            if m1:
                gpv_node.append(key)
            elif m2:
                
                if key.startswith('output'):
                    output = m2.group(2)
                else:
                    check_dict[m2.group(1)] = m2.group(2)
                    gpv_node.append(m2.group(1))
            else:
                print 'AT_ERROR : GPV parameters Format Error!'
                return False
        print gpv_node
        print check_dict
        
        if not self.Create_GPV_Config_File(gpv_node):
            print 'AT_ERROR : Create Config File ERROR!'
            return False
          
        rc = self.copyCfg(self.cfg_file)
        if rc:
            rc = self.ExcuteJacs(output)
            self.readfile(output)
            if rc and check_dict:
                rc = self.checkGPV(check_dict, output)
                if rc:
                    print 'AT_INFO : GPV PASS PASS PASS!'
                else:
                    print 'AT_ERROR : GPV FAIL FAIL FAIL!'
                return rc
            elif rc:
                print 'AT_INFO : GPV PASS PASS PASS!'
                return True
            else:
                print 'AT_ERROR : GPV FAIL FAIL FAIL!'
                return False
        else:
            return False
#     
    def getGPVResult(self, item, output):
        ""
        if not output:
            output = self.output
        try:
            cmd = 'grep "' + str(item) + '</Name>" ' + output
            print cmd
            rc = os.system(cmd)
            print rc
            if str(rc) == str(0):
                cmd = 'grep "' + str(item) + '</Name>" -A1  ' + output + '|grep "<Value"|awk -F\> ' + "'{print $2}'|awk -F\< '{print $1}'"
                f = os.popen(cmd)
                data = f.readline().strip()
                f.close()
            else:
                data = 'NodeNOTExist'
        except Exception, e:
            print e
            print cmd
            data = 'UNKnown'
        print data
        return data
        
    def checkGPV(self, dict, output):
        ""
        rc = True
        for item in dict:
            value = self.getGPVResult(item, output)
            if value != dict[item]:
                print 'AT_ERROR : ' + item + ' Check FAIL FAIL FAIL!'
                print 'AT_ERROR : Actual value:' + value + ',Expect value:' + dict[item]
                rc = False
        if rc:
            print 'AT_INFO : GPV Result Check PASS!'
        return rc
            
    def do_spv(self, *nkw):
        self.__init__()
        print '=' * 100
        print "Begin SPV"
        print nkw
        output = self.output
        
        self.nodes = list(nkw)
        spv_node = []
        spv_format = r'^ *([\w\.]+) *= *([\w\.\,/]+) +([\w]+) *$'
        
        # (u'InternetGatewayDevice.LANDevice.1.WLANConfiguration.1.SSID=1', u'output=/tmp/1')
        for key in self.nodes:
            print key
            m = re.match(spv_format, key)
            if m:
                if key.startswith('output'):
                    output = m.group(2)
                else:
                    spv_node.append(m.group(1) + '=' + m.group(2) + ' ' + m.group(3))
            else:
                print 'AT_ERROR : SPV parameters Format Error!'
                return False
             
        if not self.Create_SPV_Config_File(spv_node):
            print 'AT_ERROR : Create Config File ERROR!'
            return False
        
        rc = self.copyCfg(self.cfg_file)
        if rc:
            self.ExcuteJacs(output)
            rc = self.readfile(output, filter='FaultCode')
            if rc:
                print 'AT_ERROR : SPV FAIL,Find "FaultCode"!'
                return False
            else:
                rc = self.readfile(output, filter=r'>0</Status>')
                if rc:
                    print 'AT_INFO : SPV PASS PASS PASS PASS PASS!'
                    return True
                else:
                    print 'AT_ERROR : SPV FAIL ,NOT find <Status>0</Status>!'
                    return False
        else:
            return False
    
    
    def ExcuteJacs(self, output):
        "Excute Jacs"        
        if os.path.exists(output):
            os.remove(output)
            
        try:
            start_cmd = 'ssh -l ' + self.wan_user + ' ' + self.wan_ip 
        except Exception, e:
            print start_cmd
            print e
            return False
        child = pexpect.spawn(start_cmd, timeout=60)
#         child.logfile = sys.stdout
        try:
            fout = open(output, 'w')
        except Exception, e:
            print e
            return False
        child.logfile = fout
        
        index = child.expect(['password:', '\(yes\/no\)\?', pexpect.EOF, pexpect.TIMEOUT])
        if index == 0 or index == 1:
            if index == 1:
                child.sendline('yes')
                index = child.expect(['password:', pexpect.EOF, pexpect.TIMEOUT])
                if not index == 0 :
                    print 'AT_ERROR : Login wan pc Fail Fail!'
                    child.logfile.close()
                    return False
                    
            child.sendline(self.wan_pwd)
            index = child.expect(self.prompt)
            if index == 0 or index == 1:
                child.sendline('killall jacs')
                index = child.expect(self.prompt)
                if index == 0 or index == 1:
                    child.sendline('./jacs -f ' + self.cfg_file)
#                     child.sendline('ls')
                    index = child.expect(self.prompt)
                    if index == 0 or index == 1:
                        child.sendline('exit')
                        child.logfile.close()
                        return True
                    else :
                        print 'AT_ERROR : Run jacs FAIL!'
                        child.logfile.close()
                        return False
            elif index == 2:
                print 'AT_ERROR : Login wan pc Fail!'
                child.logfile.close()
                return False
            else:
                print 'AT_ERROR : TimeOut'
                child.logfile.close()
                return False
        else :
            print 'AT_ERROR : TimeOut'
            child.logfile.close()
            return False
    
    
    def Create_GPV_Config_File(self, node):
        try:
            file = open(self.cfg_file, 'w')
        except Exception, e:
            print e
            return False
        file.writelines('listen 1234' + os.linesep)
        file.writelines('connect ' + self.acs_url + ' ' + self.acs_user + ' ' + self.acs_pwd + ' NONE' + os.linesep)
        file.writelines('wait' + os.linesep)
        file.writelines('rpc cwmp:InformResponse MaxEnvelopes=1' + os.linesep)
        file.writelines('wait' + os.linesep)
        gpv_cmd = 'get_params '
        for p in node:
            gpv_cmd += p + ' '
        file.writelines(gpv_cmd + os.linesep)
        file.writelines('wait' + os.linesep)
        file.writelines('rpc0' + os.linesep)
        file.writelines('quit' + os.linesep)
        file.close()
        self.readfile(self.cfg_file)
        return True
    
    
    def Create_SPV_Config_File(self, node):
        try:
            file = open(self.cfg_file, 'w')
        except Exception, e:
            print e
            return False
        file.writelines('listen 1234' + os.linesep)
        file.writelines('connect ' + self.acs_url + ' ' + self.acs_user + ' ' + self.acs_pwd + ' NONE' + os.linesep)
        file.writelines('wait' + os.linesep)
        file.writelines('rpc cwmp:InformResponse MaxEnvelopes=1' + os.linesep)
        file.writelines('wait' + os.linesep)
        spv_cmd = 'set_params '
        for p in node:
            spv_cmd += p + ' '
        file.writelines(spv_cmd + os.linesep)
        file.writelines('wait' + os.linesep)
        file.writelines('rpc0' + os.linesep)
        file.writelines('quit' + os.linesep)
        file.close()
        self.readfile(self.cfg_file)
        return True
    
    def copyCfg(self, file):
        try:
            start_cmd = 'scp ' + file + ' ' + self.wan_ip + ':' + file
            print start_cmd
        except Exception, e:
            print e
            return False
        child = pexpect.spawn(start_cmd, timeout=60)
        child.logfile = sys.stdout
        
        index = child.expect(['password:', '\(yes\/no\)\?', pexpect.EOF, pexpect.TIMEOUT])
        if index == 0 or index == 1:
            if index == 1:
                child.sendline('yes')
                index = child.expect(['password:', pexpect.EOF, pexpect.TIMEOUT])
                if not index == 0 :
                    print 'AT_ERROR : Login wan pc Fail Fail!'
                    return False
                    
            child.sendline(self.wan_pwd)
            index = child.expect(['100%', pexpect.EOF, pexpect.TIMEOUT])
            if index == 0 :
                return True
            else:
                print 'AT_ERROR : SCP Config File Fail!'
                return False
     
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
#             
# tr = TR()
# tr.GPV('InternetGatewayDevice.1', 'InternetGatewayDevice.WiFi.', output='/tmp/22')
