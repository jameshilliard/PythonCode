require 'xmlrpc/client'

# TestLink 1.9.1 returns some hashes differently than the prior version (1.9.0).
# It's basically another nested hash to run through, but we don't want to do that so often.
# This will allow one to "crush" the hash together and keep the innermost hash values only. 
class Hash
  def crush(joiner=".", &block)
    flat = combine_keys(self, joiner, [], &block).flatten
    Hash[*flat.map {|f| f.to_a}.flatten]
  end
  def crush!(joiner=".", &block)
    flat = combine_keys(self, joiner, [], &block).flatten
    tmp = Hash[*flat.map {|f| f.to_a}.flatten]
    replace(tmp)
  end
private
  def combine_keys(data, joiner=".", prefix=[], &block)
    if data.respond_to?(:keys)
      data.keys.collect do |key|
        combine_keys(data[key], joiner, [prefix, key], &block)
      end.flatten
    else
      return nil if block_given? && !yield(data)
      [prefix.flatten.last => data]
    end
  end
end

class TestLink
  attr_accessor :username, :password, :user_id, :default_project_id, :apikey, :server
  def initialize(values={})
    @username = values[:username] || "automation"
    @password = values[:password] || "actiontec"
    @user_id = values[:user_id] || "49"
    @default_project_id = values[:default_project_id] || "11868"
    @apikey = values[:apikey] || "8499431de840d7b56194132964e97709"
    @params = { "devKey" => @apikey }
    @server = values[:server] || "http://10.206.1.21/testlink/lib/api/xmlrpc.php"
    @testlink_server = XMLRPC::Client.new2(@server)
  end

  def method_missing(name, *args)
    call_results = @testlink_server.call("tl.#{name}", (args[0] ? @params.merge(args[0]) : @params))
    return "invalid apikey" if call_results[0]["message"].match(/invalid developer key/i) if call_results[0].has_key?("message") if call_results.is_a?(Array)
    return call_results
  end

  # Finds an ID by a name from a given array of hashes from TestLink
  def id_of(name, obj)
    return nil unless obj
    return nil if obj == "invalid apikey" if obj.is_a?(String)
    return nil if obj.empty?
    id = nil

    if obj["name"].match(/#{name}/i)
      return obj["id"]
    else
      return false
    end if obj.has_key?("id") if obj.is_a?(Hash)

    obj.each do |object|
      # Check exact
      id = object["id"] if object["name"].match(/#{name}/i) if object.is_a?(Hash)
      id = object.last["id"] if object.last["name"].match(/#{name}/i) if object.is_a?(Array)
      
      # Check with no spaces
      id = object["id"] if object["name"].delete(' ').match(/#{name}/i) if object.is_a?(Hash)
      id = object.last["id"] if object.last["name"].delete(' ').match(/#{name}/i) if object.is_a?(Array)
    end
    return id
  end

  # Finds the name of an ID from the passed object
  def name_of(id, obj)
    return nil unless obj
    return nil if obj == "invalid apikey" if obj.is_a?(String)
    return nil if obj.empty?
    object_name = nil

    if obj["id"].match(/#{id}/i)
      return obj["name"]
    else
      return false
    end if obj.has_key?("name") if obj.is_a?(Hash)

    obj.each do |object|
      # Check exact
      object_name = object["name"] if object["id"].match(/#{id}/i) if object.is_a?(Hash)
      object_name = object.last["name"] if object.last["id"].match(/#{id}/i) if object.is_a?(Array)

      # Check with no spaces
      object_name = object["name"] if object["id"].delete(' ').match(/#{id}/i) if object.is_a?(Hash)
      object_name = object.last["name"] if object.last["id"].delete(' ').match(/#{id}/i) if object.is_a?(Array)
    end
    return object_name
  end
end