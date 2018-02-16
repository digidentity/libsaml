module Saml
  module Elements
    class AttributeValue
      include ::Saml::Base

      tag 'AttributeValue'

      register_namespace 'saml', Saml::SAML_NAMESPACE
      register_namespace 'xs',   Saml::XS_NAMESPACE
      register_namespace 'xsi',  Saml::XSI_NAMESPACE

      namespace 'saml'

      has_one :encrypted_id, EncryptedID

      attribute :type, String, tag: 'xsi:type'

      content :content, String
      has_one :name_id, Saml::Elements::NameId
    end
  end
end
