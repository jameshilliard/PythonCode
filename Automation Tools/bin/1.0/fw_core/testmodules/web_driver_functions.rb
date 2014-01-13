module WebDriverFunctions
  def start_browser
    @browser = Watir::Browser.new :firefox
    @browser.goto "http://192.168.1.1"
  end

  def stop_browser
    @browser.close
  end
end