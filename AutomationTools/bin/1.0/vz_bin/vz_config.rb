################################################################

################################################################

require 'English'
require 'rubygems'
require 'firewatir'
require 'getoptlong'
require 'json'

$valueConvert= {
  'Routing Mode'=>'routing_mode',
  'Internet Protocol'=>'iproto', 
  'IP Address Distribution '=>'',
  'Auto Detection '=>'', 
  'Multicast-IGMP Proxy Internal '=>'', 
  'Default Route '=>'default_route', 
  'CM Ration '=>'CMRatio', 
  'MTU '=>'mtumode', 
  'Device Metric '=>'routing_metric', 
}
$conversion={
  "mynetwork"=>{ 
    'DNS Server'=>{
      'Obtain DNS Server Address Automatically'=>'1',
      'Use the Following DNS Server Address'=>'0',
      'No DNS Server'=>'2',
    },
    'IP Address Distribution'=>{
      'Disabled'=>'0',
      'DHCP Relay'=>'2',
      'DHCP Server'=>'1',
    },
    'Provide Host Name If Not Specified by Client'=>{
      'on'=>'set',
      'off'=>'clear',
    },
    'Routing Mode'=>{
      'Route'=>'1',
    },
    'Default Route'=>{
      'on'=>'set',
      'off'=>'clear',
    },
    'Multicast - IGMP Proxy Internal'=>{
      'on'=>'set',
      'off'=>'clear',
    },
    'IGMP Query Version'=>{
      'IGMPv1'=>'1',
      'IGMPv2'=>'2',
      'IGMPv3'=>'3',
    },
    'Broadband Connection'=>{
      'NETWORK'=>'1',
    },
    'MTU'=>{
      'Automatic'=>'1',
      'Automatic By DHCP'=>'2',
      'Manual'=>'3',
    },
    'Internet Protocol'=>{
      'Obtain an IP Address Automatically'=>'2',
      'Use the Following IP Address'=>'1',  
    },
    'Override Subnet Mask'=>{
      'on'=>'set',
      'off'=>'clear',
    },
    'Multicast - IGMP Proxy Internal'=>{
      'on'=>'set',
      'off'=>'clear',
    },
    'Internet Connection Firewall'=>{
      'on'=>'set',
      'off'=>'clear',
    
    },
  },

}



# handle any command line arguments 
opts = GetoptLong.new( 
     ['-f',  GetoptLong::OPTIONAL_ARGUMENT], 
     ['-u',  GetoptLong::OPTIONAL_ARGUMENT],
     ['-p',  GetoptLong::OPTIONAL_ARGUMENT],
     ['-d',  GetoptLong::REQUIRED_ARGUMENT],
     ['-h',  GetoptLong::NO_ARGUMENT]
)

