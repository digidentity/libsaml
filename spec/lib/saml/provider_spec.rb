require 'spec_helper'

class ServiceProvider
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read("spec/fixtures/metadata/service_provider.xml"))
    @encryption_key = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/key.pem"))
  end
end

class ServiceProviderWithSigningKeys
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read("spec/fixtures/metadata/service_provider_with_signing_keys.xml"))
    @encryption_key = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/key.pem"))
    @signing_key = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/signing_key.pem"))
  end
end

class IdentityProvider
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read("spec/fixtures/metadata/identity_provider.xml"))
    @encryption_key = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/key.pem"))
  end
end

class IdentityAndServiceProvider
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read("spec/fixtures/metadata/identity_and_service_provider.xml"))
    @encryption_key = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/key.pem"))
  end
end

class AuthorityProvider
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read("spec/fixtures/metadata/authority_provider.xml"))
    @encryption_key = OpenSSL::PKey::RSA.new(File.read("spec/fixtures/key.pem"))
  end
end

describe Saml::Provider do
  let(:service_provider) { ServiceProvider.new }
  let(:service_provider_with_signing_key) { ServiceProviderWithSigningKeys.new }
  let(:identity_provider) { IdentityProvider.new }
  let(:authority_provider) { AuthorityProvider.new }
  let(:identity_and_service_provider) { IdentityAndServiceProvider.new }

  describe "#verify" do
    it "clears the OpenSSL error queue after a verification returns false" do
      expect(service_provider_with_signing_key.verify('sha1', 'some-invalid-sigature', 'some-document')).to eq(false)
      expect(OpenSSL.errors).to be_empty
    end
  end

  describe "#assertion_consumer_service_url" do
    it "returns the url for the given index" do
      service_provider.assertion_consumer_service_url(0).should == "https://sp.example.com/sso/receive_artifact"
    end

    it "returns the url for the default index" do
      service_provider.assertion_consumer_service_url.should == "https://sp.example.com/sso/receive_artifact_default"
    end

    context "identity and service provider" do
      it "returns the default service provider url" do
        identity_and_service_provider.assertion_consumer_service_url.should == "https://idpsp.example.com/sp/receive_artifact_default"
      end
    end
  end

  describe "#artifact_resolution_service_url" do
    it "returns the artifact_resolution_service_url" do
      identity_provider.artifact_resolution_service_url(0).should == "https://idp.example.com/sso/resolve_artifact"
    end

    it "returns the url for the default index" do
      identity_provider.artifact_resolution_service_url.should == "https://idp.example.com/sso/resolve_artifact"
    end

    context "identity and service provider" do
      it "returns the default service provider url" do
        identity_and_service_provider.artifact_resolution_service_url.should == "https://idpsp.example.com/sp/resolve"
      end

      it "with :sp_descriptor returns the default service provider url" do
        identity_and_service_provider.artifact_resolution_service_url(nil, :sp_descriptor).should == "https://idpsp.example.com/sp/resolve"
      end

      it "with :idp_descriptor returns the default identity provider url" do
        identity_and_service_provider.artifact_resolution_service_url(nil, :idp_descriptor).should == "https://idpsp.example.com/idp/resolve"
      end
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

  describe "#assertion_consumer_service" do
    it "returns the assertion_consumer_service" do
      service_provider.assertion_consumer_service(0).should be_a(Saml::Elements::SPSSODescriptor::AssertionConsumerService)
    end

    it "returns the assertion_consumer_service for the default index" do
      service_provider.assertion_consumer_service.should be_a Saml::Elements::SPSSODescriptor::AssertionConsumerService
    end
  end

  describe "#attribute_service_url" do
    it "returns the attribute service url for the specified binding" do
      authority_provider.attribute_service_url(Saml::ProtocolBinding::SOAP).should == "https://idp.example.com/SAML/AA/URI"
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

    context "identity and service provider" do
      it "returns the service provider certificate" do
        identity_and_service_provider.certificate("82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing").should be_a(OpenSSL::X509::Certificate)
        identity_and_service_provider.certificate("22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing").should be_nil
      end

      it "with :sp_descriptor returns the service provider certificate" do
        identity_and_service_provider.certificate("82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing", :sp_descriptor).should be_a(OpenSSL::X509::Certificate)
        identity_and_service_provider.certificate("22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing", :sp_descriptor).should be_nil
      end

      it "with :idp_descriptor returns the identity provider certificate" do
        identity_and_service_provider.certificate("82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing", :idp_descriptor).should be_nil
        identity_and_service_provider.certificate("22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing", :idp_descriptor).should be_a(OpenSSL::X509::Certificate)
      end
    end
  end

  describe "#sign" do
    it "uses the encryption key to sign" do
      service_provider.sign("sha256", "test").should == service_provider.encryption_key.sign(OpenSSL::Digest::SHA256.new, "test")
    end

    it "uses the signing key to sign if present" do
      service_provider_with_signing_key.sign("sha256", "test").should == service_provider_with_signing_key.signing_key.sign(OpenSSL::Digest::SHA256.new, "test")
    end
  end

  describe "#signing_key" do
    it "returns the encryption key if signing key is not present" do
      service_provider.signing_key.should == service_provider.encryption_key
    end

    it "returns a different key from the encryption key if signing key is present" do
      service_provider_with_signing_key.signing_key.should_not be_nil
      service_provider_with_signing_key.signing_key.should_not == service_provider_with_signing_key.encryption_key
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

    context "identity and service provider" do
      it "returns the service provider url" do
        identity_and_service_provider.single_logout_service_url(Saml::ProtocolBinding::HTTP_REDIRECT).should == "https://idpsp.example.com/sp/logout"
      end

      it "with :sp_descriptor returns the service provider url" do
        identity_and_service_provider.single_logout_service_url(Saml::ProtocolBinding::HTTP_REDIRECT, :sp_descriptor).should == "https://idpsp.example.com/sp/logout"
      end

      it "with :idp_descriptor returns the identity provider url" do
        identity_and_service_provider.single_logout_service_url(Saml::ProtocolBinding::HTTP_REDIRECT, :idp_descriptor).should == "https://idpsp.example.com/idp/logout"
      end
    end
  end

  describe "#type " do
    it "returns service_provider for the service provider" do
      service_provider.type.should == "service_provider"
    end

    it "returns identity_provider for the identity provider" do
      identity_provider.type.should == "identity_provider"
    end

    context "identity and service provider" do
      it "returns identity_and_service_provider for the identity and service provider" do
        identity_and_service_provider.type.should == "identity_and_service_provider"
      end
    end
  end

  describe "descriptors #descriptor, #sp_descriptor and #idp_descriptor" do
    before { subject.class.send(:public, :descriptor, :sp_descriptor, :idp_descriptor, :aa_descriptor) }

    context "service provider" do
      subject { service_provider }
      it { subject.descriptor.should be_a(Saml::Elements::SPSSODescriptor) }
      it { subject.sp_descriptor.should be_a(Saml::Elements::SPSSODescriptor) }
      it { expect{ subject.idp_descriptor }.to raise_error("Cannot find identity provider with entity_id: https://sp.example.com") }
      it { expect{ subject.aa_descriptor }.to raise_error("Cannot find attribute authority provider with entity_id: https://sp.example.com") }
    end

    context "identity provider" do
      subject { identity_provider }
      it { subject.descriptor.should be_a(Saml::Elements::IDPSSODescriptor) }
      it { expect{ subject.sp_descriptor}.to raise_error("Cannot find service provider with entity_id: https://idp.example.com") }
      it { subject.idp_descriptor.should be_a(Saml::Elements::IDPSSODescriptor) }
      it { expect{ subject.aa_descriptor }.to raise_error("Cannot find attribute authority provider with entity_id: https://idp.example.com") }
    end

    context "identity and service provider" do
      subject { identity_and_service_provider }
      it { subject.descriptor.should be_a(Saml::Elements::SPSSODescriptor) }
      it { subject.sp_descriptor.should be_a(Saml::Elements::SPSSODescriptor) }
      it { subject.idp_descriptor.should be_a(Saml::Elements::IDPSSODescriptor) }
      it { expect{ subject.aa_descriptor }.to raise_error("Cannot find attribute authority provider with entity_id: https://idpsp.example.com") }
    end

    context "authority provider" do
      subject { authority_provider }
      it { subject.descriptor.should be_a(Saml::Elements::AttributeAuthorityDescriptor) }
      it { expect{ subject.sp_descriptor}.to raise_error("Cannot find service provider with entity_id: https://auth.example.com") }
      it { expect{ subject.idp_descriptor }.to raise_error("Cannot find identity provider with entity_id: https://auth.example.com") }
      it { subject.aa_descriptor.should be_a(Saml::Elements::AttributeAuthorityDescriptor) }
    end
  end
end
