module Saml
  module Elements
    class SessionIndex
      include Saml::Base

      tag 'SessionIndex'
      register_namespace 'samlp', Saml::SAMLP_NAMESPACE
      namespace 'samlp'

      content :value, String
    end
  end
end
