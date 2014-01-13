#!/usr/bin/env python
import os,sys
import pexpect
import optparse
import re,time 
import stat
imgExt = {'BAR1KH'  : '.img',
        'BCV1200'   : '.img',
        'BHR2'      : '.rmt',
        'CAH001'    : '.img',
        'CTLC2KA'   : '.img',
        'FT'        : '.bin',
        'TDSV2200H' : '.img',
        'PK5K1A'    : '.img',
        'TV2KH'     : '.img',
        'CTLC1KA'   : '.img',
        'TV1KH'     : '.img'}

def Get_Management_network_gateway():

    lanManagementIP = os.getenv('G_HOST_IP0')
    lanManagementInterface = os.getenv('G_HOST_IF0_0_0','eth0')
    if lanManagementIP is None:
        ifconfigResult,ifconfigStatus = pexpect.run('ifconfig eth0',withexitstatus=True,timeout=15,logfile=sys.stdout)
        if ifconfigStatus:
            print 'AT_ERROR : Check %s information failed,please check it.'%lanManagementInterface
            return False
        else:
            #192.168.100.102
            m = '(inet addr:)((\d{1,3}\.?){4})'
            rc = re.search(m,ifconfigResult)
            if rc is not None:
                lanManagementInterface = rc.group(2)
    ipList = lanManagementInterface.split('.')
    ipList.pop()
    ipList.append('254')
    _gateway =  ipList[0] + '.' + ipList[1] + '.' + ipList[2] + '.' + ipList[3] 
    return _gateway     

def Add_route_for_ftp(ftp_hostname):
    
    cmd = 'ping ' + ftp_hostname + ' -c 4'
    child = pexpect.spawn(cmd)
    child.logfile_read = sys.stdout
    exp = 'PING sengftp.actiontec.com .*'
    index = child.expect([exp,pexpect.EOF,pexpect.TIMEOUT])
    print child.before
    m = '(\d{1,3}\.?){4}'
    ip_check = re.search(m,child.after)
    print '=====>' + child.after
    if ip_check is not None:
        ftp_ip = ip_check.group()
        _gateway = Get_Management_network_gateway()
        print 'So the gateway is <%s>'%_gateway
        if _gateway:
            print 'So the ftp address is <%s> and gateway sould be <%s>'%(ftp_ip,_gateway)
            cmd = 'route add -host %s gw %s'%(ftp_ip,_gateway)
    else:
        print 'AT_ERROR : have not get %s ipaddress,please check your DNS settings.'
        return False
  
def Wget_FTP_Files(FileAdd,localFileName,user='hcheng',passwd='hcheng',isDebug=False,*args,**keys):
    """
    This function is auto-download the firmware imag files from the ftp your specified.
    """
    
    if isDebug :
        FileAdd = 'ftp://sengftp.actiontec.com/Release/broadcom/VDSL6368/120618-31.122L.02-31.121L.02-TELUS/bcm.fs.kernel.120618-31.122L.02-31.121L.02-TELUS.img'
        localdir= '/root/automation/firmware'
        dutType = 'TV2KH'
        DUT_version = '31.122L.02'
        ftpDict = {'sengftp.actiontec.com':{'user':'hcheng','passwd':'hcheng'},
                   '172.16.10.241':{'user':'actiontec','passwd':'actiontec'}}
    for ftpadd in FileAdd:
    #FileAdd must only one elemet list
#        cmd = 'wget "' + ftpadd + '" --ftp-user=' + user + ' --ftp-password=' + passwd + ' -c -t 3 -w 30  -o '
        cmd = 'wget "%s" --ftp-user="%s" --ftp-password="%s"  -c -t 3 -w 30  -O "%s"'%(ftpadd,user,passwd,localFileName)
    print 'So the wget cmd is ====>:%s<===='%cmd
    firmwareDict = {'GA':os.getenv('U_CUSTOM_PREVIOUS_GA_FW_VER'),
    'CUR':os.getenv('U_CUSTOM_CURRENT_FW_VER'),
    'Test':os.getenv('U_CUSTOM_CURRENT_FW_TEST_VER')}
    for i in FileAdd :
        timeStart = time.time()
        wgetResult,wgetstatus = pexpect.run(cmd,withexitstatus=True,timeout=1200,logfile=sys.stdout)
        timeEnd = time.time()
        timeSpend = timeEnd - timeStart
        timeH,timeS = divmod(timeSpend,60)
        print 'The file get used %dm and %ds result : %s'%(int(timeH),int(round(timeS)),wgetstatus)
        if not wgetstatus:
            #print os.path.getsize(localFileName)
            os.chmod(localFileName,stat.S_IRWXO|stat.S_IRWXG|stat.S_IRWXU)
            return True
        else:
            return False

