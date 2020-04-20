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
        Saml::Util.encrypt_element(self, attribute, encrypted_key_data, encrypted_data_options)
      end

    end
  end
end
