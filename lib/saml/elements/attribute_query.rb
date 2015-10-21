module Saml
  module Elements
    class AttributeQuery
      include HappyMapper
      include Saml::Base
      include Saml::ComplexTypes::AttributeQueryType

      tag 'AttributeQuery'
      namespace 'samlp'
    end
  end
end