def Check_Download_File(FileAdd,user,passwd,localFile):
    
    """
    This function is used to check the local image file with it's info in the remote ftp 
    """
    
    for i in FileAdd: 
        #'172.16.10.252/release/broadcom/VDSL6368/120618-31.122L.02-31.121L.02-TELUS/bcm.fs.kernel.120618-31.122L.02-31.121L.02-TELUS.img'
        print 'The ftp address is : <%s>'%i
        m = '[^/]*\.com|(\d{1,3}\.?){4}' 
        rc = re.search(m,i)
        if rc is not None:
            ftpAdd = rc.group()
            print 'So the ftp address ====><%s>'%ftpAdd
        else:
            print 'Unknown ftp address,please check <%s>.'%i
        file_path = i.split(ftpAdd)[-1]
        #print 'So the ftp file path is <%s>'%file_path
        file_name = os.path.basename(file_path)
        cmd = 'ftp "%s"'%ftpAdd
        child = pexpect.spawn(cmd)
        child.logfile_read = sys.stdout
        index = child.expect(['(?i)Name',"(?i)Unknown host",pexpect.EOF,pexpect.TIMEOUT])
        if index == 0:
            child.sendline(user)
            index = child.expect(['(?i)Password',pexpect.EOF,pexpect.TIMEOUT])
            if index != 0:
                print "ftp login failed."
                child.close(force=True)
            child.sendline(passwd)
            index = child.expect(['ftp>','Login incorrect','Service not available',pexpect.EOF,pexpect.TIMEOUT])
            if index == 0:
                #child.sendline("bin")
                child.sendline('ls "%s"'%file_path)
                index = child.expect(['.*Transfer complete.*ftp>','226 Directory send OK.*ftp>',pexpect.EOF,pexpect.TIMEOUT])
                print 'Index is ====> <%d>'%index
                if index not in [0,1] :
                    print "Failed to get the file infomation."
                    child.close(force=True)
                else:
                    print 'Successfully got the file infomation'
                    child.sendline('bye')
            elif index == 1 :
                print "You entered an invalid login name or passwprd.Program quits."
                child.close(force=True)
            else:
                print "AT_ERROR : ftp login failed! index is : <%d>"%index
                child.close(force=True)
        elif index == 1 :
            print "AT_ERROR : ftp login failed ,dut to unknown host."
            child.close(force=True)
        else:
            print "AT_ERROR : ftp login failed,dut to TIMEOUT or EOF."
            child.close(force=True)
        check_result_ = child.before
        print 'Child before ====><%s>'%child.before
        print 'Child after ====><%s>'%child.after
        m_ = '.* ' + file_name
        file_info = re.search(m_,check_result_)
        if file_info is not None:
            #-rw-rw-rw-   1 user     group    12516094 Jun 18  2012 bcm.fs.kernel.120618-31.122L.02-31.121L.02-TELUS.img
            remoteFileSize = file_info.group().split()[4]
            isExist = os.path.exists(localFile)    
            if isExist:
                os.chmod(localFile,stat.S_IRWXO|stat.S_IRWXG|stat.S_IRWXU)
                localFileSize = os.path.getsize(localFile)
                if int(localFileSize) != int(remoteFileSize): 
                    print 'The local file is different with the file that in the ftp,will remove it and download again.'
                    os.remove(localFile)
                    return False
                else:
                    print 'The image file is already exist correctly in the local dir.'
                    return True
            else:
                print 'AT_ERROR : the local file doesn\'t exist,so will try to download it from the ftp server.'
                return False
        else:
            print 'There are maybe some thing wrong,process have not get the remote file size.'
            print 'Will try to download it from the ftp server.'
            return False

