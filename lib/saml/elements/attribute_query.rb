module Saml
  module Elements
    class AttributeQuery
      include XmlMapper
      include Saml::Base
      include Saml::ComplexTypes::AttributeQueryType

      tag 'AttributeQuery'
      namespace 'samlp'
    end
  end
end
