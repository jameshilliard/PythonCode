require 'spec_helper'

describe Server do
    before(:each) do
        @attr = { :ip => "10.1.10.99", :host => "esxdpc999", :connected_to => "BHR2 Rev E" }
    end

    it "should create a new instance given valid attributes" do
        Server.create!(@attr)
    end

    it "should require an IP address"
    it "should set available status to UNKNOWN"
    it "should set HOST to UNKNOWN if not entered"
end