$userInput = { 
  'username'=> 'admin',
  'password'=> 'abc123',
  'address' => '192.168.1.1',
  'port'=>'80',
  'wanip' => '0.0.0.0',
  'wangw' => '0.0.0.0',
  'wandns' => '0.0.0.0',
  'wannetmask' => '0.0.0.0',

}
$info={
  'username'=> 'admin',
  'password'=> 'abc123',
  'dut' => '1.1.1.1',
  'port'=>'80',
  'wanip' => '0.0.0.0',
  'wangw' => '0.0.0.0',
  'wandns' => '0.0.0.0',
  'wannetmask' => '0.0.0.0',
#my network
  'network'=>'0.0.0.0',                 
  'mtumode'=>'1',
  'MTUValue'=>'1',
  'coax'=>'clear',
  'set_privacy'=>'clear',
  'Password'=>'notavail',
  'CMratio'=>'3',
  'iproto'=>'3',
  'nm0'=>'255',
  'nm1'=>'255',
  'nm2'=>'255',
  'nm3'=>'255',
  'staticip0'=>'0',
  'staticip1'=>'0',
  'staticip2'=>'0',
  'staticip3'=>'0',
  'staticnm0'=>'255',
  'staticnm1'=>'255',
  'staticnm2'=>'255',
  'staticnm3'=>'0',
  'dns_opt'=>'',  
  'pridns_ip0'=>'',
  'pridns_ip1'=>'',
  'pridns_ip2'=>'',
  'pridns_ip3'=>'',
  'secdns_ip0'=>'',
  'secdns_ip1'=>'',
  'secdns_ip2'=>'',
  'secdns_ip3'=>'',
  'dhcp_mode'=>'',
  'startip0'=>'',
  'startip1'=>'',
  'startip2'=>'',
  'startip3'=>'',
  'endip0'=>'',
  'endip1'=>'',
  'endip2'=>'',
  'endip3'=>'',
  'dhcp_nm0'=>'',
  'dhcp_nm1'=>'',
  'dhcp_nm2'=>'',
  'dhcp_nm2'=>'', 
  'wins0'=>'',
  'wins1'=>'',
  'wins2'=>'',
  'wins3'=>'',
  'lease_time'=>'',
  'hostname'=>'',
  'routing_mode'=>'',
  'routing_metric'=>'',
  'default_route'=>'clear',
  'igmp_enable'=>'clear',
  'igmp_version'=>'1',
}
def fillup (data)
  $bhr2_login = [  
                 #  'session' =>[

                 {"session"=>[ {'goto'=>"\'http://"+data['dut']+":80\'"} ]},
                 #   {"waitUntil"=>[ {'span'=>':text,  \'Login\' '} ,{'exist\?'=>' '} ]},
                 #  ],
                 #  'layout' => [
                 {'username'=> [ {'text_field'=>':name, \'user_name\''},{'set'=>data['username']} ]  },
                 {'password'=> [{'text_field'=>':name, \'passwd1\''}, {'set'=>data['password']} ]} ,
                 {'action'=> [{'link'=>':text, \'OK\'' }, {'click'=>' ' } ]} ,
                 
                ]
  
  $bhr2_logout = [  
                  {'action'=> [{'link'=>':name, \'logout\'' }, {'click'=>' ' } ]} ,
                 ]


  $bhr2_mynetwork = [ 
                     'session'=>[ {'link'=>' :href,/actiontec%5Ftopbar%5FHNM/w'},{'click'=>' '}], 
                     'Network'=>[ { 'select_list'=>':id ,\'network\''},{'select_value'=> data['network']}],                 
                     'MTU'=>[ { 'select_list'=>':id ,\'mtu_mode\''},{'select_value'=> data['mtumode']}],
                     'mtusize'=>[{'text_field'=>':name, \'mtu\''},{'value'=>data['MTU Value']}],
                     'Auto Detection'=>[ { 'radio'=>':id,'+data['coax']+'\''},{ 'set' =>' '}],
                     'privacy'=>[{'checkbox'=>':name, \'clink_privacy\''},{data['set_privacy']=>''}],
                     'password'=>[{'text_field'=>':name, \'clink_password\''},{'value'=>data['Password']}],
                     'CM ratio'=>[{'select_list'=>':id, \'clink_cmratio\''},{'select_value'=>data['CMRatio']}],
                     'Internet Protocol'=> [ {'select_list'=>':id, \'ip_settings\''},{'select_value'=>data['iproto']}],
                     'Override Subnet Mask0'=>[{'text_field'=>':name ,\'static_netmask_override0\''},{'value'=> data['nm0']}],
                     'Override Subnet Mask1'=>[{'text_field'=>':name ,\'static_netmask_override1\''},{'value'=> data['nm1']}],
                     'Override Subnet Mask2'=>[{'text_field'=>':name ,\'static_netmask_override2\''},{'value'=> data['nm2']}],
                     'Override Subnet Mask3'=>[{'text_field'=>':name ,\'static_netmask_override3\''},{'value'=> data['nm3']}],
                     'Use the following ip0'=>[{'text_field'=>':name ,\'static_ip0\''},{'value'=> data['staticip0']}],
                     'Use the following ip1'=>[{'text_field'=>':name ,\'static_ip1\''},{'value'=> data['staticip1']}],
                     'Use the following ip2'=>[{'text_field'=>':name ,\'static_ip2\''},{'value'=> data['staticip2']}],
                     'Use the following ip3'=>[{'text_field'=>':name ,\'static_ip3\''},{'value'=> data['staticip3']}],
                     'Use the static nmask0'=>[{'text_field'=>':name ,\'static_netmask0\''},{'value'=> data['staticnm0']}],
                     'Use the static nmask1'=>[{'text_field'=>':name ,\'static_netmask1\''},{'value'=> data['staticnm1']}],
                     'Use the static nmask2'=>[{'text_field'=>':name ,\'static_netmask2\''},{'value'=> data['staticnm2']}],
                     'Use the static nmask3'=>[{'text_field'=>':name ,\'static_netmask3\''},{'value'=> data['staticnm3']}],
                     'dns server'=>[{'select_list'=>':id, \'dns_option\''},{'select_value'=>data['dns_opt']}],
                     'pri dns ip0'=>[{'text_field'=>':id, \'primary_dns0\''},{'value'=>data['pridns_ip0']}],
                     'pri dns ip1'=>[{'text_field'=>':id, \'primary_dns1\''},{'value'=>data['pridns_ip1']}],
                     'pri dns ip2'=>[{'text_field'=>':id, \'primary_dns2\''},{'value'=>data['pridns_ip2']}],
                     'pri dns ip3'=>[{'text_field'=>':id, \'primary_dns3\''},{'value'=>data['pridns_ip3']}],
                     'sec dns ip0'=>[{'text_field'=>':id, \'secondary_dns0\''},{'value'=>data['secdns_ip0']}],
                     'sec dns ip1'=>[{'text_field'=>':id, \'secondary_dns1\''},{'value'=>data['secdns_ip1']}],
                     'sec dns ip2'=>[{'text_field'=>':id, \'secondary_dns2\''},{'value'=>data['secdns_ip2']}],
                     'sec dns ip3'=>[{'text_field'=>':id, \'secondary_dns3\''},{'value'=>data['secdns_ip3']}],
                     'IP addr distribution'=>[{'select_list'=>':id, \'dhcp_mode\''},{'select_value'=>data['dhcp_mode']}],
                     'Start Ip address 0'=>[{'text_field'=>':id, \'start_ip0\''},{'value'=>data['startip0']}],
                     'Start Ip address 1'=>[{'text_field'=>':id, \'start_ip1\''},{'value'=>data['startip1']}],
                     'Start Ip address 2'=>[{'text_field'=>':id, \'start_ip2\''},{'value'=>data['startip2']}],
                     'Start Ip address 3'=>[{'text_field'=>':id, \'start_ip3\''},{'value'=>data['startip3']}],
                     'End Ip address 0'=>[{'text_field'=>':id, \'end_ip0\''},{'value'=>data['endip0']}],
                     'End Ip address 1'=>[{'text_field'=>':id, \'end_ip1\''},{'value'=>data['endip1']}],
                     'End Ip address 2'=>[{'text_field'=>':id, \'end_ip2\''},{'value'=>data['endip2']}],
                     'End Ip address 3'=>[{'text_field'=>':id, \'end_ip3\''},{'value'=>data['endip3']}],
                     'DHCP Subnetmask  0'=>[{'text_field'=>':name, \'dhcp_netmask0\''},{'value'=>data['dhcp_nm0']}],
                     'DHCP Subnetmask  1'=>[{'text_field'=>':name, \'dhcp_netmask1\''},{'value'=>data['dhcp_nm1']}],
                     'DHCP Subnetmask  2'=>[{'text_field'=>':name, \'dhcp_netmask2\''},{'value'=>data['dhcp_nm2']}],
                     'DHCP Subnetmask  3'=>[{'text_field'=>':name, \'dhcp_netmask3\''},{'value'=>data['dhcp_nm3']}],
                     'Winserver  0'=>[{'text_field'=>':name, \'wins0\''},{'value'=>data['wins0']}],
                     'Winserver  1'=>[{'text_field'=>':name, \'wins1\''},{'value'=>data['wins1']}],
                     'Winserver  2'=>[{'text_field'=>':name, \'wins3\''},{'value'=>data['wins2']}],
                     'Winserver  3'=>[{'text_field'=>':name, \'wins3\''},{'value'=>data['wins3']}],
                     'Lease time'=>[{'text_field'=>':name, \'lease_time\''},{'value'=>data['lease_time']}],
                     'Host name'=>[{'text_field'=>':name, \'create_hostname\''},{data['hostname']=>' '}],                  
                     'routing mode'=>[{'select_list'=>':name, \'route_level\''},{'select_value'=>data['routing_mode']}],                  
                     'routing metric'=>[{'select_list'=>':name, \'route_metric\''},{'select_value'=>data['route_metric'] }],
                     'default route'=>[{'checkbox'=>':name, \'default_route\''},{data['default_route']=>'' }],
                     'igmp proxy'=>[{'checkbox'=>':name, \'is_igmp_enabled\''},{data['igmp_enable']=>''}],
                     'igmp version'=>[{'select_list'=>':id, \'igmp_version\''},{'select_value'=>data['igmp_version'] }],
                     'action'=>[{'link'=>':text ,\'Apply\''},{'click'=>''}],                     
    ]
    


