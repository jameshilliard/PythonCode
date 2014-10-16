#*****************************************************************
#
#     File:        Sysmon.rb
#     Author:      Su He
#     Date:        2009.03.10
#     Contact:     shqa@actiontec.com
#     Discription: System Monitoring part configuration of BHR2 test case
#     Input:       N\A
#     Output:      the configuration of Advanced test case of test plan
#              
#*****************************************************************


$dir = File.dirname(__FILE__) 
require $dir+ '/../BasicUtility'


class Sysmon < BasicUtility
  
  def sysmon(rule_name, info)
  
    # Under "System Monitoring" page.    
      
    super
    
    # Check if we are under "System Monitoring" page.
    if not (@ff.text.include?'Router Status' and @ff.text.include?'Advanced Status') then
      # Wrong here.
      self.msg(rule_name,:error,'sysmon','Did NOT get the \'System Monitoring\' page.')
      return
    end
    
    # Check the key.
    if ( info.has_key?('section') &&
         info.has_key?('layout')  &&
         info.has_key?('page') ) then
      # Right,go on.
    else
      self.msg(rule_name,:error,'local_administration','Some key NOT found.')
      return
    end  
    
    # Call the sub function.
    case info['layout']
      
    when 'Router Status'
      
      # Go to "Router Status" page

      # Under "Router Status" page.
      
      # Call the sub function.
      router_status(rule_name,info)
      
    when 'Advanced Status'
      
      # Go to "Advanced Status" page.
      begin
        
        # Click the link.
        @ff.link(:text,'Advanced Status').click
        
        # Look for the confirmation page's text   
        if not @ff.text.include? 'Only advanced technical users should use this feature'
          self.msg(rule_name, :error, 'Sysmon', 'Did not reach the \'Advanced Statu\' confirm page')
          return
        end
        
        # Click "Yes" button.
        @ff.link(:text,'Yes').click
      
      end
      
      # Under "Advanced Status" page.
      
      # Call the sub function.
      begin
        
        case info['page']
          
        when 'System Logging'
          begin
            @ff.link(:text,'System Logging').click
            system_logging(rule_name,info)
          rescue
            self.msg(rule_name,:error,'System Monitoring','Can NOT find \'System Logging\' link.')
            return
          end           
          
        when 'Full Status/System wide Monitoring of Connections'
          begin
            @ff.link(:text,'Full Status/System wide Monitoring of Connections').click
            full_status_monitoring_connection(rule_name,info)
          rescue
            self.msg(rule_name,:error,'System Monitoring','Can NOT find \'Full Status/System wide Monitoring of Connections\' link.')
            return
          end           

          
        when 'Traffic Monitoring'
          begin
            @ff.link(:text,'Traffic Monitoring').click
            traffic_monitoring(rule_name,info)
          rescue
            self.msg(rule_name,:error,'System Monitoring','Can NOT find \'Traffic Monitoring\' link.')
            return
          end          

          
        when 'Bandwidth Monitoring'
          begin
            @ff.link(:text,'Bandwidth Monitoring').click
            bandwidth_monitoring(rule_name,info)
          rescue
            self.msg(rule_name,:error,'System Monitoring','Can NOT find \'Bandwidth Monitoring\' link.')
            return
          end          

        when 'IGMP Proxy'
          begin
            @ff.link(:text,'IGMP Proxy').click
            igmp_proxy(rule_name,info)
          rescue
            self.msg(rule_name,:error,'System Monitoring','Can NOT find \'IGMP Proxy\' link.')
            return
          end
          
        else
          
          # Wrong here. 
          self.msg(rule_name,:error,'Sysmon','No such \'Advanced Status\' page.')
          return 
          
        end # end of case
        
      end # end of begin
      
    else
      
      # Wrong here.
      self.msg(rule_name,:error,'System Monitoring','No such page value.')
      
    end  # end of case
    
    
  end # end of def
  
  #----------------------------------------------------------------------
  # router_status(rule_name,info)
  # Description: In "Sysmon" part, Output the router status.  
  #              This is a inside function, will be called by Sysmon().
  #----------------------------------------------------------------------
  def router_status(rule_name,info) 
    
    # Will under the default "Router Status"
    # Check
    if not @ff.text.include?'Router Status'
      # Not in this page.
      self.msg(rule_name,:error,'router_status','Did NOT get the \'Router Status\' page.')
      return
    end
    
    # Parse the json file.
    
    # "Automatic Refresh"
    if info.has_key?('Automatic Refresh')
      
      case info['Automatic Refresh']
      
      when 'on'
        
        # Set "Automatic Refresh"
        if @ff.text.include?'Automatic Refresh Off'
          
          @ff.link(:text,'Automatic Refresh Off').click
          self.msg(rule_name,:info,'Automatic Refresh',info['Automatic Refresh'])
          
        end

 
      when 'off'
        
        # Clear "Automatic Refresh"
        if @ff.text.include?'Automatic Refresh On'
          @ff.link(:text,'Automatic Refresh On').click         
        end
        self.msg(rule_name,:info,'Automatic Refresh',info['Automatic Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'router_status','Did NOT find the value in \'Automatic Refresh\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "Refresh"
    if info.has_key?('Refresh')
      
      case info['Refresh']
      
      when 'on'
        
        # Set "Refresh"
        @ff.link(:text,'Refresh').click
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
 
      when 'off'
        
        # Clear "Refresh"
        # Do nothing.
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'router_status','Did NOT find the value in \'Refresh\'.')
        return
        
      end # end of case
      
    end # end of if    

    if info.has_key?('sleep')
	sTable = false
        @ff.tables.each do |t|
          if ( t.text.include? 'Firmware Version:' and 
               ( not t.text.include? 'Router Status') and
               ( not t.text.include? 'Close') and
               t.row_count >= 5 )then
            sTable = t
            break
          end
        end
        
        if sTable == false
          # Wrong here
          self.msg(rule_name,:error,'router_status','Did NOT find the target table.')
          return
        end
        
        # Find the row
        sTable.each do |row|
          
          # Output in to the result.
          self.msg(rule_name,'Router Status before sleep',row[1],row[2])
          
        end
	sleep info['sleep'].to_i
	if @ff.text.include? 'Automatic Refresh Off'
	    @ff.refresh
	end
    end
    # Output the result here.

    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Firmware Version:' and 
           ( not t.text.include? 'Router Status') and
           ( not t.text.include? 'Close') and
           t.row_count >= 5 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'router_status','Did NOT find the target table.')
      return
    end
    
    # Find the row
    sTable.each do |row|
      
      # Output in to the result.
      self.msg(rule_name,'Router Status',row[1],row[2])
      
    end
    
    # "Close"
    if info.has_key?('Close')
      
      case info['Close']
      
      when 'on'
        
        # Set "Close"
        @ff.link(:text,'Close').click
        self.msg(rule_name,:info,'Close',info['Close'])
 
      when 'off'
        
        # Clear "Close"
        # Do nothing.
        self.msg(rule_name,:info,'Close',info['Close'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'router_status','Did NOT find the value in \'Close\'.')
        return
        
      end # end of case
      
    end # end of if   

    # Output the result
    self.msg(rule_name,:Result_Info,'Router Status','SUCCESS')    
    
  end
  
  #----------------------------------------------------------------------
  # system_logging(rule_name,info)
  # Description: In "Sysmon" part, Output the system logging.  
  #              This is a inside function, will be called by Sysmon().
  #----------------------------------------------------------------------
  def system_logging(rule_name,info) 
    
    # Will under the default "system_logging"
    # Check
    if not @ff.text.include?'System Log'
      # Not in this page.
      self.msg(rule_name,:error,'system_logging','Did NOT get the \'System Logging\' page.')
      return
    end
    
    # "Advance Basic"
    if info.has_key?('Advance Basic')
      
      case info['Advance Basic']
      
      when 'Advanced'
        
        if @ff.text.include?'Advanced >>'
          @ff.link(:text,'Advanced >>').click
        end
        
        self.msg(rule_name,:info,'Advance Basic',info['Advance Basic'])
 
      when 'Basic'
        
        if @ff.text.include?'Basic <<'
          @ff.link(:text,'Basic <<').click
        end
        self.msg(rule_name,:info,'Advance Basic',info['Advance Basic'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'system_logging','Did NOT find the value in \'Advance Basic\'.')
        return
        
      end # end of case
      
    end # end of if       
    
    # Parse the json file. 
    
    # "Clear Log"
    if info.has_key?('Clear Log')
      
      case info['Clear Log']
      
      when 'on'
        
        # Set "Clear Log"
        # Different version may be different here.
        begin
          @ff.link(:text,'Clear Log').click
        rescue
          self.msg(rule_name,:error,'System Logging','No \'Clear Log\' button in this version.')
          self.msg(rule_name,Result_Error,'System Logging','No \'Clear Log\' button in this version.')
          return
        end
        
        # Confirm it
        if @ff.text.include?'Attention'
          @ff.link(:text,'Apply').click
        end
        self.msg(rule_name,:info,'Clear Log',info['Clear Log'])
 
      when 'off'
        
        # Do nothing.
        self.msg(rule_name,:info,'Clear Log',info['Clear Log'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'system_logging','Did NOT find the value in \'Clear Log\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "Save Log"
    if info.has_key?('Save Log')
      
      case info['Save Log']
      
      when 'on'
        
        # Set "Save Log"
        @ff.link(:text,'Save Log').click
        self.msg(rule_name,:info,'Save Log',info['Save Log'])
 
      when 'off'
        
        # Do nothing.
        self.msg(rule_name,:info,'Save Log',info['Save Log'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'system_logging','Did NOT find the value in \'Save Log\'.')
        return
        
      end # end of case
      
    end # end of if    

    # "Refresh"
    if info.has_key?('Refresh')
      
      case info['Refresh']
      
      when 'on'
        
        # Set "Refresh"
        @ff.link(:text,'Refresh').click
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
 
      when 'off'
        
        # Clear "Refresh"
        # Do nothing.
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'system_logging','Did NOT find the value in \'Refresh\'.')
        return
        
      end # end of case
      
    end # end of if   
    
    # Output the result here.

    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Time' and 
           t.text.include? 'Event' and
           ( not t.text.include? 'Press the Refresh button to update the data') and
           t.row_count >= 1 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'system_logging','Did NOT find the target table.')
      return
    end
    
    iFlag = 0
    strEntry = ""
    # Find the row
    sTable.each do |row|
      
      iFlag = iFlag + 1
      
      # not for first line
      if iFlag == 1
        next
      end
      strEntry = "Log" + (iFlag - 1).to_s
      
      # Output in to the result.
      self.msg(rule_name,strEntry,'Time',row[1])
      self.msg(rule_name,strEntry,'Event',row[2])
      self.msg(rule_name,strEntry,'Event-Type',row[3])
      self.msg(rule_name,strEntry,'Details',row[4])
      
    end    

    # "Close"
    if info.has_key?('Close')
      
      case info['Close']
      
      when 'on'
        
        # Set "Close"
        @ff.link(:text,'Close').click
        self.msg(rule_name,:info,'Close',info['Close'])
 
      when 'off'
        
        # Do nothing.
        self.msg(rule_name,:info,'Close',info['Close'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'system_logging','Did NOT find the value in \'Close\'.')
        return
        
      end # end of case
      
    end # end of if  
    
    # Close the window
    if @ff.text.include?'Close'
      @ff.link(:text,'Close').click
    end

    # Output the result
    self.msg(rule_name,:Result_Info,'System Logging','SUCCESS')   
    
  end  
  
  #----------------------------------------------------------------------
  # full_status_monitoring_connection(rule_name,info)
  # Description: In "Sysmon" part, Output Full Status/System wide Monitoring of Connections.  
  #              This is a inside function, will be called by Sysmon().
  #----------------------------------------------------------------------
  def full_status_monitoring_connection(rule_name,info) 
    
    # Will under the default "Full Status/System wide Monitoring of Connections"
    # Check
    if not @ff.text.include?'Full Status/System wide Monitoring of Connections'
      # Not in this page.
      self.msg(rule_name,:error,'full_status_monitoring_connection','Did NOT get the \'Full Status/System wide Monitoring of Connections\' page.')
      return
    end
    
    # Parse the json file.  
    
    # "Automatic Refresh"
    if info.has_key?('Automatic Refresh')
      
      case info['Automatic Refresh']
      
      when 'on'
        
        # Set "Automatic Refresh"
        if @ff.text.include?'Automatic Refresh Off'
          
          @ff.link(:text,'Automatic Refresh Off').click
          self.msg(rule_name,:info,'Automatic Refresh',info['Automatic Refresh'])
          
        end

 
      when 'off'
        
        # Clear "Automatic Refresh"
        if @ff.text.include?'Automatic Refresh On'
          @ff.link(:text,'Automatic Refresh On').click         
        end
        self.msg(rule_name,:info,'Automatic Refresh',info['Automatic Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'full_status_monitoring_connection','Did NOT find the value in \'Automatic Refresh\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "Refresh"
    if info.has_key?('Refresh')
      
      case info['Refresh']
      
      when 'on'
        
        # Set "Refresh"
        @ff.link(:text,'Refresh').click
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
 
      when 'off'
        
        # Clear "Refresh"
        # Do nothing.
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'full_status_monitoring_connection','Did NOT find the value in \'Refresh\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "Reset Statistics"
    if info.has_key?('Reset Statistics')
      
      case info['Reset Statistics']
      
      when 'on'
        
        # Set "Refresh"
        @ff.link(:text,'Reset Statistics').click
        self.msg(rule_name,:info,'Reset Statistics',info['Reset Statistics'])
 
      when 'off'
        
        # Clear "Refresh"
        # Do nothing.
        self.msg(rule_name,:info,'Reset Statistics',info['Reset Statistics'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'full_status_monitoring_connection','Did NOT find the value in \'Reset Statistics\'.')
        return
        
      end # end of case
      
    end # end of if   

    # Output the result here.

    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Status' and 
           t.text.include? 'Network' and
           ( not t.text.include? 'Full Status/System wide Monitoring of Connections') and
           t.row_count >= 5 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'full_status_monitoring_connection','Did NOT find the target table.')
      return
    end
    
    iFlag = 0
    strEntry = ""
    iColumn = 2
    
    puts sTable.to_s
    
    while iColumn <= (sTable.column_count) do
      
      iFlag = iFlag + 1
      
      # not for first line
      if iFlag == 1
        next
      end
      strEntry = "Connection" + (iFlag - 1).to_s   
      
      # Output in to the result.
      self.msg(rule_name,strEntry,'Name',sTable[1][iColumn])
      self.msg(rule_name,strEntry,'Status',sTable[2][iColumn])
      self.msg(rule_name,strEntry,'Network',sTable[3][iColumn])
      self.msg(rule_name,strEntry,'Underlying Device',sTable[4][iColumn])
      self.msg(rule_name,strEntry,'Connection Type',sTable[5][iColumn])  
      self.msg(rule_name,strEntry,'MAC Address ',sTable[6][iColumn])       
      self.msg(rule_name,strEntry,'IP Address ',sTable[7][iColumn]) 
      self.msg(rule_name,strEntry,'Subnet Mask ',sTable[8][iColumn])   
      self.msg(rule_name,strEntry,'Default Gateway',sTable[9][iColumn]) 
      self.msg(rule_name,strEntry,'DNS Server',sTable[10][iColumn])
      self.msg(rule_name,strEntry,'IP Address Distribution',sTable[11][iColumn])
      self.msg(rule_name,strEntry,'Service Name',sTable[12][iColumn])      
      self.msg(rule_name,strEntry,'User Name',sTable[13][iColumn])      
      self.msg(rule_name,strEntry,'Received Packets',sTable[14][iColumn]) 
      self.msg(rule_name,strEntry,'Sent Packets',sTable[15][iColumn]) 
      self.msg(rule_name,strEntry,'Received Bytes',sTable[16][iColumn]) 
      self.msg(rule_name,strEntry,'Sent Bytes',sTable[17][iColumn])
      self.msg(rule_name,strEntry,'Receive Errors',sTable[18][iColumn]) 
      self.msg(rule_name,strEntry,'Receive Drops',sTable[19][iColumn]) 
      self.msg(rule_name,strEntry,'Time Span',sTable[20][iColumn]) 
      self.msg(rule_name,strEntry,'Channel',sTable[21][iColumn]) 
      
      iColumn = iColumn + 1
      
    end  

    # "Close"
    if info.has_key?('Close')
      
      case info['Close']
      
      when 'on'
        
        # Set "Close"
        @ff.link(:text,'Close').click
        self.msg(rule_name,:info,'Close',info['Close'])
 
      when 'off'
        
        # Do nothing.
        self.msg(rule_name,:info,'Close',info['Close'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'full_status_monitoring_connection','Did NOT find the value in \'Close\'.')
        return
        
      end # end of case
      
    end # end of if    

    # Close the window
    if @ff.text.include?'Close'
      @ff.link(:text,'Close').click
    end

    # Output the result
    self.msg(rule_name,:Result_Info,'Full Status/System wide Monitoring of Connections','SUCCESS')  
    
  end   
  
  #----------------------------------------------------------------------
  # traffic_monitoring(rule_name,info)
  # Description: In "Sysmon" part, Output traffic monitoring.  
  #              This is a inside function, will be called by Sysmon().
  #----------------------------------------------------------------------
  def traffic_monitoring(rule_name,info)
 
    # Will under the default "Traffic Monitoring"
    # Check
    if not @ff.text.include?'Traffic Monitoring'
      # Not in this page.
      self.msg(rule_name,:error,'Traffic Monitoring','Did NOT get the \'Traffic Monitoring\' page.')
      return
    end
    
    # Parse the json file.  
    
    # "Automatic Refresh"
    if info.has_key?('Automatic Refresh')
      
      case info['Automatic Refresh']
      
      when 'on'
        
        # Set "Automatic Refresh"
        if @ff.text.include?'Automatic Refresh Off'
          
          @ff.link(:text,'Automatic Refresh Off').click
          self.msg(rule_name,:info,'Automatic Refresh',info['Automatic Refresh'])
          
        end

 
      when 'off'
        
        # Clear "Automatic Refresh"
        if @ff.text.include?'Automatic Refresh On'
          @ff.link(:text,'Automatic Refresh On').click         
        end
        self.msg(rule_name,:info,'Automatic Refresh',info['Automatic Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Traffic Monitoring','Did NOT find the value in \'Automatic Refresh\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "Refresh"
    if info.has_key?('Refresh')
      
      case info['Refresh']
      
      when 'on'
        
        # Set "Refresh"
        @ff.link(:text,'Refresh').click
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
 
      when 'off'
        
        # Clear "Refresh"
        # Do nothing.
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Traffic Monitoring','Did NOT find the value in \'Refresh\'.')
        return
        
      end # end of case
      
    end # end of if   

    # "Reset Statistics"
    if info.has_key?('Reset Statistics')
      
      case info['Reset Statistics']
      
      when 'on'
        
        # Set "Refresh"
        @ff.link(:text,'Reset Statistics').click
        self.msg(rule_name,:info,'Reset Statistics',info['Reset Statistics'])
 
      when 'off'
        
        # Clear "Refresh"
        # Do nothing.
        self.msg(rule_name,:info,'Reset Statistics',info['Reset Statistics'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Traffic Monitoring','Did NOT find the value in \'Reset Statistics\'.')
        return
        
      end # end of case
      
    end # end of if   

    # Output the result here.

    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Status' and 
           t.text.include? 'Network' and
           ( not t.text.include? 'Traffic Monitoring') and
           t.row_count >= 5 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'Traffic Monitoring','Did NOT find the target table.')
      return
    end
    
    iFlag = 0
    strEntry = ""
    iColumn = 2
       
    while iColumn <= (sTable.column_count) do
      
      iFlag = iFlag + 1
      
      # not for first line
      if iFlag == 1
        next
      end
      strEntry = "Connection" + (iFlag - 1).to_s   
      
      # Output in to the result.
      self.msg(rule_name,strEntry,'Name',sTable[1][iColumn])
      self.msg(rule_name,strEntry,'Status',sTable[2][iColumn])
      self.msg(rule_name,strEntry,'Network',sTable[3][iColumn])
      self.msg(rule_name,strEntry,'Underlying Device',sTable[4][iColumn])
      self.msg(rule_name,strEntry,'Connection Type',sTable[5][iColumn])  
      self.msg(rule_name,strEntry,'IP Address ',sTable[6][iColumn]) 
      self.msg(rule_name,strEntry,'Received Packets',sTable[7][iColumn]) 
      self.msg(rule_name,strEntry,'Sent Packets',sTable[8][iColumn]) 
      self.msg(rule_name,strEntry,'Received Bytes',sTable[9][iColumn]) 
      self.msg(rule_name,strEntry,'Sent Bytes',sTable[10][iColumn])
      self.msg(rule_name,strEntry,'Receive Errors',sTable[11][iColumn]) 
      self.msg(rule_name,strEntry,'Receive Drops',sTable[12][iColumn]) 
      self.msg(rule_name,strEntry,'Time Span',sTable[13][iColumn])
      
      iColumn = iColumn + 1
      
    end # end of while 

    # "Close"
    if info.has_key?('Close')
      
      case info['Close']
      
      when 'on'
        
        # Set "Close"
        @ff.link(:text,'Close').click
        self.msg(rule_name,:info,'Close',info['Close'])
 
      when 'off'
        
        # Do nothing.
        self.msg(rule_name,:info,'Close',info['Close'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Traffic Monitoring','Did NOT find the value in \'Close\'.')
        return
        
      end # end of case
      
    end # end of if    

    # Close the window
    if @ff.text.include?'Close'
      @ff.link(:text,'Close').click
    end

    # Output the result
    self.msg(rule_name,:Result_Info,'Traffic Monitoring','SUCCESS')      
    
  end    
  
  #----------------------------------------------------------------------
  # bandwidth_monitoring(rule_name,info)
  # Description: In "Sysmon" part, Output bandwith monitoring.  
  #              This is a inside function, will be called by Sysmon().
  #----------------------------------------------------------------------
  def bandwidth_monitoring(rule_name,info) 
    
    # Will under the default "Traffic Monitoring"
    # Check
    if not @ff.text.include?'Bandwidth Monitoring'
      # Not in this page.
      self.msg(rule_name,:error,'Bandwidth Monitoring','Did NOT get the \'Bandwidth Monitoring\' page.')
      return
    end    
    
    # Parse the json file.  
    
    # "Automatic Refresh"
    if info.has_key?('Automatic Refresh')
      
      case info['Automatic Refresh']
      
      when 'on'
        
        # Set "Automatic Refresh"
        if @ff.text.include?'Automatic Refresh Off'
          
          @ff.link(:text,'Automatic Refresh Off').click
          self.msg(rule_name,:info,'Automatic Refresh',info['Automatic Refresh'])
          
        end

 
      when 'off'
        
        # Clear "Automatic Refresh"
        if @ff.text.include?'Automatic Refresh On'
          @ff.link(:text,'Automatic Refresh On').click         
        end
        self.msg(rule_name,:info,'Automatic Refresh',info['Automatic Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Bandwidth Monitoring','Did NOT find the value in \'Automatic Refresh\'.')
        return
        
      end # end of case
      
    end # end of if 
    
    # "Refresh"
    if info.has_key?('Refresh')
      
      case info['Refresh']
      
      when 'on'
        
        # Set "Refresh"
        @ff.link(:text,'Refresh').click
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
 
      when 'off'
        
        # Clear "Refresh"
        # Do nothing.
        self.msg(rule_name,:info,'Refresh',info['Refresh'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Bandwidth Monitoring','Did NOT find the value in \'Refresh\'.')
        return
        
      end # end of case
      
    end # end of if  

    # Output the result here.

    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Last Minute' and 
           t.text.include? 'Tx Rate' and
           ( not t.text.include? 'Bandwidth Monitoring') and
           t.row_count >= 5 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'Bandwidth Monitoring','Did NOT find the target table.')
      return
    end
    
    iFlag = 0
    strEntry = ""
    iColumn = 2
       
    while iColumn <= (sTable.column_count) do
      
      iFlag = iFlag + 1
      
      # not for first line
      if iFlag == 1
        next
      end
      
      strEntry = sTable[1][iColumn]   
      
      # Output in to the result.
      self.msg(rule_name,strEntry,'Tx Rate',sTable[2][iColumn])
      self.msg(rule_name,strEntry,'Rx Rate',sTable[3][iColumn])
      
      strEntry = sTable[4][iColumn]
      
      self.msg(rule_name,strEntry,'Tx Rate',sTable[5][iColumn])
      self.msg(rule_name,strEntry,'Rx Rate',sTable[6][iColumn])  
      
      iColumn = iColumn + 1
      
    end # end of while     
    
    # "Close"
    if info.has_key?('Close')
      
      case info['Close']
      
      when 'on'
        
        # Set "Close"
        @ff.link(:text,'Close').click
        self.msg(rule_name,:info,'Close',info['Close'])
 
      when 'off'
        
        # Do nothing.
        self.msg(rule_name,:info,'Close',info['Close'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'Bandwidth Monitoring','Did NOT find the value in \'Close\'.')
        return
        
      end # end of case
      
    end # end of if    

    # Close the window
    if @ff.text.include?'Close'
      @ff.link(:text,'Close').click
    end

    # Output the result
    self.msg(rule_name,:Result_Info,'Bandwidth Monitoring','SUCCESS')      
    
  end   
  
  #----------------------------------------------------------------------
  # igmp_proxy(rule_name,info)
  # Description: In "Sysmon" part, Output igmp proxy.  
  #              This is a inside function, will be called by Sysmon().
  #----------------------------------------------------------------------
  def igmp_proxy(rule_name,info) 
    
    # Will under the default "IGMP Proxy" page.
    # Check
    if not @ff.text.include?'IGMP Host Multicast Group Summary'
      # Not in this page.
      self.msg(rule_name,:error,'IGMP Proxy','Did NOT get the \'IGMP Proxy\' page.')
      return
    end    
    
    # Parse the json file.
    
    iPageFlag = 1 # flag of the page

    # "IGMP Host Multicast Group Summary"
    if info.has_key?('IGMP Host Multicast Group Summary')
      
      case info['IGMP Host Multicast Group Summary']
      
      when 'on'
        
        # Set "IGMP Host Multicast Group Summary"
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9071..\', 1)').click
        self.msg(rule_name,:info,'IGMP Host Multicast Group Summary',info['IGMP Host Multicast Group Summary'])
        iPageFlag = 1
 
      when 'off'
        
        # Clear "IGMP Host Multicast Group Summary"
        # Do nothing.
        self.msg(rule_name,:info,'IGMP Host Multicast Group Summary',info['IGMP Host Multicast Group Summary'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'IGMP Proxy','Did NOT find the value in \'IGMP Host Multicast Group Summary\'.')
        return
        
      end # end of case
      
    end # end of if 

    # "IGMP Host Multicast Group Stats"
    if info.has_key?('IGMP Host Multicast Group Stats')
      
      case info['IGMP Host Multicast Group Stats']
      
      when 'on'
        
        # Set "IGMP Host Multicast Group Stats"
        @ff.link(:href,'javascript:mimic_button(\'btn_tab_goto: 9072..\', 1)').click
        self.msg(rule_name,:info,'IGMP Host Multicast Group Stats',info['IGMP Host Multicast Group Stats'])
        iPageFlag = 2
 
      when 'off'
        
        # Clear "IGMP Host Multicast Group Stats"
        # Do nothing.
        self.msg(rule_name,:info,'IGMP Host Multicast Group Stats',info['IGMP Host Multicast Group Stats'])
        
      else
        
        # Wrong here
        self.msg(rule_name,:error,'IGMP Proxy','Did NOT find the value in \'IGMP Host Multicast Group Stats\'.')
        return
        
      end # end of case
      
    end # end of if  
    
    # Output the result here.

    # Find the table.
    sTable = false
    @ff.tables.each do |t|
      if ( t.text.include? 'Index' and 
           t.text.include? 'Interface' and
           ( not t.text.include? 'IGMP Host Multicast Group Stats') and
           ( not t.text.include? 'IGMP Host Multicast Group Summary') and
           t.row_count >= 1 )then
        sTable = t
        break
      end
    end
    
    if sTable == false
      # Wrong here
      self.msg(rule_name,:error,'IGMP Proxy','Did NOT find the target table.')
      return
    end
    
    iFlag = 0
    strEntry = ""
    
    # Find the row
    sTable.each do |row|
      
      iFlag = iFlag + 1
      
      # not for first line
      if iFlag == 1
        next
      end
      strEntry = "IGMP List" + (iFlag - 1).to_s
      
      case iPageFlag
        
      when 1
        
        # Output in to the result.
        self.msg(rule_name,strEntry,'Name','IGMP Host Multicast Group Summary')
        self.msg(rule_name,strEntry,'Index',row[1])
        self.msg(rule_name,strEntry,'Interface',row[2])
        self.msg(rule_name,strEntry,'Multicast Group',row[3])
        self.msg(rule_name,strEntry,'Filter Mode',row[4])
        self.msg(rule_name,strEntry,'Source List',row[5])
           
      when 2
        
        # Output in to the result.
        self.msg(rule_name,strEntry,'Name','IGMP Host Multicast Group Stats')
        self.msg(rule_name,strEntry,'Index',row[1])
        self.msg(rule_name,strEntry,'Interface',row[2])
        self.msg(rule_name,strEntry,'Multicast Group',row[3])
        self.msg(rule_name,strEntry,'Last Report Time',row[4])
        self.msg(rule_name,strEntry,'Total Time',row[5])  
        self.msg(rule_name,strEntry,'Total Joins',row[6]) 
        self.msg(rule_name,strEntry,'Total Leaves',row[7])         
        
      else
        
        # Wrong here
        # The programe self has some problems
        self.msg(rule_name,:error,'IGMP Proxy','Wrong program logistics.')
        return
      
      end # end of case
      
    end # end of each       
 
    # Close the window
    if @ff.text.include?'Close'
      @ff.link(:text,'Close').click
    end

    # Output the result
    self.msg(rule_name,:Result_Info,'IGMP Proxy','SUCCESS')   
    
  end  
  
end # end of class
