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
        fetch_attribute_value(key).content
      end

      def fetch_attributes(key)
        fetch_attribute_values(key).map(&:content)
      end

      def fetch_attribute_value(key)
        fetch_attribute_values(key).first
      end

      def fetch_attribute_values(key)
        attribute.find_all { |attr| attr.name == key }.flat_map(&:attribute_values)
      end
    end
  end
end
