################################################################
#     MainPage.rb
#     Author:          Mike
#     Date:            since 2009.02.16
#     Contact:         zqwang@actiontec.com
#     Discription:     Basic operation of Main Page
#     Input:           it depends
#     Output:          the result of operation
################################################################

$dir = File.dirname(__FILE__) 
require $dir+ '/../BasicUtility'

class MainPage < BasicUtility
  
  # Wireless page
  def mainpage(rule_name, info)
    
    #execute super.wireless(rule_name, info) to go to Wireless Page
    super
    
    # settings and testing on the Wireless page
    # plsease add your code here...
     
   begin
    # click the link "Change Wireless Settings"        
       @ff.link(:href, 'javascript:mimic_button(\'goto_long: 9119..\', 1)').click
       self.msg(rule_name,:info,'Change Wireless Setting','OK')
    rescue
       self.msg(rule_name, :error, 'Change Wireless Setting', 'Fail')
   end
       if @ff.text.include?'If you want to setup a wireless network, we recommend that you do the following'
         self.msg(rule_name,:info,'Change Wireless Settings','Opened')
       else 
         self.msg(rule_name, :error, 'Change Wireless Settings', 'Closed')
       end  
   
   
   begin
     # click the link "Change Login User Name / Password"       
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.link(:href, 'javascript:mimic_button(\'goto_user: 101..\', 1)').click
       self.msg(rule_name,:info,'Change Login User Name / Password','OK')
    rescue   
       self.msg(rule_name, :error, 'Change Login User Name / Password', 'Fail')
   end   
       if @ff.text.include?'User Settings'
         self.msg(rule_name,:info,'Change Login User Name / Password','Opened')
       else 
         self.msg(rule_name, :error, 'Change Login User Name / Password', 'Closed')
       end  
   
   begin
     # click the link "Enable Applications(Games, Webcams, IM & Others" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.link(:href, 'javascript:mimic_button(\'goto: 9130..\', 1)').click 
       self.msg(rule_name,:info,'Enable Applications(Games, Webcams, IM & Others','OK')
     rescue   
       self.msg(rule_name, :error, 'Enable Applications(Games, Webcams, IM & Others', 'Fail')
   end
        if @ff.text.include?'Port Forwarding'
         self.msg(rule_name,:info,'CEnable Applications(Games, Webcams, IM & Others','Opened')
       else 
         self.msg(rule_name, :error, 'Enable Applications(Games, Webcams, IM & Others', 'Closed')
       end  
   
   begin
     # click the link "Adding a Webcam" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.link(:text,'Adding a Webcam').click
       self.msg(rule_name,:info,'Adding a Webcam','OK')      
     rescue   
       self.msg(rule_name, :error, 'Adding a Webcam', 'Fail')  
   end
   
   begin
     # click the link "Verizon Help" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.link(:text,'Verizon Help').click
       self.msg(rule_name,:info,'Verizon Help','OK')
     rescue   
       self.msg(rule_name, :error, 'Verizon Help', 'Fail')  
   end 
   
   begin
     # click the link "Verizon.com" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.link(:text,'Verizon.com').click
       self.msg(rule_name,:info,'Verizon.com','OK')
     rescue   
       self.msg(rule_name, :error, 'Verizon.com', 'Fail')  
   end
   
   begin
    # click the link "Verizon Central" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.link(:text,'Verizon Central').click   
       self.msg(rule_name,:info,'Verizon Central','OK')
     rescue   
       self.msg(rule_name, :error, 'Verizon Central', 'Fail')  
   end
   
   begin
    # click the link "Verizon Business Center" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.link(:text,'Verizon Business Center').click
       self.msg(rule_name,:info,'Verizon Business Center','OK')     
    rescue   
       self.msg(rule_name, :error, 'Verizon Business Center', 'Fail')   
   end
   
   begin
    # click the link "Verizon Surround" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.link(:text,'Verizon Surround').click   
       self.msg(rule_name,:info,'Verizon Surround','OK')
     rescue   
       self.msg(rule_name, :error, 'Verizon Surround', 'Fail')  
    end
          
    begin
    # click the link "Shop Actiontec" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.image(:name,'ShopActiontec_btn').click
       self.msg(rule_name,:info,'Shop Actiontec','OK')
     rescue   
       self.msg(rule_name, :error, 'Shop Actiontec', 'Fail') 
    end
    
    begin
    # click the link "Music" 
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.image(:name,'musicbtn').click
       self.msg(rule_name,:info,'Music','OK')
    rescue   
       self.msg(rule_name, :error, 'Music', 'Fail')   
    end    
       
   begin
    # click the link "Video" 
       sleep 3
       @ff.link(:href, 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fmain..\', 1)').click
       @ff.image(:name,'videobtn').click     
       self.msg(rule_name,:info,'Video','OK')
    rescue   
       self.msg(rule_name, :error, 'Video', 'Fail')   
   end  
    
      return
   end
   
end
