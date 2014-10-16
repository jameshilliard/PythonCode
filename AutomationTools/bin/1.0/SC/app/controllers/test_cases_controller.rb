class TestCasesController < ApplicationController
  helper_method :default_column_sort, :default_column_direction
  respond_to :xml, :json, :html
  def index
    @title = "All test cases"
    respond_with @testcases = TestCase.order(default_column_sort + " " + default_column_direction).page(params[:page]).per(15)
  end

  def show
    @title = "Test case"
    @testcase = TestCase.find(params[:id])
    respond_with @testcase
  end

  def update
    @testcase = TestCase.find(params[:id])
    params[:test_case][:result] = (TEST_STATES.index(params[:test_case][:result]) || @testcase.result) if params[:test_case][:result]
    params[:test_case].delete :test_results if params[:test_case][:test_results].empty? if params[:test_case][:test_results]
    
    if @testcase.update_attributes(params[:test_case])
      flash[:notice] = "Test case updated"
      respond_with @testcase do |format|
        format.html { redirect_to :action => :show }
      end
    else
      flash[:notice] = "Errors in form"
      render :action => :show
    end
  end
  
  def dump_testcases
    TestSuite.destroy_all
    TestCase.destroy_all
    
    flash[:notice] = "Test cases and suites removed."
    redirect_to :action => 'index'
  end

  def force_update_single_user
    TestCase.delay.update_testcases(TestlinkUser.find(params[:id]))
    flash[:notice] = "Background job: Updating test cases for this user."
    redirect_to :action => 'index'
  end

  def force_update_all_users
    TestlinkUser.all.each { |tl_user| TestCase.delay.update_testcases(tl_user) }
    flash[:notice] = "Background job: Updating test cases."
    redirect_to :action => 'index'
  end

  private
  def default_column_sort
    TestCase.column_names.include?(params[:sort]) ? params[:sort] : "filename"
  end
  def default_column_direction
    ["asc", "desc"].include?(params[:direction]) ? params[:direction] : "asc"
  end
end