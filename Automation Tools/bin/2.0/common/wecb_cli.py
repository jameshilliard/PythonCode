#!/usr/bin/python -u
from optparse import OptionParser    
import os, re, time,sys
from pprint import pprint

postfile_csv = os.getenv('U_POSTFILE_CSV', None)
rdcli_csv = os.getenv('U_RDCLI_CSV', None)  
SSIDs_INDEX = os.getenv('U_DUT_WIRELESS_DEF_INDEX', '[1,2,3,4,5,6,7,8]')
wait180=['Restore_DUT','Reboot_DUT']
class WECB_CLI():
    
    ALL_SSID_INDEX = []
    filename = ''
    alias = ''
    ssidindex = ''
    keyindex = ''
    ssidname = ''
    securitykey = ''
    radiusserver = ''
    radisusecret = ''
    radiusport = ''
    set_cli_file = ''    
    get_cli_file = ''
    set_output_file = ''
    get_output_file = ''

    def env2str(self, s) :
        """
        """
        m = r'\${\w*}'
        
        rc = re.findall(m, s)
        
        if len(rc) != 0 :
            for i in range(len(rc)):
                s = s.replace(rc[i], os.popen('echo "' + rc[i] + '"').read().strip())
        
        return os.popen('echo "' + s + '"').read().strip()
    
    def str2raw(self, s) :
        """
        """
        s = str(s)
        if s.startswith('"') and s.endswith('"') :
            return s[1:-1]
        if s.startswith("'") and s.endswith("'") :
            return s[1:-1]
        return s
    
    def safe2Int(self, s) :
        """
        """
        rc = None
        try :
            rc = int(s)
        except :
            rc = None
        return rc
    
    def safe2Float(self, s) :
        """
        """
        rc = None
        try :
            rc = float(s)
        except :
            rc = None
        return rc
    
    
    def parseArr(self, s) :
        """
        ['1','10'] => ['1','10']
        [1,10] => ['1','10']
        [1..3] => ['1','2','3']
    
    
        """
    
        rc = []
        if s.startswith('[') and s.endswith(']') :
            s = s[1:-1]
            z = s.split(',')
            for p in z :
                if p.find('..') >= 0 :
                    zz = p.split('..')
                    if len(zz) == 2 :
                        b = self.str2raw(zz[0])
                        e = self.str2raw(zz[1])
                        b = self.safe2Int(b)
                        e = self.safe2Int(e)
                        if not b == None and not e == None and (e >= e):
                            for i in range(b, e + 1) :
                                rc.append(str(i))
    
                else :
                    p = self.str2raw(p)
                    rc.append(str(p))
        pass
        return rc
    
    def execute_cli(self, set_cli_file):
        '''
        '''
        print '==============Entry function execute_cli'
        print time.ctime()
        if not os.path.exists(set_cli_file):
            print set_cli_file + ' NOT Exist!'
            exit(1)
        print set_cli_file + ' has been created PASS!'
        myfile = open(set_cli_file, 'r')
        myline = myfile.readlines()
        myfile.close()
        clistr = ''
        for line in myline:
            line = line.strip()
            cstr = ' -v "' + line + '"'
            clistr = clistr + cstr
        print 'Parameter : ' + clistr
        mycmd = '$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/ssh_clicmd.log  -y ssh -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 ' + clistr
        print 'CLI Command : ' + mycmd
        set_output = os.popen(mycmd).read().strip()
        self.set_output_file = set_cli_file + '.log'
        set_file = open(self.set_output_file, 'w')
        set_file.write(set_output)
        set_file.close()
        
        if self.alias in wait180:
            print 'WaitTime : 180'
            time.sleep(180)
        else:
            print 'WaitTime : 120'
            time.sleep(120)
        print time.ctime()
        if os.path.exists(self.get_cli_file):
            print self.get_cli_file + ' Exist!'
            check_file = open(self.get_cli_file, 'r')
            check_lines = check_file.readlines()
            check_file.close()
            ckstrs = ''
            for ck_line in check_lines:
                ck_line = ck_line.strip()
                ckstrs += ' -v "' + ck_line + '"'
            print 'check string : ' + ckstrs
            chkcmd = '$U_PATH_TBIN/clicmd -o $G_CURRENTLOG/ssh_clicmd.log  -y ssh -u $U_DUT_TELNET_USER -p $U_DUT_TELNET_PWD -d $G_PROD_IP_BR0_0_0 ' + ckstrs
            print 'Check Command : ' + chkcmd
            get_output = os.popen(chkcmd).read().strip()
            self.get_output_file = self.get_cli_file + '.log'
            get_file = open(self.get_output_file, 'w')
            get_file.write(get_output)
            get_file.close()
            
            self.check_result()
            
    def check_result(self):
        #cli -s Device.WiFi.AccessPoint.6.Security.WEPKey string FFF9DFFFF9
        #Device.WiFi.AccessPoint.6.Security.WEPKey = FFF9DFFFF9 (String)
        '''
        '''
        print '==============Entry function check_result'
        print time.ctime()
        set_rule = r'cli *\-p *([^ ]*) *(\w*) *([^ ]*)'
        fr = open(self.set_cli_file, 'r')
        scmds = fr.readlines()

        fr.close()
        all_cmd=[]
        pass_cmd=[]
        error_cmd=[]
        for scmd in scmds:
            scmd = scmd.strip()
            set_cmd = re.findall(set_rule, scmd)
            if len(set_cmd) > 0:
                all_cmd.append(scmd)
                node, type, value = set_cmd[0]
                get_rule = node + ' *= *' + value

                print 'get_rule : ' + get_rule
                
                fg = open(self.get_output_file, 'r')
                gcmds = fg.readlines()
                fg.close()
                
                for gcmd in gcmds:
                    gcmd = gcmd.strip()
                    get_cmd = re.findall(get_rule, gcmd)
                    if len(get_cmd) > 0:
                        print scmd + ' SUCCESS!'
                        pass_cmd.append(scmd)
                        break
        print 'ALL CLI Command  :'+str(all_cmd)
        print 'PASS CLI Command :'+str(pass_cmd)
        lenp=len(pass_cmd)
        lena=len(all_cmd)
        if lenp<lena:
            print 'FAIL CLI Command :'
            for k in all_cmd:
                if k in pass_cmd:
                    pass
                else:
                    error_cmd.append(k)
                    print k +' Execute Fail!'
            exit(1)
        else:
            print '\nALL CLI Command execute PASS! '
            
    def append_single_ssid(self, PostFileName):
        '''    
        '''
        print '==============Entry function append_single_ssid'
        ALL_SSID_INDEX = self.ALL_SSID_INDEX
        print '\nReplace variable......\n'
        
        FileName = os.path.expandvars(self.filename)
        Alias = os.path.expandvars(self.alias)
        SSID_NAME = os.path.expandvars(self.ssidname)
        SSID_INDEX = ALL_SSID_INDEX[int(self.ssidindex)-1]
        KEY_INDEX = os.path.expandvars(self.keyindex)
        SECURITY_KEY = os.path.expandvars(self.securitykey)
        RADIUS_SERVER = os.path.expandvars(self.radiusserver)
        RADIUS_SECRET = os.path.expandvars(self.radisusecret)
        RADIUS_PORT = os.path.expandvars(self.radiusport)

        os.environ.update(
                          {
                           'FileName' :FileName,
                           'Alias' : Alias,
                           'SSID_INDEX':SSID_INDEX,
                           'KEY_INDEX':KEY_INDEX,
                           'SECURITY_KEY':SECURITY_KEY,
                           'RADIUS_SERVER':RADIUS_SERVER,
                           'RADIUS_SECRET':RADIUS_SECRET,
                           'RADIUS_PORT':RADIUS_PORT,
                           'SSID_NAME':SSID_NAME,
                           }
                          )
        
        print 'PostFileName  : ' + FileName
        print 'Alias         : ' + Alias
        print 'SSID_NAME     : ' + SSID_NAME
        print 'SSID_INDEX    : ' + SSID_INDEX
        print 'KEY_INDEX     : ' + KEY_INDEX
        print 'SECURITY_KEY  : ' + SECURITY_KEY
        print 'RADIUS_SERVER : ' + RADIUS_SERVER
        print 'RADIUS_SECRET  : ' + RADIUS_SECRET
        print 'RADIUS_PORT    : ' + RADIUS_PORT + '\n'
        error_count = 0
        
        if str(SECURITY_KEY).find('$') != -1 :
            print 'SECURITY_KEY is still variable,not be replaced!'
            error_count += 1
        if str(KEY_INDEX).find('$') != -1 :
            print 'KEY_INDEX is still variable,not be replaced!'
            error_count += 1
        if str(SSID_INDEX).find('$') != -1 :
            print 'SSID_INDEX is still variable,not be replaced!'
            error_count += 1
        if str(RADIUS_SERVER).find('$') != -1 :
            print 'RADIUS_SERVER is still variable,not be replaced!'
            error_count += 1
        if str(RADIUS_SECRET).find('$') != -1 :
            print 'RADIUS_SECRET is still variable,not be replaced!'
            error_count += 1
        if str(RADIUS_PORT).find('$') != -1 :
            print 'RADIUS_PORT is still variable,not be replaced!'
            error_count += 1
        if str(SSID_NAME).find('$') != -1 :
            print 'SSID_NAME is still variable,not be replaced!'
            error_count += 1
        if error_count > 0:
            exit(1)
            
        m_alias = r'^ *' + Alias + r'.*'
        fa = open(rdcli_csv, 'r')
        alines = fa.readlines()
        fa.close()
        ac_arr = []
        for line in alines:
            ac_count = re.findall(m_alias, line)
            if ac_count :
                tem_ac_str = ac_count[0]
                tem_ac_list = tem_ac_str.split(',')
                ac_arr.append(tem_ac_list)
        print ac_arr
        len_ac_arr = len(ac_arr)
        if len_ac_arr >= 2:
            print 'AT_ERROR : find ' + str(len_ac_arr) + ' "' + Alias + '"' + ' in ' + rdcli_csv
            exit(1)
        elif len_ac_arr == 0:
            print 'AT_ERROR : NO find ' + Alias + ' in ' + rdcli_csv
            exit(1)
        elif len_ac_arr == 1:
            print 'Alias = ' + Alias
            print 'Find 1 ' + Alias + ' rule in ' + rdcli_csv
            act_ac_arr = ac_arr[0]
            c_alias = act_ac_arr[0]
            if c_alias != Alias:
                print 'Alias = ' + Alias + ' in postfile_csv NOT Equal with Alias = ' + c_alias + ' in rdcli_csv'
            CLI = act_ac_arr[1]
            CLI_CMD = os.path.expandvars(CLI)
            CLI_List = CLI_CMD.split('::')
            print CLI_List
            
            s_cli = open(self.set_cli_file, 'a')          
            g_cli = open(self.get_cli_file, 'a')
            
            for item in CLI_List:
                print item

                if item.startswith('cli -p'):
                    
                    m_g = r'cli *\-p *[^ ]*'
                    
                    rc_cmd = re.findall(m_g, item)
                    
                    if len(rc_cmd) > 0:
                        
                        item_check = rc_cmd[0].replace('cli -p', 'cli -g')
                    
                        print 'The checking command is :', item_check
                        g_cli.write(item_check + '\n')
                    
                s_cli.write(item + '\n')
                
            s_cli.close()
            g_cli.close()    
        
    
    def Create_Wireless_CLI_File(self, PostFileName, rc_arr):
        '''
        '''
        print '==============Entry function Create_Wireless_CLI_File'
        self.ALL_SSID_INDEX = self.parseArr(SSIDs_INDEX)
        ALL_SSID_INDEX=self.ALL_SSID_INDEX
        ALL_SSID_NUM=len(ALL_SSID_INDEX)
        act_list = rc_arr[0]
        
        self.filename = str(act_list[0])
        self.alias = str(act_list[1])
        self.ssidindex = str(act_list[2])
        fiveG = os.getenv('U_DUT_Wireless_Frequency')
        if fiveG == '5':
            self.ssidindex=str(int(act_list[2])+4)
        self.keyindex = act_list[3]
        self.ssidname = act_list[4]
        self.securitykey = act_list[5]
        self.radiusserver = act_list[6]
        self.radisusecret = act_list[7]
        self.radiusport = act_list[8]
        
        print 'PostFileName  : ' + self.filename
        print 'Alias         : ' + self.alias
        print 'SSID_INDEX    : ' + self.ssidindex
        print 'KEY_INDEX     : ' + self.keyindex
        print 'SSID_NAME     : ' + self.ssidname
        print 'SECURITY_KEY  : ' + self.securitykey
        print 'RADIUS_SERVER : ' + self.radiusserver
        print 'RADIUS_SECRET : ' + self.radisusecret
        print 'RADIUS_PORT   : ' + self.radiusport
                                          
