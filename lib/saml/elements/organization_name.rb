module Saml
  module Elements
    class OrganizationName
      include Saml::ComplexTypes::LocalizedNameType
      include Saml::Base

      tag 'OrganizationName'
      namespace 'md'

      content :value, String
    end
  end
end
