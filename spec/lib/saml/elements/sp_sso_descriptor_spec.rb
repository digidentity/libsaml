require 'spec_helper'

describe Saml::Elements::SPSSODescriptor do
  describe "#assertion_consumer_services" do

    it "returns an empty array if no services have been registered" do
      subject.assertion_consumer_services.should == []
    end

  end

  describe "Optional fields" do
    [:attribute_consuming_services].each do |field|
      it "should have the #{field} field" do
        subject.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject.send("#{field}=", nil)
        subject.errors.entries.should == [] #be_valid
        subject.send("#{field}=", "")
        subject.errors.entries.should == [] #be_valid
      end
    end
  end

  describe "#add_assertion_consumer_service" do
    it 'adds a new assertion consumer service index' do
      subject.add_assertion_consumer_service('binding', 'location', 1, true)
      assertion_consumer_service = subject.assertion_consumer_services.first
      assertion_consumer_service.binding.should == 'binding'
      assertion_consumer_service.location.should == 'location'
      assertion_consumer_service.index.should == 1
      assertion_consumer_service.is_default.should == true
    end
  end
end
