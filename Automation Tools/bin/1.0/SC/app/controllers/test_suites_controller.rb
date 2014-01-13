class TestSuitesController < ApplicationController
  helper_method :default_column_sort, :default_column_direction
  respond_to :xml, :json, :html
  def index
    @title = "Test Suite overview"
    respond_with @testsuites = TestSuite.order(default_column_sort + " " + default_column_direction)
  end

  def show
    @testsuite = TestSuite.find(params[:id])
    @title = "Test Suite #{@testsuite.suite_name}"
    respond_with @testsuite
  end

  def update
    params[:testsuite][:result] = (TEST_STATES.index(params[:testsuite][:result]) || 0) if params[:testsuite][:result]
    @testsuite = TestSuite.find(params[:id])
    if @testsuite.update_attributes(params[:testsuite])
      flash[:notice] = "Test suite updated"
    else
      flash[:notice] = "Errors in form"
    end
    respond_with @testsuite do |format|
      format.html { redirect_to :action => :show }
    end
  end

  def new
    @title = "New test suite entry"
    @testsuite = TestSuite.new
  end

  def edit
    @testsuite = TestSuite.find(params[:id])
    @title = "Edit Test Suite #{@testsuite.suite_name}"
    respond_with @testsuite
  end

  def destroy
    @testsuite = TestSuite.find(params[:id])
    # Set server state to available before destroying if it was set to Pending
    if @testsuite.test_server.state == SERVER_STATES.index("Pending")
      @testsuite.test_server.update_attribute(:state, SERVER_STATES.index("Available"))
    else
      # FixMe: Have server stop testing if it's currently testing (force stop)
    end if @testsuite.test_server
    # Destroy test suite
    @testsuite.destroy
    flash[:notice] = "Test suite removed."
    respond_with @testsuite
  end

  def force_testsuite_build
    TestSuite.delay.build_suites
    flash[:notice] = "Background job: Creating test suites."
    redirect_to :action => :index
  end

  def dump_testsuites
    # server state to Available if it was set to Pending
    TestSuite.all.each do |ts|
      if ts.test_server.state == SERVER_STATES.index("Pending")
        ts.test_server.update_attribute(:state, SERVER_STATES.index("Available"))
      else
        # FixMe: Have server stop testing if it's currently testing (force stop)
      end if ts.test_server
      ts.destroy
    end
    flash[:notice] = "Test suites removed."
    redirect_to :action => :index
  end

  def force_assign_testsuites
    TestSuite.delay.test_suites_to_servers
    flash[:notice] = "Background job: Assigning test suites."
    redirect_to :action => :index
  end

  def send_all_results
    TestSuite.all.each do |ts|
      ts.delay.report_testlink_results
    end
  end

  def force_send_results
    @testsuite = TestSuite.find(params[:id])
    @testsuite.delay.report_testlink_results
    flash[:notice] = "Background job: Sending results."
    redirect_to :action => :index
  end

  private
  def default_column_sort
    TestSuite.column_names.include?(params[:sort]) ? params[:sort] : "suite_name"
  end
  def default_column_direction
    ["asc", "desc"].include?(params[:direction]) ? params[:direction] : "asc"
  end
end