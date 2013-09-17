module Saml
  module Elements
    class OrganizationUrl
      include Saml::ComplexTypes::LocalizedNameType
      include Saml::Base

      tag 'OrganizationURL'
      namespace 'md'

      content :value, String
    end
  end
end
