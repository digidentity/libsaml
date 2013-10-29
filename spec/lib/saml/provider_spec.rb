require 'spec_helper'

class ServiceProvider
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read("spec/fixtures/metadata/service_provider.xml"))
    @private_key = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/key.pem"))
  end
end

class IdentityProvider
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read("spec/fixtures/metadata/identity_provider.xml"))
    @private_key = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/key.pem"))
  end
end

describe Saml::Provider do
  let(:service_provider) { ServiceProvider.new }
  let(:identity_provider) { IdentityProvider.new }

  describe "#assertion_consumer_service_url" do
    it "returns the url for the given index" do
      service_provider.assertion_consumer_service_url(0).should == "https://sp.example.com/sso/receive_artifact"
    end

    it "returns the url for the default index" do
      service_provider.assertion_consumer_service_url.should == "https://sp.example.com/sso/receive_artifact_default"
    end
  end

  describe "#artifact_resolution_service_url" do
    it "returns the artifact_resolution_service_url" do
      identity_provider.artifact_resolution_service_url(0).should == "https://idp.example.com/sso/resolve_artifact"
    end

    it "returns the url for the default index" do
      identity_provider.artifact_resolution_service_url.should == "https://idp.example.com/sso/resolve_artifact"
    end
  end

  describe "#attribute_consuming_service" do
    it "returns the attribute_consuming_service" do
      service_provider.attribute_consuming_service(0).should be_a(Saml::Elements::AttributeConsumingService)
    end

    it "returns the attribute_consuming_service for the default index" do
      service_provider.attribute_consuming_service.should be_a(Saml::Elements::AttributeConsumingService)
    end
  end

  describe "#assertion_consumer_service_indices" do
    context "when there is an assertion consumer service" do
      it "returns an array with the indices of all assertion consumer services" do
        service_provider.assertion_consumer_service_indices.should eq [ 0, 1 ]
      end
    end

    context "when there isn't an assertion consumer service" do
      it "returns an empty array" do
        service_provider.entity_descriptor.sp_sso_descriptor.assertion_consumer_services = nil
        service_provider.assertion_consumer_service_indices.should eq []
      end
    end
  end

  describe "#certificate" do
    context "when a key name isn't specified" do
      it "returns the first certificate for signing it finds" do
        service_provider.certificate(nil, "signing").should be_a(OpenSSL::X509::Certificate)
      end
    end

    context "when a key name is specified" do
      it "returns the certificate which contains the specified key name" do
        service_provider.certificate("82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8").should be_a(OpenSSL::X509::Certificate)
      end
    end
  end

  describe "#sign" do
    it "uses the private key to sign" do
      service_provider.sign("sha256", "test").should == service_provider.private_key.sign(OpenSSL::Digest::SHA256.new, "test")
    end
  end

  describe "#single_sign_on_service_url" do
    it "returns the single_sign_on_service_url" do
      identity_provider.single_sign_on_service_url(Saml::ProtocolBinding::HTTP_REDIRECT).should == "https://idp.example.com/sso/request"
    end
  end

  describe "#single_logout_service_url" do
    it "returns the single_logout_service_url" do
      identity_provider.single_logout_service_url(Saml::ProtocolBinding::HTTP_REDIRECT).should == "https://idp.example.com/sso/logout"
    end
  end

  describe "#type " do
    it "returns service_provider for the service provider" do
      service_provider.type.should == "service_provider"
    end

    it "returns identity_provider for the identity provider" do
      identity_provider.type.should == "identity_provider"
    end
  end

end
