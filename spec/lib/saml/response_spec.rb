require 'spec_helper'

describe Saml::Response do

  let(:response) { build(:response) }

  it "Should be a StatusResponseType" do
    expect(Saml::Response.ancestors).to include Saml::ComplexTypes::StatusResponseType
  end

  describe "Optional fields" do
    [:assertion].each do |field|
      it "should have the #{field} field" do
        expect(response).to respond_to(field)
      end

      it "should allow #{field} to blank" do
        response.send("#{field}=", nil)
        expect(response.errors.entries).to eq([]) #be_valid
        response.send("#{field}=", "")
        expect(response.errors.entries).to eq([]) #be_valid
      end
    end
  end

  describe "parse" do
    let(:response_xml) { File.read(File.join('spec', 'fixtures', 'artifact_response.xml')) }
    let(:response) { Saml::Response.parse(response_xml, :single => true) }

    it "should parse the Response" do
      expect(response).to be_a(Saml::Response)
    end

    it 'parses Assertion elements' do
      aggregate_failures do
        expect(response.assertions.count).to eq 1
        expect(response.assertion).to be_a(Saml::Assertion)
      end
    end

    it "should parse multiple assertions" do
      expect(response.assertions.first).to be_a(Saml::Assertion)
    end

    it "should parse the encrypted assertion" do
      expect(response.encrypted_assertion).to be_a(Saml::Elements::EncryptedAssertion)
    end

    it "should parse multiple encrypted assertions" do
      expect(response.encrypted_assertions.first).to be_a(Saml::Elements::EncryptedAssertion)
    end
  end

  describe 'authn_failed?' do
    it 'returns true if sub status is AUTHN_FAILED' do
      status          = Saml::Elements::Status.new(:status_code => Saml::Elements::StatusCode.new(:value            => Saml::TopLevelCodes::RESPONDER,
                                                                                                  :sub_status_value => Saml::SubStatusCodes::AUTHN_FAILED))
      response.status = status
      expect(response.authn_failed?).to be true
    end

    it 'returns false if sub status is not AUTHN_FAILED' do
      expect(response.authn_failed?).to be false
    end
  end

  describe 'no_authn_context?' do
    it 'returns true if sub status is NO_AUTHN_CONTEXT' do
      status          = Saml::Elements::Status.new(:status_code => Saml::Elements::StatusCode.new(:value            => Saml::TopLevelCodes::RESPONDER,
                                                                                                  :sub_status_value => Saml::SubStatusCodes::NO_AUTHN_CONTEXT))
      response.status = status
      expect(response.no_authn_context?).to be true
    end

    it 'returns false if sub status is not no_authn_context' do
      expect(response.no_authn_context?).to be false
    end
  end

  describe 'request_denied?' do
    it 'returns true if sub status is AUTHN_FAILED' do
      status          = Saml::Elements::Status.new(:status_code => Saml::Elements::StatusCode.new(:value            => Saml::TopLevelCodes::RESPONDER,
                                                                                                  :sub_status_value => Saml::SubStatusCodes::REQUEST_DENIED))
      response.status = status
      expect(response.request_denied?).to be true
    end

    it 'returns false if sub status is not AUTHN_FAILED' do
      expect(response.request_denied?).to be false
    end
  end

  describe '#request_unsupported?' do
    context 'when the sub status is REQUEST_UNSUPPORTED' do
      let(:status_code) { Saml::Elements::StatusCode.new(value: Saml::TopLevelCodes::RESPONDER, sub_status_value: Saml::SubStatusCodes::REQUEST_UNSUPPORTED) }
      let(:status) { Saml::Elements::Status.new(status_code: status_code) }

      before { response.status = status }

      it 'returns true' do
        expect(response.request_unsupported?).to eq true
      end
    end

    context 'when the sub status is NOT REQUEST_UNSUPPORTED' do
      it 'returns false' do
        expect(response.request_unsupported?).to eq false
      end
    end
  end

  describe '#unknown_principal?' do
    context 'when the sub status is UNKNOWN_PRINCIPAL' do
      let(:status_code) { Saml::Elements::StatusCode.new(value: Saml::TopLevelCodes::RESPONDER, sub_status_value: Saml::SubStatusCodes::UNKNOWN_PRINCIPAL) }
      let(:status) { Saml::Elements::Status.new(status_code: status_code) }

      before { response.status = status }

      it 'returns true' do
        expect(response.unknown_principal?).to eq true
      end
    end

    context 'when the sub status is NOT UNKNOWN_PRINCIPAL' do
      it 'returns false' do
        expect(response.unknown_principal?).to eq false
      end
    end
  end

  describe 'assertions' do
    let(:response) do
      response = Saml::Response.new(assertion: Saml::Assertion.new)
      Saml::Response.parse(Saml::Response.parse(response.to_xml, single: true).to_xml)
    end

    it 'only adds 1 assertion' do
      expect(response.assertions.count).to eq(1)
    end
  end

  describe 'encrypt assertions' do
    let(:response) do
      response = Saml::Response.new(assertion: Saml::Assertion.new)
      Saml::Response.parse(Saml::Response.parse(response.to_xml, single: true).to_xml)
    end

    it 'encrypts the assertion' do
      expect {
        response.encrypt_assertions(response.provider.certificate)
      }.to change(response.assertions, :count).by(-1)
      expect(response.encrypted_assertions.count).to eq(1)
    end
  end

  describe 'decrypt assertions' do
    let(:response) do
      response = Saml::Response.new(assertion: Saml::Assertion.new)
      response.encrypt_assertions(response.provider.certificate)
      response
    end

    it 'encrypts the assertion' do
      expect {
        expect {
          response.decrypt_assertions(response.provider.encryption_key)
        }.to change(response.assertions, :count).by(1)
      }.to change(response.encrypted_assertions, :count).by(-1)
    end
  end

  describe 'encrypted assertions' do
    let(:response) { Saml::Response.new(encrypted_assertion: Saml::Elements::EncryptedAssertion.new) }

    it 'should have one encrypted assertion' do
      expect(response.encrypted_assertions.count).to eq(1)
    end

    it 'adds an extra encrypted assertion' do
      response.encrypted_assertions << Saml::Elements::EncryptedAssertion.new
      expect(response.encrypted_assertions.count).to eq(2)
    end
  end

end
