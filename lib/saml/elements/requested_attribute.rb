module Saml
  module Elements
    class RequestedAttribute
      include Saml::ComplexTypes::AttributeType
      include Saml::Base

      attribute :is_required, HappyMapper::Boolean, :tag => "isRequired"
    end
  end
end
