require 'spec_helper'

describe Saml::Config do

  let(:private_key_file) { File.join('spec', 'fixtures', 'key.pem') }
  let(:private_key)      { OpenSSL::PKey::RSA.new(File.read(private_key_file)) }

  let(:certificate_file) { File.join('spec', 'fixtures', 'certificate.pem') }
  let(:certificate)      { OpenSSL::X509::Certificate.new(File.read(certificate_file)) }

  after do
    Saml::Config.ssl_private_key = nil
    Saml::Config.ssl_certificate = nil
  end

  describe '#ssl_private_key_file' do
    it 'initializes an OpenSSL::PKey::RSA' do
      expect(OpenSSL::PKey::RSA).to receive(:new).with File.read(private_key_file)
      Saml::Config.ssl_private_key_file = private_key_file
    end

    it 'sets #ssl_private_key' do
      allow(OpenSSL::PKey::RSA).to receive(:new).and_return 'key'
      Saml::Config.ssl_private_key_file = private_key_file
      expect(Saml::Config.ssl_private_key).to eq 'key'
    end
  end

  describe '#ssl_private_key' do
    it 'sets #ssl_private_key' do
      Saml::Config.ssl_private_key = private_key
      expect(Saml::Config.ssl_private_key).to eq private_key
    end
  end

  describe '#ssl_certificate_file' do
    it 'initializes an OpenSSL::X509::Certificate' do
      expect(OpenSSL::X509::Certificate).to receive(:new).with File.read(certificate_file)
      Saml::Config.ssl_certificate_file = certificate_file
    end

    it 'sets #ssl_certificate' do
      allow(OpenSSL::X509::Certificate).to receive(:new).and_return 'cert'
      Saml::Config.ssl_certificate_file = certificate_file
      expect(Saml::Config.ssl_certificate).to eq 'cert'
    end
  end

  describe '#ssl_certificate' do
    it 'sets #ssl_certificate' do
      Saml::Config.ssl_certificate = certificate
      expect(Saml::Config.ssl_certificate).to eq certificate
    end
  end

  describe '#include_nested_prefixlist' do
    it 'is disabled by default' do
      expect(Saml::Config.include_nested_prefixlist).to eq false
    end
  end
end
