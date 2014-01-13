class ApplicationController < ActionController::Base
  helper_method :update_notice
  protect_from_forgery

  protected
  def update_notice(page)
    page.replace_html "notice", flash[:notice]
    page.visual_effect :appear, "notice", :duration => 0.5
    page.visual_effect :fade, "notice", :duration => 0.5, :delay => 5
  end
end
