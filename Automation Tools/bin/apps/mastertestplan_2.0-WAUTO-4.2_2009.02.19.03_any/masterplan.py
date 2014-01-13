#!/usr/bin/python
import sys
import os
import commands
from optparse import OptionParser 
import glob
import string
import time
import subprocess


#Set Environmental variable "VW_MTP_HOME" to install directory of the MasterTestPlan
# By default this file exists at the top of that directory. 
current_dir = os.getcwd()
os.environ['VW_MTP_HOME'] = current_dir
print "VW_MTP_HOME = " + os.environ['VW_MTP_HOME']

#Delete temporary file 'testlist' which is generated during script execution.
if os.path.exists("testlist"):
	commands.getstatusoutput('rm testlist')



#test_types is a dictionary containing test types like tcpgoodput, throughput, packetloss, securitydhcp as keys and the actual scripts like pbtc027_1,pbtc027_2
#as arguments. example: {'tcpgoodput':['pbtc027','pbtc028','pbtc029','pbtc30']

test_types = {}
dummy_list = []
store_data = {}

#getTCLFiles is a function that searches through all the master test plan folder and searches for files with 'TCL' extension
#It returns a dictionary named store_data in {file_name:complete_path} format example: {ATC001:'/root/automation/mastertestplan/functionalverification/association/ATC001.tcl'}
def getTCLFiles(dummy, dirname, filesindir):
        (m, n) = os.path.split(dirname)
        files_without_extension = []
        for indexx in filesindir :
                (k, j) = os.path.splitext(indexx)
                files_without_extension.append(k)
        test_types[n] = files_without_extension

        for fname in glob.glob(dirname + '/*.[Tt][Cc][Ll]'):
                (a, b) = os.path.split(fname)
                (x, y) = os.path.splitext(b)
                store_data[x] = fname
                

os.path.walk(os.environ['VW_MTP_HOME'] ,getTCLFiles, None)

#OPTIONPARSER

usage = "usage: python <script.py> --testNames <list of tests to run> <options .. >"
parser = OptionParser(usage)
parser.add_option("--pf", action="store_true", dest="pf_status", default=False, help="--pf : Use pass/fail criteria in test.")
parser.add_option("--nopause", action="store_true", dest="pause_status", default=False, help="--nopause : do not pause (for 15sec default) after configuring AP")
parser.add_option("--nodut", action="store_true", dest="nodut", default=False, help="--nodut: Do not change remote dut configuration automatically")
parser.add_option("--savepcaps", action="store_true", dest="pcaps", default=False, help="--savepcaps: Turn on packet capture option for tests.")
parser.add_option("--debug", action="store", dest="debug", type="int", default=0, help="--debug <level> :Specify debug level 1-99")
parser.add_option("--testid", action="store", dest="testid", type="string", default="", help="--testid <test identifier string> :For uniquely identifying this test run.")
parser.add_option("--testNames", action="append", dest="testNames", help="Select Test Names eg.'ATC005 PBTC001' or packetloss or mastertestplan")
parser.add_option("--vw_autoPath", action="store", dest="vw_autoPath", help="Please specify the complete path of vw_auto.tcl file from /automation/automation/bin/")
parser.add_option("--db", action="store_true", dest="DbSupport", default=False, help="--db : TRUE/FALSE database support enable/disable by default disabled")
(options, args) = parser.parse_args()
DbSupport = options.DbSupport
testString = options.testNames
TestNames = str(testString).strip('[\' \']')
TestNames1 = TestNames.split()
del options.testNames[0]
options.testNames = eval(str(TestNames1))

    
#testNames[] IS THE LIST THAT CONTAINS ALL THE TESTNAMES THAT ARE SELECTED AT COMMANDLINE.
#VALID COMMAND LINE OPTIONS ARE ANY COMBINATION OF INDIVISUAL TESTNAMES(eg. BTC005 PBTC001) AND GROUP-NAMES(eg.THROUGHPUT LATENCY) OR' MASTERTESTPLAN'

if 'mastertestplan' in options.testNames:
	print "Entire Master Test Plan Selected"
	master_test_plan = ['association', 'basicforwarding', 'securitydhcp', 'clientcallcapacity', 'ratevsrange', 'throughput', 'latency', 'packetloss', 'maxforwardingrate', 'roaming', 'tcpgoodput', 'qos','wimix','11nthroughput','11nbasic']
	for a in master_test_plan:
		options.testNames.insert(options.testNames.index('mastertestplan'), a)
	del options.testNames[options.testNames.index('mastertestplan')]
	print options.testNames
if 'association' in options.testNames:
	print "association selected"
	association_array = test_types['Association']
	for a in association_array:
		options.testNames.insert(options.testNames.index('association'), a)
	del options.testNames[options.testNames.index('association')]
	print options.testNames
