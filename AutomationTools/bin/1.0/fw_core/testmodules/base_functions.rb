module BaseFunctions
  def login(attribs)
    puts "Logging in using #{attribs[:username]}/#{attribs[:password]}"
    @browser.text_field(:name => "user_name").set(attribs[:username])
    @browser.text_field(:name => "passwd1").set(attribs[:password])
    @browser.a(:text => "OK").click
    return true
  end
  def logout(attribs)
    puts "Logging out"
    @browser.a(:href => "javascript:mimic_button('logout: ...', 1)").click
    return true
  end
end