#        if self.filename != PostFileName:
#            print 'AT_ERROR : PostFile Name dont match!'
#            exit(1)
        if self.alias.startswith('ALL'):
            print 'Setup ALL SSID : ' + str(ALL_SSID_INDEX)
            
            securitykeys = self.securitykey.split('::')
            
            KEY_NUM = len(securitykeys)
            
            for i in range(ALL_SSID_NUM - KEY_NUM):
                securitykeys.append(securitykeys[0])
            
            for idx, idx_value in enumerate(ALL_SSID_INDEX):
                print '----------------------------------------------------------------------------------------------------'
                current_ssid_var = 'U_WIRELESS_SSID' + str(idx + 1)
                current_ssid_val = os.getenv(current_ssid_var)
                
                print '%s : %s' % (current_ssid_var, current_ssid_val)
           
                self.ssidname = current_ssid_val
                self.ssidindex = idx
                self.securitykey = securitykeys[idx]
                
                self.append_single_ssid(PostFileName)
            
        else:
            self.append_single_ssid(PostFileName)
            
        self.execute_cli(self.set_cli_file)
        
    def Create_Common_CLI_File(self, PostFileName, rc_arr):
        '''
        '''
        print '==============Entry function Create_Common_CLI_File'
        act_list = rc_arr[0]
        
        self.filename = str(act_list[0])
        self.alias = str(act_list[1])

        
        print 'PostFileName  : ' + self.filename
        print 'Alias         : ' + self.alias
                                 
        FileName = os.path.expandvars(self.filename)
        Alias = os.path.expandvars(self.alias)

        os.environ.update(
                          {
                           'FileName' :FileName,
                           'Alias' : Alias,
                           }
                          )

        m_alias = r'^ *' + Alias + r'.*'
        fa = open(rdcli_csv, 'r')
        alines = fa.readlines()
        fa.close()
        ac_arr = []
        for line in alines:
            ac_count = re.findall(m_alias, line)
            if ac_count :
                tem_ac_str = ac_count[0]
                tem_ac_list = tem_ac_str.split(',')
                ac_arr.append(tem_ac_list)
        print ac_arr
        len_ac_arr = len(ac_arr)
        if len_ac_arr >= 2:
            print 'AT_ERROR : find ' + str(len_ac_arr) + ' "' + Alias + '"' + ' in ' + rdcli_csv
            exit(1)
        elif len_ac_arr == 0:
            print 'AT_ERROR : NO find ' + Alias + ' in ' + rdcli_csv
            exit(1)
        elif len_ac_arr == 1:
            print 'Alias = ' + Alias
            print 'Find 1 ' + Alias + ' rule in ' + rdcli_csv
            act_ac_arr = ac_arr[0]
            c_alias = act_ac_arr[0]
            if c_alias != Alias:
                print 'Alias = ' + Alias + ' in postfile_csv NOT Equal with Alias = ' + c_alias + ' in rdcli_csv'
            CLI = act_ac_arr[1]
            CLI_CMD = os.path.expandvars(CLI)
            CLI_List = CLI_CMD.split('::')
            print CLI_List
            
            #G_CURRENTLOG = os.getenv('G_CURRENTLOG', '/tmp')
            #self.set_cli_file = os.path.expandvars(G_CURRENTLOG + '/' + PostFileName)
            
           # self.get_cli_file = self.set_cli_file + '_check'
