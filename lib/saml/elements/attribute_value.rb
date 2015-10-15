module Saml
  module Elements
    class AttributeValue
      include Saml::Base

      register_namespace 'saml', Saml::SAML_NAMESPACE
      register_namespace 'xs',  'http://www.w3.org/2001/XMLSchema'
      register_namespace 'xsi', 'http://www.w3.org/2001/XMLSchema-instance'

      namespace 'saml'
      tag 'AttributeValue'

      attribute :type, String, tag: 'xsi:type'

      content :content, String
    end
  end
end
