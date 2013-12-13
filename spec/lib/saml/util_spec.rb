require 'spec_helper'

class ServiceProvider
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read("spec/fixtures/metadata/service_provider.xml"))
    @private_key       = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/key.pem"))
  end
end

describe Saml::Util do
  let(:service_provider) { ServiceProvider.new }
  let(:signed_message) { "signed xml" }
  let(:message) { FactoryGirl.build :authn_request, issuer: service_provider.entity_id }

  describe "authn_request" do
    describe ".sign_xml" do
      it "calls add_signature on the specified message" do
        message.should_receive(:add_signature)
        described_class.sign_xml message
      end

      it "creates a new signed document" do
        Xmldsig::SignedDocument.should_receive(:new).with(any_args).and_return stub.as_null_object
        described_class.sign_xml message
      end

      context "when a block is given" do
        it "sign is called on the signed document, not on the provider" do
          message.provider.should_not_receive(:sign)
          Xmldsig::SignedDocument.any_instance.should_receive(:sign).and_return signed_message

          described_class.sign_xml(message) do |data, signature_algorithm|
            service_provider.sign signature_algorithm, data
          end
        end
      end

      context "without specifiying a block" do
        it "sign is called on the provider of the specified message" do
          Xmldsig::SignedDocument.any_instance.should_receive(:sign).and_yield(stub, stub)
          message.provider.should_receive(:sign).and_return signed_message

          described_class.sign_xml message
        end
      end
    end
  end

  describe "assertion" do
    let(:assertion) { FactoryGirl.build :assertion, issuer: service_provider.entity_id }
    let(:signed_assertion) { "signed xml" }

    describe ".sign_xml" do
      it "calls add_signature on the specified assertion" do
        assertion.should_receive(:add_signature)
        described_class.sign_xml assertion
      end

      it "creates a new signed document" do
        Xmldsig::SignedDocument.should_receive(:new).with(any_args).and_return stub.as_null_object
        described_class.sign_xml assertion
      end

      context "when a block is given" do
        it "sign is called on the signed document, not on the provider" do
          assertion.provider.should_not_receive(:sign)
          Xmldsig::SignedDocument.any_instance.should_receive(:sign).and_return signed_assertion

          described_class.sign_xml(assertion) do |data, signature_algorithm|
            service_provider.sign signature_algorithm, data
          end
        end
      end

      context "without specifiying a block" do
        it "sign is called on the provider of the specified assertion" do
          Xmldsig::SignedDocument.any_instance.should_receive(:sign).and_yield(stub, stub)
          assertion.provider.should_receive(:sign).and_return signed_assertion

          described_class.sign_xml assertion
        end
      end
    end
  end

  describe ".post" do
    let(:location) { "http://example.com/foo/bar" }
    let(:post_request) { described_class.post location, message }
    let(:net_http) { double.as_null_object }

    before :each do
      Net::HTTP.any_instance.stub(:request) do |request|
        @request = request
        stub(code: "200", body: message.to_xml)
      end
    end

    it "posts the request" do
      Net::HTTP.any_instance.should_receive(:request)
      post_request
    end

    it "knows its path" do
      post_request
      @request.path.should == "/foo/bar"
    end

    it "has a body" do
      post_request
      @request.body.should == message
    end

    it "has default headers" do
      default_headers = { 'Content-Type' => 'text/xml' }

      Net::HTTP::Post.should_receive(:new).with("/foo/bar", default_headers).and_return(net_http)
      post_request
    end

    it "can have additional headers" do
      default_headers     = { 'Content-Type' => 'text/xml' }
      additional_headers  = { "header" => "foo" }

      Net::HTTP::Post.should_receive(:new).with("/foo/bar", {"Content-Type"=>"text/xml", "header"=>"foo"}).and_return(net_http)
      described_class.post location, message, additional_headers
    end

    context "default settings" do
      before do
        Net::HTTP.stub(:new).and_return(net_http)
      end

      it "uses SSL" do
        net_http.should_receive(:use_ssl=).with(true)
        post_request
      end

      it "sets the verify mode to 'VERIFY_PEER'" do
        net_http.should_receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
        post_request
      end

      it "doesn't use the certificate" do
        net_http.should_not_receive(:cert=)
        post_request
      end

      it "doesn't use the private key" do
        net_http.should_not_receive(:key=)
        post_request
      end
    end

    context "with certificate and private key" do
      let(:certificate_file)  { File.join('spec', 'fixtures', 'certificate.pem') }
      let(:key_file)          { File.join('spec', 'fixtures', 'key.pem') }

      before :each do
        Saml::Config.ssl_certificate_file = certificate_file
        Saml::Config.ssl_private_key_file = key_file

        Net::HTTP.stub(:new).and_return(net_http)
      end

      after :each do
        Saml::Config.ssl_certificate_file = nil
        Saml::Config.ssl_private_key_file = nil
      end

      it "sets the certificate" do
        OpenSSL::X509::Certificate.stub(:new).and_return("cert")
        net_http.should_receive(:cert=).with("cert")
        post_request
      end

      it "sets the private key" do
        OpenSSL::PKey::RSA.stub(:new).and_return("key")
        net_http.should_receive(:key=).with("key")
        post_request
      end
    end
  end

  describe ".verify_xml" do
    let(:message) { Saml::Response.new(assertions: [Saml::Assertion.new.tap { |a| a.add_signature },
                                                    Saml::Assertion.new.tap { |a| a.add_signature }]) }
    let(:signed_xml) { Saml::Util.sign_xml(message) }

    it "verifies all the signatures in the file" do
      response = Saml::Response.parse(signed_xml)

      response.provider.should_receive(:verify).exactly(3).times.and_return(true)
      Saml::Util.verify_xml(response, signed_xml)
    end

    it "returns the signed message type" do
      malicious_response = Saml::Response.new(issuer: 'hacked')
      malicious_xml = "<hack>#{signed_xml}#{malicious_response.to_xml}</hack>"
      malicious_xml.gsub!("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", '')
      response = Saml::Response.parse(malicious_xml, single: true)

      Saml::Util.verify_xml(response, malicious_xml).should be_a(Saml::Response)
    end
  end

  describe ".encrypt_assertion" do
    let(:encrypted_assertion) { Saml::Util.encrypt_assertion(Saml::Assertion.new.to_s, service_provider.private_key) }
    it "returns an encrypted assertion object" do
      encrypted_assertion.should be_a Saml::Elements::EncryptedAssertion
    end

    it "is not valid when with no encrypted data" do
      encrypted_assertion.encrypted_data = nil
      encrypted_assertion.should be_invalid
    end
  end
end
