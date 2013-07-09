require 'spec_helper'

describe Saml::Elements::SPSSODescriptor do
  describe "#assertion_consumer_services" do

    it "returns an empty array if no services have been registered" do
      subject.assertion_consumer_services.should == []
    end

  end
end