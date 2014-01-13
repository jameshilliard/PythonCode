################################################################
#     BasicUtility.rb
#     Author:          RuBingSheng
#     Date:            since 2009.02.16
#     Contact:         Bru@actiontec.com
#     Discription:     Basic Utility Class of using Ruby in Web application test
#     Input:           it depends
#     Output:          the result of operation
################################################################

class BasicUtility
  
  include FireWatir
  
  # not much to initialize, just create a new browser window
  # and the output hash.
  def initialize
    @out = {}
    @logs = Dir.getwd()
    @logs = @logs + '/results'
    
    # routes in the config are expected to be in the a.b.c.d/w.x.y.z format
    @re_route = /(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)\.(\d+)\.(\d+)\.(\d+)/
    
    # some have a prefix of the interface - int:a.b.c.d/w.x.y.z
    @re_int_route = /(\S+):(\d+)\.(\d+)\.(\d+)\.(\d+)\/(\d+)\.(\d+)\.(\d+)\.(\d+)/
    
    begin
#      @ff = FireWatir::Firefox.new(:waitTime => 7)
      @ff = FireWatir::Firefox.new
      @ff.wait
    rescue => ex
      puts('Error: ' + ex.message)
      exit -1
    end
  end
  
  
  # close the browser window
  def close
    @ff.close()
  end
  
  
  # remember where to store any logs.  allow timestamps
  # and create the directory if necessary
  def logs(where)
    
    # the directory string we are passed may have timestamp info in it.
    t = Time.now
    @logs = t.strftime(where)
    
    # does it already exists?  otherwise create the directory tree
    if File.exist?(@logs)
      
      # make sure it is a directory
      s = File.stat(@logs)
      if not s.directory?
        puts 'Error: logs set to ' + @logs.to_s + ' which is not a directory'
        exit -2
      end
    else
      begin
        FileUtils.mkdir_p(@logs)
      rescue
        puts 'Error: could not create logs directory ' + @logs.to_s
        exit -2
      end
    end
  end
  
  
  # run the passed in command, returning the return code and a pointer to the output
  def command(rule_name, what)
    
    STDOUT.sync=true
    
    begin
      oname = @logs + '/' + rule_name + '.out'
      f = File.open(oname, 'w')
      # redirect stderr to stdout so we see syntax errors from the shell
      IO.popen(what + ' 2>&1') do |pipe|
        pipe.sync = true
        while line = pipe.gets
          puts line
          f.write(line)
        end
      end
      rc = $?.exitstatus
    rescue => ex
      puts 'Error: Command failed for rule ' + rule_name + ' ' + ex.message
      exit -2
    end
    
    f.close
    
    self.msg(rule_name, 'command', 'output', oname)
    self.msg(rule_name, 'command', 'rc', rc.to_s)
  end
  
  
  # output message handler
  # level - info, warning or error
  def msg(rule, level, section, msg)
    
    if level == :debug and $debug > 0
      puts(printf('Debug: %s, %s, %s', rule, section, msg))
      return
    elsif level == :info
      level_s = 'Info'
    elsif level == :warning
      level_s = 'Warning'
    elsif level == :error
      level_s = 'ERRORSUMMY'
    else
      level_s = level
    end
    
    if not @out.has_key?(rule)
      @out[rule] = {level_s => {section => msg}}
    else
      if not @out[rule].has_key?(level_s)
        @out[rule][level_s] = {section => msg}
      else
        @out[rule][level_s][section] = msg
      end
    end
  end
  
  
  # return the log of what has happened so far
  def output
    return @out
  end
  
  
  # save the output json file
  def saveoutput(resultjsonfile_path_name)
    lines = JSON.pretty_generate(@out)
    dirname=resultjsonfile_path_name
    # filename="result_json.log"
 #   dirname=File.dirname(resultjsonfile_path_name)
  #  filename=File.basename(resultjsonfile_path_name)
    print "#{dirname}"
#    if dirname=='/' or FileTest::exist?(@logs+dirname) 
#    if dirname=='/' or FileTest::exist?(dirname) 
#      oname = @logs +resultjsonfile_path_name
#      oname = resultjsonfile_path_name+'/'+filename
#    else 
      #      oname = @logs +resultjsonfile_path_name
#      Dir.mkdir(@logs+dirname)
#      print "Make directory #{dirname}"
#      Dir.mkdir(dirname)
      oname = resultjsonfile_path_name
