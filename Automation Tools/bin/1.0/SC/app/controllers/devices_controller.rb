class DevicesController < ApplicationController
  helper_method :default_column_sort, :default_column_direction
  def index
    @title = "Devices"
    @devices = Device.all
    @new_device = Device.new
  end
  
  def create
    params[:device][:aliases] = params[:device][:aliases].split(',').collect {|x| x.strip}
    params[:device][:possible_usernames] = params[:device][:possible_usernames].split(',').collect {|x| x.strip}
    params[:device][:possible_passwords] = params[:device][:possible_passwords].split(',').collect {|x| x.strip}
    params[:device][:possible_ips] = params[:device][:possible_ips].split(',').collect {|x| x.strip}
    @new_device = Device.new(params[:device])
    flash[:notice] = @new_device.save ? "Device added" : "Unable to add device"
    render(:update) do |page|
      page.replace_html "devices", :partial => "list", :locals => { :devices => Device.all }
      update_notice page
    end
  end

  def destroy
    Device.find(params[:id]).destroy
    flash[:notice] = "Device removed."
    render(:update) do |page|
      page.replace_html "devices", :partial => "list", :locals => { :devices => Device.all }
      update_notice page
    end
  end

  private
  def default_column_sort
    Device.column_names.include?(params[:sort]) ? params[:sort] : "model"
  end
  def default_column_direction
    ["asc", "desc"].include?(params[:direction]) ? params[:direction] : "asc"
  end

end