module Saml
  module Elements
    class AttributeStatement
      include Saml::Base

      tag "AttributeStatement"
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      has_many :attribute, Saml::Elements::Attribute
      has_many :encrypted_attributes, Saml::Elements::EncryptedAttribute

      def fetch_attribute(key)
        attribute = self.attribute.find do |attr|
          attr.name == key
        end
        attribute.attribute_value if attribute
      end
    end
  end
end