#    end
    print "oname=#{oname}"
    begin
      f = File.open(oname, 'w')
      lines.each do |line|
        f.write(line)
        puts line
      end
      f.close
    rescue
      puts 'Error: could not write JSON output file'
      exit -2
    end
  end
  
  
  # jump to the main page.  log into the device if necessary    
  def main(rule_name, info)
    
    # only need to build the url the 1st time
    if @url_head == nil              
      proto = 'http'
      proto = info['protocol'] if info.key?('protocol')
      
      addr = '192.168.1.1'
      addr = info['address'] if info.key?('address')
      
      port = '80'
      port = info['port'] if info.key?('port')
      
      @user = 'admin'
      @user = info['username'] if info.key?('username')
      
      @pass = 'admin1'
      @pass = info['password'] if info.key?('password')
      
      @url_head = proto + '://' + addr + ':' + port + '/'
    end
    
    begin
      @ff.goto(@url_head)
    rescue
      self.msg(rule_name, :error, 'main-login', 'Cannot reach main page')
      return
    end
    
    rc = 'Unknown error'       
    # catch the exception if there is no login page
    begin
      #@ff.text_field(:name, 'user_name').set(@user)
      #@ff.text_field(:name, 'passwd1').set(@pass)
      @ff.text_field(:name, 'user_name').value=@user
      if @ff.text.include?'Password'
        @ff.text_field(:name, 'passwd1').set(@pass)
      else
	self.msg(rule_name, :info, 'Login', 'No Password is need')
      end
      @ff.link(:text, 'OK').click
      rc = 'Successfully logged in'
    rescue
      rc = 'Reached main page'
    end
    
    self.msg(rule_name, :info, 'main', rc)
  end
  
  
# main functions  page
def mainpage(rule_name, info)
  # jump to the main page
  self.main(rule_name, info)
