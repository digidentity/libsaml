module Saml
  module Elements
    class AuthenticatingAuthority
      include Saml::Base

      tag "AuthenticatingAuthority"

      register_namespace "saml", ::Saml::SAML_NAMESPACE
      namespace "saml"

      content :value, String
    end
  end
end
