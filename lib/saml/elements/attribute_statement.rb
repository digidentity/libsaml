module Saml
  module Elements
    class AttributeStatement
      include Saml::Base

      tag 'AttributeStatement'
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      has_many :attributes, Saml::Elements::Attribute
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
        attributes.find_all { |attr| attr.name == key }.flat_map(&:attribute_values)
      end

      def attribute
        warn '[DEPRECATED] please use #attributes'
        attributes
      end

      def attribute=(attributes)
        warn '[DEPRECATED] please use #attributes='
        self.attributes = attributes
      end
    end
  end
end
