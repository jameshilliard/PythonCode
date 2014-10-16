#--------------------------------------------------------------------------------------
#	File: mainmotive.rb
#	Name: shqa
#	Contact: shqa@actiontec.com
#
#	Options:
#		-l
#		-s
#		-b
#		-n
#		-u
#		-p
#		--gpv
#		--spv
#		--do_case
#
#
#	Copyright @ Actiontec Ltd.
#--------------------------------------------------------------------------------------
require 'rubygems'
require 'getoptlong'
$dir=File.dirname(__FILE__) + "/"
require $dir + 'operatemotive'
require $dir + 'operatelogger'
#require 'rdoc/usage'
require 'rexml/document' 

class Mainclass
   include OperateMotive

   def initialize
       opts = GetoptLong.new(
                  ['-l', GetoptLong::OPTIONAL_ARGUMENT],
                  ['-s', GetoptLong::REQUIRED_ARGUMENT],
                  ['-b', GetoptLong::OPTIONAL_ARGUMENT],
                  ['--dev', '-n', GetoptLong::OPTIONAL_ARGUMENT],
		  ['--remove', '-r', GetoptLong::OPTIONAL_ARGUMENT],
                  ['--username', '-u', GetoptLong::REQUIRED_ARGUMENT],
                  ['--password', '-p', GetoptLong::REQUIRED_ARGUMENT],
                  ['--gpv', GetoptLong::OPTIONAL_ARGUMENT],
                  ['--spv', GetoptLong::OPTIONAL_ARGUMENT],
		  ['--svalue', GetoptLong::OPTIONAL_ARGUMENT],
		  ['--stype', GetoptLong::OPTIONAL_ARGUMENT],
                  ['--do_case', GetoptLong::OPTIONAL_ARGUMENT],
                  ['--help', '-h', GetoptLong::NO_ARGUMENT]        
       )
       
       usageStr="mainmotive.rb\t[-l logfile location] 
       \t\t-s selenium server ip
       \t\t[-b browser class e.g. iexplore, firefox]
       \t\t[--dev, -n find device according to serial number]
       \t\t[--remove, -r remove dev according to serial number]
       \t\t--username, -u motive login username
       \t\t--password, -p motive login password
       \t\t[--gpv get parameter name]
       \t\t[--spv set paremeter name]
       \t\t[--svalue parameter value]
       \t\t[--stype parameter type]
       \t\t[--do_case set the path of case config]
       