end   
  
  
  # wireless functions  page
  def wireless(rule_name, info)
    
    # jump to the main page
    self.main(rule_name, info)
    
    # click the wireless page
    begin
      @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fwireless..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'wireless', 'Did not reach page')
    end
  end    
  
  
  # my network functions page
  def mynetwork(rule_name, info)
    
    # jump to the main page
    self.main(rule_name, info)
    
    # click the my network page
    begin
      @ff.link(:href, /actiontec%5Ftopbar%5FHNM/).click
    rescue
      self.msg(rule_name, :error, 'My Network', 'did not reach page')
      return
    end
  end
  
  
  # firewall functions  page
  def firewall(rule_name, info)
    
    # jump to the main page
    self.main(rule_name, info)
    
    # click the firewall page
    begin
      @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5FJ%5Ffirewall..\', 1)').click
    rescue
      self.msg(rule_name, :error, 'firewall-main', 'did not reach page')
      return
    end
    
    # and the are you sure
    begin
      @ff.link(:text, 'Yes').click
    rescue
      self.msg(rule_name, :error, 'firewall-confirmation', 'did not reach page')
      return
    end
  end
  
  
  # parental control functions  page
  def parentalcontrol(rule_name, info)
    
    # jump to the main page
    self.main(rule_name, info)
    
    # click the parental control page
    begin
      @ff.link(:href, /actiontec%5Ftopbar%5Fparntl%5Fcntrl/).click
    rescue
      self.msg(rule_name, :error, 'parental control-main', 'did not reach page')
      return
    end
  end
  
  
  # jump to the advanced options page
  def advanced(rule_name, info)
    
    # click the advanced link
    begin
      @ff.link(:href, /actiontec%5Ftopbar%5Fadv%5Fsetup../).click
    rescue
      self.msg(rule_name, :error, 'advanced', 'Did not reach Advanced page')
      return
    end
    
    # look for the confirmation page's text   
    if not @ff.text.include? 'Any changes made in this section'
      self.msg(rule_name, :error, 'advanced', 'Did not reach are you sure page')
      return
    end
    
    # we are sure
    begin
      @ff.link(:text, 'Yes').click
    rescue
      self.msg(rule_name, :error, 'advanced', 'Did not reach confirmation page')
      return
    end
    
    self.msg(rule_name, :info, 'advanced', 'Reached page')
  end
  
  
  # jump to the system monitoring page
  def sysmon(rule_name, info)
    
    # jump to the main page
    self.main(rule_name, info)
    
    # click the advanced link
    #begin
    @ff.link(:href, /actiontec%5Ftopbar%5Fstatus../).click
    #rescue
    #    self.msg(rule_name, :error, 'sysmon', 'Did not reach System Monitoring page')
    #    return
    #end
    
    self.msg(rule_name, :info, 'sysmon', 'Reached page')
  end
  
  
  # reboot the router
  def reboot(rule_name, info)
    
    # need the advanced page
    self.advanced(rule_name, info)
    
    @ff.link(:text, 'Reboot Router').click
    
    if not @ff.text.include? 'Are you sure you want to reboot'
      self.msg(rule_name, :error, 'reboot', 'Did not find confirmation page')
      return
    end
    
    @ff.link(:text, 'OK').click
    self.msg(rule_name, :info, 'reboot', 'initiated')
    sleep 50
  end
  
  
  # logout of the device
  def logout(rule_name, info)
    
    # jump to the main page
    self.main(rule_name, info)
    
    # click logout
    begin
      @ff.link(:text, 'Logout').click
      self.msg(rule_name, :info, 'logout', 'success')
    rescue
      self.msg(rule_name, :error, 'logout', 'failed')
    end
  end
  
  
  # get the system info
  def info(rule_name, info)
    
    # need the system monitoring page
    self.sysmon(rule_name, info)
    
    out = {'action' => 'get', 'section' => 'info'}
    
    # find the innermost table
    found = false
    @ff.tables.each do |t|
      if t.text.include? 'Firmware Version'
        found = t
      end
    end
    
    if found != false
      out['firmware_version'] = found[1][2].text
      out['model_name'] = found[2][2].text
      out['hardware_version'] = found[3][2].text
      out['serial_number'] = found[4][2].text
      out['phys_conn_type'] = found[5][2].text
      out['bband_conn_type'] = found[6][2].text
      out['bband_conn_status'] = found[7][2].text
      out['bband_ip'] = found[8][2].text
      out['bband_subnet'] = found[9][2].text
      out['bband_mac'] = found[10][2].text
      out['bband_gw'] = found[11][2].text
      out['bband_dns'] = found[12][2].text
      out['uptime'] = found[13][2].text
      @out[rule_name] = out
      @ff.back
    else
      self.msg(rule_name, :error, 'info', 'did not find valid sysmon info')
    end
    
  end
  
  
  # firmware upgrades
  def firmware(rule_name, info)
    
    if not info.has_key?('filename')
      self.msg(rule_name, :error, 'firmware', 'No firmware filename specified in configuration')
      return
    end
    
    # need the advanced page
    self.advanced(rule_name, info)
    
    # click the firmware upgrade link
    begin
      @ff.link(:text, 'Firmware Upgrade').click
    rescue
      self.msg(rule_name, :error, 'firmware', 'Did not reach firmware upgrade page')
      return
    end
    
    # and the upgrade now link
    begin
      @ff.link(:text, 'Upgrade Now').click
    rescue
      self.msg(rule_name, :error, 'firmware', 'Did not reach upgrade now page')
      return
    end
    
    # set the firmware filename
    begin
      @ff.file_field(:name, "image").set(info['filename'])
    rescue
      self.msg(rule_name, :error, 'firmware', 'Did not set firmware file name')
      return
    end
    
    # click ok
    begin
      @ff.link(:text, 'OK').click
    rescue
      self.msg(rule_name, :error, 'firmware', 'Did not click firmware OK')
      return
    end
    
    # look for the successful upload text
    if not @ff.text.include? 'Do you want to reboot?'
      self.msg(rule_name, :error, 'advanced', 'Did not reach the reboot page')
      return
    end
    
    # click apply
    begin
      @ff.link(:text, 'Apply').click
    rescue
      self.msg(rule_name, :error, 'firmware', 'Did not click firmware Apply')
      return
    end
    
    # check for the wait message
    if not @ff.text.include? 'system is now being upgraded'
      self.msg(rule_name, :error, 'firmware', 'Did not see upgrading marker text')
      return
    end
    
    # give it some time to upgrade
    sleep 60
    @ff.refresh
    @ff.wait
    count = 0
    
    until count > 6 or @ff.text.include? 'is up again'
      count += 1
      sleep 5
    end
    if count == 7
      self.msg(rule_name, :error, 'firmware', 'Did not see login box after firmware upgrade')
      return
    end
    
    self.msg(rule_name, :info, 'firmware', 'Firmware upgrade success')
  end
  
  # jump off point to the rest of the functions
  def do(rule_name, info)
      
      # check if the logs should go somewhere else
      if info.has_key?('logs')
        self.logs(info['logs'])
      end
      
      # check for any ruby code to run before doing anything else
      if info.has_key?('eval')
        eval(info['eval'])
      end
      
      # check for commands to execute too
      if info.has_key?('command')
        self.command(rule_name, info['command'])
      end
      
      section = info['section']
      case info['section']
      when 'null'
        self.msg(rule_name, :info, 'null', '')
      when 'login'
        self.main(rule_name, info)
      when 'logout'
        self.logout(rule_name, info)
      when 'info'
        self.info(rule_name, info)
        
      when 'mainpage'
        self.mainpage(rule_name, info)
      when 'wireless'
        self.wireless(rule_name, info)
      when 'mynetwork'
        self.mynetwork(rule_name, info)
      when 'firewall'
        self.firewall(rule_name, info)
      when 'parentalcontrol'
        self.parentalcontrol(rule_name, info)
      when 'advanced'
        self.advanced(rule_name, info)
      when 'sysmon'
        self.sysmon(rule_name,info)
        
      else
        self.msg(rule_name, :error, section, 'undefined')
      end
      
      return
    end
  end
