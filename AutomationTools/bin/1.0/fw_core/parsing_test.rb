#!/usr/bin/env ruby
# Quick demonstration of parsing some simple commands/modules
require 'yaml'
require 'rubygems'
require 'httparty'
require 'json'

class SCUpdate
  attr_reader :response
  include HTTParty
  headers 'content-type' => 'application/json'

  def initialize(server_uri)
    @response = nil
    @server_uri = server_uri
  end
  def server_state(servid, state)
    @response = self.class.put("#{@server_uri}/test_servers/#{servid}.json", :body => "{'test_server':#{JSON.generate({:state => state})}}")
  end
  def tc_update(tcid, result)
    @response = self.class.put("#{@server_uri}/test_cases/#{tcid}.json", :body => "{'test_case':#{JSON.generate({:result => result})}}")
  end
end

class Jail
  def initialize
    @loaded_modules = []
  end
  def extension(mod)
    unless @loaded_modules.include?(mod)
      load "testmodules/#{underscore(mod)}.rb"
      extend(Object.const_get(mod))
      @loaded_modules << mod
    end
  end
  
  private
  # Borrowing from inflector within ActiveSupport 3.0.x, since the methods work as is
  # really no point in rewriting a regexp sub method from scratch to do it
  def underscore(camel_cased_word)
    word = camel_cased_word.to_s.dup
    word.gsub!(/::/, '/')
    word.gsub!(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
    word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
    word.tr!("-", "_")
    word.downcase!
    word
  end
  # Same for this
  def camelize(lower_case_and_underscored_word, first_letter_in_uppercase = true)
    if first_letter_in_uppercase
      lower_case_and_underscored_word.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
    else
      lower_case_and_underscored_word.to_s[0].chr.downcase + camelize(lower_case_and_underscored_word)[1..-1]
    end
  end
end

# Parses attributes with the coded keys
def parse_attributes(attribute_string)
  keywords = %w{with using and given}
  parsed_attributes = {}
  found_attributes = []
  while attribute_string.slice(/(#{keywords.join('|')})\s+\w*\s+\w*/)
    found_attributes << attribute_string.slice!(/(#{keywords.join('|')})\s+\w*\s+\w*/)
  end
  found_attributes.each {|fa| parsed_attributes[fa.slice(/\s\w*/).strip.to_sym] = fa.slice(/\w*\z/)}
  return parsed_attributes
end

# Read our files in
definitions = YAML::load_file("test.yml")
jail = Jail.new
definitions[:required].each {|r| require r } if definitions.has_key?(:required)

puts "Waiting for testing assignments ..."
while(true)
  if File.exists?("/home/cborn/automation/bin/1.0/fw_core/testing_assignment.tst")
    puts "Beginning testing"
    test_functions = YAML::load_file("/home/cborn/automation/bin/1.0/fw_core/testing_assignment.tst")
    testing = SCUpdate.new("http://localhost:3000")
    testing.server_state(test_functions[:server_id], "Busy")

    test_functions[:test_cases].each do |tc_id, tc_steps|
      result = true
      tc_steps.each do |t|
        module_method = t.slice(/\A\w*/).downcase
        definitions[:modules].each do |mod,functions|
          if functions.has_key?(module_method.to_sym)
            jail.extension(mod)
            if functions[module_method.to_sym].has_key?(:before_execution)
              jail.extension(functions[module_method.to_sym][:before_execution][:module][:name])
              functions[module_method.to_sym][:before_execution][:module][:actions].each do |act|
                jail.__send__(act)
              end
            end
            result ? jail.__send__(functions[module_method.to_sym][:method], parse_attributes(t)) : false
            if functions[module_method.to_sym].has_key?(:after_execution)
              jail.extension(functions[module_method.to_sym][:after_execution][:module][:name])
              functions[module_method.to_sym][:after_execution][:module][:actions].each do |act|
                jail.__send__(act)
              end
            end
          end
        end
      end
      testing.tc_update(tc_id, result ? "Passed" : "Failed")
    end
    testing.server_state(test_functions[:server_id], "Pending")
    system("rm -f /home/cborn/automation/bin/1.0/fw_core/testing_assignment.tst")
  end
end