def main():
    """
    Entry if not imported
    """
        
    usage = "usage: %prog [options]"

    option = optparse.OptionParser(usage=usage)

    option.add_option("-v", "--version", dest="version",action='append',
                            help="The DUT current version you want to check!")
    option.add_option("-d","--ftp_address",dest="ftp_address",
                            help="Specify ftp address.")
    option.add_option("-D", "--Debug", dest="is_Debug", action='store_true', default=False,
                            help="whether it is in debug mode.")
    option.add_option("-u", "--ftp_username", dest="ftp_user", default="leon",
                            help="Specify download ftp username.")
    option.add_option("-p", "--ftp_password", dest="ftp_passwd", default="123qaz",
                            help="Specify donwload ftp loggin password.")
    option.add_option("-t","--dut_type",dest="dut_type",
                            help="Specify current dut type.")
    option.add_option("-a", "--all_file", dest="isDownloadAll",action='store_true',default=False,
                            help="Download the GA,current and test image from ftp.")
    
    (opts, args) = option.parse_args()

    downloadVer = []
    m_downloadVer = [] 
    if not len(args) == 0:
        print args
    if opts.version:
        Check_version = opts.version
    if opts.is_Debug:
        p_dict = {'U_CUSTOM_PREVIOUS_GA_FW_VER':'TV2KH-31.122L.02',
                 'U_CUSTOM_PREVIOUS_GA_FW_VER_PATH':'ftp://sengftp.actiontec.com/Release/broadcom/VDSL6368/120618-31.122L.02-31.121L.02-TELUS/bcm.fs.kernel.120618-31.122L.02-31.121L.02-TELUS.img',
                 'U_DUT_TYPE':'TV2KH',
                 'U_CUSTOM_CURRENT_FW_VER':'TV2KH-31.122L.10a',
                 'U_CUSTOM_CURRENT_FW_VER_PATH':'172.16.10.252/HD2/Broadband/Telus_V2000H/Firmware_Release/130226-31.122L.10a-31.121L.10a-TELUS/bcm.fs.kernel.130226-31.122L.10a-31.121L.10a-TELUS.img',
                 'U_CUSTOM_CURRENT_FW_TEST_VER':'TV2KH-31.122L.11test',
                 'U_CUSTOM_CURRENT_FW_TEST_VER_PATH':'ftp://sengftp.actiontec.com/Release/broadcom/VDSL6368/130301-31.122L.11test-31.121L.11test-TELUS/bcm.fs.kernel.130301-31.122L.11test-31.121L.11test-TELUS.img'}
        os.environ.update(p_dict)
        
    dutType = os.getenv('U_DUT_TYPE')
    if dutType is None:
        dutType = opts.dut_type
    if not dutType:
        print 'AT_ERROR : Unknow DUT type,please check the parameter U_DUT_TYPE!'
    if opts.isDownloadAll:
        m_downloadVer = ['U_CUSTOM_PREVIOUS_GA_FW_VER','U_CUSTOM_CURRENT_FW_VER','U_CUSTOM_CURRENT_FW_TEST_VER']
    else:
        if opts.version is None :
            m_downloadVer = ['U_CUSTOM_CURRENT_FW_VER']
        else:
            #downloadVer = ['GA','Current','Test']
            downloadVer = [i for i in opts.version ]
            for ver in downloadVer:
                ver = ver.lower()
                if ver == 'ga':
                    m_downloadVer.append('U_CUSTOM_PREVIOUS_GA_FW_VER')
                elif ver == 'test':
                    m_downloadVer.append('U_CUSTOM_CURRENT_FW_TEST_VER')
                elif ver == 'current':
                    m_downloadVer.append('U_CUSTOM_CURRENT_FW_VER')
                else:
                     print 'AT_WARNING : <%s> is unknow parameter,will use default value to replace it.'%ver
        if 'U_CUSTOM_CURRENT_FW_VER' not in m_downloadVer:
            m_downloadVer += ['U_CUSTOM_CURRENT_FW_VER']    
    print 'So will download imag files as : %s '%(m_downloadVer)
                    
    for m_ver in m_downloadVer:
        user = os.getenv('U_CUSTOM_FIRMWARE_FTP_USER',opts.ftp_user).strip()
        passwd = os.getenv('U_CUSTOM_FIRMWARE_FTP_PASSWD',opts.ftp_passwd).strip()
        print 'FTP user is ==><%s:<%s>'%(type(user),user)
        print 'FTP password is ==>%s:<%s>'%(type(passwd),passwd)
        if not user:
            user = 'leon'
        if not passwd :
            passwd = '123qaz'

        localFileDir = os.getenv('U_CUSTOM_FW_DIR','/root/automation/firmware')        
        #localFileName = dutType + '-' + os.getenv(m_ver) + imgExt[dutType]
        localFileName = dutType + '-' + os.getenv(m_ver) + imgExt.get(dutType,'.img')
        localFile = os.path.join(localFileDir,localFileName)
        print 'So the local file is :<%s>'%localFile
        
        fileAdd = [os.getenv(m_ver+'_PATH')]
        print 'So the ftp address is : <%s>'%fileAdd
        DUT_image_file_check = Check_Download_File(fileAdd,user,passwd,localFile)
        print 'Retry...%s'%DUT_image_file_check
        if not DUT_image_file_check:        
            rc  = Wget_FTP_Files(FileAdd=fileAdd,localFileName=localFile,user=user,passwd=passwd)
            print 'rc====>%s'%rc
            if not rc :
                DUT_image_file_check_retry = Check_Download_File(fileAdd,user,passwd,localFile)
                print 'DUT_image_file_check_retry====>%s'%DUT_image_file_check_retry
                if not DUT_image_file_check_retry:
                    sys.exit(1)
                else:
                    sys.exit(0)
if __name__ == '__main__':
    exit(0)
    main()

