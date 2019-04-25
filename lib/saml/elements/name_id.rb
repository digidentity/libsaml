module Saml
  module Elements
    class NameId
      include Saml::Base

      tag 'NameID'
      register_namespace 'saml', Saml::SAML_NAMESPACE
      namespace 'saml'

      attribute :format, String, tag: "Format"
      attribute :name_qualifier, String, tag: "NameQualifier"
      attribute :sp_name_qualifier, String, tag: "SPNameQualifier"

      content :value, String
    end
  end
end
