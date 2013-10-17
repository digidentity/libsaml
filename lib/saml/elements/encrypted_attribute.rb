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
    end
  end
end
