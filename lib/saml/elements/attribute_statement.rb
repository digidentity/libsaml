module Saml
  module Elements
    class AttributeStatement
      include Saml::Base

      tag 'AttributeStatement'
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      has_many :attribute, Saml::Elements::Attribute
      has_many :encrypted_attributes, Saml::Elements::EncryptedAttribute

      def fetch_attribute(key)
        fetch_attributes(key).first
      end

      def fetch_attributes(key)
        attribute.find_all { |attr| attr.name == key }.flat_map(&:attribute_values).map(&:content)
      end
    end
  end
end
