module Saml
  module Elements
    class AuthenticatingAuthority
      include Saml::Base

      tag "AuthenticatingAuthority"

      register_namespace "saml", ::Saml::SAML_NAMESPACE
      namespace "saml"
    end
  end
end
