require 'spec_helper'

describe Saml::Elements::SPSSODescriptor do
  describe "#assertion_consumer_services" do

    it "returns an empty array if no services have been registered" do
      expect(subject.assertion_consumer_services).to eq([])
    end

  end

  describe "Optional fields" do
    [:attribute_consuming_services].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        subject.send("#{field}=", nil)
        expect(subject.errors.entries).to eq([]) #be_valid
        subject.send("#{field}=", "")
        expect(subject.errors.entries).to eq([]) #be_valid
      end
    end
  end

  describe "#add_assertion_consumer_service" do
    it 'adds a new assertion consumer service index' do
      subject.add_assertion_consumer_service('binding', 'location', 1, true)
      assertion_consumer_service = subject.assertion_consumer_services.first
      expect(assertion_consumer_service.binding).to eq('binding')
      expect(assertion_consumer_service.location).to eq('location')
      expect(assertion_consumer_service.index).to eq(1)
      expect(assertion_consumer_service.is_default).to eq(true)
    end
  end
end