if 'basicforwarding' in options.testNames:
	print "basicforwarding selected"
	basicforwarding_array = test_types['BasicForwarding']
	for a in basicforwarding_array:
		options.testNames.insert(options.testNames.index('basicforwarding'), a)
	del options.testNames[options.testNames.index('basicforwarding')]
	print options.testNames
if 'securitydhcp' in options.testNames:
	print "securitydhcp selected"
	securitydhcp_array = test_types['SecurityDHCP']
	for a in securitydhcp_array:
		options.testNames.insert(options.testNames.index('securitydhcp'), a)
	del options.testNames[options.testNames.index('securitydhcp')]
	print options.testNames
if 'clientcallcapacity' in options.testNames:
	print "clientcallcapacity selected"
	clientcallcapacity_array = test_types['ClientCallCapacity']
	for a in clientcallcapacity_array:
		options.testNames.insert(options.testNames.index('clientcallcapacity'), a)
	del options.testNames[options.testNames.index('clientcallcapacity')]
	print options.testNames
if 'ratevsrange' in options.testNames:
	print "ratevsrange selected"
	ratevsrange_array = test_types['RateVsRange']
	for a in ratevsrange_array:
		options.testNames.insert(options.testNames.index('ratevsrange'), a)
	del options.testNames[options.testNames.index('ratevsrange')]
	print options.testNames
if 'latency' in options.testNames:
	print "latency selected"
	latency_array = test_types['Latency']
	for a in latency_array:
		options.testNames.insert(options.testNames.index('latency'), a)
	del options.testNames[options.testNames.index('latency')]
	print options.testNames
if 'maxforwardingrate' in options.testNames:
	print "maxforwardingrate selected"
	maxforwardingrate_array = test_types['MaximumForwardingRate'] 
	for a in maxforwardingrate_array:
		options.testNames.insert(options.testNames.index('maxforwardingrate'), a)
	del options.testNames[options.testNames.index('maxforwardingrate')]
	print options.testNames
if 'packetloss' in options.testNames:
	print "packetloss selected"
	packetloss_array = test_types['PacketLoss']
	for a in packetloss_array:
		options.testNames.insert(options.testNames.index('packetloss'), a)
	del options.testNames[options.testNames.index('packetloss')]
	print options.testNames
if 'roaming' in options.testNames:
	print "roaming selected"
	roaming_array = test_types['Roaming']
	for a in roaming_array:
		options.testNames.insert(options.testNames.index('roaming'), a)
	del options.testNames[options.testNames.index('roaming')]
	print options.testNames
if 'tcpgoodput' in options.testNames:
	print "tcpgoodput selected"
	tcpgoodput_array = test_types['TCPGoodput']
	for a in tcpgoodput_array:
		options.testNames.insert(options.testNames.index('tcpgoodput'), a)
	del options.testNames[options.testNames.index('tcpgoodput')]
	print options.testNames
if 'throughput' in options.testNames:
	print "throughput selected"
	throughput_array = test_types['Throughput']
	for a in throughput_array:
		options.testNames.insert(options.testNames.index('throughput'), a)
	del options.testNames[options.testNames.index('throughput')]
	print options.testNames
if 'qos' in options.testNames:
	print "qos selected"
	qos_array = test_types['QoS']
	for a in qos_array:
		options.testNames.insert(options.testNames.index('qos'), a)
	del options.testNames[options.testNames.index('qos')]
	print options.testNames
if 'wimix' in options.testNames:
	print "wimix selected"
	wimix_array = test_types['WiMix']
	for a in wimix_array:
		options.testNames.insert(options.testNames.index('wimix'), a)
	del options.testNames[options.testNames.index('wimix')]
	print options.testNames
if '11nthroughput' in options.testNames:
    nthroughput_array = test_types['11nThroughput']
    for a in nthroughput_array:
        options.testNames.insert(options.testNames.index('11nthroughput'), a)
    del options.testNames[options.testNames.index('11nthroughput')]
    print options.testNames
if '11nbasic' in options.testNames:
    nbasic_array = test_types['11nBasic']
    for a in nbasic_array:
        options.testNames.insert(options.testNames.index('11nbasic'), a)
    del options.testNames[options.testNames.index('11nbasic')]
    print options.testNames




#REMOVE THE FILES THAT ARE HIGHER LEVEL GENERAL CONFIGURATION FILES LIKE CLIENT_SETUP.TCL AND GLOBAL_CONFIGS.TCL
#THESE FILES ARE NOT TO BE EXECUTED WITH VW_AUTO.TCL.
if store_data.has_key('client_setup'):
	del store_data['client_setup']
if store_data.has_key('global_configs'):
	del store_data['global_configs']
if store_data.has_key('association_setup'):
	del store_data['association_setup']
