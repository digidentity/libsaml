module Saml
  module Elements
    class AttributeValue
      include Saml::Base

      register_namespace 'saml', Saml::SAML_NAMESPACE
      register_namespace 'xs',   Saml::XS_NAMESPACE
      register_namespace 'xsi',  Saml::XSI_NAMESPACE

      namespace 'saml'
      tag 'AttributeValue'

      attribute :type, String, tag: 'xsi:type'

      content :content, String
    end
  end
end