#            if os.path.exists(self.set_cli_file):
#                os.remove(self.set_cli_file)
            s_cli = open(self.set_cli_file, 'w') 
           # g_cli = open(self.get_cli_file, 'a')
            
            for item in CLI_List:
#                print item
#
#                if item.startswith('cli -p'):
#                    
#                    m_g = r'cli *\-p *[^ ]*'
#                    
#                    rc_cmd = re.findall(m_g, item)
#                    
#                    if len(rc_cmd) > 0:
#                        #print rc_cmd[0]
#                        
#                        item_check = rc_cmd[0].replace('cli -p', 'cli -g')
#                    
#                        print 'The checking command is :', item_check
#                        g_cli.write(item_check + '\n')
                    
                s_cli.write(item + '\n')
                
            s_cli.close()
           # g_cli.close()
            
        self.execute_cli(self.set_cli_file)

    def classify(self, PostFileName):
        '''
        '''
        print '==============Entry function classify'
        
        m_pfile = r'^ *' + PostFileName + r'.*'
        
        fn = open(postfile_csv, 'r')
        lines = fn.readlines()
        fn.close()
        
        rc_arr = []
        for line in lines:
            rc_count = re.findall(m_pfile, line)
            if rc_count:
                tmp_arr = rc_count[0]
                arrarr = tmp_arr.split(',')
                rc_arr.append(arrarr)
        print rc_arr
        
        len_arr = len(rc_arr)
        if len_arr >= 2:
            print 'AT_ERROR : find ' + str(len_arr) + ' "' + PostFileName + '"' + ' in ' + postfile_csv
            exit(1)
        elif len_arr == 0:
            print 'AT_ERROR : NO find ' + PostFileName + ' in ' + postfile_csv
            exit(1)
        elif len_arr == 1:
            print 'Find 1 ' + PostFileName + ' in ' + postfile_csv
        else:
            print 'AT_ERROR : '
            exit(1)
            
        G_CURRENTLOG = os.getenv('G_CURRENTLOG', '/tmp')
        self.set_cli_file = os.path.expandvars(G_CURRENTLOG + '/' + PostFileName)            
        self.get_cli_file = self.set_cli_file + '_check'
        
        if os.path.exists(self.get_cli_file):
            os.remove(self.set_cli_file)
        if os.path.exists(self.get_cli_file):
            os.remove(self.get_cli_file)
                    
        act_list = rc_arr[0]
        if str(act_list[-1]) == 'WL':
            self.Create_Wireless_CLI_File(PostFileName, rc_arr)
        elif str(act_list[-1]) == 'Common':
            self.Create_Common_CLI_File(PostFileName,rc_arr)
        else:
            print 'AT_ERROR : Not Find match kinds!'
            exit(1)              