end

def test( obj )
  case obj.class
  when Array then puts "Array"
  when Hash then puts "Hash"
  when Class then puts "Class"
  else puts "ugh"
  end
end
class Cfgpage 
  def initialize
    puts 'Initialize...'
    @ff = FireWatir::Firefox.new
    sleep 1
  end  
  def close
    #close Firefox windows
    @ff.close
    @ff.close
  end
  def validate( obj) 
    puts 'validate...'
    obj.each do |value|
      value.each do |k1,v1|
        @temp=''
        @count =0
        v1.each do  |v2|
          v2.each do |k3,v3|
            if @count == 0
              puts "0: k3 =#{k3} ;  v3 = #{v3}"
              @temp='@ff' + '.' + k3  +'('+ v3 +')'
            else 
              puts "1: k3 =#{k3} ;  v3 = #{v3}"
              if /^\s*$/ =~ v3   
                @temp=@temp + '.'+ k3
              else 
                @temp=@temp + '.'+ k3+'( \''+v3+'\')'
              end
            end 
            @count += 1
          end
          puts "method = #{@temp}"
#          eval(@temp)
        end
      end
    end
  end
  def execute( obj) 
    puts 'validate...'
    obj.each do |value|
      value.each do |k1,v1|
        @temp=''
        @count =0
        v1.each do  |v2|
          v2.each do |k3,v3|
            if @count == 0
              puts "0: k3 =#{k3} ;  v3 = #{v3}"
              @temp='@ff' + '.' + k3  +'('+ v3 +')'
            else 
              puts "1: k3 =#{k3} ;  v3 = #{v3}"
              if /^\s*$/ =~ v3   
                @temp=@temp + '.'+ k3
              else 
                @temp=@temp + '.'+ k3+'( \''+v3+'\')'
              end
            end 
            @count += 1
          end
          puts "method = #{@temp}"
          eval(@temp)
        end
      end
    end
  end
