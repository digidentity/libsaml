require 'spec_helper'

describe Saml::AuthnRequest do

  let(:authn_request) { build(:authn_request, issuer: "https://sp.example.com") }

  it "Should be a RequestAbstractType" do
    Saml::AuthnRequest.ancestors.should include Saml::ComplexTypes::RequestAbstractType
  end

  it "should have tag AuthnRequest" do
    Saml::AuthnRequest.tag_name.should == "AuthnRequest"
  end

  [:force_authn, :assertion_consumer_service_index, :assertion_consumer_service_url, :protocol_binding, :provider_name, :requested_authn_context, :is_passive, :scoping].each do |attribute|
    it "should accept the #{attribute} attribute" do
      authn_request.should respond_to(attribute)
    end
  end

  describe "validations" do
    it "should allow empty force_authn" do
      authn_request.force_authn = nil
      authn_request.should be_valid
    end

    it "should check for boolean field if force authn is set" do
      authn_request.force_authn = true
      authn_request.should be_valid
      authn_request.force_authn = false
      authn_request.should be_valid
      authn_request.force_authn = "not a boolean"
      authn_request.should_not be_valid
    end

    it "should check the assertion_consumer_service index for numericality" do
      authn_request.assertion_consumer_service_index = 1
      authn_request.should be_valid
      authn_request.assertion_consumer_service_index = "a"
      authn_request.should_not be_valid
    end

    it "should check for mutually exclusion for assertion consumer service index and assertion consumer url" do
      authn_request.assertion_consumer_service_index = 1
      authn_request.assertion_consumer_service_url   = "not_allowed"
      authn_request.should_not be_valid
    end

    it "should check for mutually exclusion for assertion consumer service index and assertion consumer url" do
      authn_request.assertion_consumer_service_index = 1
      authn_request.protocol_binding                 = "not_allowed"
      authn_request.should_not be_valid
    end
  end

  describe "#parse" do

    let(:authn_request_xml) { File.read(File.join('spec', 'fixtures', 'authn_request.xml')) }
    let(:authn_request) { Saml::AuthnRequest.parse(authn_request_xml) }

    it "should create an AuthnRequest" do
      authn_request.should be_a(Saml::AuthnRequest)
    end

    it "should parse assertion_consumer_service_index" do
      authn_request.assertion_consumer_service_index.should == 1
    end

    it "should parse ForceAuthn" do
      authn_request.force_authn.should == false
    end

    it "should parse the provider name" do
      authn_request.provider_name == "Provider"
    end

    it "should create an Saml::Elements::RequestedAuthnContext" do
      authn_request.requested_authn_context.should be_a(Saml::Elements::RequestedAuthnContext)
    end

    it 'should create a Saml::Elements::Scoping' do
      expect(authn_request.scoping).to be_a(Saml::Elements::Scoping)
    end

    context "with two requested_authn_context_class_refs" do
      let(:authn_request_xml) { File.read(File.join('spec', 'fixtures', 'authn_request_with_two_authn_contexts.xml'))}

      it "should create an array of two AuthnContextClassRefs" do
        authn_request.requested_authn_context.authn_context_class_refs.should ==
            %w(urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport urn:oasis:names:tc:SAML:2.0:ac:classes:MobileTwoFactorUnregistered)
      end
    end

  end

  describe ".to_xml" do
    let(:authn_request_xml) { File.read(File.join('spec', 'fixtures', 'authn_request.xml')) }
    let(:authn_request) { Saml::AuthnRequest.parse(authn_request_xml) }
    let(:new_authn_request_xml) { authn_request.to_xml }
    let(:new_authn_request) { Saml::AuthnRequest.parse(new_authn_request_xml) }

    it "should generate a parseable XML document" do
      new_authn_request.should be_a(Saml::AuthnRequest)
    end
  end

  describe "NameIDPolicy element test on AuthnRequest" do
    let(:authn_request_xml) { File.read(File.join('spec', 'fixtures', 'authn_request_with_name_id_policy.xml')) }
    let(:authn_request) { Saml::AuthnRequest.parse(authn_request_xml) }
    let(:new_authn_request_xml) { authn_request.to_xml }
    let(:new_authn_request) { Saml::AuthnRequest.parse(new_authn_request_xml) }

    it "NameIDPolicy element should have correct values" do
      new_authn_request.name_id_policy.allow_create.should == true
      new_authn_request.name_id_policy.format.should == 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'
    end
  end

  describe "#assertion_url" do

    it "returns the url as specified" do
      described_class.new(assertion_consumer_service_url: "http://example.com").
          assertion_url.should == "http://example.com"
    end

    it "uses the assertion consumer service index" do
      described_class.new(issuer: "https://sp.example.com", assertion_consumer_service_index: 0).
          assertion_url.should == "https://sp.example.com/sso/receive_artifact"
    end

  end

end
