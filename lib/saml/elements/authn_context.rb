module Saml
  module Elements
    class AuthnContext
      include Saml::Base

      tag "AuthnContext"
      namespace 'saml'
      element :authn_context_class_ref, String, :tag => "AuthnContextClassRef"

      has_many :authenticating_authorities, ::Saml::Elements::AuthenticatingAuthority

      validates :authn_context_class_ref, :inclusion => ClassRefs::ALL_CLASS_REFS + [nil]
    end
  end
end
