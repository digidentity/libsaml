module Saml
  module Elements
    class EncryptedAttribute
      include Saml::Base

      tag "EncryptedAttribute"

      register_namespace "saml", Saml::SAML_NAMESPACE
      namespace "saml"

      element :encrypted_data, Xmlenc::Builder::EncryptedData

      has_many :encrypted_keys, Xmlenc::Builder::EncryptedKey, xpath: "./"

      validates :encrypted_data, presence: true

      def encrypt(attribute, encrypted_key_data, encrypted_data_options = {})
        self.encrypted_data = Xmlenc::Builder::EncryptedData.new(encrypted_data_options)
        self.encrypted_data.set_encryption_method algorithm: 'http://www.w3.org/2001/04/xmlenc#aes256-cbc'
        self.encrypted_data.set_key_name key_name

        encrypted_key_data.each do |key_descriptor, key_options|
          encrypted_key = self.encrypted_data.encrypt Nokogiri::XML(attribute.to_xml).root.to_xml, key_options
          encrypted_key.set_encryption_method algorithm: 'http://www.w3.org/2001/04/xmlenc#rsa-oaep-mgf1p', digest_method_algorithm: 'http://www.w3.org/2000/09/xmldsig#sha1'
          encrypted_key.set_key_name key_descriptor.key_info.key_name
          encrypted_key.carried_key_name = key_name
          encrypted_key.encrypt key_descriptor.certificate.public_key

          self.encrypted_keys ||= []
          self.encrypted_keys << encrypted_key
        end
      end

      private

      def key_name
        @key_name ||= Saml.generate_id
      end
    end
  end
end
