require 'spec_helper'

describe Saml::LogoutRequest do
  let(:logout_request) { build(:logout_request) }

  it "Should be a RequestAbstractType" do
    Saml::LogoutRequest.ancestors.should include Saml::ComplexTypes::RequestAbstractType
  end

  it 'responds to xml_value' do
    expect(logout_request).to respond_to :xml_value
  end

  describe "Optional fields" do
    [:not_on_or_after, :session_index].each do |field|
      it "should have the #{field} field" do
        logout_request.should respond_to(field)
      end

      it "should allow #{field} to blank" do
        logout_request.send("#{field}=", nil)
        logout_request.should be_valid
        logout_request.send("#{field}=", "")
        logout_request.should be_valid
      end
    end
  end

  describe "Required fields" do
    [:name_id].each do |field|
      it "should have the #{field} field" do
        logout_request.should respond_to(field)
      end

      it "should check the presence of #{field}" do
        logout_request.send("#{field}=", nil)
        logout_request.should_not be_valid
      end
    end
  end

  describe "#parse" do

    let(:logout_request_xml) { File.read(File.join('spec','fixtures','logout_request.xml')) }
    let(:logout_request) { Saml::LogoutRequest.parse(logout_request_xml) }

    it "should create an LogoutRequest" do
      logout_request.should be_a(Saml::LogoutRequest)
    end

    it "should parse name_id" do
      logout_request.name_id.should == "s00000000:123456789"
    end

    it "should parse session_index" do
      logout_request.session_index.should == "123456789123456789123456789123456789"
    end
  end

  describe ".to_xml" do
    let(:logout_request_xml) { File.read(File.join('spec','fixtures','logout_request.xml')) }
    let(:logout_request) { Saml::LogoutRequest.parse(logout_request_xml, :single => true) }
    let(:new_logout_request_xml) { logout_request.to_xml }
    let(:new_logout_request) { Saml::LogoutRequest.parse(new_logout_request_xml) }

    it "should generate a parseable XML document" do
      new_logout_request.should be_a(Saml::LogoutRequest)
    end
  end
end
