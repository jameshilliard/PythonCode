The Master Test Plan Automation contains TCL configuration files for the tests that
are specified in Veriwave's Master Test Plan. The TCL configuration files in this 
product work with Veriwave's WaveAutomation software to automate the very large and
complex Master Test Plan.

The user should be familar with the use and configuration of the WaveAutomation 
product. 


Installation and Setup:
------------------------
1) unzip MasterTestPlan.zip in any folder. 

2) Edit the masterplan.bat(Win32) or masterplan.sh(Linux) file to include the complete
   path of "vw_auto.tcl" file.
   (vw_auto.tcl file is a part of WaveAutomation software and defaulted to
   "~/automation/automation/bin" location.)
   
3) Edit global_configs.tcl.
   This file contains configuration information that is common to all tests such
   as the Veriwave chassis name/ip address and test trial duration. Refer to the
   file for details.
   
4) Edit client_setup.tcl.
   This file contains configuraion information for the clients that will be used
   throughout the Master Test Plan test. Specifically, you will need to set 
   parameters like ssid, channel, IP addressing, and DUT configuration name. 

5) Create your dut configuration module. 
   A sample configuration module is included as hardware.tcl. Edit this file
   to match the specifics of your hardware setup. 
   NOTE: In order for the complete Master Test Plan to execute the DUT must be
   configurable under WaveAutomation. Otherwise the user must change the configuration
   options of the various tests so that they match the capabilities of a statically
   configured DUT/AP. 

Usage examples:
------------------------
python masterplan.py --help
python masterplan.py --testNames mastertestplan
python masterplan.py --testNames securitydhcp
python masterplan.py --testNames tcpgoodput association 
python masterplan.py --testNames ATC001
python masterplan.py --testNames "ATC001 ATC002 ATC005"
python masterplan.py --testNames PBTC001_1 --debug 5 
python masterplan.py --testNames PBTC020 --debug 3 --nodut
python masterplan.py --testNames PBTC022 --nodut --nopause


Note:
1) The argument "--testNames" is required.
   It specifies the name of the test or tests to run.

2) ATC001, PBTC001_1 are the names of the tests as defined in the Master Test 
   Plan document. These names are the same as the name of the individual 
   configuration scripts. Other names like "tcpgoodput" refer to sections of the
   Master Test Plan. 
   
3) By default, when using for the first time, the software assumes that it is connected to the cisco-1020 series controller 
   based AP and tries to configure it.
   If the end user is using any other AP then he needs to specify this information in the global_configs.tcl file under cfg_load_module
   header.
   cfg_load_module looks for 'tcl' file with cisco-1020 AP configuration in the /automation/automation/conf/dut/ directory.  

4) Please modify the AP configuration file ex:cisco-1020.tcl file (~/automation/automation/conf/dut/) to include mac address, ip address of the AP, ip address, slot number of the chassis
   to be used in the test.