def printUsage() :
    print '-'*8
    print usage
    return True

def main() :
    """
    """
    
    print '==========Entry function main'
    usage = sys.argv[0] + ' $DUT_TYPE $Postfile [-d 0]'
    argc = len(sys.argv)
    print argc
    if argc < 3 :
        printUsage()
        return False
    print sys.argv[0]
    
    if postfile_csv:
        if not os.path.isfile(postfile_csv):
            print 'AT_ERROR : ' + str(postfile_csv) + ' not exist!\n'
            exit(1)
    else:
        print 'AT_ERROR : U_POSTFILE_CSV not define'
        exit(1)
        
    if rdcli_csv:
        if not os.path.isfile(rdcli_csv):
            print 'AT_ERROR : ' + str(rdcli_csv) + ' not exist!\n'
            exit(1)
    else:
        print 'AT_ERROR : U_RDCLI_CSV not define'
        exit(1)
        
    dut_type = sys.argv[1]
    post_file = sys.argv[2]

#    if not os.path.exists(post_file):
#        print '\nAT_ERROR : ','postfile file is not exist :',post_file
#        return False
    post_file=os.path.basename(post_file)
    #post_file=str(post_file).replace(dut_type, '\*')
    print 'post_file : '+post_file
    mc = WECB_CLI()
    mc.classify(post_file)

#    usage += "Arguments :\n"
#    usage += "-f/--file              : the rule file , contains all the rules using in tr test \n"
#    usage += "-r/--rule              : the rule currently to be search from the rule file \n"
#    usage += "-d/--debug             : the debug level \n"
#    usage += "-o/--output            : the output log file \n"
#    usage += "-v/--variable=value    : the replace rule\n"
#    
#    parser = OptionParser(usage=usage)
#    parser.add_option("-f", "--file", dest="postfile", help="the file that contains all the rules")
#    parser.add_option("-o", "--output", dest="log_path", help="the out put file path")
#    parser.add_option("-d", "--index", dest="debug_level", help="the debug level")
#    parser.add_option("-v", "--newvalue", dest="new_value", help="the replace rule")
#
#    (options, args) = parser.parse_args()
#    
#    if os.path.isfile(options.postfile):
#        post_file = os.path.basename(str(options.postfile))
#        
#
#        print 'current postfile : ' + post_file
#
#        print '\n'
#    else:
#        print 'AT_ERROR : ' + str(options.postfile) + ' not exist!\n'
#        print usage
#        exit(1)
#    
    
#    
main()
