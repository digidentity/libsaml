module Saml
  module Elements
    class Signature
      class Reference
        include Saml::Base

        tag "Reference"
        namespace 'ds'

        attribute :uri, String, :tag => "URI"
        element :transforms, Transforms
        element :digest_method, DigestMethod
        element :digest_value, String, :tag => "DigestValue", :state_when_nil => true

        def initialize(*args)
          @transforms    = Transforms.new
          @digest_method = DigestMethod.new
          super(*args)
        end
      end
    end
  end
end
