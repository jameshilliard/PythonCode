# == NAME
# launch_test.rb
#
# == SYNOPSIS
# Launches the TR-069 test suite.
#
# == OPTIONS
# launch_test [OPTION]
#
# -i filename (--initialization-file):
#    use the initialization file filename
#
# -t filename (--test-cases-file):
#    use the test cases file filename
#
# -d dLevel (--debug-level):
#    set debug level to dLevel. Acceptable levels are (from low to high):
#	-debug
#	-info
#	-warning
#	-error
#	-fatal
#
# -h (--help):
#    show this help information

=begin
Filename: launch_tests.rb
Description: Main entry of the test suite for TR-069 testing
Author: Kurt Liu
Date: 03/20/09
=end

require 'rubygems'
require 'win32ole.so' # Required to run in Cygwin
require 'motive'
# require 'firewatir'
require "rexml/document"
require 'getoptlong'
require 'rdoc/usage'
require 'timer'
require 'automation_debug'
# include FireWatir

# TODO:
# * Add debug level flags and set appropriate debug output
# * Add RDoc documentations

# Method: executeTestCase
# Processes the test case based on the test type and parameter name
def executeTestCase (test_case)
	# Extract the test case data
	case_id = test_case.elements["id"].text
	case_keyword = test_case.elements["keyword"].text
	case_description = test_case.elements["description"].text	
	case_test_type = test_case.elements["test_type"].text
	case_parameter_name = test_case.elements["parameter_name"].text
	
	# Filter based on the type of test
	case case_test_type
		when "get parameter value"
			testGenericRead(test_case)
			# Filter based on the parameter name
			#case case_parameter_name
			#	when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.SSID"
				#	testSSIDRead(test_case)
			#	else
				# Assume the test case is okay and start reading
				# Perhaps a function that checks whether the parameter name
				#   is part of a list of accepted parameters is needed
				# For now, call testGenericRead for all parameter names
			#		testGenericRead(test_case)
			#end
		when "set parameter value"
			case case_parameter_name
				# Here I am hard coding the values to set based on the paramter name,
				#   which is not ideal at all
				# The values I hard coded here are either based on the current 
				#   values set on my BHR, or some random value. I am not sure 
				#   if they are valid.
				when "InternetGatewayDevice.DeviceInfo.ProvisioningCode"
					testGenericWrite(test_case, "string", "TLCO.GRP2")
				when "InternetGatewayDevice.DeviceConfig.PersistentData"
					testGenericWrite(test_case, "string", "This is the arbitrary user data that MUST persist across CPE reboots.")
				when "InternetGatewayDevice.ManagementServer.URL"
					testGenericWrite(test_case, "string", "https://xatechdm.xdev.motive.com/cwmpWeb/CPEMgt")
				when "InternetGatewayDevice.ManagementServer.Username"
					testGenericWrite(test_case, "string", $bhr_serial)
				when "InternetGatewayDevice.ManagementServer.Password"
					testGenericWrite(test_case, "string", "actiontec")
				when "InternetGatewayDevice.ManagementServer.PeriodicInformEnable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.ManagementServer.PeriodicInformInterval"
					testGenericWrite(test_case, "unsignedInt", "300")
				when "InternetGatewayDevice.ManagementServer.PeriodicInformTime"
					testGenericWrite(test_case, "dateTime", "2009-03-11T17:18:09.000Z")
				when "InternetGatewayDevice.ManagementServer.ConnectionRequestUsername"
					testGenericWrite(test_case, "string", $bhr_serial)
				when "InternetGatewayDevice.ManagementServer.ConnectionRequestPassword"
					testGenericWrite(test_case, "string", "actiontec")
				when "InternetGatewayDevice.ManagementServer.UpgradesManaged"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.Time.NTPServer1"
					testGenericWrite(test_case, "string", "0.pool.ntp.org")
				when "InternetGatewayDevice.Time.NTPServer2"
					testGenericWrite(test_case, "string", "1.pool.ntp.org")
				when "InternetGatewayDevice.Time.NTPServer1"
					testGenericWrite(test_case, "string", "2.pool.ntp.org")
				when "InternetGatewayDevice.Time.LocalTimeZone"
					testGenericWrite(test_case, "string", "-08:00")
				when "InternetGatewayDevice.Time.LocalTimeZoneName"
					testGenericWrite(test_case, "string", "Pacific_Time")
				when "InternetGatewayDevice.Time.DaylightSavingsUsed"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.Time.DaylightSavingsStart"
					testGenericWrite(test_case, "dateTime", "2009-03-11T08:00:09.000Z")
				when "InternetGatewayDevice.Time.DaylightSavingsEnd"
					testGenericWrite(test_case, "dateTime", "2009-11-11T09:00:09.000Z")
				when "InternetGatewayDevice.UserInterface.PasswordRequired"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.Layer3Forwarding.DefaultConnectionService"
					testGenericWrite(test_case, "string", "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3")
				# You can't seem to set values for these parameters under
				# 	InternetGatewayDevice.Layer3Forwarding.Forwarding.1.
				# 	InternetGatewayDevice.Layer3Forwarding.Forwarding.2.
				# It will result in Motive returning query error and cause test case to fail.
				# You have to add an object in order to test SPV on these parameters.
				#	However, the program does not automate "Add Object" function right now.
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.Enable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.Type"
					testGenericWrite(test_case, "string", "Network")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.DestIPAddress"
					testGenericWrite(test_case, "string", "192.168.1.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.DestSubnetMask"
					testGenericWrite(test_case, "string", "255.255.255.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.SourceIPAddress"
					testGenericWrite(test_case, "string", "0.0.0.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.SourceSubnetMask"
					testGenericWrite(test_case, "string", "0.0.0.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.GatewayIPAddress"
					testGenericWrite(test_case, "string", "0.0.0.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.Interface"
					testGenericWrite(test_case, "string", "InternetGatewayDevice.LANDevice.1.")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.ForwardingMetric"
					testGenericWrite(test_case, "int", "4")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.1.MTU"
					testGenericWrite(test_case, "unsignedInt", "1500")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.Enable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.Type"
					testGenericWrite(test_case, "string", "Network")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.DestIPAddress"
					testGenericWrite(test_case, "string", "10.1.10.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.DestSubnetMask"
					testGenericWrite(test_case, "string", "255.255.255.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.SourceIPAddress"
					testGenericWrite(test_case, "string", "0.0.0.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.SourceSubnetMask"
					testGenericWrite(test_case, "string", "0.0.0.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.GatewayIPAddress"
					testGenericWrite(test_case, "string", "0.0.0.0")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.Interface"
					testGenericWrite(test_case, "string", "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.ForwardingMetric"
					testGenericWrite(test_case, "int", "3")
				when "InternetGatewayDevice.Layer3Forwarding.Forwarding.2.MTU"
					testGenericWrite(test_case, "unsignedInt", "1500")
				when "InternetGatewayDevice.LANConfigSecurity.ConfigPassword"
					testGenericWrite(test_case, "string", $bhr_password)
				when "InternetGatewayDevice.IPPingDiagnostics.DiagnosticsState"
					testGenericWrite(test_case, "string", "Requested")
				when "InternetGatewayDevice.IPPingDiagnostics.Interface"
					testGenericWrite(test_case, "string", "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.IPInterface.1")
				when "InternetGatewayDevice.IPPingDiagnostics.Host"
					testGenericWrite(test_case, "string", "127.1.1.1")
				when "InternetGatewayDevice.IPPingDiagnostics.NumberOfRepetitions"
					testGenericWrite(test_case, "unsignedInt", "1")
				when "InternetGatewayDevice.IPPingDiagnostics.Timeout"
					testGenericWrite(test_case, "unsignedInt", "100")
				when "InternetGatewayDevice.IPPingDiagnostics.DataBlockSize"
					testGenericWrite(test_case, "unsignedInt", "1")
				when "InternetGatewayDevice.IPPingDiagnostics.DSCP"
					testGenericWrite(test_case, "unsignedInt", "0")					
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.DHCPServerConfigurable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.DHCPServerEnable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.DHCPRelay"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.MinAddress"
					testGenericWrite(test_case, "string", "192.168.1.2")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.MaxAddress"
					testGenericWrite(test_case, "string", "192.168.1.254")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.ReservedAddresses"
					testGenericWrite(test_case, "string", "192.168.1.222")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.SubnetMask"
					testGenericWrite(test_case, "string", "255.255.255.0")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.DNSServers"
					testGenericWrite(test_case, "string", "192.168.1.1")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.DomainName"
					testGenericWrite(test_case, "string", "home")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.IPRouters"
					testGenericWrite(test_case, "string", "192.168.1.1")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.DHCPLeaseTime"
					testGenericWrite(test_case, "int", "86400")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.UseAllocatedWAN"
					testGenericWrite(test_case, "string", "Normal")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.PassthroughLease"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.PassthroughMACAddress"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.AllowedMACAddresses"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.IPInterface.1.Enable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.IPInterface.1.IPInterfaceIPAddress"
					testGenericWrite(test_case, "string", "192.168.1.1")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.IPInterface.1.IPInterfaceSubnetMask"
					testGenericWrite(test_case, "string", "255.255.255.0")
				when "InternetGatewayDevice.LANDevice.1.LANHostConfigManagement.IPInterface.1.IPInterfaceAddressingType"
					testGenericWrite(test_case, "string", "Static")
				when "InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2.Enable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2.MACAddressControlEnabled"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2.MaxBitRate"
					testGenericWrite(test_case, "string", "Auto")
				when "InternetGatewayDevice.LANDevice.1.LANEthernetInterfaceConfig.2.DuplexMode"
					testGenericWrite(test_case, "string", "Auto")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.Enable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.MaxBitRate"
					testGenericWrite(test_case, "string", "Auto")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.Channel"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.SSID"
					testGenericWrite(test_case, "string", "Adamo")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.BeaconType"
					testGenericWrite(test_case, "string", "Basic")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.MACAddressControlEnabled"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.WEPKeyIndex"
					testGenericWrite(test_case, "unsignedInt", "1")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.KeyPassphrase"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.BasicEncryptionModes"
					testGenericWrite(test_case, "string", "WEPEncryption")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.BasicAuthenticationMode"
					testGenericWrite(test_case, "string", "None")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.WPAEncryptionModes"
					testGenericWrite(test_case, "string", "TKIPEncryption")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.WPAAuthenticationMode"
					testGenericWrite(test_case, "string", "PSKAuthentication")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.IEEE11iEncryptionModes" # GPV failed
					testGenericWrite(test_case, "string", "TKIPEncryption")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.IEEE11iAuthenticationMode" # GPV failed
					testGenericWrite(test_case, "string", "PSKAuthentication")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.BasicDataTransmitRates"
					testGenericWrite(test_case, "string", "6,9,12,18,24,36,48,54")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.OperationalDataTransmitRates"
					testGenericWrite(test_case, "string", "6,9,12,18,24,36,48,54")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.InsecureOOBAccessEnabled"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.BeaconAdvertisementEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.RadioEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.AutoRateFallBackEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.LocationDescription"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.RegulatoryDomain" # GPV failed
					testGenericWrite(test_case, "string", "US ")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.DeviceOperationMode"
					testGenericWrite(test_case, "string", "InfrastructureAccessPoint")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.DistanceFromRoot"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.PeerBSSID"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.AuthenticationServiceMode"
					testGenericWrite(test_case, "string", "None")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.WEPKey.1.WEPKey"
					testGenericWrite(test_case, "string", "0000000000")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.WEPKey.2.WEPKey"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.WEPKey.3.WEPKey"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.WEPKey.4.WEPKey"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.PreSharedKey.1.PreSharedKey"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.PreSharedKey.1.KeyPassphrase"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.PreSharedKey.1.AssociatedDeviceMACAddress"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.WANDevice.3.WANCommonInterfaceConfig.EnabledForInternet"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.5.WANCommonInterfaceConfig.EnabledForInternet"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.Enable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.MaxBitRate"
					testGenericWrite(test_case, "string", "Auto")
				when "InternetGatewayDevice.WANDevice.3.WANEthernetInterfaceConfig.DuplexMode"
					testGenericWrite(test_case, "string", "Auto")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.Enable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.ConnectionType"
					testGenericWrite(test_case, "string", "IP_Routed")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.Name"
					testGenericWrite(test_case, "string", "Broadband Connection (Ethernet)")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.AutoDisconnectTime"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.IdleDisconnectTime"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.WarnDisconnectDelay"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.NATEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.AddressingType"
					testGenericWrite(test_case, "string", "DHCP")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.ExternalIPAddress"
					testGenericWrite(test_case, "string", "173.8.154.236") # Can only be set if AddressingType is "Static"
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.SubnetMask"
					testGenericWrite(test_case, "string", "255.255.255.0") # Can only be set if AddressingType is "Static"
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.DefaultGateway"
					testGenericWrite(test_case, "string", "173.8.154.238") # Can only be set if AddressingType is "Static"
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.DNSEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.DNSOverrideAllowed"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.DNSServers"
					testGenericWrite(test_case, "string", "68.87.85.98,68.87.69.146")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.MaxMTUSize"
					testGenericWrite(test_case, "unsignedInt", "1500")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.MACAddress"
					testGenericWrite(test_case, "string", "00:1f:90:55:af:2a")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.MACAddressOverride"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.ConnectionTrigger"
					testGenericWrite(test_case, "string", "Manual")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANIPConnection.3.RouteProtocolRx"
					testGenericWrite(test_case, "string", "Off")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.Enable"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.ConnectionType"
					testGenericWrite(test_case, "string", "IP_Routed")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.Name"
					testGenericWrite(test_case, "string", "Broadband Connection (Coax)")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.AutoDisconnectTime"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.IdleDisconnectTime"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.WarnDisconnectDelay"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.NATEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.AddressingType"
					testGenericWrite(test_case, "string", "DHCP")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.ExternalIPAddress"
					testGenericWrite(test_case, "string", "0.0.0.0") # Can only be set if AddressingType is "Static"
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.SubnetMask"
					testGenericWrite(test_case, "string", "0.0.0.0") # Can only be set if AddressingType is "Static"
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.DefaultGateway"
					testGenericWrite(test_case, "string", "0.0.0.0") # Can only be set if AddressingType is "Static"
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.DNSEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.DNSOverrideAllowed"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.DNSServers"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.MaxMTUSize"
					testGenericWrite(test_case, "unsignedInt", "1500")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.MACAddress"
					testGenericWrite(test_case, "string", "00:1f:90:55:af:2b")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.MACAddressOverride"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.ConnectionTrigger"
					testGenericWrite(test_case, "string", "Manual")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANIPConnection.5.RouteProtocolRx"
					testGenericWrite(test_case, "string", "Off")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.Enable"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.ConnectionType"
					testGenericWrite(test_case, "string", "IP_Routed")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.Name"
					testGenericWrite(test_case, "string", "WAN PPPoE")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.AutoDisconnectTime"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.IdleDisconnectTime"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.WarnDisconnectDelay"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.NATEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.Username"
					testGenericWrite(test_case, "string", "verizonfios")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.Password"
					testGenericWrite(test_case, "string", "verizon")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.MaxMRUSize"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.DNSEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.DNSOverrideAllowed"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.DNSServers"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.MACAddress"
					testGenericWrite(test_case, "string", "00:1f:90:55:af:2a")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.MACAddressOverride"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.PPPoEACName"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.PPPoEServiceName"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.ConnectionTrigger"
					testGenericWrite(test_case, "string", "AlwaysOn")
				when "InternetGatewayDevice.WANDevice.3.WANConnectionDevice.3.WANPPPConnection.8.RouteProtocolRx"
					testGenericWrite(test_case, "string", "Off")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.Enable"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.ConnectionType"
					testGenericWrite(test_case, "string", "IP_Routed")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.Name"
					testGenericWrite(test_case, "string", "WAN PPPoE 2")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.AutoDisconnectTime"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.IdleDisconnectTime"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.WarnDisconnectDelay"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.NATEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.Username"
					testGenericWrite(test_case, "string", "verizonfios")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.Password"
					testGenericWrite(test_case, "string", "verizon")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.MaxMRUSize"
					testGenericWrite(test_case, "unsignedInt", "0")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.DNSEnabled"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.DNSOverrideAllowed"
					testGenericWrite(test_case, "boolean", "true")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.DNSServers"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.MACAddress"
					testGenericWrite(test_case, "string", "00:1f:90:55:af:2b")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.MACAddressOverride"
					testGenericWrite(test_case, "boolean", "false")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.PPPoEACName"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.PPPoEServiceName"
					testGenericWrite(test_case, "string", "")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.ConnectionTrigger"
					testGenericWrite(test_case, "string", "AlwaysOn")
				when "InternetGatewayDevice.WANDevice.5.WANConnectionDevice.5.WANPPPConnection.9.RouteProtocolRx"
					testGenericWrite(test_case, "string", "Off")
				#when "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.SSID"
				#	testSSIDWrite(test_case)
				else
					# If the parameter name doesn't match, report error only
					$debug.log('debug', "Parameter name is not recognized!")
					$testcaseTotalCount-=1
        end
    when "firmware update"
      testFirmwareUpdate(test_case)
		else
			$debug.log('debug', "Test type is not recognized!")
			$testcaseTotalCount-=1
	end
end

# Method: testGenericRead
# Conducts a GPV function test for the given parameter
def testGenericRead(test_case)
	$debug.log('debug', "Test started")
    parameter_name = test_case.elements["parameter_name"].text
	
	# Check whether the parameter is a partial branch (ends in a dot .)
	if parameter_name[-1].chr == '.'
		isBranch = true
	else
		isBranch = false
	end
	
	# Submit the GPV request
	submit_result = submitGetParameterValueRequest(parameter_name)

	# Verify the GPV result
	# GPV passed
	if $motive.verifyParameterRequestStatus(submit_result)
		$testcasePassCount += 1
		$debug.log('debug', 'Testcase passed')

		# If the parameter is a branch, write an empty string to the log and
		#	test result XML
		if isBranch
			parameterValue = ""
		else
			parameterValue = readParameterValue(parameter_name)
		end
		$debug.log('debug', "Parameter value read from Motive is: " +
								parameterValue)
		
		# Write result to the test result XML
		exportResult(test_case.elements["id"].text.to_i, parameter_name,
						"pass", parameterValue)
	# GPV failed
	else
		$testcaseFailCount += 1
		$debug.log('debug', 'Testcase failed')
		
		# No need to get the parameter value since GPV failed
		# Write result to the test result XML
		exportResult(test_case.elements["id"].text.to_i, parameter_name,
						"fail", parameterValue)
	end
	$debug.log('debug', "Test completed")
end

# Method: testGenericWrite
# Conducts a SPV function test for the given parameter
def testGenericWrite(test_case, type, setValue)
	$debug.log('debug', "Test started")
    parameter_name = test_case.elements["parameter_name"].text
	
	# Check whether the parameter is a partial branch (ends in a dot .)
	if parameter_name[-1].chr == '.'
		isBranch = true
	else
		isBranch = false
	end
	
	# Submit the SPV request
	submit_result = submitSetParameterValueRequest(parameter_name, type, setValue)

	# Verify the SPV result
	if $motive.verifyParameterRequestStatus(submit_result)
		$testcasePassCount += 1
		$debug.log('debug', 'Testcase passed')

		# SPV should never be done on a branch parameter
		parameterValue = setValue
		$debug.log('debug', "Parameter value written to Motive is: " +
								parameterValue)
		exportResult(test_case.elements["id"].text.to_i, parameter_name,
						"pass", parameterValue)
	else
		$testcaseFailCount += 1
		$debug.log('debug', 'Testcase failed')
		
		# SPV should never be done on a branch parameter
		parameterValue = setValue
		$debug.log('debug', "Parameter value written to Motive is: " +
								parameterValue)
		
		# Write result to the test result XML
		exportResult(test_case.elements["id"].text.to_i, parameter_name,
						"fail", parameterValue)
	end
	$debug.log('debug', "Test completed")

end


# Method: submitGetParameterValueRequest
# Submits the GetParameterValue request
def submitGetParameterValueRequest(parameter_name)
	$debug.log('debug', "Test Case: #{parameter_name} [READ]")
	
	parameter = $motive.getParameterValues

	if parameter_name.include? '.'
		# split the parameter into the last string, and everything in front of it
		parameter_end_string = parameter_name[parameter_name.rindex(".")+1 .. -1]
		parameter_path_string = parameter_name[0 .. parameter_name.rindex(".")-1]
		parameter.at(parameter_path_string)
		parameter.get(parameter_end_string)
	else
		$debug.log('debug', "Parameter name does not contain a dot ('.')!")
	end
	return $motive.parameterSubmit
end

def submitSetParameterValueRequest(parameter_name, type, value)
	$debug.log('debug', "Test Case: #{parameter_name} [WRITE]")
	parameter = $motive.setParameterValues

	if parameter_name.include? '.'
		# split the parameter into the last string, and everything in front of it
		parameter_end_string = parameter_name[parameter_name.rindex(".")+1 .. -1]
		parameter_path_string = parameter_name[0 .. parameter_name.rindex(".")-1]
		parameter.at(parameter_path_string)
		parameter.set(type, parameter_end_string, value)
	else # handles the case where there is no dot in the parameter name
		$debug.log('debug', "Parameter name does not contain a dot ('.')!")
	end
	return $motive.parameterSubmit
end

# Method: readParameterValue
# Gets the parameter value
def readParameterValue(parameter_name)
	verify_parameter = $motive.verifyParameterValues
	verify_parameter.at(parameter_name[0 .. parameter_name.rindex('.')-1])
	parameterValue = verify_parameter.readParameterValue(parameter_name[parameter_name.rindex('.')+1 .. -1])
	return parameterValue
end

# Method: verifyParameterValue
# Verifies the parameter value
def verifyParameterValue(parameter_name, expected_value)
	verify_parameter = $motive.verifyParameterValues
	verify_parameter.at(parameter_name[0 .. parameter_name.rindex('.')-1])
	if verify_parameter.verify(parameter_name[parameter_name.rindex('.')+1 .. -1], expected_value)
		$testcasePassCount += 1
	else
		$testcaseFailCount += 1
	end
end

# pads an integer with "0" in front and return the padded string
def formatToString(i)
	i = i.to_i
	case i
		when 0 .. 9
			return "0000" + i.to_s
		when 10 .. 99
			return "000" + i.to_s
		when 100 .. 999
			return "00" + i.to_s
		when 1000 .. 9999
			return "0" + i.to_s
		when 10000 .. 99999
			return i.to_s
		else
			puts "Integer is not in range of 0 .. 99999. Int = " + i.to_s
	end
end

# Writes the result of the test to file
# "test_results\test_result_xxxxx.xml"
def exportResult(id, parameterName, result, expectedValue)
	testResultPath = "test_results/"  # The path separator "/" seems to work on Windows, too
	# Check if directory does not exist
	if !File.directory? testResultPath
		Dir.mkdir(testResultPath)
	end
	file = File.new(testResultPath + "test_result_" + formatToString(id) +
						".xml", "w")
	file.puts "<test_result>"
	file.puts "\t<test_case>"
	file.print "\t\t<id>", id, "</id>\n"
	file.print "\t\t<parameter_name>", parameterName, "</parameter_name>\n"
	file.print "\t\t<result>", result, "</result>\n"
	file.print "\t\t<expected_value>", expectedValue, "</expected_value>\n"
	file.puts "\t</test_case>"
	file.puts "</test_result>"
	
	file.close
end

# Method: testFirmwareUpdate
# Update Firmware
def testFirmwareUpdate(test_case)
	$debug.log('debug', "Test started")
  parameter_name = test_case.elements["parameter_name"].text
	$debug.log('debug', "Test Case: #{parameter_name} [UPDATE]")
  versionList = parameter_name.split(";")

  allPassed = true
  versionList.each do |ver|
    if ver.length == 0
      next
    end

    submit_result = submitUpdateFirmwareRequest(ver)

    # Verify the result
    # passed
    if $motive.verifyParameterRequestStatus(submit_result)
      $debug.log('debug', "Update to firmware #{ver} success!")
    # failed
    else
      $debug.log('debug', "Update to firmware #{ver} failure! Reason:#{submit_result[4]}")
      allPassed = false
    end

    sleep(10)
  end

	# Verify the result
	# passed
	if allPassed
    $testcasePassCount += 1
    $debug.log('debug', 'Testcase passed')

		# Write result to the test result XML
		exportResult(test_case.elements["id"].text.to_i, parameter_name, "pass", "Success")
	# failed
	else
		$testcaseFailCount += 1
		$debug.log('debug', 'Testcase failed')

		# No need to get the parameter value since GPV failed
		# Write result to the test result XML
		exportResult(test_case.elements["id"].text.to_i, parameter_name, "fail", "Failed")
	end

  $debug.log('debug', "Test completed")
end

def submitUpdateFirmwareRequest(ver)
  $debug.log('debug', "Update to firmware version: #{ver}")
	parameter = $motive.upgradeFirmware(ver)

#	if parameter_name.include? '.'
		# split the parameter into the last string, and everything in front of it
#		parameter_end_string = parameter_name[parameter_name.rindex(".")+1 .. -1]
#		parameter_path_string = parameter_name[0 .. parameter_name.rindex(".")-1]
#		parameter.at(parameter_path_string)
#		parameter.get(parameter_end_string)
#	else
#		$debug.log('debug', "Parameter name does not contain a dot ('.')!")
#	end
	return parameter
end
#--------------------------------------------------------------------------
# Main
# This is where the program execution begins
#--------------------------------------------------------------------------

$initializationFile = "initialization/initialization.xml"
$testCasesFile = "test_cases/test_cases_00001.xml"
$debugLevel = "debug"
# Added by Wayne, 2009-5-6
# For log file path specifying
$logFilepath = "log/" + Time.now.strftime("%Y-%m-%d_%H-%M-%S") + ".log"

# Processes command line arguments
opts = GetoptLong.new(
  [ "--initialization-file",	"-i",	GetoptLong::REQUIRED_ARGUMENT ],
  [ "--test-cases-file",		"-t",	GetoptLong::REQUIRED_ARGUMENT ],
  [ "--debug-level",			"-d",	GetoptLong::REQUIRED_ARGUMENT ],
  [ "--help",					"-h",	GetoptLong::NO_ARGUMENT ],
  [ "--log-filepath",					"-l",	GetoptLong::REQUIRED_ARGUMENT ]
)
begin
	opts.each do |opt, arg|
		case opt
			when '--initialization-file'
				$initializationFile = arg
			when '--test-cases-file'
				$testCasesFile = arg
			when '--debug-level'
				case arg
					when 'debug'
						$debugLevel = "debug"
					when 'info'
						$debugLevel = "info"
					when 'warning'
						$debugLevel = "warning"
					when 'error'
						$debugLevel = "error"
					when 'fatal'
						$debugLevel = "fatal"
					else
						raise "Debug level is not recognized!"
				end
			when '--help'
				RDoc::usage
      when '--log-filepath'
        $logFilepath = arg
		end
	end
rescue
	puts $!
	RDoc::usage
	exit
end


begin
  puts "Log file path is " + $logFilepath
	# Initialize and start the timer
	$programTimer = Timer.new
	$programTimer.start
	#$debug = AutomationDebug.new($debugLevel)
	$debug = AutomationDebug.new($logFilepath, $debugLevel)
	
	# Initialize the Debug object
	#$debug = AutomationDebug.new($debugLevel)
	
	$debug.log('debug', "Program started")
	$debug.log('info', "Current test case: #{$testCasesFile}")

	# Opens the initialization file
	init_file = File.new($initializationFile)
	
	# Load the initialization XML into REXML
	doc = REXML::Document.new init_file

	# Extract the initialization data
	$bhr_url = doc.root.elements["bhr"].elements["url"].get_text().value
	$bhr_serial = doc.root.elements["bhr"].elements["serial"].get_text().value
	$bhr_username = doc.root.elements["bhr"].elements["username"].get_text().value
	$bhr_password = doc.root.elements["bhr"].elements["password"].get_text().value
	$bhr_hardware_version = doc.root.elements["bhr"].elements["hardware_version"].get_text().value
	$bhr_software_version = doc.root.elements["bhr"].elements["software_version"].get_text().value

	$motive_url = doc.root.elements["motive"].elements["url"].get_text().value
	$motive_username = doc.root.elements["motive"].elements["username"].get_text().value
	$motive_password = doc.root.elements["motive"].elements["password"].get_text().value

	# Initialize test count. This was useful when the program used to run many test cases consecutively
	$testcaseTotalCount = 0
	$testcasePassCount = 0
	$testcaseFailCount = 0

	# Create the Motive object and log in
	$motive = Motive.new($motive_url, $motive_username, $motive_password)
	
	# Select the device with the specified serial number
	$motive.selectDevice($bhr_serial)

	# Open the config file containing the test case info
	test_cases_file = File.new($testCasesFile)
	
	# Load the config XML into REXML
	doc = REXML::Document.new test_cases_file

	# Process all the test cases in the config XML, sequentially
	doc.elements.each("test_cases/case") { |test_case|
		begin
			$debug.log('info', "Testcase started")
			executeTestCase(test_case)
		rescue
			puts $!, $@
			raise
		ensure
			$debug.log('info', "Testcase ended")
			$testcaseTotalCount+=1
		end
	}

# Catch errors from above execution
rescue 
	$debug.log('error', "An error has occurred!")
	$debug.log('error', $!)
	$debug.log('error', $@)
ensure
	$debug.log('info', "Total # of Testcases executed: #{$testcaseTotalCount}")
	$debug.log('info', "# of testcases passed: #{$testcasePassCount}")
	$debug.log('info', "# of testcases failed: #{$testcaseFailCount}")

	# Report an error if pass count + fail count is not equal to total count
	if $testcaseTotalCount != ($testcasePassCount + $testcaseFailCount)
		$debug.log('error', "Total number of test cases does not equal to the " +
			"sum of pass and failed test cases!")
	end

	# Logout Motive and close browser
	$motive.shutdown if $motive != nil
	
	$debug.log('info', "Program stopped")
	$debug.log('info', "Total elapsed time: " + $programTimer.elapsedTime + " seconds")
	$debug.finalize
end





=begin
def testSSIDWrite(test_case)
	$debug.log('debug', "Test started")

    parameter_name = test_case.elements["parameter_name"].text
	parameter_name = "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.SSID"
	newSSID = rand(10000).to_s # randomize the SSID so it is guaranteed to be different
							   #	than the current SSID
	
	submit_result = submitSetParameterValueRequest("string", parameter_name, newSSID)


	#--------------------------------------------------------------------------
	# Get SSID from BHR
	#--------------------------------------------------------------------------
	ff = Firefox.new
	ff.goto($bhr_url)

	# Login
	if ff.text_field(:name, 'user_name').exists?
		ff.text_field(:name, 'user_name').set($bhr_username)
	end
	if ff.text_field(:name, 'passwd1').exists?
		ff.text_field(:name, 'passwd1').set($bhr_password)
	end
	if $bhr_hardware_version == "E"
		ff.link(:text, 'OK').click # BHR2
	elsif $bhr_hardware_version == "D" || $bhr_hardware_version == "C"
		ff.button(:value, '  OK  ').click # BHR1
	end
	
	# Click on Wireless Settings
	if $bhr_hardware_version == "E"
		ff.link(:href, "javascript:mimic_button('sidebar: actiontec%5Ftopbar%5Fwireless..', 1)").click # BHR2
	elsif $bhr_hardware_version == "D" || $bhr_hardware_version == "C"		
		ff.link(:href, "javascript:mimic_button('sidebar: actiontec_topbar_wireless..', 0)").click # BHR1
	end
	
	# Find SSID value
	bhr_ssid = ff.table(:index, 18).row_values(2)[1]
	#puts ff.table(:xpath, "//td[b='SSID']/../../..").row_values(2) # find by XPath
	puts "BHR SSID is ", bhr_ssid
	
	ff.link(:text, "Logout").click
	ff.close
	
	#--------------------------------------------------------------------------
	# Verify query success and SSID is identical
	#--------------------------------------------------------------------------
	if bhr_ssid != newSSID
		puts "SSID on BHR (", bhr_ssid, ") is not equal to specified SSID(", newSSID, ")!"
		$testcaseFailCount += 1
	elsif $motive.verifyParameterRequestStatus(submit_result)
		verifyParameterValue(parameter_name, newSSID)
	else
		$testcaseFailCount += 1
	end
	$debug.log('debug', "Test completed")
end

def testSSIDRead(test_case)
    $debug.log('debug', "Test started")
    parameter_name = test_case.elements["parameter_name"].text
	parameter_name = "InternetGatewayDevice.LANDevice.1.WLANConfiguration.7.SSID"

	submit_result = submitGetParameterValueRequest(parameter_name)


	#--------------------------------------------------------------------------
	# Get SSID from BHR
	#--------------------------------------------------------------------------
	ff = Firefox.new
	ff.goto($bhr_url)

	# Login
	if ff.text_field(:name, 'user_name').exists?
		ff.text_field(:name, 'user_name').set($bhr_username)
	end
	if ff.text_field(:name, 'passwd1').exists?
		ff.text_field(:name, 'passwd1').set($bhr_password)
	end
	if $bhr_hardware_version == "E"
		ff.link(:text, 'OK').click # BHR2
	elsif $bhr_hardware_version == "D" || $bhr_hardware_version == "C"
		ff.button(:value, '  OK  ').click # BHR1
	end
	
	# Click on Wireless Settings
	if $bhr_hardware_version == "E"
		ff.link(:href, "javascript:mimic_button('sidebar: actiontec%5Ftopbar%5Fwireless..', 1)").click # BHR2
	elsif $bhr_hardware_version == "D" || $bhr_hardware_version == "C"		
		ff.link(:href, "javascript:mimic_button('sidebar: actiontec_topbar_wireless..', 0)").click # BHR1
	end
	
	# Find SSID value
	bhr_ssid = ff.table(:index, 18).row_values(2)[1]
	#puts ff.table(:xpath, "//td[b='SSID']/../../..").row_values(2) # find by XPath
	puts "BHR SSID is ", bhr_ssid
	
	ff.link(:text, "Logout").click
	ff.close
	
	#--------------------------------------------------------------------------
	# Verify query success and SSID is identical
	#--------------------------------------------------------------------------
	if $motive.verifyParameterRequestStatus(submit_result)
		verifyParameterValue(parameter_name, bhr_ssid)
	else
		$testcaseFailCount += 1
	end
    $debug.log('debug', "Test completed")
end
=end