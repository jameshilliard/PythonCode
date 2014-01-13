class TestServersController < ApplicationController
  helper_method :default_column_sort, :default_column_direction
  respond_to :xml, :json, :html
  def show
    @server = TestServer.find(params[:id])
    @title = "Test Server Information (#{params[:id]})"
    respond_with @server
  end

  def index
    @title = "Test Server Overview"
    respond_with @servers = TestServer.order(default_column_sort + " " + default_column_direction)
  end

  def new
    @title = "New test server entry"
    @server = TestServer.new
    @server.state = SERVER_DEFAULT_STATE
    respond_with @server
  end

  def create
    (params[:test_server][:state] = SERVER_STATES.index(params[:test_server][:state]) || 0) unless params[:test_server][:state].is_a?(Fixnum)
    @server = TestServer.new(params[:test_server])
    if @server.save
      flash[:notice] = "Test Server added"
    else
      flash[:notice] = "Errors in form"
    end
    respond_with @server
  end

  def edit
    @server = TestServer.find(params[:id])
    @title = "Edit Test Server (#{@server.id})"
    respond_with @server
  end

  def update
    params[:test_server][:state] = (SERVER_STATES.index(params[:test_server][:state]) || 0) if params[:test_server][:state]
    @server = TestServer.find(params[:id])
    if @server.update_attributes(params[:test_server])
      flash[:notice] = "Test server updated"
    else
      flash[:notice] = "Errors in form"
    end
    respond_with @server do |format|
      format.html { redirect_to :action => :show }
    end
  end
  
  def destroy
    @server = TestServer.find(params[:id]).destroy
    flash[:notice] = "TestServer removed."
    respond_with @server
  end

  def remove_test_suite
    @server = TestServer.find(params[:id])
    @server.test_suite.update_attribute(:result, TEST_STATES.index("Processing"))
    @server.test_suite.update_attribute(:assigned, false)
    @server.test_suite.test_cases.update_all("result=#{TEST_STATES.index("Processing")}", :result => TEST_STATES.index("Queued"))
    @server.test_suite = nil
    @server.update_attribute(:state, SERVER_STATES.index("Available")) if @server.state == SERVER_STATES.index("Pending")
    screwcap_server = TaskManager.new(:silent => true)
    screwcap_server.server :test_server_in_use, :address => @server.ip, :user => @server.username, :password => @server.password
    screwcap_server.task :cleanup, :server => :test_server_in_use do
      run "rm -f /root/testing_assignment.tst"
      run "rm -f /root/test_case.ids"
    end
    screwcap_server.run!(:cleanup)
    flash[:notice] = "Test suite removed from this server."
    redirect_to :action => :show
  end

  private
  def default_column_sort
    TestServer.column_names.include?(params[:sort]) ? params[:sort] : "hostname"
  end
  def default_column_direction
    ["asc", "desc"].include?(params[:direction]) ? params[:direction] : "asc"
  end
end
