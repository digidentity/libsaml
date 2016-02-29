module Saml
  module Elements
    class EncryptedID
      include ::XmlMapper
      include ::Saml::Base
      include ::Saml::XMLHelpers

      tag 'EncryptedID'

      attr_accessor :xml_node

      register_namespace 'saml', ::Saml::SAML_NAMESPACE
      namespace 'saml'

      has_one :encrypted_data, Xmlenc::Builder::EncryptedData
      has_many :encrypted_keys, Xmlenc::Builder::EncryptedKey, xpath: './'
      has_one :name_id, Saml::Elements::NameId

      validates :encrypted_data, presence: true

      def initialize(*args)
        options = args.extract_options!
        super(*(args << options))
      end

      def encrypt(key_descriptor, key_options = {})
        certificate = key_descriptor.certificate
        key_name = key_descriptor.key_info.key_name

        self.encrypted_data = Xmlenc::Builder::EncryptedData.new
        self.encrypted_data.set_key_retrieval_method Xmlenc::Builder::RetrievalMethod.new(
          uri: "##{key_options[:id]}"
        )
        self.encrypted_data.set_encryption_method(
          algorithm: 'http://www.w3.org/2001/04/xmlenc#aes256-cbc'
        )
        encrypted_key = self.encrypted_data.encrypt(name_id_xml, key_options)
        encrypted_key.set_encryption_method(
          algorithm: 'http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p',
          digest_method_algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1'
        )
        encrypted_key.set_key_name key_name
        encrypted_key.encrypt certificate.public_key
        self.encrypted_keys = [encrypted_key]
        self.name_id = nil
      end

      private

      def name_id_xml
        Nokogiri::XML(name_id.to_xml).root.to_xml
      end
    end
  end
end
