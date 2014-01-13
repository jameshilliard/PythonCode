# == Schema Information
# Schema version: 20110203190610
#
# Table name: test_suites
#
#  id                     :integer(4)      not null, primary key
#  suite_name             :string(255)     not null
#  firmware_version       :string(255)     not null
#  device_type            :string(255)     not null
#  test_section           :string(255)     not null
#  test_log_location      :string(255)
#  currently_running      :boolean(1)      not null
#  result                 :integer(4)
#  assigned               :boolean(1)      not null
#  review_required        :boolean(1)      not null
#  manual_override        :boolean(1)      not null
#  server_id              :integer(4)
#  created_at             :datetime
#  updated_at             :datetime
#  full_step_count        :integer(4)
#  testing_environment_id :integer(4)
#

require 'testlink'
class TestSuite < ActiveRecord::Base
  has_many :test_cases, :dependent => :nullify
  belongs_to :test_server
  belongs_to :testing_environment
  
  scope :similar_name, lambda { |n| where("suite_name like ?", n+"%").order("id DESC") }
  scope :unassigned, where(:assigned => false)
  scope :processing, where(:result => 7)
  # This will return the oldest created suites first
  scope :needs_server, unassigned.processing.order("created_at desc")

  def report_testlink_results
    self.test_cases.not_reported.each do |tc|
      next if tc.result.nil?
      next if tc.reported == TRUE
      status = TEST_STATES[tc.result]
      # Only report back pass or fails, even if they were forced passed or failed. 
      next unless status.match(/failed|passed/i)
      # Because testlink users could be different in an entire test suite, we have to redefine this each time
      tl = TestLink.new(:server => tc.testlink_user.server_address, :apikey => tc.testlink_user.apikey)
      if tl.sayHello
        response = tl.reportTCResult("testcaseid" => tc.testlink_testcase_id, "testplanid" => tc.testlink_testplan_id, "status" => (status.match(/passed/i) ? "p" : "f"), "guess" => true, "platformname" => tc.device_type)
        tc.update_attribute(:testlink_report_response, response)
        tc.update_attribute(:reported, true)
      end
    end
  end

  def clean_up
    # If we've reported everything, then this suite is done
    # Remove everything
    if self.test_cases.not_reported.empty?
      self.test_cases.destroy_all
      self.test_server.update_attribute(:state, SERVER_STATES.index("Available"))
      self.destroy
    end
  end
  
  def self.build_suites
    new_suites = {}
    groups = self.get_testgroups_by_steptotals
    groups.each_pair do |tsname, test_cases|
      test_cases.each do |tc|
        if new_suites.has_key?(tsname)
          # Assign to the test suite
          self.assign_this(tc, new_suites[tsname])
        else
          # Create a new suite, and assign
          new_suites[tsname] = self.create_empty_suite(tc.firmware_version, tc.test_section, tc.device_type, tsname)
          self.assign_this(tc, new_suites[tsname])
        end
      end
    end
  end

  def self.test_suites_to_servers
    # Get suites that are processing
    suites = TestSuite.needs_server.all

    # Iterate through processing suites and assign
    suites.each do |ts|
      # Find the first available server with the correct device
      serv = TestServer.find_free_server(ts.device_type)
      # Jump to the next suite if we don't have an available server for this test yet
      next if serv.nil?
      # Otherwise assign the server ID to this suite
      serv.test_suite = ts
      # Update the server status to pending
      ts.test_server.update_attribute(:state, SERVER_STATES.index("Pending"))
      # And set the assigned flag to true
      ts.update_attribute(:assigned, true)
      ts.update_attribute(:result, TEST_STATES.index("Queued"))
      ts.test_cases.update_all(:result => TEST_STATES.index("Queued"))
      # Queue the test system test suite build, which will in turn begin the testing phase
      TestSuite.delay.build_testsystem_suite(serv, 0, true)
    end
  end

  # Builds a test suite
  # FixMe: This will be dynamic in the future so that any test can be run, for now
  # it's going to be limited to port forwarding. For testing and demonstration purposes.
  def self.build_testsystem_suite(serv, coax, newsetup=false)
    if newsetup
      tcs = {}
      serv.test_suite.test_cases.each {|tc| tcs[tc.id] = tc.documentation.gsub(/<\/?p>/, '').split('||') }
      suite_file = {:server_id => serv.id, :test_cases => tcs}
      screwcap_server = TaskManager.new(:silent => true)
      screwcap_server.server :test_server_in_use, :address => serv.ip, :user => serv.username, :password => serv.password
      screwcap_server.task :transfer_suite_files, :server => :test_server_in_use do
        scp :local => StringIO.new(suite_file.to_yaml), :remote => "/home/cborn/automation/bin/1.0/fw_core/testing_assignment.tst"
      end
      screwcap_server.run!(:transfer_suite_files)
    else
      testcases = []
      files = serv.test_suite.test_cases.collect {|tc| tc.filename}
      identities = serv.test_suite.test_cases.collect {|tc| "#{tc.filename}==#{tc.id}"}.join("\n")
      identities << "\ntest_server_id==#{serv.id}"
      files.each { |tc| testcases << "-tc $SQAROOT/platform/1.0/verizon/testcases/ala/tcases_1/#{tc}"}
      tsuite = <<-EOS
      -v G_USER=qaauto
      -v G_CONFIG=1.0
      -v G_TBTYPE=ala
      -v G_TST_TITLE="Advanced Local Administration"
      -v G_PROD_TYPE=MC524WR
      -v G_HTTP_DIR=test/
      -v G_FTP_DIR=/log/autotest
      -v G_TESTBED=tb2
      -v G_FROMRCPT=hsu@actiontec.om
      -v G_FTPUSR=root
      -v G_FTPPWD=@ctiontec123
      -v U_USER=admin
      -v U_PWD=admin1
      -v G_LIBVERSION=1.0
      -v G_LOG=$SQAROOT/automation/logs
      -v U_COMMONLIB=$SQAROOT/lib/$G_LIBVERSION/common
      -v U_COMMONBIN=$SQAROOT/bin/$G_LIBVERSION/common
      -v U_TBCFG=$SQAROOT/config/$G_LIBVERSION/testbed
      -v U_TBPROF=$SQAROOT/config/$G_LIBVERSION/common
      -v U_VERIWAVE=$SQAROOT/bin/1.0/veriwave/
      -v U_MI424=$SQAROOT/bin/1.0/mi424wr/
      -v U_TESTPATH=$SQAROOT/platform/1.0/verizon/testcases/ala/json_1
      -v U_DEBUG=3
      -v U_RUBYBIN=$SQAROOT/bin/$G_LIBVERSION/rbin
      -v U_VZBIN=$SQAROOT/bin/$G_LIBVERSION/vz_bin
      -v U_COMMONJSON=$SQAROOT/platform/1.0/verizon2/testcases/common/json
      -v U_COAX=0
      #------------------------------
      # Set up the test environment.
      #------------------------------
      -nc $SQAROOT/config/$G_CONFIG/common/testbedcfg_nokill.xml;
      -nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/enable_tnet.xml
      #------------------------------
      # Test cases
      #------------------------------
      -nc $SQAROOT/platform/1.0/verizon2/testcases/common/tcases/set_default_time.xml
      #{testcases.join("\n")}
      #------------------------------
      # Checkout
      #------------------------------
      -label finish
      -nc $SQAROOT/config/$G_CONFIG/common/finalresult.xml
      -nc $SQAROOT/config/$G_CONFIG/common/uploadlog.xml
      EOS
      # Clean up the file since we used an indented heredoc.
      suite_file = (tsuite.each_line.collect {|x| x.strip}).join("\n")
      screwcap_server = TaskManager.new(:silent => true)
      screwcap_server.server :test_server_in_use, :address => serv.ip, :user => serv.username, :password => serv.password
      screwcap_server.task :transfer_suite_files, :server => :test_server_in_use do
        scp :local => StringIO.new(suite_file), :remote => "/root/testing_assignment.tst"
        scp :local => StringIO.new(identities), :remote => "/root/test_case.ids"
      end
      screwcap_server.run!(:transfer_suite_files)
    end
  end

  private
  def self.get_testgroups_by_steptotals
    valid_groups = {}
    test_groups = TestCase.not_assigned.group_by(&:test_section).keys
    test_groups.each do |k|
      group_count = TestCase.not_assigned.with_section(k).sum(:step_count)
      if group_count <= TESTSUITE_MAX_STEPS && group_count >= TESTSUITE_MIN_STEPS
        tname = self.create_suite_name(k)
        others = TestSuite.similar_name(tname+"_").all
        tname += "#{others.first.suite_name.slice(/_\d+/).next}" unless others.empty?
        valid_groups["#{tname}"] = TestCase.not_assigned.with_section(k)
      elsif group_count > TESTSUITE_MAX_STEPS
        chunk_size = TESTSUITE_MAX_STEPS/(TestCase.not_assigned.with_section(k).average(:step_count))
        chunks = ((TestCase.not_assigned.with_section(k).size.to_f)/(chunk_size.to_f)).ceil
        1.upto(chunks) do |chunk|
          valid_groups["#{self.create_suite_name(k)}_#{sprintf("%03d", chunk)}"] = self.get_test_case_chunk(k,chunk_size,chunk-1)
        end
      elsif group_count < TESTSUITE_MIN_STEPS
        # FixMe: Implement this!
        # Find a suitable test suite that deals with the same section if possible
        # If we found one, assign these test cases to that
        # If not, we'll create a new suite just to get the testing done
      end
    end
    return valid_groups
  end

  def self.get_test_case_chunk(sect, csize, count)
    return TestCase.not_assigned.with_section(sect).order("id DESC").limit(csize).offset(csize*count).all
  end

  def self.create_suite_name(section)
    return section.join.gsub(/[^A-Z0-9]/,'').downcase
  end
  
  def self.create_empty_suite(fv, ts, dt, n)
    ns = TestSuite.new
    ns.suite_name = n
    ns.firmware_version = fv
    ns.test_section = ts.join("->")
    ns.device_type = dt
    ns.assigned = false
    ns.review_required = false
    ns.manual_override = false
    ns.currently_running = false
    ns.full_step_count = 0
    ns.result = TESTSUITE_DEFAULT_STATE
    ns.save  
    return ns
  end
  
  def self.assign_this(tc, ts)
    tc.update_attribute(:test_suite_id, ts.id)
    ts.update_attribute(:full_step_count, tc.step_count + ts.full_step_count)
  end
end
