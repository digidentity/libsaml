require 'spec_helper'

describe Saml::Elements::IDPSSODescriptor do
  describe "#single_sign_on_services" do

    it "returns an empty array if no services have been registered" do
      subject.single_sign_on_services.should == []
    end

  end
end