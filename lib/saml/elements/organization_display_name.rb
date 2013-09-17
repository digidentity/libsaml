module Saml
  module Elements
    class OrganizationDisplayName
      include Saml::ComplexTypes::LocalizedNameType
      include Saml::Base

      tag 'OrganizationDisplayName'
      namespace 'md'

      content :value, String
    end
  end
end
