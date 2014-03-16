class TlUserController < ApplicationController
  helper_method :default_column_sort, :default_column_direction
  def index
    @title = "Registered TestLink Users"
    @tl_users = TestlinkUser.all
    @tl_user = TestlinkUser.new
  end

  def create
    @tl_user = TestlinkUser.new(params[:testlink_user])
    TestlinkUser.default_user[0].update_attribute(:default, false) unless TestlinkUser.default_user.empty? if @tl_user.default
    if @tl_user.save
      flash[:notice] = "TestLink user added successfully."
    else
      flash[:notice] = "Unable to add TestLink user."
    end
    render(:update) do |page|
      page.replace_html "current_users", :partial => "list", :locals => { :tl_users => TestlinkUser.all }
      update_notice page
    end
  end

  def destroy
    # Set the session to nil as it causes problems if we delete the current session default
    session[:testlink_user_id] = nil
    # Remove projects first, then user
    TestlinkProject.assigned_to(params[:id]).each {|p| p.destroy }
    TestlinkUser.find(params[:id]).destroy
    flash[:notice] = "TestLink user removed."
    render(:update) do |page|
      page.replace_html "current_users", :partial => "list", :locals => { :tl_users => TestlinkUser.all }
      update_notice page
    end
  end

  def change_default
    if TestlinkUser.default_user[0].update_attribute(:default, false) && TestlinkUser.find(params[:id]).update_attribute(:default, true)
      flash[:notice] = "Default user changed"
    else
      flash[:notice] = "Unable to change default user"
    end unless TestlinkUser.default_user.empty?
    if TestlinkUser.find(params[:id]).update_attribute(:default, true)
      flash[:notice] = "Default user selected"
    else
      flash[:notice] = "Unable to select default user"
    end if TestlinkUser.default_user.empty?
    render(:update) do |page|
      page.replace_html "current_users", :partial => "list", :locals => { :tl_users => TestlinkUser.all }
      update_notice page
    end
  end

  # This method pushes all current test results for all TL users to their associated TestLink server
  def force_results_push
    TestlinkUser.all.each do |tlu|
      tlu.report_testlink_results
    end
    flash[:notice] = "Background job: Pushing test case results."
    redirect_to :action => :index
  end

  private
  def default_column_sort
    TestlinkUser.column_names.include?(params[:sort]) ? params[:sort] : "testlink_username"
  end
  def default_column_direction
    ["asc", "desc"].include?(params[:direction]) ? params[:direction] : "asc"
  end
end