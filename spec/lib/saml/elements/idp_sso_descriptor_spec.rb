require 'spec_helper'

describe Saml::Elements::IDPSSODescriptor do
  describe "#single_sign_on_services" do

    it "returns an empty array if no services have been registered" do
      expect(subject.single_sign_on_services).to eq([])
    end

  end

  describe "Optional fields" do
    [:want_authn_requests_signed].each do |field|
      it "should have the #{field} field" do
        expect(subject).to respond_to(field)
      end
    end
  end
end
