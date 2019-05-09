module Saml
  module Elements
    class Signature
      class Reference
        include Saml::Base

        tag "Reference"
        register_namespace 'ds', Saml::XML_DSIG_NAMESPACE
        namespace 'ds'

        attribute :uri, String, tag: "URI"
        element :transforms, Transforms
        element :digest_method, DigestMethod
        element :digest_value, String, tag: "DigestValue", namespace: 'ds', state_when_nil: true

        def initialize(*args)
          @transforms    = Transforms.new
          @digest_method = DigestMethod.new
          super(*args)
        end
      end
    end
  end
end
