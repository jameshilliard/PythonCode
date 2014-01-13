class TlProjectController < ApplicationController
  helper_method :default_column_sort, :default_column_direction
  def index
    session[:testlink_user_id] = params[:id] unless session[:testlink_user_id]
    @title = "TestLink Projects for user #{TestlinkUser.find(session[:testlink_user_id]).username}"
    @tl_projects = TestlinkProject.assigned_to(session[:testlink_user_id]).order(default_column_sort + " " + default_column_direction)
    @tl_project = TestlinkProject.new
  end

  def create
    params[:testlink_project][:testlink_user_id] = session[:testlink_user_id]
    @tl_project = TestlinkProject.new(params[:testlink_project])
    if @tl_project.save
      flash[:notice] = "TestLink project added successfully."
    else
      flash[:notice] = "Unable to add TestLink project."
    end
    render(:update) do |page|
      page.replace_html "current_projects", :partial => "list", :locals => { :tl_projects => TestlinkProject.all }
      update_notice page
    end
  end

  def destroy
    TestlinkProject.find(params[:id]).destroy
    flash[:notice] = "TestLink project removed."
    render(:update) do |page|
      page.replace_html "current_projects", :partial => "list", :locals => { :tl_projects => TestlinkProject.all }
      update_notice page
    end
  end

  private
  def default_column_sort
    TestlinkProject.column_names.include?(params[:sort]) ? params[:sort] : "project_name"
  end
  def default_column_direction
    ["asc", "desc"].include?(params[:direction]) ? params[:direction] : "asc"
  end
end