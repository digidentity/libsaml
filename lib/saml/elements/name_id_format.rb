module Saml
  module Elements
    class NameIdFormat
      include Saml::Base

      tag 'NameIDFormat'
      register_namespace 'md', Saml::MD_NAMESPACE
      namespace 'md'

      content :value, String
    end
  end
end

