module Saml
  module Elements
    class RequestedAttribute
      include Saml::ComplexTypes::AttributeType
      include Saml::Base

      tag "RequestedAttribute"
      register_namespace "md", Saml::MD_NAMESPACE
      namespace "md"

      attribute :is_required, HappyMapper::Boolean, :tag => "isRequired"
    end
  end
end
