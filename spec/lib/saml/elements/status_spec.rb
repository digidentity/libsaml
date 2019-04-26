require 'spec_helper'

describe Saml::Elements::Status do
  let(:status) { FactoryBot.build(:status) }

  describe "Required fields" do
    [:status_code].each do |field|
      it "should have the #{field} field" do
        expect(status).to respond_to(field)
      end

      it "should check the presence of #{field}" do
        status.send("#{field}=", nil)
        expect(status).not_to be_valid
      end
    end
  end

  describe "parse" do
    let(:status_xml) { File.read(File.join('spec','fixtures','logout_response.xml')) }
    let(:status) { Saml::Elements::Status.parse(status_xml, single: true) }

    it "should parse the Status" do
      expect(status).to be_a(Saml::Elements::Status)
    end

    it "should parse the StatusCode" do
      expect(status.status_code).to be_a(Saml::Elements::StatusCode)
    end

    it "should parse the StatusDetail" do
      expect(status.status_detail).to be_a(Saml::Elements::StatusDetail)
    end

    it 'should parse the StatusMessage' do
      expect(status.status_message).to eq 'some message'
    end
  end
end
