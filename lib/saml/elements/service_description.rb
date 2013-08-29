module Saml
  module Elements
    class ServiceDescription
      include Saml::Base

      tag "ServiceDescription"
      register_namespace "md", Saml::MD_NAMESPACE
      namespace "md"

      content :value, String
    end
  end
end
