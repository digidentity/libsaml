require 'spec_helper'

describe Saml::Elements::StatusCode do
  let(:status_code) { FactoryBot.build(:status_code) }

  describe "Required fields" do
    [:value].each do |field|
      it "should have the #{field} field" do
        expect(status_code).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        status_code.send("#{field}=", nil)
        expect(status_code).not_to be_valid
      end
    end
  end

  describe "value" do
    it "should not be valid with an invalid value" do
      status_code.value = "invalid"
      expect(status_code).not_to be_valid
    end

    it "should be valid if value is in Error list" do
      Saml::TopLevelCodes::ALL.each do |error|
        status_code.value = error
        expect(status_code).to be_valid
      end
    end
  end

  describe "substatus" do
    let(:status) { Saml::Elements::StatusCode.new(:value            => "urn:oasis:names:tc:SAML:2.0:status:Requester",
                                                  :sub_status_value => "urn:oasis:names:tc:SAML:2.0:status:NoAuthnContext") }
    it "should allow a substatus" do
      expect(status.sub_status_code).not_to be_blank
    end
  end

  describe "parse" do
    let(:status_code_xml) { File.read(File.join('spec', 'fixtures', 'logout_response.xml')) }
    let(:status_code) { Saml::Elements::StatusCode.parse(status_code_xml, :single => true) }

    it "should parse the StatusCode" do
      expect(status_code).to be_a(Saml::Elements::StatusCode)
    end

    it "should parse the value" do
      expect(status_code.value).to eq(Saml::TopLevelCodes::SUCCESS)
    end
  end
end
