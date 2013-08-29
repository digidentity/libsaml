module Saml
  module Elements
    class Attribute
      include Saml::ComplexTypes::AttributeType
      include Saml::Base

      tag "Attribute"
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'
    end
  end
end
