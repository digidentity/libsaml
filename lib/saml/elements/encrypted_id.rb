module Saml
  module Elements
    class EncryptedID
      include ::HappyMapper
      include ::Saml::Base
      include ::Saml::XMLHelpers

      tag 'EncryptedID'

      register_namespace 'saml', ::Saml::SAML_NAMESPACE
      namespace 'saml'

      has_one :encrypted_data, Xmlenc::Builder::EncryptedData
      has_many :encrypted_keys, Xmlenc::Builder::EncryptedKey

      validates :encrypted_data, presence: true
    end
  end
end