end
def parseJson(filename)
  begin
    json = JSON.parse!(File.open(filename).read)
  rescue JSON::ParserError => ex
    puts "Error: Cannot parse " + filename
    puts "#{ex.message}"
    exit -1
  end
  return json
end

def convert(data,result)
  data.each do |key1,key2|
    puts " key1 = #{key1} , key2 = #{key2} "
    section = key2['section']
    puts "section = #{section} \n"
    key2.each do |k1,v1|
      puts " k1 = #{k1} , v1 = #{v1} "
      if $conversion[section][k1] == nil 
        result[k1]=v1
      else
        result[k1]=$conversion[section][k1]
      end
    end
  end

end
begin
  # parse the input
  opts.each do |opt, arg|
    case opt
    when '-f'
      puts " filename = #{arg} "
      $info['filename']=arg
      input = parseJson(arg)
#convert from jason file to correct format       
      convert(input,$info)
    when '-u'
      puts " user = #{arg} "
      $user = arg
      $info['username']=arg
    when '-p'
      puts " password = #{arg} "
      $info['password']=arg
    when '-h'
      $address = arg
      puts "Usage:vz_config.rb -f <input file > -d <dut >  -u <user> -p <password> "
      exit 1
    when '-d'
      $info['address']=arg
      puts " address = #{$address}"
    end
  end
rescue => ex
  puts "Error: #{ex.class}: #{ex.message}"
end



begin
#  puts 'RUBY SCRIPT START ...'
#  $userInput.each do |key,value|
#    puts  "key =#{key} ;  value = #{value}"
#  end

  exit 0

  cfg = Cfgpage.new
 
#  $info['dut']='192.168.1.1'
  fillup $info
  


#  cfg.validate($bhr2_login)
#  cfg.validate($bhr2_logout)
  cfg.validate($bhr2_mynetwork)
  cfg.close
end
