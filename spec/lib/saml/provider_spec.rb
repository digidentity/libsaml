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

    context 'with iterate_certificates_until_verified mode' do
      let(:another_signing_key) do
        OpenSSL::PKey::RSA.new(File.read("spec/fixtures/signing_key.pem"))
      end
      let(:valid_signature) do
        another_signing_key.sign('sha256', signature_base_string)
      end
      let(:signature_base_string) do
        'sing me!'
      end
      before do
        allow(service_provider_with_signing_key).to receive(:iterate_certificates_until_verified?).and_return(true)
      end

      it do
        expect(service_provider_with_signing_key.verify('sha256', valid_signature, signature_base_string)).to eq(true)
      end
    end
  end

  describe "#assertion_consumer_service_url" do
    it "returns the url for the given index" do
      expect(service_provider.assertion_consumer_service_url(0)).to eq("https://sp.example.com/sso/receive_artifact")
    end

    it "returns the url for the default index" do
      expect(service_provider.assertion_consumer_service_url).to eq("https://sp.example.com/sso/receive_artifact_default")
    end

    context "identity and service provider" do
      it "returns the default service provider url" do
        expect(identity_and_service_provider.assertion_consumer_service_url).to eq("https://idpsp.example.com/sp/receive_artifact_default")
      end
    end
  end

  describe "#artifact_resolution_service_url" do
    it "returns the artifact_resolution_service_url" do
      expect(identity_provider.artifact_resolution_service_url(0)).to eq("https://idp.example.com/sso/resolve_artifact")
    end

    it "returns the url for the default index" do
      expect(identity_provider.artifact_resolution_service_url).to eq("https://idp.example.com/sso/resolve_artifact")
    end

    context "identity and service provider" do
      it "returns the default service provider url" do
        expect(identity_and_service_provider.artifact_resolution_service_url).to eq("https://idpsp.example.com/sp/resolve")
      end

      it "with :sp_descriptor returns the default service provider url" do
        expect(identity_and_service_provider.artifact_resolution_service_url(nil, :sp_descriptor)).to eq("https://idpsp.example.com/sp/resolve")
      end

      it "with :idp_descriptor returns the default identity provider url" do
        expect(identity_and_service_provider.artifact_resolution_service_url(nil, :idp_descriptor)).to eq("https://idpsp.example.com/idp/resolve")
      end
    end
  end

  describe "#attribute_consuming_service" do
    it "returns the attribute_consuming_service" do
      expect(service_provider.attribute_consuming_service(0)).to be_a(Saml::Elements::AttributeConsumingService)
    end

    it "returns the attribute_consuming_service for the default index" do
      expect(service_provider.attribute_consuming_service).to be_a(Saml::Elements::AttributeConsumingService)
    end
  end

  describe "#assertion_consumer_service" do
    it "returns the assertion_consumer_service" do
      expect(service_provider.assertion_consumer_service(0)).to be_a(Saml::Elements::SPSSODescriptor::AssertionConsumerService)
    end

    it "returns the assertion_consumer_service for the default index" do
      expect(service_provider.assertion_consumer_service).to be_a Saml::Elements::SPSSODescriptor::AssertionConsumerService
    end
  end

  describe "#attribute_service_url" do
    it "returns the attribute service url for the specified binding" do
      expect(authority_provider.attribute_service_url(Saml::ProtocolBinding::SOAP)).to eq("https://idp.example.com/SAML/AA/URI")
    end
  end

  describe "#assertion_consumer_service_indices" do
    context "when there is an assertion consumer service" do
      it "returns an array with the indices of all assertion consumer services" do
        expect(service_provider.assertion_consumer_service_indices).to eq [ 0, 1 ]
      end
    end

    context "when there isn't an assertion consumer service" do
      it "returns an empty array" do
        service_provider.entity_descriptor.sp_sso_descriptor.assertion_consumer_services = nil
        expect(service_provider.assertion_consumer_service_indices).to eq []
      end
    end
  end

  describe "#certificate" do
    context "when a key name isn't specified" do
      it "returns the first certificate for signing it finds" do
        expect(service_provider.certificate(nil, "signing")).to be_a(OpenSSL::X509::Certificate)
      end
    end

    context "when a key name is specified" do
      it "returns the certificate which contains the specified key name" do
        expect(service_provider.certificate("82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8")).to be_a(OpenSSL::X509::Certificate)
      end
    end

    context "identity and service provider" do
      it "returns the service provider certificate" do
        expect(identity_and_service_provider.certificate("82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing")).to be_a(OpenSSL::X509::Certificate)
        expect(identity_and_service_provider.certificate("22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing")).to be_nil
      end

      it "with :sp_descriptor returns the service provider certificate" do
        expect(identity_and_service_provider.certificate("82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing", :sp_descriptor)).to be_a(OpenSSL::X509::Certificate)
        expect(identity_and_service_provider.certificate("22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing", :sp_descriptor)).to be_nil
      end

      it "with :idp_descriptor returns the identity provider certificate" do
        expect(identity_and_service_provider.certificate("82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing", :idp_descriptor)).to be_nil
        expect(identity_and_service_provider.certificate("22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8", "signing", :idp_descriptor)).to be_a(OpenSSL::X509::Certificate)
      end
    end
  end

  describe '#find_key_descriptor' do
    let(:key_descriptor) { service_provider.find_key_descriptor('22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8', 'encryption', :sp_descriptor) }

    it 'returns a key descriptor'  do
      aggregate_failures do
        expect(key_descriptor).to be_a Saml::Elements::KeyDescriptor
        expect(key_descriptor.key_info.key_name).to eq '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8'
        expect(key_descriptor.use).to eq 'encryption'
      end
    end
  end

  describe '#find_key_descriptors_by_use' do
    let(:key_descriptors) { service_provider.find_key_descriptors_by_use('signing', :sp_descriptor) }

    it 'returns all key descriptors with the specified use'  do
      aggregate_failures do
        expect(key_descriptors.count).to eq 3
        expect(key_descriptors.first).to be_a Saml::Elements::KeyDescriptor
        expect(key_descriptors.first.key_info.key_name).to eq '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8'
        expect(key_descriptors.first.use).to eq 'signing'
        expect(key_descriptors.second).to be_a Saml::Elements::KeyDescriptor
        expect(key_descriptors.second.key_info.key_name).to eq '82cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8'
        expect(key_descriptors.second.use).to eq 'signing'
        expect(key_descriptors.third).to be_a Saml::Elements::KeyDescriptor
        expect(key_descriptors.third.key_info.key_name).to eq '64df07ee8485e04608afd614829f932da3ac6a7c'
        expect(key_descriptors.third.use).to eq 'signing'
      end
    end
  end

  describe "#sign" do
    context "using sha256" do
      it "uses the encryption key to sign" do
        expect(service_provider.sign("sha256", "test")).to eq(service_provider.encryption_key.sign(OpenSSL::Digest::SHA256.new, "test"))
      end

      it "uses the signing key to sign if present" do
        expect(service_provider_with_signing_key.sign("sha256", "test")).to eq(service_provider_with_signing_key.signing_key.sign(OpenSSL::Digest::SHA256.new, "test"))
      end
    end

    context "using sha512" do
      it "uses the encryption key to sign" do
        expect(service_provider.sign("sha512", "test")).to eq(service_provider.encryption_key.sign(OpenSSL::Digest::SHA512.new, "test"))
      end

      it "uses the signing key to sign if present" do
        expect(service_provider_with_signing_key.sign("sha512", "test")).to eq(service_provider_with_signing_key.signing_key.sign(OpenSSL::Digest::SHA512.new, "test"))
      end
    end
  end

  describe "#signing_key" do
    it "returns the encryption key if signing key is not present" do
      expect(service_provider.signing_key).to eq(service_provider.encryption_key)
    end

    it "returns a different key from the encryption key if signing key is present" do
      expect(service_provider_with_signing_key.signing_key).not_to be_nil
      expect(service_provider_with_signing_key.signing_key).not_to eq(service_provider_with_signing_key.encryption_key)
    end
  end

  describe "#single_sign_on_service_url" do
    it "returns the single_sign_on_service_url" do
      expect(identity_provider.single_sign_on_service_url(Saml::ProtocolBinding::HTTP_REDIRECT)).to eq("https://idp.example.com/sso/request")
    end
  end

  describe "#single_logout_service_url" do
    it "returns the single_logout_service_url" do
      expect(identity_provider.single_logout_service_url(Saml::ProtocolBinding::HTTP_REDIRECT)).to eq("https://idp.example.com/sso/logout")
    end

    context "identity and service provider" do
      it "returns the service provider url" do
        expect(identity_and_service_provider.single_logout_service_url(Saml::ProtocolBinding::HTTP_REDIRECT)).to eq("https://idpsp.example.com/sp/logout")
      end

      it "with :sp_descriptor returns the service provider url" do
        expect(identity_and_service_provider.single_logout_service_url(Saml::ProtocolBinding::HTTP_REDIRECT, :sp_descriptor)).to eq("https://idpsp.example.com/sp/logout")
      end

      it "with :idp_descriptor returns the identity provider url" do
        expect(identity_and_service_provider.single_logout_service_url(Saml::ProtocolBinding::HTTP_REDIRECT, :idp_descriptor)).to eq("https://idpsp.example.com/idp/logout")
      end
    end
  end

  describe "#type " do
    it "returns service_provider for the service provider" do
      expect(service_provider.type).to eq("service_provider")
    end

    it "returns identity_provider for the identity provider" do
      expect(identity_provider.type).to eq("identity_provider")
    end

    context "identity and service provider" do
      it "returns identity_and_service_provider for the identity and service provider" do
        expect(identity_and_service_provider.type).to eq("identity_and_service_provider")
      end
    end
  end

  describe "descriptors #descriptor, #sp_descriptor and #idp_descriptor" do
    before { subject.class.send(:public, :descriptor, :sp_descriptor, :idp_descriptor, :aa_descriptor) }

    context "service provider" do
      subject { service_provider }
      it { expect(subject.descriptor).to be_a(Saml::Elements::SPSSODescriptor) }
      it { expect(subject.sp_descriptor).to be_a(Saml::Elements::SPSSODescriptor) }
      it { expect{ subject.idp_descriptor }.to raise_error("Cannot find identity provider with entity_id: https://sp.example.com") }
      it { expect{ subject.aa_descriptor }.to raise_error("Cannot find attribute authority provider with entity_id: https://sp.example.com") }
    end

    context "identity provider" do
      subject { identity_provider }
      it { expect(subject.descriptor).to be_a(Saml::Elements::IDPSSODescriptor) }
      it { expect{ subject.sp_descriptor}.to raise_error("Cannot find service provider with entity_id: https://idp.example.com") }
      it { expect(subject.idp_descriptor).to be_a(Saml::Elements::IDPSSODescriptor) }
      it { expect{ subject.aa_descriptor }.to raise_error("Cannot find attribute authority provider with entity_id: https://idp.example.com") }
    end

    context "identity and service provider" do
      subject { identity_and_service_provider }
      it { expect(subject.descriptor).to be_a(Saml::Elements::SPSSODescriptor) }
      it { expect(subject.sp_descriptor).to be_a(Saml::Elements::SPSSODescriptor) }
      it { expect(subject.idp_descriptor).to be_a(Saml::Elements::IDPSSODescriptor) }
      it { expect{ subject.aa_descriptor }.to raise_error("Cannot find attribute authority provider with entity_id: https://idpsp.example.com") }
    end

    context "authority provider" do
      subject { authority_provider }
      it { expect(subject.descriptor).to be_a(Saml::Elements::AttributeAuthorityDescriptor) }
      it { expect{ subject.sp_descriptor}.to raise_error("Cannot find service provider with entity_id: https://auth.example.com") }
      it { expect{ subject.idp_descriptor }.to raise_error("Cannot find identity provider with entity_id: https://auth.example.com") }
      it { expect(subject.aa_descriptor).to be_a(Saml::Elements::AttributeAuthorityDescriptor) }
    end
  end
end
