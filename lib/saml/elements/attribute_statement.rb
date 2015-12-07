module Saml
  module Elements
    class AttributeStatement
      include Saml::Base
      include Saml::AttributeFetcher

      tag 'AttributeStatement'
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      has_many :attributes, Saml::Elements::Attribute
      has_many :encrypted_attributes, Saml::Elements::EncryptedAttribute

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
