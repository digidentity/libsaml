require 'spec_helper'

class ServiceProvider
  include Saml::Provider

  def initialize
    @entity_descriptor = Saml::Elements::EntityDescriptor.parse(File.read('spec/fixtures/metadata/service_provider.xml'))
    @encryption_key    = OpenSSL::PKey::RSA.new(File.read('spec/fixtures/key.pem'))
  end
end

describe Saml::Util do
  let(:service_provider) { ServiceProvider.new }
  let(:signed_message) { 'signed xml' }
  let(:message) { FactoryBot.build :authn_request, issuer: service_provider.entity_id }

  describe 'authn_request' do
    describe '.sign_xml' do
      it 'calls add_signature on the specified message' do
        expect(message).to receive(:add_signature)
        described_class.sign_xml message
      end

      it 'creates a new signed document' do
        expect(Xmldsig::SignedDocument).to receive(:new).with(any_args).and_return double.as_null_object
        described_class.sign_xml message
      end

      describe '"format" parameter' do
        context 'when no format is given' do
          it 'formats the message as xml by default' do
            expect(message).to receive(:to_xml).and_call_original
            described_class.sign_xml message
          end
        end

        context 'when a format is given' do
          it 'formats the message as the given format' do
            expect(message).to receive(:to_soap).and_call_original
            described_class.sign_xml message, :soap
          end
        end
      end

      describe '"include_nested_prefixlist" parameter' do
        let(:artifact_response_xml) { File.read(File.join('spec', 'fixtures', 'unsigned_artifact_response_with_signed_response_with_multiple_signatures.xml')) }
        let(:artifact_response)     { Saml::ArtifactResponse.parse(artifact_response_xml, single: true) }

        let(:artifact_response_prefixlist) { Nokogiri::XML::Document.parse(subject).xpath('samlp:ArtifactResponse/ds:Signature//ec:InclusiveNamespaces').attr('PrefixList').value }

        context 'when enabled by config' do
          before { Saml::Config.include_nested_prefixlist = true }
          after { Saml::Config.include_nested_prefixlist = false }

          subject { described_class.sign_xml artifact_response, :xml, false }

          it 'adds the nested and the default prefixlists to the unsigned signatures' do
            expect(artifact_response_prefixlist).to eq 'foo bar baz ds saml samlp xs'
          end
        end

        context 'when enabled by parameter' do
          subject { described_class.sign_xml artifact_response, :xml, true }

          it 'adds the nested and the default prefixlists to the unsigned signatures' do
            expect(artifact_response_prefixlist).to eq 'foo bar baz ds saml samlp xs'
          end
        end

        context 'when disabled' do
          subject { described_class.sign_xml artifact_response, :xml, false }

          it 'adds the default prefixlists to the unsigned signatures' do
            expect(artifact_response_prefixlist).to eq 'ds saml samlp xs'
          end
        end
      end

      context 'when a block is given' do
        it 'sign is called on the signed document, not on the provider' do
          expect(message.provider).not_to receive(:sign)
          expect_any_instance_of(Xmldsig::SignedDocument).to receive(:sign).and_return signed_message

          described_class.sign_xml(message) do |data, signature_algorithm|
            service_provider.sign signature_algorithm, data
          end
        end
      end

      context 'without specifiying a block' do
        it 'sign is called on the provider of the specified message' do
          expect_any_instance_of(Xmldsig::SignedDocument).to receive(:sign).and_yield(double, double)
          expect(message.provider).to receive(:sign).and_return signed_message

          described_class.sign_xml message
        end
      end
    end
  end

  describe 'assertion' do
    let(:assertion) { FactoryBot.build :assertion, issuer: service_provider.entity_id }
    let(:signed_assertion) { 'signed xml' }

    describe '.sign_xml' do
      it 'calls add_signature on the specified assertion' do
        expect(assertion).to receive(:add_signature)
        described_class.sign_xml assertion
      end

      it 'creates a new signed document' do
        expect(Xmldsig::SignedDocument).to receive(:new).with(any_args).and_return double.as_null_object
        described_class.sign_xml assertion
      end

      context 'when a block is given' do
        it 'sign is called on the signed document, not on the provider' do
          expect(assertion.provider).not_to receive(:sign)
          expect_any_instance_of(Xmldsig::SignedDocument).to receive(:sign).and_return signed_assertion

          described_class.sign_xml(assertion) do |data, signature_algorithm|
            service_provider.sign signature_algorithm, data
          end
        end
      end

      context 'without specifiying a block' do
        it 'sign is called on the provider of the specified assertion' do
          expect_any_instance_of(Xmldsig::SignedDocument).to receive(:sign).and_yield(double, double)
          expect(assertion.provider).to receive(:sign).and_return signed_assertion

          described_class.sign_xml assertion
        end
      end
    end
  end

  describe '.post' do
    let(:location) { 'http://example.com/foo/bar' }
    let(:post_request) { described_class.post location, message }
    let(:net_http) { double.as_null_object }

    before :each do
      allow_any_instance_of(Net::HTTP).to receive(:request) do |request|
        @request = request
        double(:response, code: '200', body: message.to_xml)
      end
    end

    it 'posts the request' do
      expect_any_instance_of(Net::HTTP).to receive(:request)
      post_request
    end

    it 'knows its path' do
      post_request
      expect(@request.path).to eq('/foo/bar')
    end

    it 'has a body' do
      post_request
      expect(@request.body).to eq(message)
    end

    it "has default headers" do
      default_headers = { 'Content-Type' => 'text/xml', 'Cache-Control' => 'no-cache, no-store', 'Pragma' => 'no-cache' }

      expect(Net::HTTP::Post).to receive(:new).with('/foo/bar', default_headers).and_return(net_http)
      post_request
    end

    it "can have additional headers" do
      default_headers = { 'Content-Type' => 'text/xml', 'Cache-Control' => 'no-cache, no-store', 'Pragma' => 'no-cache' }
      additional_headers = { "header" => "foo" }

      expect(Net::HTTP::Post).to receive(:new).with("/foo/bar", default_headers.merge(additional_headers)).and_return(net_http)
      described_class.post location, message, additional_headers
    end

    it "can use a proxy" do
      proxy = { addr: '127.0.0.1', port: 8888, user: 'someuser', pass: 'somepass' }

      expect(Net::HTTP).to receive(:new).with("example.com", 80, proxy[:addr], proxy[:port], proxy[:user], proxy[:pass]).and_return(net_http)
      described_class.post location, message, {}, proxy
    end

    context 'default settings' do
      before do
        allow(Net::HTTP).to receive(:new).and_return(net_http)
      end

      it 'does not use SSL if sheme is http' do
        expect(net_http).to receive(:use_ssl=).with(false)

        location = 'http://example.com/foo/bar'
        described_class.post location, message
      end

      it 'uses SSL if scheme is https' do
        expect(net_http).to receive(:use_ssl=).with(true)

        location = 'https://example.com/foo/bar'
        described_class.post location, message
      end

      it "sets the verify mode to 'VERIFY_PEER'" do
        expect(net_http).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
        post_request
      end

      it "doesn't use the certificate" do
        expect(net_http).not_to receive(:cert=)
        post_request
      end

      it "doesn't use the private key" do
        expect(net_http).not_to receive(:key=)
        post_request
      end

      it "doesn't use proxy settings" do
        expect(Net::HTTP).to receive(:new).with('example.com', 80, :ENV, nil, nil, nil)
        post_request
      end
    end

    context 'with certificate and private key' do
      let(:certificate_file) { File.join('spec', 'fixtures', 'certificate.pem') }
      let(:key_file) { File.join('spec', 'fixtures', 'key.pem') }

      before :each do
        allow(OpenSSL::X509::Certificate).to receive(:new).and_return('cert')
        allow(OpenSSL::PKey::RSA).to receive(:new).and_return('key')

        Saml::Config.ssl_certificate_file = certificate_file
        Saml::Config.ssl_private_key_file = key_file

        allow(Net::HTTP).to receive(:new).and_return(net_http)
      end

      after :each do
        Saml::Config.ssl_certificate_file = nil
        Saml::Config.ssl_private_key_file = nil
      end

      it 'sets the certificate' do
        expect(net_http).to receive(:cert=).with('cert')
        post_request
      end

      it 'sets the private key' do
        expect(net_http).to receive(:key=).with('key')
        post_request
      end
    end

    context 'with http_ca_file' do
      let(:http_ca_file) { File.join('spec', 'fixtures', 'certificate.pem') }

      before :each do
        Saml::Config.http_ca_file = http_ca_file

        allow(Net::HTTP).to receive(:new).and_return(net_http)
      end

      after :each do
        Saml::Config.http_ca_file = nil
      end

      it 'sets the ca_file' do
        expect(net_http.cert_store).to receive(:add_file).with(http_ca_file)
        post_request
      end
    end
  end

  describe '.verify_xml' do
    describe 'response' do
      let(:message) { Saml::Response.new(assertions: [Saml::Assertion.new.tap { |a| a.add_signature },
                                                      Saml::Assertion.new.tap { |a| a.add_signature }]) }
      let(:signed_xml) { Saml::Util.sign_xml(message) }

      it 'verifies all the signatures in the file' do
        response = Saml::Response.parse(signed_xml)

        expect(response.provider).to receive(:verify).exactly(3).times.and_return(true)
        Saml::Util.verify_xml(response, signed_xml)
      end

      it 'verifies all the signatures in the file with its corresponding key name' do
        xml = File.read(File.join('spec', 'fixtures', 'artifact_response_with_authn_request_signed_with_multiple_certificates.xml'))
        response = Saml::ArtifactResponse.parse(xml, single: true)

        aggregate_failures do
          expect(response.issuer).to eq 'https://sp.example.com'
          expect(response.signature.key_name).to eq '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8'
          expect(response.authn_request.issuer).to eq 'https://sp.example.com'
          expect(response.authn_request.signature.key_name).to eq '64df07ee8485e04608afd614829f932da3ac6a7c'
        end

        expect(Saml::Util.verify_xml(response, xml)).to be_a(Saml::ArtifactResponse)
      end

      it 'returns the signed message type' do
        malicious_response = Saml::Response.new(issuer: 'hacked')
        malicious_xml      = "<hack>#{signed_xml}#{malicious_response.to_xml}</hack>"
        malicious_xml.gsub!("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", '')
        response = Saml::Response.parse(malicious_xml, single: true)

        expect(Saml::Util.verify_xml(response, malicious_xml)).to be_a(Saml::Response)
      end
    end

    describe 'assertion' do
      let(:message) { Saml::Assertion.new }
      let(:signed_xml) { Saml::Util.sign_xml(message) }

      it 'verifies all the signatures in the file' do
        assertion = Saml::Assertion.parse(signed_xml)

        expect(assertion.provider).to receive(:verify).exactly(1).times.and_return(true)
        Saml::Util.verify_xml(assertion, signed_xml)
      end

      it 'returns the signed message type' do
        malicious_assertion = Saml::Assertion.new(issuer: 'hacked')
        malicious_xml       = "<hack>#{signed_xml}#{malicious_assertion.to_xml}</hack>"
        malicious_xml.gsub!("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n", '')
        assertion = Saml::Assertion.parse(malicious_xml, single: true)

        expect(Saml::Util.verify_xml(assertion, malicious_xml)).to be_a(Saml::Assertion)
      end
    end

    describe 'authn request within an artifact response' do
      let(:artifact_response) { Saml::ArtifactResponse.new authn_request: Saml::AuthnRequest.new.tap(&:add_signature) }
      let(:signed_xml) { Saml::Util.sign_xml(artifact_response) }

      let(:authn_request) { Saml::AuthnRequest.parse signed_xml, single: true }

      it 'parses the authn request from the signed XML without an undefined samlp prefix error' do
        expect(Saml::Util.verify_xml(authn_request, signed_xml)).to be_a(Saml::AuthnRequest)
      end
    end
  end

  describe '.encrypt_assertion' do
    context 'with a certificate as param' do
      let(:encrypted_assertion) { Saml::Util.encrypt_assertion(Saml::Assertion.new, service_provider.certificate) }

      it 'adds no key_info to the encrypted assertion' do
        expect(encrypted_assertion.encrypted_keys.key_info).to be_nil
      end

      it 'returns an encrypted assertion object' do
        expect(encrypted_assertion).to be_a Saml::Elements::EncryptedAssertion
      end

      it 'is not valid when with no encrypted data' do
        encrypted_assertion.encrypted_data = nil
        expect(encrypted_assertion).to be_invalid
      end

      context 'with include_certificate option' do
        let(:encrypted_assertion) do
          Saml::Util.encrypt_assertion(Saml::Assertion.new, service_provider.certificate, include_certificate: true)
        end

        it 'adds a key_info w/ x509Data w/o key_name to the encrypted assertion' do
          expect(encrypted_assertion.encrypted_keys.key_info.key_name).to be_nil
          expect(encrypted_assertion.encrypted_keys.key_info.x509Data.x509certificate.to_pem).to eq service_provider.certificate.to_pem
        end
      end
    end

    context 'with a key descriptor as param' do
      let(:key_name) { '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8' }
      let(:key_descriptor) { service_provider.find_key_descriptor(key_name) }
      let(:encrypted_assertion) { Saml::Util.encrypt_assertion(Saml::Assertion.new, key_descriptor) }

      it 'adds a key_info w/o x509Data w/ key_name to the encrypted assertion' do
        expect(encrypted_assertion.encrypted_keys.key_info.key_name).to eq key_name
        expect(encrypted_assertion.encrypted_keys.key_info.x509Data).to be_nil
      end

      context 'with include_certificate option' do
        let(:encrypted_assertion) do
          Saml::Util.encrypt_assertion(Saml::Assertion.new, key_descriptor, include_certificate: true)
        end

        it 'adds a key_info w/ x509Data w/ key_name to the encrypted assertion' do
          expect(encrypted_assertion.encrypted_keys.key_info.key_name).to eq key_name
          expect(encrypted_assertion.encrypted_keys.key_info.x509Data.x509certificate.to_pem).to eq service_provider.certificate.to_pem
        end
      end
    end

    context 'with a wrong param' do
      let(:encrypted_assertion) { Saml::Util.encrypt_assertion(Saml::Assertion.new, 'foobar') }

      it 'raises an argument error' do
        expect { encrypted_assertion }.to raise_error(ArgumentError)
      end
    end
  end

  describe '.decrypt_assertion' do
    let(:encrypted_assertion) { Saml::Util.encrypt_assertion(Saml::Assertion.new, service_provider.certificate) }

    it 'it returns decrypted assertion xml' do
      assertion = Saml::Util.decrypt_assertion(encrypted_assertion, service_provider.encryption_key)
      expect(assertion).to be_a Saml::Assertion
    end
  end

  describe '.encrypt_name_id' do
    let(:name_id) { Saml::Elements::NameId.new(value: 'NAAM') }
    let(:key_name) { '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8' }
    let(:key_descriptor) { service_provider.entity_descriptor.sp_sso_descriptor.find_key_descriptor(key_name, 'encryption') }
    let(:encrypted_id) { Saml::Util.encrypt_name_id(name_id, key_descriptor) }

    it 'creates an EncryptedID' do
      expect(encrypted_id).to be_a Saml::Elements::EncryptedID
    end

    it 'can decrypt back' do
      expect(Saml::Util.decrypt_encrypted_id(encrypted_id, service_provider.encryption_key).name_id).to be_a Saml::Elements::NameId
    end
  end

  describe '.encrypt_encrypted_id' do
    let(:name_id) { Saml::Elements::NameId.new(value: 'NAAM') }
    let(:key_name) { '22cd8e9f32a7262d2f49f5ccc518ccfbf8441bb8' }
    let(:key_descriptor) { service_provider.entity_descriptor.sp_sso_descriptor.find_key_descriptor(key_name, 'encryption') }
    let(:encrypted_id) { Saml::Elements::EncryptedID.new(name_id: name_id) }

    before { described_class.encrypt_encrypted_id(encrypted_id, key_descriptor) }

    it 'returns an EncryptedID' do
      expect(encrypted_id).to be_a Saml::Elements::EncryptedID
    end

    it 'builds the encrypted_data' do
      expect(encrypted_id.encrypted_data).to be_a Xmlenc::Builder::EncryptedData
    end

    it 'name_id is removed' do
      expect(encrypted_id.name_id).to eq nil
    end

    it 'can decrypt back' do
      expect(Saml::Util.decrypt_encrypted_id(encrypted_id, service_provider.encryption_key).name_id).to be_a Saml::Elements::NameId
    end
  end

  describe '.decrypt_encrypted_id' do
    let(:encrypted_id_xml) { File.read('spec/fixtures/encrypted_name_id.xml') }
    let(:parsed_encrypted_id) { Saml::Elements::EncryptedID.parse(encrypted_id_xml) }

    let(:decrypted) { Saml::Util.decrypt_encrypted_id(encrypted_id_xml, service_provider.encryption_key) }

    it 'contains a NameId' do
      expect(decrypted.name_id).to be_a Saml::Elements::NameId
    end

    it 'does not contain #encrypted_data' do
      expect(decrypted.encrypted_data).to eq nil
    end

    it 'passes the "fail_silent" option to EncryptedDocument decryption' do
      expect_any_instance_of(Xmlenc::EncryptedDocument).to receive(:decrypt).with(service_provider.encryption_key, true).and_call_original
      Saml::Util.decrypt_encrypted_id(encrypted_id_xml, service_provider.encryption_key, true)
    end
  end

  describe '.download_metadata_xml' do
    let(:location) { 'http://example.com/foo/bar' }
    let(:download_metadata) { described_class.download_metadata_xml location }
    let(:response) { double(:response, code: '200', body: 'metadata') }
    let(:net_http) { double('Net::HTTP', request: response).as_null_object }

    before :each do
      allow_any_instance_of(Net::HTTP).to receive(:request) do |request|
        @request = request
        response
      end
    end

    it 'downloads the metadata' do
      expect(download_metadata).to eq('metadata')
    end

    context 'when metadata cannot be found' do
      let(:response) { double(:response, code: '404', body: 'not_found') }

      it 'raises an error' do
        expect {
          download_metadata
        }.to raise_error(Saml::Errors::MetadataDownloadFailed)
      end
    end

    context 'when an http error occurs' do
      let(:response) { raise Timeout::Error.new }

      it 'raises an error' do
        expect {
          download_metadata
        }.to raise_error(Saml::Errors::MetadataDownloadFailed)
      end
    end

    context 'default settings' do
      before do
        allow(Net::HTTP).to receive(:new).and_return(net_http)
      end

      it 'does not use SSL if sheme is http' do
        expect(net_http).to receive(:use_ssl=).with(false)

        location = 'http://example.com/foo/bar'
        described_class.download_metadata_xml location
      end

      it 'uses SSL if scheme is https' do
        expect(net_http).to receive(:use_ssl=).with(true)

        location = 'https://example.com/foo/bar'
        described_class.download_metadata_xml location
      end

      it "sets the verify mode to 'VERIFY_PEER'" do
        expect(net_http).to receive(:verify_mode=).with(OpenSSL::SSL::VERIFY_PEER)
        download_metadata
      end
    end

    context 'with http_ca_file' do
      let(:http_ca_file) { File.join('spec', 'fixtures', 'certificate.pem') }

      before :each do
        Saml::Config.http_ca_file = http_ca_file

        allow(Net::HTTP).to receive(:new).and_return(net_http)
      end

      after :each do
        Saml::Config.http_ca_file = nil
      end

      it 'sets the ca_file' do
        expect(net_http.cert_store).to receive(:add_file).with(http_ca_file)
        location = 'https://example.com/foo/bar'
        described_class.download_metadata_xml location
      end
    end
  end
end
