require 'spec_helper'

describe Saml::LogoutResponse do
  it "Should be a RequestAbstractType" do
    Saml::LogoutResponse.ancestors.should include Saml::ComplexTypes::StatusResponseType
  end

  let(:logout_response_xml) { File.read(File.join('spec','fixtures','logout_response.xml')) }
  let(:response) { Saml::LogoutResponse.parse(logout_response_xml) }

  describe ".to_xml" do
    it "should generate a parseable XML document" do
      response.should be_a(Saml::LogoutResponse)
    end
  end

  describe 'partial_logout?' do
    it 'returns true if sub status is PARTIAL_LOGOUT' do
      status          = Saml::Elements::Status.new(:status_code => Saml::Elements::StatusCode.new(:value            => Saml::TopLevelCodes::RESPONDER,
                                                                                                  :sub_status_value => Saml::SubStatusCodes::PARTIAL_LOGOUT))
      response.status = status
      response.partial_logout?.should be_true
    end

    it 'returns false if sub status is not PARTIAL_LOGOUT' do
      response.partial_logout?.should be_false
    end
  end
end