if store_data.has_key('basic_forwarding'):
	del store_data['basic_forwarding']
if store_data.has_key('max_VoIPCall_capacity'):
	del store_data['max_VoIPCall_capacity']
if store_data.has_key('max_client_capacity'):
	del store_data['max_client_capacity']
if store_data.has_key('Security'):
	del store_data['Security']
if store_data.has_key('rate_vs_range'):
	del store_data['rate_vs_range']
if store_data.has_key('latency'):
	del store_data['latency']
if store_data.has_key('max_forwarding_rate'):
	del store_data['max_forwarding_rate']
if store_data.has_key('packetloss'):
	del store_data['packetloss']
if store_data.has_key('VoIPRoaming'):
	del store_data['VoIPRoaming']
if store_data.has_key('Roaming'):
	del store_data['Roaming']
if store_data.has_key('tcp_goodput'):
	del store_data['tcp_goodput']
if store_data.has_key('Throughput'):
	del store_data['Throughput']
if store_data.has_key('VoIPSLA'):
	del store_data['VoIPSLA']
if store_data.has_key('wimix'):
	del store_data['wimix']
if store_data.has_key('11nthroughput'):
	del store_data['throughput']
if store_data.has_key('11nbasic'):
        del store_data['11nbasic']
try :
	fileptr2 = open('testlist','w')

except IOError:
	pass

#COMPARE (USER INPUT) 'options.testNames[]' WITH ALREADY EXISTING FILENAMES IN 'store_data{}' TO FORM A QUERY FOR vw_auto.tcl

def getCommandlineOptions(recv_list):
	recv_list = recv_list + ' ' + '--debug' + ' ' + str(options.debug)
	if options.pf_status == True:
		recv_list = recv_list + ' ' +  '--pf'
	if options.pause_status == True:
		recv_list = recv_list + ' ' +  '--nopause'
	if options.nodut == True:
		recv_list = recv_list + ' ' + '--nodut'
	if options.pcaps == True:
		recv_list = recv_list + ' ' + '--savepcaps'
	if options.testid != "":
	  recv_list = recv_list + ' ' + '--tid' + ' ' + options.testid
	return recv_list
	

for a in options.testNames:
	if store_data.has_key(a):
		print "KEY FOUND!!!-->",a
		commandline_to_vwauto = getCommandlineOptions(store_data[a])
		fileptr2.write(commandline_to_vwauto + '\n')
	else:
		print "Bad TestName input!! or TestScript Doesn't exist in database"

fileptr2.close()


# BJL - attempt to automatically pick 
# Session table updation for database support, the input will be taken indirectlyfrom 
# global_configs.tcl. First the test runs normally with automation build getting all
# inputs from the global_configs.tcl and populates the database details into a file.
# The file is read for the parameters and all data is populated.
 
StartTime= time.localtime(time.time())
SessionStartTime = time.strftime('%Y-%m-%d %H:%M:%S', StartTime)
SessionName = "Session_"+SessionStartTime
SessionDescription = "MTP AUTOMATION RUN"

#RUN TESTSCRIPT_1.SH WHICH RUNS ./VW_AUTO.TCL -f $filename COMMAND.
cwd = os.getcwd()

if os.name == "nt":
    mypath=os.environ['USERPROFILE']
    print mypath
    p = subprocess.popen('masterplan.bat') 
else:
    mypath=os.environ['HOME']
    os.system('source masterscript.sh')
    print "execution of test is over"

EndTime = time.localtime(time.time())
SessionEndTime   = time.strftime('%Y-%m-%d %H:%M:%S', EndTime)
SessionData = "NULL"+", "+"'"+SessionName+"'"+", "+"'"+SessionStartTime+"'"+", "+"'"+SessionEndTime+"'"+", "+"'"+SessionDescription+"'"

myfile=os.path.join(mypath,'dbdatafiledetails')
try:    
   fileptr=open(myfile)
   print "@@@@@@@@@@"
   print myfile
   myline=fileptr.readline()
   fileptr.close()
   mydata=myline.split(",")
   print myline,mydata
   dbfilepath=os.path.join(mydata[-1],'wave_engine')
   os.sys.path.insert(0,dbfilepath)
   if mydata[5]== "True":
       if mydata[0]== 'mysql':
          import vw_dataExport
          ExportDataObj= vw_dataExport.ExportData(mydata[4],mydata[0],mydata[1],mydata[2],mydata[3])
          ExportDataObj.connectToDatabase()
          if not ExportDataObj.checkTableexistence("SessionTable"):
             ExportDataObj.createTable("SessionTable")
          ExportDataObj.insertIntoTableList("SessionTable", SessionData)
          ExportDataObj.disconnectDatabase()
          os.remove(myfile)
       else:
          pass
   else:
       pass
except:
       pass

