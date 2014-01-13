# == Copyright
# (c) 2011 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born
require 'tr69_server_commands'

# Ruby 1.8.7 doesn't support public_send. 
class Object
  def public_send(name, *args)
    unless public_methods.include?(name.to_s)
      raise NoMethodError.new("undefined method `#{name}' for \"#{self.inspect}\":#{self.class}")
    end
    send(name, *args)
  end
end

class CommunicationInterface < EventMachine::Connection
  include EM::P::LineText2
  include TR69ServerCommands
  attr_accessor :server, :client_id

  def post_init
    @device_serial = ""
    @operation_type = ""
    @parameter_list = []
    @client_id = Socket.unpack_sockaddr_in(self.get_peername).join "_"
    @client_id << "_#{rand(65535)}"
    @gcl = false
    @relay_log = false
    @prompt = true
    logger.info "#{client_id} connected"
    send_line "Welcome #{client_id}. TR69Server #{TR69SERVER_VERSION.join('.')}"
    send_prompt
  end

  def motive
    server.get_motive_session(@client_id, @relay_log)
  end

  def receive_line data
    case data
    when /^\//i
      parse_command data.strip
    when /^pong$/i
      # Do nothing
    when "\n"
      send_prompt
    else
      @cmd = data.slice(/^.*?(?=\s|$)/).strip
      param = data.slice(/\s.*$/) # All methods should take none, or one parameter
      if respond_to?(@cmd)
        public_send(@cmd, param.strip) if param
        public_send(@cmd) unless param
        send_prompt
        @cmd = ""
      else
        acknowledge false, "INVALID"
        send_prompt
      end
    end
  end

  def parse_command cmd
    case cmd
    when /server_shutdown/i
      server.shutdown
    when /quit/i
      close_connection
    else
      send_line "No such command: #{cmd}"
    end
    send_prompt
  end

  def acknowledge(success, message="")
    logger.debug((success ? "OK #{@cmd} #{message}" : "ERR #{@cmd} #{message}"))
    send_line((success ? "OK #{@cmd} #{message}" : "ERR #{@cmd} #{message}"))
  end

  def keep_alive
    send_line "PING"
  end

  def send_line data
    send_data "#{data}\n"
  end

  def send_prompt
    send_data "TR69Server# " if @prompt
  end

  def unbind
    logger.info "#{client_id} disconnected"
    server.remove_motive_session(@client_id)
    server.connections.delete(self)
  end
end
