#!/usr/bin/env ruby
# == Copyright
# (c) 2010 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born

# Grabs the specified value from the GUI
$: << File.dirname(__FILE__)
File.dirname(__FILE__)=="." ? $: << "../common" : $: << "./common"

require 'rubygems'
require 'ip_utils'
require 'user-choices'
require 'firewatir'

class GUIParser < UserChoices::Command
    include FireWatir
    # include Net
    include UserChoices
    # include Log

    def initialize(file="")
        @config_file = file
        @logged_in = false
        builder = ChoicesBuilder.new
        add_sources(builder)
        add_choices(builder)
        @user_choices = builder.build
        postprocess_user_choices
        # logs(@user_choices[:log_file], 4-@user_choices[:debug], @user_choices[:verbose])
        @menu_links = {
            :wireless => 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fwireless..\', 1)',
            :my_network => "javascript:mimic_button('sidebar: actiontec%5Ftopbar%5FHNM..', 1)",
            :firewall_settings => 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5FJ%5Ffirewall..\', 1)',
            :parental_control => /actiontec%5Ftopbar%5Fparntl%5Fcntrl/,
            :advanced => 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fadv%5Fsetup..\', 1)',
            :system_monitoring => 'javascript:mimic_button(\'sidebar: actiontec%5Ftopbar%5Fstatus..\', 1)'
        }
    end

    def add_sources(builder)
        builder.add_source(CommandLineSource, :usage, "Usage: ruby #{$0} [options]")
        builder.add_source(YamlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/yml|yaml/i)
        builder.add_source(XmlConfigFileSource, :from_complete_path, "#{@config_file}") if @config_file.match(/xml/i)
        builder.add_source(EnvironmentSource, :with_prefix, "bhr2_")
    end

    def add_choices(builder)
        builder.add_choice(:index) { |cmd| cmd.uses_switch("--index", "Returns table index values for specified table passed with --value. For finding table indices")}
        builder.add_choice(:username) { |cmd| cmd.uses_option("-u", "--username USER", "Specifies the login username information for the BHR2 under testing") }
        builder.add_choice(:password) { |cmd| cmd.uses_option("-p", "--password PASS", "Specifies the login password information for the BHR2 under testing") }
        builder.add_choice(:interface) { |cmd| cmd.uses_option("-i", "--interface INT", "Specifies the IP address to reach the BHR2 under testing") }
        builder.add_choice(:page) { |cmd| cmd.uses_option("--page PATH", "Goes to the specified page path to retrieve values") }
        builder.add_choice(:value, :type=>[:string]) { |cmd| cmd.uses_option("-v", "--value TABLE,ROW,COLUMN", "The value of the table,row,column to retrieve") }
        builder.add_choice(:log) { |cmd| cmd.uses_switch("--log", "Retrieves the security log") }
        builder.add_choice(:config) { |cmd| cmd.uses_switch("--config", "Retrieves the config") }
        builder.add_choice(:debug, :type=>:integer, :default=>3) { |command_line| command_line.uses_option("--debug LEVEL", "Set debug value - default is 3 (highest)") }
        builder.add_choice(:verbose, :type=>:boolean, :default=>true) { |command_line| command_line.uses_switch("--verbose", "Enables/disables console output") }
        builder.add_choice(:log_file) { |command_line| command_line.uses_option("--output FILE", "Set output log file; If not set, no log file is created") }
    end
    def confirm
        if @ff.link(:text, 'OK').exists?
            @ff.link(:text, 'OK').click
        elsif @ff.link(:text, 'Yes').exists?
            @ff.link(:text, 'Yes').click
        end
    end
	def login
        waittime = 15
        @ff = FireWatir::Firefox.new(:waitTime => waittime)
        @ff.wait
        @ff.goto(@user_choices[:interface])
        raise "Can't connect to address specified" if @ff.text.include?('Failed to Connect')
        @ff.text_field(:name, 'user_name').set(@user_choices[:username])
        @ff.text_field(:name, 'passwd1').set(@user_choices[:password]) if @ff.text_field(:name, 'passwd1').exists?
        confirm
        raise "Unable to login" unless @ff.contains_text("Router Status")
	end

    def logout
        @ff.link(:text, "Logout").click
        @ff.close
    end

    def page_jump
        @user_choices[:page].split(">").each do |jump|
            @menu_links.has_key?(jump.downcase.gsub(' ', '_').to_sym) ? @ff.link(:href, @menu_links[jump.downcase.gsub(' ', '_').to_sym]).click : @ff.link(:text, jump).click
            confirm
        end
    end

    # Gets the security log from the GUI. 
    def get_security_log
        log_file = []
        log_line = ""
        i = 2
        @user_choices[:page] = "System Monitoring>Advanced Status>System Logging"
        self.page_jump

        while @ff.tables[14].rows[1].cells[1].tables[2].tables[7].row(:index, i).exists?
            log_line = ""
            @ff.tables[14].rows[1].cells[1].tables[2].tables[7].row(:index, i).cells.each { |x| log_line << x.text + " " }
            log_file << log_line.strip
            i += 1
        end
        return log_file
    end

    def table_value
        # Find the table
        v = false
        temp_val = false
        values = []
        @ff.tables.each { |x| v = x if x.text.match(/#{@user_choices[:value][0]}/i) }
        # Find the row
        raise "Found no table related to #{@user_choices[:value][0]}" unless v
        if @user_choices[:index]
            puts "Indexing"
            index_x = 0
            v.each do |x|
                index_y = 0
                x.each { |y| values << "[#{index_x+1}][#{index_y+1}] #{y.text}" unless y.text.empty?; index_y += 1 }
                index_x += 1
            end
            return values
        end
        if @user_choices[:value][1].to_i > 0
            if @user_choices[:value][2].to_i > 0
                values << v[@user_choices[:value][1].to_i][@user_choices[:value][2].to_i].text
            else
                values << v[@user_choices[:value][1].to_i].text
            end
            return values
        else
            v.each { |x| temp_val = x if x.text.match(/#{@user_choices[:value][1]}/i) }
        end
        raise "Found no table related to #{@user_choices[:value][0]}" unless temp_val
        # Interpret
        html = temp_val.innerHTML
        #puts html.inspect
        parsing = true
        while parsing
            case html
            when /<select/i
                temphtml = html.slice!(/<select .*?>/i)
                temphtml.match(/(?:id=|name=)"(.*?)"/i)
                current_id = $1
                $&.match(/id=/i) ? current_tag = :id : current_tag = :name
                values << @ff.select_list(current_tag, current_id).getSelectedItems
            when /checkbox/i
                temphtml = html.slice!(/<input .*type="checkbox".*?>/i)
                temphtml.match(/(?:id=|name=)"(.*?)"/i)
                current_id = $1
                $&.match(/id=/i) ? current_tag = :id : current_tag = :name
                @ff.checkbox(current_tag, current_id).checked? ? values << "TRUE" : values << "FALSE"
            when /text/i
                temphtml = html.slice!(/<input .*type="text".*?>/i)
                temphtml.match(/(?:id=|name=)"(.*?)"/i)
                current_id = $1
                $&.match(/id=/i) ? current_tag = :id : current_tag = :name
                @ff.text_field(current_tag, current_id).value
            when /radio/i
                temphtml = html.slice!(/<input .*type="radio".*?>/i)
                temphtml.match(/(?:id=|name=)"(.*?)"/i)
                current_id = $1
                $&.match(/id=/i) ? current_tag = :id : current_tag = :name
                @ff.radio(current_tag, current_id).checked? ? values << "TRUE" : values << "FALSE"
            else
                parsing = false
            end
        end

        values
    end
    
    def parse
        begin
            login
            if @user_choices[:log]
                puts get_security_log
            else
                page_jump
                puts table_value
            end
        ensure
            logout
        end
    end
end

config_file = ""
config_index = ARGV.index("-f") || ARGV.index("--file")
config_file = ARGV[config_index+1] unless config_index.nil?
GUIParser.new(config_file).parse
