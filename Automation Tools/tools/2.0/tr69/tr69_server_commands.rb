# == Copyright
# (c) 2011 Actiontec Electronics, Inc.
# Confidential. All rights reserved.
# == Author
# Chris Born
module TR69ServerCommands
  public
  def disable_prompt
    @prompt = false
  end
  def enable_prompt
    @prompt = true
  end
  def device d
    @device_serial = d
    acknowledge true, @device_serial
  end

  def contact_time
    @operation_type = "last_contact_time"
    @parameter_list =["NoneRequired"]
    acknowledge true
    execute_get_info
  end

  def parameter p
    @parameter_list << p.strip
    acknowledge true, p
  end

  def comm_log
    @gcl = true
    acknowledge true
  end

  def relay_log
    @relay_log = self
    acknowledge true
  end

  def expiration t
    motive.expiration_timeout = t.to_i
    acknowledge true, t
  end

  def operation op
    acknowledge (motive.supported_operation?(op) ? (@operation_type = motive.operation_name(op)) : false), op
  end

  def execute
    if verified_data
      acknowledge true
      results_op = proc {
        motive.process(@client_id, @device_serial, @operation_type, @parameter_list, @gcl)
      }

      results_cb = proc {|completed|
        if completed
          logger.info "Sending results to client"
          send_line "[BEGIN RESULT LOG]"
          if motive.logs[:results].is_a?(Hash)
            motive.logs[:results].each_pair do |key_name, key_data|
              if key_data.is_a?(Array)
                unless key_data.empty?
                  send_line "#{key_name}"
                  key_data.each {|v| send_line v}
                end
              else
                send_line "#{key_name} = #{key_data}"
              end
            end
          elsif motive.logs[:results].is_a?(Array)
            motive.logs[:results].each {|v| send_line v}
          else
            send_line motive.logs[:results]
          end
          send_line "\n[END RESULT LOG]"

          if @gcl
            logger.info "Sending communication logs to client"
            send_line "[BEGIN COMM LOG]"
            motive.logs[:comm_log].delete("\r").split("\n").each { |l| send_line l unless l.strip.empty? }
            send_line "\n[END COMM LOG]"
          end
          logger.info "Logs and results have been sent"
          logger.info "Finished queue process"
          send_line "Finished processing"
        end
      }

      EventMachine.defer(results_op, results_cb)
    else
      acknowledge false
    end
  end

  private
  def verified_data
    if @device_serial.empty?
      send_line "No device serial entered. Execution refused!"
      send_prompt
      return false
    end
    if @operation_type.empty?
      send_line "No operation type specified. Set with \"operation: type\"."
      send_line "Execution refused!"
      send_prompt
      return false
    end
    if @parameter_list.empty?
      send_line "No parameters entered. Please add some."
      send_prompt
      return false
    end
    return true
  end

  def execute_get_info
    if verified_data
      results_op = proc {
        motive.process(@client_id, @device_serial, @operation_type, @parameter_list)
      }

      results_cb = proc {|completed|
        if completed
          logger.info "Sending results to client"
          send_line "Last contact time was: #{motive.logs[:results]}"

          logger.info "Logs and results have been sent"
          logger.info "Finished queue process"
          send_line "Finished processing"
        end
      }

      EventMachine.defer(results_op, results_cb)
    else 
      acknowledge false
    end
  end
end
