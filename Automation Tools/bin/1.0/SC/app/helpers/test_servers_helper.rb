module TestServersHelper
  def human_readable_idle(i)
    # We're only allowing for 3 states - unknown, available, and busy
    # Return unknown if outside the range of 0 to 2
    return "Unknown" unless (0..(SERVER_STATES.length-1)) === i
    return SERVER_STATES[i]
  end
  
  def idle_class(i)
    return "unknown" unless (0..(SERVER_STATES.length-1)) === i
    return SERVER_STATES[i].downcase
  end

  def state_action_button(i)
 
  end
end