ruby mainmotive.rb -s $G_MOTIVE_SERVER -n $G_PROD_SERIALNUM -u $G_MOTIVE_USER -p $G_MOTIVE_PASS --remove --gpv [Parameter[,expectValue]]|root[--spv [Parameter,SetValue,type[,expectValue]]]
	\t type - string
	\t        int
	\t        unsignedInt
	\t        dateTime
	\t        boolean
	\t        base64\n
	e.g.
       \truby mainmotive.rb -s 192.168.10.156 -n CSJE8491401178 -u ps_training -p 999actiontec --gpv InternetGatewayDevice.DeviceInfo
       or
       \truby mainmotive.rb -s 192.168.10.156 -n CSJE8491401178 -u ps_training -p 999actiontec --spv InternetGatewayDevice.ManagementServer.PeriodicInformInterval --svalue setValue --stype type
       or
       \truby mainmotive.rb -s 192.168.10.156 -n CSJE8491401178 -u ps_training -p 999actiontec --do_case './config/test_000023.xml'
       or
       \truby mainmotive.rb -s 192.168.10.156 -n CSJE8491401178 -u ps_training -p 999actiontec -r\n\n"
       @log = nil
       @getpv = nil
       @setpv = nil
       @browser = 'iexplore'
       @selesrv = nil
       @devname = nil  
       @logdir = nil
       @user = nil
       @passwd = nil      
       @operate = true
       @do_gpv = false
       @do_spv = false
       @run_case = false
       @gpv_exp = "actiontec"
       @do_case = nil
       @rmdev = false

       opts.each do |opt, arg|
         case opt
            when '-l'
                 @logdir = arg
            when '-b'
                 @browser = arg
            when '-s'
                 @selesrv = arg
            when '--dev'
                 @devname = arg
            when '--remove'
                 @rmdev = true
            when '--gpv'
                 @getpv = arg
            when '--spv'
                 @setpv = arg
	    when '--svalue'
		 @svalue = arg
	    when '--stype'
		 @stype = arg
	    when '--do_case'
		 @do_case = arg
            when '--username'
                 @user = arg
            when '--password'
                 @passwd = arg
            when '--help'
		 puts "#{usageStr}"
                 exit 
         end
       end
       
       prework
       if @getpv == nil and @setpv == nil and @do_case == nil
          @operate = false
          @log.msg(:warn, "There is no gpv, spv or do_case operation")
       elsif (@getpv != nil and @setpv != nil) or (@getpv != nil and @do_case != nil) or (@setpv != nil and @do_case != nil)
          @log.msg(:error, "Confuse to handle all gpv, spv and do_case in one operation....")
          @log.destory
          exit 0
       elsif @getpv != nil
          @do_gpv = true
       elsif @setpv != nil
          @do_spv = true
       elsif @do_case != nil
	  @run_case = true
       end

       if @devname == nil 
		@log.msg(:error, "Missing Device serial number....")	
		@log.destory
		exit 0
       elsif @user == nil 
		@log.msg(:error, "Missing Motive Login user name....")
		@log.destory
		exit 0
       elsif @passwd == nil
		@log.msg(:error, "Missing Motive Login password....")
		@log.destory
		exit 0
       elsif @selesrv == nil 
		@log.msg(:error, "Missing Selenium Server IP address....")
		@log.destory
		exit 0
       end

       if @operate == true and @rmdev == true
          @log.msg(:error, "Operations conflict: remove dev and gpv,spv ")
          @log.destory
          exit 0
       end

   end

   def debug
       puts @devname
       puts @selesrv
       puts @browser
       puts @user
       puts @do_gpv
       puts @do_spv
       puts "do_gpv is #{@do_gpv}, do_spv is #{@do_spv}, Run case is #{@run_case}"
   end

   def prework
       @log = MessageOut.new(@logdir)
   end

   def endwork(status)
       __destroyBrowser
       @log.destory
       if status == 'true'
		exit 0
       elsif status == 'fail'
		exit 1
       else
		exit 0
       end
   end
    
   def startwork
       login(@selesrv, @browser, @user, @passwd)
       findDevice(@devname)
       if @rmdev == true
          delDevice(@devname)
       else
          activeDevice
          manageDevice

          if @operate == true
            if @do_gpv == true
               gpv
            end
            if @do_spv == true
               spv
            end
            if @run_case == true
               do_case
            end
          end
       end
   end
  
   def delDevice(devname)
       ret = __delDevice(devname)
       if ret == false
          @log.msg(:error, "Fail to del Device #{devname}")
          endwork('false')
          exit
       else
         endwork('pass')
       end
   end

   def activeDevice
	
       __activeDevice

   end
 
   def login(selesrv, browser, user, passwd)
       __initSelenium(selesrv, browser)
       @log.msg(:info, "Finish initial selenium....")
       __loginMotive(user, passwd)
       @log.msg(:info, "Finish login....")
   end
   
   def findDevice(devname)
       ret = __findDevice(devname)
       if ret == false and @rmdev == true
          @log.msg(:info, "No exists the device #{devname} on Motive")
          endwork('pass')
       elsif ret == false
          @log.msg(:error, "Cannot find the device #{devname}")
          endwork('fail')
       elsif ret == true
          @log.msg(:info, "Find the device #{devname}")
       end
   end

   def manageDevice
	is_managed = __manageDevice
	if is_managed == false
	    @log.msg(:error, "Cannot manage the device")
            endwork('false')
            exit
	else
	    @log.msg(:info, "Turn to Manage the device page....")
	end
   end

   def gpv
	@log.msg(:info, "Start GPV operation - #{@getpv}")
	arrGet = @getpv.split(/,/)
	@get_pv = arrGet[0].chomp
	if arrGet.length == 1
	 	@get_exp = nil
	else
	 	@get_exp = arrGet[1].chomp
	end

	if @get_pv == 'root'
		@log.msg(:info, "Now do GPV root....")
		@get_pv = "InternetGatewayDevice."
		ret_gpv = __gpv_root(@get_pv)
		if ret_gpv == false
		   @log.msg(:info, "Fail to do GPV root....")
                   endwork('fail')
		else
		   @log.msg(:info, "Succeed to GPV root....")
                   endwork('pass')
		end
	else
		@log.msg(:info, "Get the value of '#{@get_pv}', '#{@get_exp}'")
		__outputData(@get_pv)
		endwork('pass')
	end

   end

   def spv
	@log.msg(:info, "Start SPV operation....")
	#arrSet = @setpv.split(/,/)
	@set_pv = @setpv
	@spv_value = @svalue
	@spv_type = @stype

	#if arrSet.length == 3
	#	@spv_exp = nil
	#else
	#	@spv_exp = arrSet[3].chomp
	#end
	#@log.msg(:info, "Get the value of '#{@set_pv}','#{@spv_value}','#{@spv_type}','#{@spv_exp}'")
	
	@log.msg(:info, "Get the value of '#{@set_pv}','#{@spv_value}','#{@spv_type}'")
	# Set parameter value
	ret_spv = __spv(@set_pv,@spv_value,@spv_type,@spv_exp)
	if ret_spv == false 
	    @log.msg(:info, "Fail to do SPV, The vaule of #{@set_pv} is not set as #{@spv_value}")
            endwork('fail')
	else
	    @log.msg(:info, "Succeed to do SPV, The value of #{@set_pv} is set as #{@spv_value}")
            endwork('pass')
	end

   end

    def do_case
	begin
	@log.msg(:info,"Start running test case ....")
	# Open the config file containing the test case info
	test_cases = File.new(@do_case)
	
	# Load the config XML into REXML
	cases = REXML::Document.new(test_cases)
	
	$case_id = cases.root.get_text('/test_cases/case/id').value
	$case_parameter_name = cases.root.get_text('/test_cases/case/parameter_name').value
	$case_config = cases.root.get_text('/test_cases/case/config').value
	$case_set_value = cases.root.get_text('/test_cases/case/set_value').value
	$case_expect_value = cases.root.get_text('/test_cases/case/expect_value').value
	$case_set_type = cases.root.get_text('/test_cases/case/set_type').value
	$case_flag = cases.root.get_text('/test_cases/case/flag').value
	
	#puts "cases: #{$case_id}\n ----------\n #{$case_parameter_name}\n #{$case_config}\n #{$case_set_value}\n #{$case_expect_value}\n #{$case_set_type}\n #{$case_flag}\n -------------"
	
	case $case_flag
	    when "R"
		@log.msg(:info, "Start GPV operation - #{$case_parameter_name}")
		ret_gpv = __gpv($case_parameter_name,$case_expect_value)
		if ret_gpv == false
		    @log.msg(:info, "Fail to GPV ....")
		else
		    @log.msg(:info, "Successful to GPV ....")
		end
	    when "RW"
		@log.msg(:info,"Start SPV operation - #{$case_parameter_name}")
		ret_spv = __spv($case_parameter_name,$case_set_value,$case_set_type,$case_expect_value)
		if ret_spv == false
		    @log.msg(:info,"Fail to SPV ....")
		else
		    @log.msg(:info,"Successful to SPV ....")
		end
	    when "P"
		@log.msg(:info, "Start GPV parent operation - #{$case_parameter_name}")
		ret_gpv = __gpv($case_parameter_name,$case_expect_value)
		if ret_gpv == false
		    @log.msg(:info, "Fail to GPV ....")
		else
		    @log.msg(:info, "Successful to GPV ....")
		end

	    else
		@log.msg(:warn,"The parameter flag is invalid, pls check again ....")
	    end
	end
    end

end

motivetest = Mainclass.new
motivetest.startwork
