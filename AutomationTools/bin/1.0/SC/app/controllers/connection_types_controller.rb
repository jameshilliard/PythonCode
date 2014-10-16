class ConnectionTypesController < ApplicationController
  helper_method :default_column_sort, :default_column_direction
  respond_to :xml, :json, :html
  def show
    @connection_type = ConnectionType.find(params[:id])
    @title = "Connection Information (#{params[:id]})"
    respond_with @connection_type
  end

  def index
    @title = "Connection Types"
    respond_with @connection_types = ConnectionType.order(default_column_sort + " " + default_column_direction)
  end

  def new
    @title = "New connection type"
    @connection_type = ConnectionType.new
    respond_with @connection_type
  end

  def create
    @connection_type = ConnectionType.new(params[:connection_type])
    if @connection_type.save
      flash[:notice] = "Connection added"
    else
      flash[:notice] = "Errors in form"
    end
    respond_with @connection_type
  end

  def edit
    @connection_type = ConnectionType.find(params[:id])
    @title = "Edit Connection (#{@connection_type.id})"
    respond_with @connection_type
  end

  def update
    @connection_type = ConnectionType.find(params[:id])
    if @connection_type.update_attributes(params[:connection_type])
      flash[:notice] = "Connection updated"
    else
      flash[:notice] = "Errors in form"
    end
    respond_with @connection_type do |format|
      format.html { redirect_to :action => :show }
    end
  end
end
