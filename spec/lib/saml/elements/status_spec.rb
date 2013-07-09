require 'spec_helper'

describe Saml::Elements::Status do
  let(:status) { FactoryGirl.build(:status) }

  describe "Required fields" do
    [:status_code].each do |field|
      it "should have the #{field} field" do
        status.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        status.send("#{field}=", nil)
        status.should_not be_valid
      end
    end
  end

  describe "parse" do
    let(:status_xml) { File.read(File.join('spec','fixtures','logout_response.xml')) }
    let(:status) { Saml::Elements::Status.parse(status_xml, :single => true) }

    it "should parse the Status" do
      status.should be_a(Saml::Elements::Status)
    end

    it "should parse the StatusCode" do
      status.status_code.should be_a(Saml::Elements::StatusCode)
    end
  end
end
